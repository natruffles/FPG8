// taken from Shawn Hymel's tutorial series:
// https://github.com/ShawnHymel/introduction-to-fpga/blob/main/08-memory/solution-sequencer/memory.v

// Updated version to make sure that block ram is inferred by yosys
module ram #(
    parameter INIT_FILE = ""
) (
    input clk,
    input w_en,
    input r_en,
    input [11:0] addr,
    input [15:0] w_data,
    output reg [15:0] r_data
);

// initialization template
/*
ram #(   
    .INIT_FILE()
) ram_inst0 (
    .clk(),
    .w_en(),
    .r_en(),
    .addr(),
    .w_data(),
    .r_data(),
);
*/

// Declare memory
reg [15:0] mem [0:4095];

// Interact with the memory block
always @(posedge clk) begin
    if (w_en) begin
        mem[{{4{addr[11]}}, addr[11:0]}] <= w_data;
    end else if (r_en) begin
        r_data <= mem[{{4{addr[11]}}, addr[11:0]}];
    end
end

//assign MDR_RAM_connect = (r_en) ? mem[r_addr] : 16'bZZZZZZZZZZZZZZZZ;

// Initialization (if available)
initial if (INIT_FILE) begin
    $readmemb(INIT_FILE, mem);
end
    
endmodule