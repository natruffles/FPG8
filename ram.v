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
    input [ADDR_WIDTH - 1:0] addr,
    inout [MEM_WIDTH - 1:0] MDR_RAM_connect,
    input [MEM_WIDTH - 1:0] write_data,
    output [15:0] RAM_REG_OUT
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
    .addr(),
    .MDR_RAM_connect(),
    .write_data()
);
*/

// number of bits needed for address based on the number of mem addresses
localparam ADDR_WIDTH = $clog2(MEM_DEPTH);

// declare the memory
reg [MEM_WIDTH - 1:0] mem [0:MEM_DEPTH - 1];

// reading and writing from memory block
always @ (posedge clk) begin
    if (w_en) begin
        mem[addr] <= write_data;
    end
end

assign MDR_RAM_connect = (r_en)? mem[addr] : 16'bZZZZZZZZZZZZZZZZ;

// initialize memory from file if available
initial if (INIT_FILE) begin
    $readmemb(INIT_FILE, mem);
end

assign RAM_REG_OUT = mem[253];

endmodule