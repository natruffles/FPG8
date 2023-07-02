// consists of 2 registers in a primary/replica configuration

module Z (
    input clk,
    input reset,
    input [15:0] from_ALU,
    output [15:0] out_to_bus,
    input Z_in,
    input Z_out
);

// instantiation template 
/*
Z Z_inst0 (
    .clk(),
    .reset(),
    .from_ALU(),
    .out_to_bus(),
    .Z_in(),
    .Z_out()
);
*/

reg [15:0] Z1;
reg [15:0] Z2;

// register is either set by latch or reset by reset
always @(posedge clk) begin
    if (reset) begin
        Z1 <= 0;
        Z2 <= 0;
    end else if (Z_in) begin
        Z1 <= from_ALU;
    end 
    Z2 <= Z1;
end

//assign out_to_bus = (Z_out & ~Z_in)? Z1 : 
//                    (Z_out & Z_in)? Z2 :
//                    16'bZZZZZZZZZZZZZZZZ;

assign out_to_bus = (~Z_out)? 16'bZZZZZZZZZZZZZZZZ :
                    (~Z_in)? Z1 :
                    Z2;

endmodule