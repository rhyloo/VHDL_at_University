----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.11.2019 19:10:32
-- Design Name: 
-- Module Name: FSM_PLC - Estructura
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.Tipos_FSM_PLC.all;

entity FSM_PLC is
    generic( k    : natural := 32;    -- k entradas.
             p    : natural := 32;    -- p salidas.
             m    : natural := 32;    -- m biestables. (Hasta 16 estados)
             T_DM : time    := 10 ps; -- Tiempo de retardo desde el cambio de direcci�n del MUX hasta la actualizaci�n de la salida Q.
             T_D  : time    := 10 ps; -- Tiempo de retardo desde el flanco activo del reloj hasta la actualizaci�n de la salida Q.
             T_SU : time    := 10 ps; -- Tiempo de Setup.
             T_H  : time    := 10 ps; -- Tiempo de Hold.
             T_W  : time    := 10 ps); -- Anchura de pulso.
     port   (   x : in  STD_LOGIC_VECTOR( k - 1 downto 0 );     -- x es el bus de entrada.
                y : out STD_LOGIC_VECTOR( p - 1 downto 0 );     -- y es el bus de salida.
              Tabla_De_Estado : in Tabla_FSM( 0 to 2**m - 1 );  -- Contiene la Tabla de Estado estilo Moore: Z(n+1)=T1(Z(n),x(n))
              Tabla_De_Salida : in Tabla_FSM( 0 to 2**m - 1 );  -- Contiene la Tabla de Salida estilo Moore: Y(n  )=T2(Z(n))
              clk     : in STD_LOGIC;   -- La se�al de reloj.
              cke     : in STD_LOGIC;   -- La se�al de habilitaci�n de avance: si vale '1' el aut�mata avanza a ritmo de clk y si vale '0' manda Trigger.              
              reset   : in STD_LOGIC;   -- La se�al de inicializaci�n.
              Trigger : in STD_LOGIC ); -- La se�al de disparo (single shot) as�ncrono y pos�blemente con rebotes para hacer un avance �nico. Ha de llevar un sincronizador.
end FSM_PLC;

architecture Estructura of FSM_PLC is

component MUX_PLC is    -- Implementa las ecuaciones de transici�n y salida estilos Moore � Mealy.
    generic( N_Bits_Dir : Natural := 3; 
             T_D        : time    := 10 ps ); -- Tiempo de retardo desde el cambio de direcci�n hasta la actualizaci�n de la salida Q.
    Port   ( Direccion  : in  STD_LOGIC_VECTOR ( N_Bits_Dir  - 1 downto 0 );
             Dato       : out STD_LOGIC_VECTOR ( N_Bits_Dato - 1 downto 0 );
             Tabla_ROM  : in  Tabla_FSM( 0 to 2**N_Bits_Dir - 1 ) );
end component MUX_PLC;

component Reg_PLC is    -- Registro de estado del aut�mata estilos Moore � Mealy.
   generic( N_Bits_Reg : integer := 8;
            T_D        : time := 10 ps ); -- Tiempo de retardo desde el flanco activo del reloj hasta la actualizaci�n de la salida Q.
   Port   ( D          :  in STD_LOGIC_VECTOR( N_Bits_Reg - 1 downto 0 );
            Q          : out STD_LOGIC_VECTOR( N_Bits_Reg - 1 downto 0 );
            reset      :  in STD_LOGIC;
            cke        :  in STD_LOGIC;
            clk        :  in STD_LOGIC);
end component Reg_PLC;

component Sincronizador is -- Genera el CKE libre de rebotes y de duraci�n 1 ciclo de reloj clk.
    generic ( n     : natural := 4 );
    Port    ( I     : in STD_LOGIC;
              CKE   : out STD_LOGIC;
              reset : in STD_LOGIC;
              clk   : in STD_LOGIC);
end component Sincronizador;

signal Estado_Actual       : STD_LOGIC_VECTOR( m - 1 downto 0 );
signal Proximo_Estado      : STD_LOGIC_VECTOR( m - 1 downto 0 );
signal Estados_Con_Formato : Tabla_FSM( 0 to 2**k - 1 );
signal Salidas_Con_Formato : Tabla_FSM( 0 to 2**k - 1 ); -- S�lo sirve para Mealy.
signal Salida_Mux          : STD_LOGIC_VECTOR( N_Bits_Dato - 1 downto 0 ); -- Pr�ximo estado justificado a la derecha con ceros.
signal Salida              : STD_LOGIC_VECTOR( N_Bits_Dato - 1 downto 0 ); -- Salida justificada a la derecha con ceros.

signal Dato_Intermedio_1 : STD_LOGIC_VECTOR( N_Bits_Dato - 1 downto 0 );
signal Dato_Intermedio_2 : STD_LOGIC_VECTOR( N_Bits_Dato - 1 downto 0 ); -- S�lo sirve para Mealy.

signal Pos_Trigger  : STD_LOGIC; -- Trigger filtrado y sin rebotes, con la anchura de un ciclo de reloj.
signal Clock_Enable : STD_LOGIC; -- Se�al de trigger y cke procesada con una OR.

begin
--
-- Verificaciones b�sica de rangos y tiempos: �NO SON SINTETIZABLES!
--
Comprueba_2kxm : process
                begin
                    assert( 2**k * m <= N_Bits_Dato )    report " No cumple la restricci�n de tama�o!" severity failure;
                    wait;
                end process Comprueba_2kxm;

Comprueba_2kxp : process
                begin
                    assert( 2**k * p <= N_Bits_Dato )    report " No cumple la restricci�n de tama�o!" severity failure;
                    wait;
                end process Comprueba_2kxp;

Comprueba_TSUH: process -- Proceso Pasivo para la verificaci�n del Setup y Hold.
                begin
                    wait until rising_edge(clk);
                    assert (Proximo_Estado'Stable( T_SU ) ) report " No cumple el tiempo de Setup!" severity failure;
	                wait for T_H;
                    assert (Proximo_Estado'Stable( T_H  ) ) report " No cumple el tiempo de Hold!"  severity failure;
end process Comprueba_TSUH;

Comprueba_TW:   process -- Proceso Pasivo para la verificaci�n de la anchura de un pulso (Width).
                begin
                    wait until rising_edge(clk); --�IMPORANTE! ESTA L�NEA SUSTITUYE A LA SIGUIENTE PARA SINTESIS.(ES REALMENTE EQUIVALENTE)
--                    wait until Proximo_Estado'Event; -- D representa la se�al a medir (std_Logic_Vector).
                    assert (Proximo_Estado'Delayed'Stable( T_W ) ) report " No cumple la anchura de pulso!" severity Error;
                end process Comprueba_TW;

-- Procesos del FSM.                
Sincronizacion: Sincronizador
                generic map( 2 ) -- El sincronizador tiene 32 etapas en el filtro FIR (Finite Impulse Response).
                port    map( I     => Trigger,
                             CKE   => Pos_Trigger,
                             reset => reset,
                             clk   => clk );
                             
Generacion_CKE: Clock_Enable <= Pos_Trigger or cke;

Registro_PLC:   Reg_PLC -- Registro de estado del aut�mata.
                generic map( m, 10 ps )
                Port    map( D     => Proximo_Estado,
                             Q     => Estado_Actual,
                             reset => reset,
                             cke   => Clock_Enable,
                             clk   => clk);


--
-- Ecuaci�n de Transici�n de estado en los dos estilos: Mealy y Moore.
--
                                                                                                                         
-- ajusta a la derecha con ceros de relleno, m bits del Estado a N_Bits_Dato bits del dato del MUX.
Asignacion_MUX : process( Dato_Intermedio_1 )
    begin
        for i in 0 to 2**k - 1 loop
            Estados_Con_Formato( i ) <= std_logic_vector( resize( unsigned( Dato_Intermedio_1( m * ( i + 1 ) - 1 downto m * i ) ), N_Bits_Dato ) );
        end loop;
    end process Asignacion_MUX;
    
Ecuacion_De_Transicion_1: MUX_PLC generic map( m, T_DM ) -- Selecciona a partir del estado actual todos lo posibles pr�ximos estados.
                                  Port    map( Direccion => Estado_Actual,
                                               Dato      => Dato_Intermedio_1,
                                               Tabla_ROM => Tabla_De_Estado);
Ecuacion_De_Transicion_2: MUX_PLC generic map( k, T_DM ) -- Selecciona a partir de la entrada actual el pr�ximo estado.
                                  Port    map( Direccion => x,
                                               Dato      => Salida_Mux,
                                               Tabla_ROM => Estados_Con_Formato);
                                               
Asignacion_Proximo_Estado: Proximo_Estado <= Salida_MUX( m - 1 downto 0 );  -- ajusta de N_Bits_Dato bits del dato del MUX a m bits del estado.  
                                                                                         
--
-- Ecuaci�n de salida estilo Moore:
-- Descomentar en caso de Moore comentar en caso de Mealy:
                                                                                                                     
Ecuacion_De_Salida_Moore: MUX_PLC generic map( m, T_DM ) -- Selecciona a partir del estado actual la salida.
                                  Port    map( Direccion => Estado_Actual,
                                               Dato      => Salida,
                                               Tabla_ROM => Tabla_De_Salida);    
Salida_De_Moore: y <= Salida( p - 1 downto 0 );

--Fin de Descomentar en caso de Moore comentar en caso de Mealy
--
                       
--
-- Ecuaci�n de salida estilo Mealy:
-- Descomentar en caso de Mealy comentar en caso de Moore:
--

-- ajusta a la derecha con ceros de relleno, p bits de la salida a N_Bits_Dato bits del dato del MUX.
--Asignacion_MUX_Mealy : process( Dato_Intermedio_2 )
--    begin
--        for i in 0 to 2**k - 1 loop
--            Salidas_Con_Formato( i ) <= std_logic_vector( resize( unsigned( Dato_Intermedio_2( p * ( i + 1 ) - 1 downto p * i ) ), N_Bits_Dato ) );
--        end loop;
--    end process Asignacion_MUX_Mealy;
                                                                      
--Ecuacion_De_Salida_1_Mealy: MUX_PLC generic map( m, T_DM ) -- Selecciona a partir del estado actual todas las posibles salidas.
--                                  Port    map( Direccion => Estado_Actual,
--                                               Dato      => Dato_Intermedio_2,
--                                               Tabla_ROM => Tabla_De_Salida);
--Ecuacion_De_Salida_2_Mealy: MUX_PLC generic map( k, T_DM ) -- Selecciona a partir de la entrada actual la salida.
--                                  Port    map( Direccion => x,
--                                               Dato      => Salida,
--                                               Tabla_ROM => Salidas_Con_Formato);
--Salida_De_Mealy: y <= Salida( p - 1 downto 0 );                       

--Fin de Descomentar en caso de Mealy comentar en caso de Moore
--
                                                                      
end Estructura;
