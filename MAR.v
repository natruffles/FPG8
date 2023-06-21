module MAR (
    input clk, // data read/written on positive clock edges
    input reset, // reset all registers to a certain value
    inout [15:0] DATA,  // in and out from bus line
    output [15:0] REG_OUT_MAR,  // for debugging, to RAM
    input MAR_in,
    input r_en,
    input w_en
);

// instantiation template 
/*
MAR MAR_inst0 (
    .clk(),
    .reset(), 
    .DATA(), 
    .REG_OUT_MAR(),
    .MAR_in(),
    .r_en(),
    .w_en()
);
*/

wire [15:0] REG_OUT_FROM_MAR;

register MAR_reg (
    .clk(clk),
    .reset(reset),
    .DATA(DATA),
    .REG_OUT(REG_OUT_FROM_MAR),  
    .latch(MAR_in), 
    .enable(1'b0)  
);

// Connection needs to bypass MAR if R_EN or W_EN is high at the same time that MAR_in is high
assign REG_OUT_MAR = (MAR_in & (r_en | w_en)) ? DATA : REG_OUT_FROM_MAR;

endmodule