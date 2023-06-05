// testbench for GPR

`timescale 1 ns / 10 ps

module GPR_tb();

reg clk = 0;
reg rst = 0;

wire [15:0] reg_out_0;
wire [15:0] reg_out_1;
wire [15:0] reg_out_2;
wire [15:0] reg_out_3;
wire [15:0] reg_out_4;
wire [15:0] reg_out_5;
wire [15:0] reg_out_6;
wire [15:0] reg_out_7;
wire [15:0] reg_out_8;
reg [15:0] w_bus_reg = 16'b1010101010101010;;
wire [15:0] w_bus;
assign w_bus = w_bus_reg;
reg GPR_in = 0;
reg GPR_out = 0;
reg [2:0] GPR_select = 3'b000;
reg [2:0] Rd_1 = 3'b010;
reg [2:0] Rd_2 = 3'b010;
reg [2:0] Rs_1 = 3'b011;
reg [2:0] Rs_2 = 3'b100;

localparam DURATION = 10000; // 10 us simulation time

GPR uut (
    .clk(clk), 
    .reset(rst),
    .DATA(w_bus), 
    .REG_OUT_0(reg_out_0),  
    .REG_OUT_1(reg_out_1), 
    .REG_OUT_2(reg_out_2), 
    .REG_OUT_3(reg_out_3), 
    .REG_OUT_4(reg_out_4), 
    .REG_OUT_5(reg_out_5), 
    .REG_OUT_6(reg_out_6), 
    .REG_OUT_7(reg_out_7), 
    .GPR_in(GPR_in),
    .GPR_out(GPR_out),
    .GPR_select(GPR_select),
    .Rd_1(GPR_select),
    .Rd_2(GPR_select),
    .Rs_1(GPR_select),
    .Rs_2(GPR_select)
);

initial begin
    #10
    clk = 1'b1;
    rst = 1'b1;
    #1
    clk = 1'b0;
    rst = 1'b0;
    #10
    GPR_in = 1'b1;
    GPR_select = 3'b011;
    clk = 1'b1;
    #1
    clk = 1'b0;
    #10
    clk = 1'b1;
    #1
    clk = 1'b0;
end

initial begin
    $dumpfile("GPR_tb.vcd");
    $dumpvars(0, GPR_tb);
    #(DURATION);
    $display("Finished!");
    $finish;
end

endmodule
