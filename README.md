# Cache_Memory_Controller

## Project Overview
This project implements a complete **Memory Hierarchy System** using SystemVerilog. The primary goal is to simulate the interaction between a CPU, a Direct-Mapped Cache, and a slower Main Memory (SDRAM).

The core of the project is a **Cache Controller** governed by a Finite State Machine (FSM) that implements a **Write-Back Policy** using Dirty Bits. This ensures data consistency while optimizing performance by minimizing access to the slow main memory.

### Key Features
* **16-bit CPU Interface:** Simulates read/write requests with strict handshake protocols.
* **Direct Mapped Cache:** Uses Tag, Index, and Offset mapping.
* **Write-Back Policy:** "Dirty" blocks are written to SDRAM only upon eviction, reducing bus traffic.
* **Finite State Machine (FSM):** Handles Hits, Misses, Allocations, and Write-Backs automatically.
* **Burst Transfer Simulation:** Simulates 32-word block transfers between SDRAM and Cache.

---

## System Architecture

The system is organized into three main hierarchical modules:

<img width="707" height="446" alt="image" src="https://github.com/user-attachments/assets/e452c0cd-31fe-450c-86f9-ee0a6f2a54bb" />

### 1. CPU (Processor)
The master of the system. It generates 16-bit addresses and 8-bit data. It uses a 4-cycle **Chip Select (CS)** signal to initiate transactions and waits for the **Ready (RDY)** signal from the Cache before proceeding.

<img width="406" height="224" alt="image" src="https://github.com/user-attachments/assets/15b5c6c1-bdd5-48a1-9cfa-ae51b026e6dd" />

### 2. Cache Unit
Acts as the high-speed buffer. It contains:
* **Cache Controller:** The "brain" that checks Tags, Valid bits, and Dirty bits to decide if a request is a HIT or a MISS.
* **BlockRAM:** Fast internal memory (SRAM) for data storage.
* **Mux/Demux Logic:** Routes data flow between CPU, BlockRAM, and SDRAM based on the FSM state.

### 3. SDRAM Controller
Represents the large, slow main memory. It communicates with the Cache only during Misses (to provide new blocks) or Write-Backs (to save modified blocks).

<img width="589" height="280" alt="image" src="https://github.com/user-attachments/assets/bc8736f6-2764-486d-bfc5-54c07336e37d" />

---

## Logic & Control Flow

The Cache Controller operates using an FSM with four primary states: `IDLE`, `COMPARE_TAG`, `ALLOCATE`, and `WRITE_BACK`.

**FSM**
<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/53e20809-81ad-4189-815d-99c5b4f6018f" />

**WorkFlow**
<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/62e0f640-a39c-4ba3-aaaa-78a6d43dfbe1" />

### Behavioral Cases (Hit/Miss Logic)
The system handles four specific scenarios:

1.  **Write Hit:**
    * **Condition:** Tag match + Valid bit is 1.
    * **Action:** Data is written to Cache immediately. **Dirty Bit is set to 1**.
2.  **Read Hit:**
    * **Condition:** Tag match + Valid bit is 1.
    * **Action:** Data is sent to the CPU immediately. No SDRAM access required.
3.  **Clean Miss:**
    * **Condition:** Tag mismatch, but the old block is clean (Dirty = 0).
    * **Action:** The Controller enters `ALLOCATE` state and fetches a new block from SDRAM.
4.  **Dirty Miss (Critical Case):**
    * **Condition:** Tag mismatch, and the old block is modified (Dirty = 1).
    * **Action:** The Controller first enters `WRITE_BACK` to save the old data to SDRAM, then switches to `ALLOCATE` to fetch the new data.

---

## Simulation & Testing

The project is verified using a system-level Testbench (`tb_top_system.sv`). The waveform below demonstrates the sequence of operations covering all behavioral cases.

<img width="1910" height="1015" alt="Test_results" src="https://github.com/user-attachments/assets/78c023be-ffb0-4309-a7d2-47a4df1d778b" />

### Test Scenario Walkthrough
The simulation performs the following sequence (visible in the waveform):

* **Test 0 (Miss Clean):** CPU reads `0x1234`. Cache is empty. System fetches 32 bytes from SDRAM (notice the long `RDY=0` period).
* **Test 1 (Write Hit):** CPU writes `0xAA` to `0x1234`. Cache updates internally and sets Dirty Bit = 1.
* **Test 2 (Read Hit):** CPU reads `0x1234`. Data is returned instantly (Fast access).
* **Test 3 (Dirty Miss):** CPU reads `0xFF34`. This conflicts with the dirty block at `0x1234`.
    * **Observation:** The system performs a **Write-Back** (saving `0x1234` to SDRAM), followed immediately by an **Allocate** (loading `0xFF34`). This is seen as a double-length activity period on the bus.

---

## Implementation Details

* **Language:** SystemVerilog
* **Simulation Tool:** Xilinx Vivado
* **Clock Period:** 10ns (100 MHz)
* **Cache Structure:**
    * Block Size: 32 Bytes
    * Tag: 8 bits
    * Index: 3 bits
    * Offset: 5 bits
 
<img width="347" height="285" alt="image" src="https://github.com/user-attachments/assets/646c270b-97b9-40ea-8fb3-d14c73c53c18" />


