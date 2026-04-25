# 🔒 Password-Protected Entry System (Basys 3 FPGA)

### 🎬 Hardware Demonstration
(https://github.com/user-attachments/assets/22aad2bc-b6ba-4f27-ba9b-3f8da19bd923)

## 📝 Project Overview
This project implements a digital password lock on the Xilinx Basys 3 FPGA development board using Verilog HDL. It was designed to demonstrate the practical application of combinational and sequential logic, hardware debouncing, and display multiplexing. 

Users can set and verify a 4-digit code using 16 on-board DIP switches, interacting with the system through dedicated tactile push-buttons. The authentication outcomes are rendered in real-time on a time-multiplexed 7-segment display as **PASS**, **FAIL**, or **DONE**.

## ⚙️ Key Technical Implementations
* **Finite State Machine (FSM):** Engineered a robust 3-state architecture to manage system flow.
* **Hardware Debouncing:** Custom Verilog logic to filter out mechanical bounce from the tactile push-buttons, ensuring accurate state transitions.
* **Display Multiplexing:** Time-multiplexed the 4-digit 7-segment display at ~1.5 kHz using the onboard 100 MHz clock to drive dynamic character output.
* **RTL to Bitstream:** Mapped the Verilog RTL directly to the Basys 3 constraints (`.xdc` file) for hardware synthesis via Xilinx Vivado.

## 🧠 FSM Architecture
The core logic is governed by a Finite State Machine with three distinct states:
1. **`IDLE` (2'b00):** The default waiting state for password entry.
2. **`CHECK` (2'b01):** Triggered by the Center Button (BTNC). The system verifies the switch inputs against the stored logic.
3. **`CHANGE` (2'b10):** Triggered by the Right Button (BTNR). The system commits the new switch configuration to memory as the updated password.

## 🎛️ Hardware I/O Mapping
| Component | Basys 3 Peripheral | Function |
| :--- | :--- | :--- |
| **Input Data** | `sw[15:0]` (16 DIP Switches) | 4-digit password entry (4 switches per digit) |
| **Enter/Verify** | `btnC` (Center Button) | Submits the password for verification |
| **Change Password** | `btnR` (Right Button) | Enters the setup mode to save a new password |
| **Reset** | `btnD` (Down Button) | Resets the system back to the IDLE state |
| **Output** | `seg[6:0]` & `an[3:0]` | 7-segment display showing system status |

## 👥 Engineering Team
This project was successfully developed and hardware-validated as a collaborative B.Tech project by:
* **Eldho Varghese Binu**
* **Elsa Rachel Shiju**
* **Fathima Nihala PK**
