@echo off
REM ****************************************************************************
REM Vivado (TM) v2022.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Thu Jan 12 09:45:30 +0100 2023
REM SW Build 3526262 on Mon Apr 18 15:48:16 MDT 2022
REM
REM IP Build 3524634 on Mon Apr 18 20:55:01 MDT 2022
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim Test_Bench_behav -key {Behavioral:sim_1:Functional:Test_Bench} -tclbatch Test_Bench.tcl -view C:/Users/izana/Documents/GitHub/SEA/practica3_v2/Test_Bench_behav.wcfg -log simulate.log"
call xsim  Test_Bench_behav -key {Behavioral:sim_1:Functional:Test_Bench} -tclbatch Test_Bench.tcl -view C:/Users/izana/Documents/GitHub/SEA/practica3_v2/Test_Bench_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
