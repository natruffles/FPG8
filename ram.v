// taken from Shawn Hymel's tutorial series:
// https://github.com/ShawnHymel/introduction-to-fpga/blob/main/08-memory/solution-sequencer/memory.v

// Updated version to make sure that block ram is inferred by yosys
module ram #(
    parameter MEM_WIDTH = 16,
    parameter MEM_DEPTH = 256,
    parameter INIT_FILE = ""
) (
    input clk,
    input w_en,
    input r_en,
    input [ADDR_WIDTH - 1:0] w_addr,
    input [ADDR_WIDTH - 1:0] r_addr,
    input [MEM_WIDTH - 1:0] w_data,
    output reg [MEM_WIDTH - 1:0] r_data
);

// initialization template
/*
ram_new #(   
    .MEM_WIDTH(), 
    .MEM_DEPTH(), 
    .INIT_FILE()
) ram_new_inst0 (
    .clk(),
    .w_en(),
    .r_en(),
    .w_addr(),
    .r_addr(),
    .w_data(),
    .r_data(),
    .MDR_RAM_connect()
);
*/

// number of bits for address is logbase2(256) = 8 by default
localparam ADDR_WIDTH = $clog2(MEM_DEPTH);

// Declare memory
reg [MEM_WIDTH - 1:0] mem [0:MEM_DEPTH - 1];

// Interact with the memory block
always @(posedge clk) begin
    if (w_en) begin
        mem[w_addr] <= w_data;
    end else if (r_en) begin
        r_data <= mem[r_addr];
    end
end

//assign MDR_RAM_connect = (r_en) ? mem[r_addr] : 16'bZZZZZZZZZZZZZZZZ;

// Initialization (if available)
initial if (INIT_FILE) begin
    $readmemb(INIT_FILE, mem);
end
    
endmodule