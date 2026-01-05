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

<img width="480" height="481" alt="image" src="https://github.com/user-attachments/assets/a12a8ab4-5250-472d-a5d4-2782a6b45622" />

## Arbiter FSM Diagram
The Arbiter acts as a Moore machine that manages priority and SRAM timing. It ensures that the winning Master has exclusive access to the memory for a fixed 4-cycle window.

<img width="434" height="453" alt="image" src="https://github.com/user-attachments/assets/312fbc97-937c-41bb-a687-6e6a5b6decfc" />

