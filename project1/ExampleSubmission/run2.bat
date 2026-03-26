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


::Arithmetic Logic Unit System Simulation
call xvlog ../Register16bit.v  
call xvlog ../RegisterFile.v
call xvlog ../AddressRegisterFile.v  
call xvlog ../InstructionRegister.v
call xvlog ../DataRegister.v  
call xvlog ../ArithmeticLogicUnit.v
call xvlog ../InstructionMemory.v
call xvlog ../InstructionMemoryUnit.v
call xvlog ../DataMemory.v
call xvlog ../DataMemoryUnit.v
call xvlog ../ArithmeticLogicUnitSystem.v  
call xvlog ../ArithmeticLogicUnitSystemSimulation.v
call xvlog ../Helper.v

call xelab -top ArithmeticLogicUnitSystemSimulation -snapshot alusyssim -debug typical
call xsim alusyssim -R


cd ..