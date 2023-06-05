// taken from Shawn Hymel's tutorial series:
// https://github.com/ShawnHymel/introduction-to-fpga/blob/main/08-memory/solution-sequencer/memory.v

module ram #(
    parameter MEM_WIDTH = 16,
    parameter MEM_DEPTH = 256,
    parameter INIT_FILE = "" // null by default
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
ram #(   
    .MEM_WIDTH(), 
    .MEM_DEPTH(), 
    .INIT_FILE()
) ram_inst0 (
    .clk(),
    .w_en(),
    .r_en(),
    .w_addr(),
    .r_addr(),
    .w_data(),
    .r_data()
);
*/

// number of bits needed for address based on the number of mem addresses
localparam ADDR_WIDTH = $clog2(MEM_DEPTH);

// declare the memory
reg [MEM_WIDTH - 1:0] mem [0:MEM_DEPTH - 1];

// reading and writing from memory block
always @ (posedge clk) begin
    if (w_en) begin
        mem[w_addr] <= w_data;
    end
    if (r_en) begin
        r_data <= mem[r_addr];
    end
end

// initialize memory from file if available
initial if (INIT_FILE) begin
    $readmemh(INIT_FILE, mem);
end

endmodule