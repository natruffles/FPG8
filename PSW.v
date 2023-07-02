module PSW (
    input clk,
    input reset,
    output [1:0] REG_OUT_PSW, 
    input Z_in,
    input [3:0] IR_opcode,
    input IR_S,
    input [2:0] ALU_control,
    input CC_Z_in,
    input CC_N_in
);

// instantiation template 
/*
PSW PSW_inst0 (
    .clk(),
    .reset(),
    .REG_OUT_PSW(), 
    .Z_in(),
    .IR_opcode(),
    .IR_S(),
    .ALU_control(),
    .CC_Z_in(),
    .CC_N_in()
);
*/

reg [1:0] r;

// register can be input with 3 options with decreasing priority:
// reset to 0 if reset is high 
// input from bus if latch is high
// input 2 bits (don't touch the other 14) from comparator if opcode
//   represents an ALU operation, IR.S is true, and the ALU operation is 
//   one performed that is supported by the ALU operation opcode
always @(posedge clk) begin
    if (reset) begin
        r <= 0;
    end else if (IR_opcode >= 0 && IR_opcode <= 5 && Z_in && IR_S && ALU_control != 3'b111 & ALU_control != 3'b010) begin
        r[0] <= CC_Z_in;
        r[1] <= CC_N_in;
    end
end

assign REG_OUT_PSW = r;

endmodule