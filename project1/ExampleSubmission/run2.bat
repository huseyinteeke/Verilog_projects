@echo off
:: Vivado ortam değişkenlerini yükle
call C:\Xilinx\Vivado\2017.4\settings64.bat

set folder=Simulation_Files

:: Eğer klasör varsa silip temiz başla (opsiyonel ama tavsiye edilir)
if exist %folder% rmdir /s /q %folder%
mkdir %folder%
cd %folder%
copy ..\*.mem .

::Arithmetic Logic Unit Simulation
call xvlog ../ArithmeticLogicUnit.v  
call xvlog ../ArithmeticLogicUnitSimulation.v
call xvlog ../Helper.v
call xelab -top ArithmeticLogicUnitSimulation -snapshot alusim -debug typical
call xsim alusim -R

cd ..