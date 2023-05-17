module register_top (
    output [4:0] led,
    input b1, b2, b3, b4
);

wire one_shot_clock;
wire reset = ~b1;
wire latch = ~b2;
wire enable = ~b3;

/*
// instantiation template 
register register_inst0 (
    .clk(one_shot_clock),
    .reset(reset),
    .DATA(),
    .REG_OUT(),  
    .latch(latch), 
    .enable(enable)  
);
*/

assign led = 5'b11111;

endmodule