# RISC-V-CPU
The project is dedicated to the development of a processor with a RISC architecture that can be programmed in a high-level C language. The project is carried out for educational purposes and is based on a course of lectures and laboratory work on the architecture of microprocessor systems of the Moscow University of Electronic Technologies
![](https://img.shields.io/badge/Education%20Project-%F0%9F%93%96-orange) ![No maintenance](http://unmaintained.tech/badge.svg)   
![](https://img.shields.io/github/last-commit/MrShelDie/RISC-V-CPU) ![](https://img.shields.io/badge/Done-20%25-orange) 

---

### RISC-V processor Microarchitecture

The following is the RISC-V processor microarchitecture. The PC register (Program Counter - instruction counter) is connected to the address input of the instruction memory. The instruction being read is decoded by the main decoder, as a result of which it exposes control signals for all processor blocks (multiplexers, ALU, memory interface).

<div align="center">
	<img src="https://github.com/MPSU/APS/blob/technical/Labs/Pic/uarch_md.png?raw=true"/>
<div/>

- Data memory:
	- stores the data that the program works with,
	- uses indirect-register addressing.
- Sign extension blocks (SE, Sign Extend) – receive a 12 or 20-bit constant as input and expand it to a 32-bit number by cloning the highest bit into all the missing highest bits of the number.
- The control device aka the main command decoder, or simply the main decoder (Main Decoder) is a combination circuit that receives instructions as input and, depending on their opcode and fields `function3`, `function7`, issues control signals to all processor blocks (blue in the figure) leading to the execution of the required instructions. For example, if the main decoder receives `opcode` = 0110011, `funct3` = 000, `funct7` = 0100000, which corresponds to a subtraction operation between register values, then the decoder needs to make sure that the values from the register file get to the ALU, then the control signals of the multiplexers will be switched to `ex_op_a_sel` = 00 and `ex_op_b_sel` = 000, and the operation code ALU `alu_op_o` = 01000. And the like for all other output signals of the command decoder.

In the figure shown, the `mem_size_o` and `mem_req_o` signals are combined into a single signal, however, when describing the module, these will be two different signals.

---

### RISC-V Instruction Set (RV32I)

<div align="center">
	<img src="https://github.com/MPSU/APS/blob/technical/Other/Pic/rv32i_spec.png?raw=true"/>
<div/>

For details, read  <a href="https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf">this</a>.

