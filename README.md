# APB Slave Design and Verification

This repository contains the design and verification code for an **APB (Advanced Peripheral Bus) Slave** module using **SystemVerilog**. The project includes a testbench that simulates various read and write transactions, along with error detection mechanisms like address and data validation errors.

## APB Slave Design Overview

The processors operate at a very high frequency and the external peripherals operate at a very low frequency, so to handle the transaction with them we use APB protocol. APB is not pipelined, and is a simple synchronous protocol. Every transfer takes at least two cycles to complete. APB interface is designed for accessing the programmable control registers of peripheral devices. APB peripherals also referred as completers, and are typically connected to the main memory using an APB bridge. APB transfers are initiated by an APB bridge, also referred as Requesters.

![image](https://github.com/user-attachments/assets/0812e739-3bb1-4d6e-afc8-719caeb3ad00)


The APB Slave is designed to interact with a master (Verification Environment) via the APB protocol. It can perform **read** and **write** operations to an internal memory, handle **address validation** and **data validation errors**, and output a **pready** signal when the operation is complete. Key features include:

- **State machine** with Idle, Read, and Write states.
- **Memory storage** using a 16-entry deep, 8-bit wide memory.
- **Error Detection**: Flags for address, address validation, and data errors.

## Testbench Overview

The testbench is designed using **SystemVerilog classes** and contains the following components:
- **Transaction Class**: Defines the fields for APB transactions like `paddr`, `pwdata`, `pwrite`, etc.
- **Driver**: Drives the APB signals to the DUT (Device Under Test).
- **Monitor**: Monitors and logs the transactions.
- **Scoreboard**: Compares the expected and actual results for validation.
- **Generator**: Randomly generates transactions for stimulus.
  

