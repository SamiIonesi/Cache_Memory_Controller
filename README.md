# Cache_Memory_Controller
<img width="1014" height="670" alt="Block_diagram" src="https://github.com/user-attachments/assets/026660b7-ff16-42aa-868e-ad7d842a4333" />

## Project Overview

This project implements a multi-master memory access system in Verilog. The architecture allows four independent master units (B_units) to access a single Synchronous SRAM through a centralized Priority Arbiter. The system is designed to handle physical propagation delays and specific handshaking protocols required for reliable data transfer in high-frequency digital designs.

## System Architecture

The system consists of the following components:

- **Master Units (B_units)**: Initiate read/write requests and manage local data latching.

- **Priority Arbiter**: Resolves concurrent requests using a fixed-priority scheme (B0 > B1 > B2 > B3).

- **Multiplexers**: Select the active address and data paths based on the Arbiter's decision.

- **Synchronous SRAM**: A memory module with registered outputs (1-clock cycle read latency).

## B_unit FSM Diagram
The Bus unit manages the request lifecycle. It sends a request to the Arbiter and waits for an acknowledgment before latching user-provided address and data values.

States:

- S_IDLE: Waits for an internal request (req_in).

- S_WAIT_ACK1: Asserts req_out to the arbiter and drives address/data/control signals. Waits for the Arbiter to respond with ack.

- S_WAIT_ACK2: De-asserts req_out (handshake completion).

- S_DONE: Finalizes the transaction. If it was a Read operation, it latches the data coming from memory.

<img width="480" height="481" alt="image" src="https://github.com/user-attachments/assets/a12a8ab4-5250-472d-a5d4-2782a6b45622" />

## Arbiter FSM Diagram
The Arbiter acts as a Moore machine that manages priority and SRAM timing. It ensures that the winning Master has exclusive access to the memory for a fixed 4-cycle window.

States:

- S_IDLE: Monitors requests (req0 - req3). If a request exists, it latches the winner based on priority and the Write/Read type.

- S_PROC: Drives the SRAM interface signals (addr_to_mem, data_to_mem, we_to_mem) based on the selected master.

- S_ACK1: Asserts the specific ack signal for the winning B_unit.

- S_ACK2: Maintains ack high. If the operation is a Read, it routes data from memory to the specific B_unit.

<img width="434" height="453" alt="image" src="https://github.com/user-attachments/assets/312fbc97-937c-41bb-a687-6e6a5b6decfc" />

## Transaction Flows

### Write Flow (B_unit writing to Memory)

1. Initiation: The B_unit receives an internal req_in and wr_in=1. It moves to S_WAIT_ACK1.

2. Request: The B_unit sets req_out=1 and drives the Address and Data onto the bus.

3. Arbitration: The Arbiter (in S_IDLE) sees the request. It transitions to S_PROC, locking the selection ID.

4. Execution:

    - Arbiter (S_PROC): Drives we_to_mem=1, addr_to_mem, and data_to_mem towards the SRAM.

    - Arbiter (S_ACK1): Raises ack for the specific B_unit.

5. Handshake:

    - The B_unit detects ack=1 and transitions to S_WAIT_ACK2.

    - The B_unit lowers req_out=0.

6. Completion: The Arbiter moves to S_ACK2 (holding signals stable) and then back to S_IDLE. The B_unit moves to S_DONE and then S_IDLE.

### Read Flow (B_unit reading from Memory)

1. Initiation: The B_unit receives an internal req_in and wr_in=0. It moves to S_WAIT_ACK1.

2. Request: The B_unit sets req_out=1, drives the Address, and sets data bus to 0 (Z or ignored).

3. Arbitration: The Arbiter (in S_IDLE) sees the request. It transitions to S_PROC.

4. Execution:

    - Arbiter (S_PROC): Drives we_to_mem=0 and addr_to_mem towards the SRAM.

    - Arbiter (S_ACK1): Raises ack for the specific B_unit.

5. Data Valid & Handshake:

    - Arbiter (S_ACK2): The SRAM provides valid data (data_from_mem). The Arbiter routes this data to the winner's input bus (data_to_Bx).

    - The B_unit detects ack=1, transitions to S_WAIT_ACK2, and lowers req_out.

6. Latching: The B_unit transitions to S_DONE. In this state, it checks !wr_out and latches the data available on the bus into its internal dout register.

7. Completion: Both FSMs return to S_IDLE.



