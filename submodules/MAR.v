module MAR (
    input clk, // data read/written on positive clock edges
    input reset, // reset all registers to a certain value
    inout [15:0] DATA,  // in and out from bus line
    output [15:0] REG_OUT_MAR,  // for debugging, to RAM
    input MAR_in
);

// instantiation template 
/*
MAR MAR_inst0 (
    .clk(),
    .reset(), 
    .DATA(), 
    .REG_OUT_MAR(),
    .MAR_in()
);
*/

register MAR_reg (
    .clk(clk),
    .reset(reset),
    .DATA(DATA),
    .REG_OUT(REG_OUT_MAR),  
    .latch(MAR_in), 
    .enable(1'b0)  
);

endmodule