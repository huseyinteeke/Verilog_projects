@echo off

call "C:\Xilinx\Vivado\2017.4\settings64.bat"

set folder=Simulation_Files
if not exist %folder% mkdir %folder%

cd %folder%

call xvlog ../register8bit.v
call xvlog ../Register8bitSimulation.v
call xvlog ../Helper.v

call xelab -top Register8bitSimulation -snapshot reg8sim -debug typical
call xsim reg8sim -R

pause