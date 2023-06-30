module GPR (
    input clk, // data read/written on positive clock edges
    input reset, // reset all registers to a certain value
    inout [15:0] DATA,  // in and out from bus line
    output [15:0] REG_OUT_0,  // for debugging
    output [15:0] REG_OUT_1,
    output [15:0] REG_OUT_2,
    output [15:0] REG_OUT_3,
    output [15:0] REG_OUT_4,
    output [15:0] REG_OUT_5,
    output [15:0] REG_OUT_6,
    output [15:0] REG_OUT_7,
    input GPR_in, // allows data input into register
    input GPR_out,  // allows data output onto bus
    input [2:0] GPR_select,
    input [2:0] Rd_1,
    input [2:0] Rd_2,
    input [2:0] Rs_1,
    input [2:0] Rs_2
);

// instantiation template 
/*
GPR GPR_inst0 (
    .clk(), 
    .reset(),
    .DATA(), 
    .REG_OUT_0(),  
    .REG_OUT_1(),  
    .REG_OUT_2(),  
    .REG_OUT_3(),  
    .REG_OUT_4(),  
    .REG_OUT_5(),  
    .REG_OUT_6(),  
    .REG_OUT_7(),  
    .GPR_in(),
    .GPR_out(),
    .GPR_select(),
    .Rd_1(),
    .Rd_2(),
    .Rs_1(),
    .Rs_2()
);
*/

reg [7:0] GPR_latch_select;
reg [7:0] GPR_enable_select;
reg [2:0] select_address;

// GPR[0] is special in that it always outputs 0 (garbage disposal)
register GPR_0 (
    .clk(clk),
    .reset(1'b1),
    .DATA(DATA),
    .REG_OUT(REG_OUT_0),  
    .latch(GPR_latch_select[0]), 
    .enable(GPR_enable_select[0])  
);

// GPR[1] thru GPR[7] are normal
register GPR_1 (
    .clk(clk),
    .reset(reset),
    .DATA(DATA),
    .REG_OUT(REG_OUT_1),  
    .latch(GPR_latch_select[1]), 
    .enable(GPR_enable_select[1])  
);
register GPR_2 (
    .clk(clk),
    .reset(reset),
    .DATA(DATA),
    .REG_OUT(REG_OUT_2),  
    .latch(GPR_latch_select[2]), 
    .enable(GPR_enable_select[2])  
);
register GPR_3 (
    .clk(clk),
    .reset(reset),
    .DATA(DATA),
    .REG_OUT(REG_OUT_3),  
    .latch(GPR_latch_select[3]), 
    .enable(GPR_enable_select[3])  
);
register GPR_4 (
    .clk(clk),
    .reset(reset),
    .DATA(DATA),
    .REG_OUT(REG_OUT_4),  
    .latch(GPR_latch_select[4]), 
    .enable(GPR_enable_select[4])  
);
register GPR_5 (
    .clk(clk),
    .reset(reset),
    .DATA(DATA),
    .REG_OUT(REG_OUT_5),  
    .latch(GPR_latch_select[5]), 
    .enable(GPR_enable_select[5])  
);
register GPR_6 (
    .clk(clk),
    .reset(reset),
    .DATA(DATA),
    .REG_OUT(REG_OUT_6),  
    .latch(GPR_latch_select[6]), 
    .enable(GPR_enable_select[6])  
);
register GPR_7 (
    .clk(clk),
    .reset(reset),
    .DATA(DATA),
    .REG_OUT(REG_OUT_7),  
    .latch(GPR_latch_select[7]), 
    .enable(GPR_enable_select[7])  
);

// set which register is selected for input/output
always @( * ) begin
    case (GPR_select)
        3'b000 : select_address <= 3'b0;
        3'b001 : select_address <= 3'b111;
        3'b010 : select_address <= Rd_1;
        3'b011 : select_address <= Rd_2;
        3'b100 : select_address <= Rs_1;
        3'b101 : select_address <= Rs_2;
        3'b110 : select_address <= 3'b0;
        3'b111 : select_address <= 3'b0;
        default: select_address <= 3'b0;
    endcase
end

// enable latching/enabling of correct register in GPR
always @( * ) begin
    if (GPR_in & ~GPR_out) begin
        GPR_enable_select <= 8'b00000000;
        case (select_address)
            3'b000 : GPR_latch_select <= 8'b00000001;
            3'b001 : GPR_latch_select <= 8'b00000010;
            3'b010 : GPR_latch_select <= 8'b00000100;
            3'b011 : GPR_latch_select <= 8'b00001000;
            3'b100 : GPR_latch_select <= 8'b00010000;
            3'b101 : GPR_latch_select <= 8'b00100000;
            3'b110 : GPR_latch_select <= 8'b01000000;
            3'b111 : GPR_latch_select <= 8'b10000000;
            default: GPR_latch_select <= 8'b00000000;
        endcase
    end else if (~GPR_in & GPR_out) begin
        GPR_latch_select <= 8'b00000000;
        case (select_address)
            3'b000 : GPR_enable_select <= 8'b00000001;
            3'b001 : GPR_enable_select <= 8'b00000010;
            3'b010 : GPR_enable_select <= 8'b00000100;
            3'b011 : GPR_enable_select <= 8'b00001000;
            3'b100 : GPR_enable_select <= 8'b00010000;
            3'b101 : GPR_enable_select <= 8'b00100000;
            3'b110 : GPR_enable_select <= 8'b01000000;
            3'b111 : GPR_enable_select <= 8'b10000000;
            default: GPR_enable_select <= 8'b00000000;
        endcase
    end else begin
        GPR_enable_select <= 8'b00000000;
        GPR_latch_select <= 8'b00000000;
    end
end

endmodule