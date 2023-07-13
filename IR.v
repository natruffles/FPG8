module IR (
    input clk, // data read/written on positive clock edges
    input reset, // reset all registers to a certain value
    inout [15:0] DATA,  // in and out from bus line
    output [15:0] REG_OUT_IR,  // for debugging
    output [3:0] opcode_out,
    output [2:0] rd_out_1,
    output [2:0] rd_out_2,
    output S,
    output [1:0] shift,
    output [2:0] rs_1,
    output [2:0] rs_2,
    input IR_in,
    input IR_offset_out
);

// instantiation template 
/*
IR IR_inst0 (
    .clk(), 
    .reset(),
    .DATA(), 
    .REG_OUT_IR(),
    .opcode_out(),
    .rd_out_1(),
    .rd_out_2(),
    .S(),
    .shift(),
    .rs_1(),
    .rs_2(),
    .IR_in(),
    .IR_offset_out()
);
*/

reg [15:0] r;

// register is either set by latch or reset by reset
always @(posedge clk) begin
    if (reset) begin
        r <= 0;
    end else begin
        if (IR_in) begin
            r <= DATA;
        end
    end
end

// if enable, r is driven to data port, else no connection (high impedance)
assign DATA = (IR_offset_out) ? {4'b0, r[11:0]} : 16'bZZZZZZZZZZZZZZZZ;
assign REG_OUT_IR = r;

assign opcode_out = REG_OUT_IR[15:12];
assign S = REG_OUT_IR[11];
assign shift = REG_OUT_IR[10:9];
assign rd_out_1 = REG_OUT_IR[8:6];
assign rs_1 = REG_OUT_IR[5:3];
assign rs_2 = REG_OUT_IR[2:0];
assign rd_out_2 = REG_OUT_IR[11:9];

endmodule