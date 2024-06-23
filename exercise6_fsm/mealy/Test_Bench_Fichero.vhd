----------------------------------------------------------------------------------
-- Company: Universidad de Málaga
-- Engineer: Izan Amador, Jorge L. Benavides
--
-- Create Date: 23.11.2022 17:47:41
-- Design Name: Debouncer
-- Module Name: Test_Bench - Behavioral
-- Project Name: Sincronizador
-- Target Devices: Zybo
-- Tool Versions: Vivado 2022.1
-- Description: Debouncer for a button.
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.textIO.ALL;                     -- Se va a hacer uso de ficheros.

entity Test_Bench_Fichero is
--  Port ( );
end Test_Bench_Fichero;

architecture Comportamiento of Test_Bench_Fichero is

  component detector_secuencia
    port(x  : in  std_logic;
         clk   : in  std_logic;
         reset : in  std_logic;
         cke   : in  std_logic;
         y     : out std_logic);
  end Component detector_secuencia;


  constant semiperiodo : time    := 10 ns;
  signal x_interno, y_interno, reset_interno, cke_interno : std_logic := 'U';
  signal clk_interno : std_logic := '0';


begin

  DUT : detector_secuencia
    port map(
      x => x_interno,
      y => y_interno,
      reset => reset_interno,
      clk => clk_interno,
      cke => cke_interno);

-- Taken from The Student Guide to VHDL, Peter J.Asheden
  clock_gen : process (clk_interno) is
  begin
    if clk_interno = '0' then
      clk_interno <= '1' after semiperiodo,
                     '0' after 2*semiperiodo;
    end if;
  end process clock_gen;

  cke_interno <= '1';

  reset : process
  begin
    reset_interno <= '0';
    wait for 5 ns;
    reset_interno <= '1';
    wait for 5 ns;
    reset_interno <= '0';
    wait;
  end process reset;

  Estimulos_Desde_Fichero : process

    file Input_File  : text;
    file Output_File : text;

    variable Input_Data   : BIT_VECTOR(0 downto 0) := (OTHERS => '0');
    variable Delay        : time                   := 0 ms;
    variable Input_Line   : line                   := NULL;
    variable Output_Line  : line                   := NULL;
    variable Std_Out_Line : line                   := NULL;
    variable Correcto     : Boolean                := True;
    constant Coma         : character              := ',';


  begin

-- detector_secuencia_mealy_Estimulos.txt contiene los estímulos y los tiempos de retardo para el semisumador.
    file_open(Input_File, "C:\Users\izana\Documents\GitHub\SEA\Estimulos\detector_secuencia_mealy_Estimulos.txt", read_mode);
-- detector_secuencia_mealy_Estimulos.csv contiene los estímulos y los tiempos de retardo para el Analog Discovery 2.
    file_open(Output_File, "C:\Users\izana\Documents\GitHub\SEA\CSV\detector_secuencia_mealy_Estimulos.csv", write_mode);

-- Titles: Son para el formato EXCEL *.CSV (Comma Separated Values):
    write(Std_Out_Line, string'("Retardo"), right, 7);
    write(Std_Out_Line, Coma, right, 1);
    write(Std_Out_Line, string'("Entradas"), right, 8);

    Output_Line := Std_Out_Line;

    writeline(output, Std_Out_Line);
    writeline(Output_File, Output_Line);

    while (not endfile(Input_File)) loop

      readline(Input_File, Input_Line);

      read(Input_Line, Delay, Correcto);  -- Comprobación de que se trata de un texto que representa
      -- el retardo, si no es así leemos la siguiente línea.
      if Correcto then

        read(Input_Line, Input_Data);  -- El siguiente campo es el vector de pruebas.
        x_interno <= TO_STDLOGICVECTOR(Input_Data)(0);

        -- De forma simultánea lo volcaremos en consola en csv.
        write(Std_Out_Line, Delay, right, 5);  -- Longitud del retardo, ej. "20 ms".
        write(Std_Out_Line, Coma, right, 1);
        write(Std_Out_Line, Input_Data, right, 2);  --Longitud de los datos de entrada.

        Output_Line := Std_Out_Line;

        writeline(output, Std_Out_Line);
        writeline(Output_File, Output_Line);

        wait for Delay;
      end if;
    end loop;

    file_close(Input_File);             -- Cerramos el fichero de entrada.
    file_close(Output_File);            -- Cerramos el fichero de salida.
    wait;
  end process Estimulos_Desde_Fichero;


end Comportamiento;
