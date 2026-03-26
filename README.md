# 16-Bit Custom ALU System & Datapath (Verilog)

A fully custom-designed, completely synchronous 16-bit Arithmetic Logic Unit (ALU) and Datapath architecture implemented in Verilog. This project demonstrates a ground-up approach to digital design, managing everything from bit-level flag generation to multi-component data routing.

## 🚀 Overview

Instead of using pre-existing cores, this system is built from scratch to maintain full architectural control over the datapath. It processes 16-bit instructions and handles memory operations, arithmetic/logic computations, and register management precisely at the clock edge.

### Key Features:
* **Custom 16-bit ALU:** Supports 16 distinct arithmetic and logical operations.
* **Synchronous Flag Management:** Zero (Z), Carry (C), Negative (N), and Overflow (O) flags are strictly evaluated and updated on the positive edge of the clock to prevent race conditions.
* **Bit-Level Overflow Detection:** Custom MSB (Most Significant Bit) evaluation logic for flawless signed arithmetic handling.
* **Separation of Logic:** Combinational paths for instant ALU output calculations and sequential paths for flag registers.

## 🧩 System Architecture

The datapath consists of the following core modules interconnected via multiplexers:
* **ALU (Arithmetic Logic Unit):** The brain of the computation.
* **RF (Register File):** 16-bit general-purpose registers.
* **ARF (Address Register File):** Manages memory addressing.
* **IMU & DMU (Memory Units):** Instruction and Data memory handling.
* **Instruction & Data Registers (IR/DR):** Data buffering and instruction pipelining.
* **Multiplexers (MUX2to1, MUX4to1):** Controls the data flow between modules.


*(Note: You can see the elaborated RTL schematic of the system in the repository images, showcasing the precise gate-level implementation of the `case` blocks and memory synchronizers.)*

## 🛠️ Simulation & Testing

The design was verified using **Xilinx Vivado**. The testbench evaluates the combinatorial output stability and the sequential flag register updates under various load conditions.

* **Simulation Environment:** Vivado Simulator (xsim)
* **Test Coverage:** Comprehensive testing of all ALU operations, memory reads/writes, and Datapath routing.
* **Status:** `35/35 Tests Passed (0 Fails)`

## 💻 How to Run

1. Clone this repository.
2. Open the project in Xilinx Vivado (or your preferred Verilog simulator like Icarus Verilog).
3. Set `ArithmeticLogicUnitSystemSimulation.v` as the top module.
4. Run the behavioral simulation.