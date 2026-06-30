# Sumário de apredizagem
## Inicio
Diagnóstico da Linha de Base: Compreensão completa do pipeline original de 5 estágios (IF/ID/EX/MEM/WB). Identificação visual, via ondas do ModelSim, do comportamento do Load-use Stall (adiando a execução em 1 ciclo com bolha) e do Branch Taken Flush (limpeza de 2 instruções usando NOPs).

## Meio
Expansão do ISA (U-type & Jumps): Implementação bem-sucedida das instruções LUI e AUIPC através da expansão do módulo pl_sign_ext.sv e controle associado. Estruturação do suporte para desvios incondicionais JAL e JALR.Controle de Condicionais (B-type): Ampliação da lógica de comparação da ALU em pl_alu.sv para processar as operações de menor que (sinalizado/não sinalizado) exigidas pelas novas instruções de branch (BNE, BLT, BGE, BLTU, BGEU).Suporte a Sub-palavras (Loads e Stores Parciais): Fase mais complexa do desenvolvimento. No estágio MEM, foi integrado um circuito multiplexador combinacional capaz de isolar bytes e meias-palavras baseando-se nos bits menos significativos do endereço (alu_result[1:0]). Adicionou-se suporte a máscaras de escrita para SB e SH na memória de dados, além da extensão de sinal adequada para LB/LH e extensão de zeros para LBU/LHU.
## Fim
  Verificação de Software Integrada: Desenvolvimento de rotinas em assembly customizadas contendo misturas severas de todas as novas instruções e hazards. Os testes passaram com sucesso no simulador ModelSim, atingindo o critério automático de parada (Halt) via oscilação controlada do PC em loops fechados.

# RV32I Pipelined Base Project

Processador RISC-V de 32 bits com pipeline de 5 estágios implementado em SystemVerilog, baseado nas seções 4.6 a 4.10 de *Computer Organization and Design: RISC-V Edition* (Patterson & Hennessy). O projeto tem como plataforma alvo a placa **DE2-115** (Intel Cyclone IV E) e é estruturado para servir de base para extensões do conjunto de instruções pelos alunos.

---

## Instruções suportadas

| # | Instrução | Tipo | Opcode  | Status |
|---|-----------|------|---------|:------:|
| 1 | `ADD`     | R    | 0110011 | ✅ |
| 2 | `SUB`     | R    | 0110011 | ✅ |
| 3 | `OR`      | R    | 0110011 | ✅ |
| 4 | `AND`     | R    | 0110011 | ✅ |
| 5 | `SLT`     | R    | 0110011 | ✅ |
| 6 | `LW`      | I    | 0000011 | ✅ |
| 7 | `SW`      | S    | 0100011 | ✅ |
| 8 | `BEQ`     | B    | 1100011 | ✅ |

#### Aritmética, lógica e deslocamentos (R-type)

| # | Instrução | Tipo | Opcode  | Status |
|---|-----------|------|---------|:------:|
| 1 | `XOR`     | R    | 0110011 | ✅ |
| 2 | `SLL`     | R    | 0110011 | ✅ |
| 3 | `SRL`     | R    | 0110011 | ✅ |
| 4 | `SRA`     | R    | 0110011 | ✅ |
| 5 | `SLTU`    | R    | 0110011 | ✅ |

#### Aritmética, lógica e deslocamentos com imediatos (I-type)

| # | Instrução | Tipo | Opcode  | Status |
|---|-----------|------|---------|:------:|
| 1 | `ADDI`    | I    | 0010011 | ✅ |
| 2 | `ANDI`    | I    | 0010011 | ✅ |
| 3 | `ORI`     | I    | 0010011 | ✅ |
| 4 | `SLTI`    | I    | 0010011 | ✅ |
| 5 | `SLLI`    | I    | 0010011 | ✅ |
| 6 | `SRLI`    | I    | 0010011 | ✅ |
| 7 | `SRAI`    | I    | 0010011 | ✅ |
#### Acesso à memória — loads (I-type)

| # | Instrução | Tipo | Opcode  | Status |
|---|-----------|------|---------|:------:|
| 1 | `LB`      | I    | 0000011 | ✅ |
| 2 | `LH`      | I    | 0000011 | ✅ |
| 3 | `LBU`     | I    | 0000011 | ✅ |
| 4 | `LHU`     | I    | 0000011 | ✅ |

#### Acesso à memória — stores (S-type)

| # | Instrução | Tipo | Opcode  | Status |
|---|-----------|------|---------|:------:|
| 1 | `SB`      | S    | 0100011 | ✅ |
| 2 | `SH`      | S    | 0100011 | ✅ |

#### Desvios condicionais (B-type)

| # | Instrução | Tipo | Opcode  | Status |
|---|-----------|------|---------|:------:|
| 1 | `BNE`     | B    | 1100011 | ✅ |
| 2 | `BLT`     | B    | 1100011 | ✅ |
| 3 | `BGE`     | B    | 1100011 | ✅ |
| 4 | `BLTU`    | B    | 1100011 | ✅ |
| 5 | `BGEU`    | B    | 1100011 | ✅ |

#### Jumps (J-type)

| # | Instrução | Tipo | Opcode  | Status |
|---|-----------|------|---------|:------:|
| 1 | `JAL`     | J    | 1101111 | ✅ |
| 2 | `JALR`    | I    | 1100111 | ✅ |

#### Imediato superior (U-type)

| # | Instrução | Tipo | Opcode  | Status |
|---|-----------|------|---------|:------:|
| 1 | `LUI`     | U    | 0110111 | ✅ |
| 2 | `AUIPC`   | U    | 0010111 | ✅ |



## Estrutura do repositório

```
rv32i_pipelined_base_project/
│
├── src/                        Código-fonte SystemVerilog
│   ├── pl_pipe_pkg.sv          Structs dos registradores de pipeline
│   ├── pl_top.sv               Top-level (PLL 50→10 MHz + CPU)
│   ├── pl_cpu.sv               Wrapper: Control + ALU_Ctrl + Datapath
│   ├── pl_control.sv           Unidade de controle (estágio ID)
│   ├── pl_alu_ctrl.sv          Controle da ALU (estágio EX)
│   ├── pl_alu.sv               ALU 32 bits
│   ├── pl_regfile.sv           Banco de registradores 32×32 b
│   ├── pl_sign_ext.sv          Extensão de sinal I/S/B
│   ├── pl_imem.sv              Memória de instruções 256×32 b (MIF)
│   ├── pl_dmem.sv              Memória de dados 256×32 b (MIF)
│   ├── pl_mmio.sv              Controlador MMIO (SW/KEY/LED/UART)
│   ├── pl_uart.sv              UART RS-232 8N1 (9600 baud, 50 MHz)
│   ├── pl_hazard.sv            Detecção de hazard load-use
│   ├── pl_forward.sv           Unidade de forwarding
│   ├── pl_datapath.sv          Datapath 5 estágios
│   ├── pl_cpu_tb.sv            Testbench de verificação
│   └── pll_10mhz.v             PLL Altera (50 MHz → 10 MHz)
│
├── mifs/                       Arquivos de inicialização de memória
│   ├── instruction.mif         Programa de teste padrão
│   ├── data.mif                Dados iniciais do programa de teste
│   ├── mmio_test_program.mif   Programa de teste MMIO + UART
│   └── mmio_test_data.mif      Dados para o teste MMIO
│
├── assembler/
│   ├── assembler.py            Montador Python: assembly → .mif / dump
│   ├── hello.asm               Programa de entrada padrão
│   ├── instruction.mif         MIF gerado (saída do assembler)
│   ├── data.mif                MIF de dados gerado (modo --dump)
│   └── program.hex             Hex gerado (modo normal)
│
├── dump/
│   └── serial_dump.py          Captura e decodifica dump serial do FPGA
│
├── modelsim/                   Projeto ModelSim para simulação
│   ├── *.mpf                   Arquivo de projeto ModelSim
│   ├── program.hex             Imagem da instrução (.hex para $readmemh)
│   ├── data.hex                Imagem dos dados (.hex para $readmemh)
│   ├── golden.txt              Saída esperada pelo testbench
│   └── output.txt              Saída gerada na última simulação
│
└── quartus/                    Projeto Quartus Prime para síntese
    ├── *.qpf / *.qsf           Arquivos de projeto Quartus
    ├── instruction.mif         MIF da instrução (cópia de trabalho)
    └── data.mif                MIF dos dados (cópia de trabalho)
```

## Recursos

- [Manual RISC-V ISA v2.2](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf)
- [RISC-V ISA Reference (msyksphinz)](https://msyksphinz-self.github.io/riscv-isadoc/html/rvi.html)
- [RISC-V Interpreter — Cornell University](https://www.cs.cornell.edu/courses/cs3410/2019sp/riscv/interpreter/)
- Patterson & Hennessy, *Computer Organization and Design: RISC-V Edition*, seções 4.6 – 4.10
