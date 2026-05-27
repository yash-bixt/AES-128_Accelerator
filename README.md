# AES-128 FPGA Hardware Accelerator

A complete AES-128 Encryption & Decryption Hardware Accelerator implemented in Verilog and deployed on the Nexys 4 FPGA board.

This project performs real-time AES encryption and decryption over UART using dynamically supplied 128-bit keys and plaintext/ciphertext inputs.

---

## Features

- AES-128 Encryption
- AES-128 Decryption
- UART Communication Interface
- Runtime Configurable 128-bit Keys
- ASCII Plaintext Support
- HEX Ciphertext Support
- FPGA Deployment on Nexys 4 DDR
- Real-Time Terminal Interaction
- Verilog RTL Design

---

## System Flow

### Encryption Flow

```text
Plaintext + Key
        ↓
UART RX
        ↓
Command Parser
        ↓
AES-128 Encryption Core
        ↓
Ciphertext Generation
        ↓
UART TX
        ↓
Terminal Output
```

### Decryption Flow

```text
Ciphertext + Key
        ↓
UART RX
        ↓
Command Parser
        ↓
AES-128 Decryption Core
        ↓
Recovered Plaintext
        ↓
UART TX
        ↓
Terminal Output
```

---

## FPGA Board

- Nexys 4 DDR
- Xilinx Artix-7 FPGA

---

## Tools Used

- Vivado Design Suite
- Verilog HDL
- Xilinx XSim Simulator
- UART Serial Communication

---

## RTL Modules

### AES Modules

- aes128_core.v
- aes128_encrypt_core.v
- aes128_decrypt_core.v
- key_expansion.v
- sub_bytes.v
- shift_rows.v
- mix_columns.v

### UART Modules

- uart_rx.v
- uart_tx.v
- uart_result_sender.v
- baud_tick_gen.v

### Control Modules

- command_parser.v
- aes_uart_top.v

---

## UART Configuration

```text
Baud Rate  : 115200
Data Bits  : 8
Parity     : None
Stop Bits  : 1
Flow Ctrl  : None
```

---

## Command Format

### Encryption

```text
E <128-bit HEX Key> <ASCII Plaintext>
```

### Decryption

```text
D <128-bit HEX Key> <128-bit HEX Ciphertext>
```

---

# Working Examples

## Example 1

### Encrypt

```text
E 000102030405060708090A0B0C0D0E0F Cat
```

### FPGA Output

```text
C6720370F726CFBF8E04641F3B45CF850
```

### Decrypt

```text
D 000102030405060708090A0B0C0D0E0F 6720370F726CFBF8E04641F3B45CF850
```

### FPGA Output

```text
PCat
```

---

## Example 2

### Encrypt

```text
E 00112233445566778899AABBCCDDEEFF HELLO
```

### FPGA Output

```text
C0DC88A6F7075AA147B910CD196182F12
```

### Decrypt

```text
D 00112233445566778899AABBCCDDEEFF 0DC88A6F7075AA147B910CD196182F12
```

### FPGA Output

```text
PHELLO
```

---

## Example 3

### Encrypt

```text
E 1FDEA5789AEF12ECDF41AA69DEACEE00 YASH
```

### FPGA Output

```text
C785CEC893008DB1E2A14684A409453F5
```

### Decrypt

```text
D 1FDEA5789AEF12ECDF41AA69DEACEE00 785CEC893008DB1E2A14684A409453F5
```

### FPGA Output

```text
PYASH
```

---

## Verification

The design was verified through:

- Functional RTL Simulation
- UART Communication Testing
- FPGA Hardware Validation
- AES Encryption/Decryption Test Vectors
- Full UART Loopback Testing

---

## Applications

- Secure Communication Systems
- Hardware Cryptographic Accelerators
- Embedded Security Systems
- FPGA Security Research
- Secure IoT Communication
- High-Speed Encryption Engines
- Hardware Security Prototyping

---

## Future Improvements

- AES-256 Support
- Pipelined AES Architecture
- CBC/CTR Modes
- AXI Interface
- DMA Integration
- ASIC Flow Implementation
- Secure File Encryption System

---

## Author

Yash Sharma  
B.Tech ECE | FPGA | VLSI | Digital Design | Hardware Security
