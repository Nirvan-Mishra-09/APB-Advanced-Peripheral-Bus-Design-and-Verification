# APB Slave Design and Verification

This repository contains the design and verification code for an **APB (Advanced Peripheral Bus) Slave** module using **SystemVerilog**. The project includes a testbench that simulates various read and write transactions, along with error detection mechanisms like address and data validation errors.

## APB Slave Design Overview

The processor operates at a very high frequency and the external peripherals operate at a very low frequency, so to handle the transaction with them we use APB protocol. APB is not pipelined, and is a simple synchronous protocol. Every transfer takes at least two cycles to complete. APB interface is designed for accessing the programmable control registers of peripheral devices. APB peripherals also referred as completers, and are typically connected to the main memory using an APB bridge. APB transfers are initiated by an APB bridge, also referred as Requesters.

![image](https://github.com/user-attachments/assets/0812e739-3bb1-4d6e-afc8-719caeb3ad00)


The APB Slave is designed to interact with a master (Verification Environment) via the APB protocol. It can perform **read** and **write** operations to an internal memory, handle **address validation** and **data validation errors**, and output a **pready** signal when the operation is complete. Key features include:

- **State machine** with Idle, Read, and Write states.
- **Memory storage** using a 16-entry deep, 8-bit wide memory.
- **Error Detection**: Flags for address, address validation, and data errors.

![image](https://github.com/user-attachments/assets/6abb49db-1ad3-429d-b1b8-9c070e0eec22)


Here's a **Signal Description** section formatted for your GitHub repository's README:

---

### Signal Description

| Signal Name | Direction | Width  | Description |
|-------------|------------|--------|-------------|
| `pclk`      | Input      | 1 bit  | Clock signal used for synchronous operation. |
| `presetn`   | Input      | 1 bit  | Active-low reset signal that resets the state of the slave to its initial state. |
| `paddr`     | Input      | 32 bits | Address input used for reading from or writing to a specific memory location. |
| `psel`      | Input      | 1 bit  | Select signal used to indicate the slave is selected for communication. |
| `penable`   | Input      | 1 bit  | Enable signal used to indicate the start of the data transfer phase in a transaction. |
| `pwdata`    | Input      | 8 bits | Write data input used to send data to the slave during write operations. |
| `pwrite`    | Input      | 1 bit  | Write control signal, high for write operation and low for read operation. |
| `prdata`    | Output     | 8 bits | Read data output that holds data during read operations from the slave. |
| `pready`    | Output     | 1 bit  | Ready signal, asserted when the slave is ready to complete the current transfer. |
| `pslverr`   | Output     | 1 bit  | Slave error signal, asserted when an error (address, data, or value error) occurs during a transfer. |

---

This table provides a concise explanation of each signal in the APB Slave module. You can paste this into your GitHub `README.md` under a "Signal Description" heading.

## Testbench Overview

The testbench is designed using **SystemVerilog classes** and contains the following components:
- **Transaction Class**: Defines the fields for APB transactions like `paddr`, `pwdata`, `pwrite`, etc.
- **Driver**: Drives the APB signals to the DUT (Device Under Test).
- **Monitor**: Monitors and logs the transactions.
- **Scoreboard**: Compares the expected and actual results for validation.
- **Generator**: Randomly generates transactions for stimulus.

# APB Protocol Verification Log

This log showcases the transactions and verification process during the APB protocol testing. It includes various stages like stimulus generation, driving the stimulus, monitoring the results, and scoreboarding for validation.

## Reset
- **Action:** Reset Done
- **Time:** -

---

## Transaction 1
- **Address (paddr):** 0
- **Write Data (pwdata):** 172
- **Write Enable (pwrite):** 1
- **Read Data (prdata):** 0
- **Slave Error (pslverr):** 0
- **Time:** @ 90000

| Module    | Action                 | Time      |
|-----------|------------------------|-----------|
| Generator | Stimulus Generated      | @ 90000   |
| Driver    | Stimulus Driven         | @ 150000  |
| Monitor   | Stimulus Monitored      | @ 170000  |
| Scoreboard| Data Stored (Data: 172, Addr: 0) | @ 170000  |

---

## Transaction 2
- **Address (paddr):** 15
- **Write Data (pwdata):** 226
- **Write Enable (pwrite):** 1
- **Read Data (prdata):** 0
- **Slave Error (pslverr):** 0
- **Time:** @ 170000

| Module    | Action                 | Time      |
|-----------|------------------------|-----------|
| Generator | Stimulus Generated      | @ 170000  |
| Driver    | Stimulus Driven         | @ 230000  |
| Monitor   | Stimulus Monitored      | @ 250000  |
| Scoreboard| Data Stored (Data: 226, Addr: 15) | @ 250000  |

---

## Transaction 3
- **Address (paddr):** 13
- **Write Data (pwdata):** 231
- **Write Enable (pwrite):** 1
- **Read Data (prdata):** 0
- **Slave Error (pslverr):** 0
- **Time:** @ 250000

| Module    | Action                 | Time      |
|-----------|------------------------|-----------|
| Generator | Stimulus Generated      | @ 250000  |
| Driver    | Stimulus Driven         | @ 310000  |
| Monitor   | Stimulus Monitored      | @ 330000  |
| Scoreboard| Data Stored (Data: 231, Addr: 13) | @ 330000  |

---

## Transaction 4
- **Address (paddr):** 3
- **Write Data (pwdata):** 79
- **Write Enable (pwrite):** 0 (Read Operation)
- **Read Data (prdata):** 0
- **Slave Error (pslverr):** 0
- **Time:** @ 330000

| Module    | Action                 | Time      |
|-----------|------------------------|-----------|
| Generator | Stimulus Generated      | @ 330000  |
| Driver    | Stimulus Driven         | @ 390000  |
| Monitor   | Stimulus Monitored      | @ 410000  |
| Scoreboard| Data Matched (Addr: 3)  | @ 410000  |

---

## Transaction 5
- **Address (paddr):** 10
- **Write Data (pwdata):** 185
- **Write Enable (pwrite):** 1
- **Read Data (prdata):** 0
- **Slave Error (pslverr):** 0
- **Time:** @ 410000

| Module    | Action                 | Time      |
|-----------|------------------------|-----------|
| Generator | Stimulus Generated      | @ 410000  |
| Driver    | Stimulus Driven         | @ 470000  |
| Monitor   | Stimulus Monitored      | @ 490000  |
| Scoreboard| Data Stored (Data: 185, Addr: 10) | @ 490000  |

---

## Transaction 6
- **Address (paddr):** 13
- **Write Data (pwdata):** 20
- **Write Enable (pwrite):** 1
- **Read Data (prdata):** 0
- **Slave Error (pslverr):** 0
- **Time:** @ 490000

| Module    | Action                 | Time      |
|-----------|------------------------|-----------|
| Generator | Stimulus Generated      | @ 490000  |
| Driver    | Stimulus Driven         | @ 550000  |
| Monitor   | Stimulus Monitored      | @ 570000  |
| Scoreboard| Data Stored (Data: 20, Addr: 13) | @ 570000  |

---

## Transaction 7
- **Address (paddr):** 2
- **Write Data (pwdata):** 105
- **Write Enable (pwrite):** 0 (Read Operation)
- **Read Data (prdata):** 0
- **Slave Error (pslverr):** 0
- **Time:** @ 570000

| Module    | Action                 | Time      |
|-----------|------------------------|-----------|
| Generator | Stimulus Generated      | @ 570000  |
| Driver    | Stimulus Driven         | @ 630000  |
| Monitor   | Stimulus Monitored      | @ 650000  |
| Scoreboard| Data Matched (Addr: 2)  | @ 650000  |

---

