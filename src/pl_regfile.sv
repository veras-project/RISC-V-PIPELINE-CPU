// =============================================================================
// pl_regfile.sv
// Banco de Registradores 32 x 32 bits -- RV32I pipelined
//
// Leitura  : assincrona (combinatorial) -- usada no estagio ID
// Escrita  : sincrona no NEGEDGE do clock, proveniente do estagio WB
// x0       : hardwired a zero (escrita ignorada silenciosamente)
//
// Por que negedge?
//   No pipeline de 5 estagios, apos um load-use stall, pode ocorrer o seguinte
//   conflito: a instrucao que causou o stall completa WB no mesmo posedge em
//   que a instrucao dependente (retida em ID) captura seus operandos no
//   registrador ID/EX. Com escrita em posedge, a leitura combinacional de ID
//   enxerga o valor ANTIGO do registrador (antes da escrita), resultando em
//   dado incorreto no ID/EX. Com escrita em negedge, a atualizacao ocorre no
//   meio do ciclo de clock, garantindo que o posedge seguinte ja leia o valor
//   correto do banco. Essa e a solucao canonica do P&H (Fig. 4.63) e a mesma
//   adotada pelo rv32i-base-project.
// =============================================================================

`timescale 1ns / 1ps

module pl_regfile (
    input  logic        clk,
    input  logic [3:0]  ByteEnable,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] WriteData,
    output logic [31:0] ReadData1,
    output logic [31:0] ReadData2
);

    logic [31:0] rf [31:0];

    // Escrita no negedge: a atualizacao fica visivel antes do proximo posedge,
    // evitando o conflito read-after-write quando WB e ID ocorrem no mesmo ciclo.
    always_ff @(negedge clk) begin
        if (rd != 5'b0) begin
            if (ByteEnable[0]) rf[rd][7:0]   <= WriteData[7:0];
            if (ByteEnable[1]) rf[rd][15:8]  <= WriteData[15:8];
            if (ByteEnable[2]) rf[rd][23:16] <= WriteData[23:16];
            if (ByteEnable[3]) rf[rd][31:24] <= WriteData[31:24];
        end
    end

    assign ReadData1 = (rs1 != 5'b0) ? rf[rs1] : 32'b0;
    assign ReadData2 = (rs2 != 5'b0) ? rf[rs2] : 32'b0;

endmodule
