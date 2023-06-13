module PSW (
    input clk,
    input reset,
    inout [15:0] DATA,  
    output [15:0] REG_OUT_PSW, 
    input latch, 
    input enable, 
    input [3:0] IR_opcode,
    input IR_S,
    input Z_in,
    input CC_Z_in,
    input CC_N_in
);

// instantiation template 
/*
PSW PSW_inst0 (
    .clk(),
    .reset(),
    .DATA(),  
    .REG_OUT_PSW(), 
    .latch(), 
    .enable(), 
    .IR_opcode(),
    .IR_S(),
    .Z_in(),
    .CC_Z_in(),
    .CC_N_in()
);
*/

reg [15:0] r;

// register can be input with 3 options with decreasing priority:
// reset to 0 if reset is high 
// input from bus if latch is high
// input 2 bits (don't touch the other 14) from comparator if opcode
//   represents an ALU operation, IR.S is true, and Z_in (control signal) is true
always @(posedge clk) begin
    if (reset) begin
        r <= 0;
    end else if (latch) begin
        r <= DATA;
    end else if (IR_opcode >= 0 && IR_opcode <= 5 && IR_S && Z_in) begin
        r[0] <= CC_Z_in;
        r[1] <= CC_N_in;
    end
end

// if enable, r is driven to data port, else no connection (high impedance)
assign DATA = (enable)? r : 16'bZZZZZZZZZZZZZZZZ;
assign REG_OUT_PSW = r;

endmodule