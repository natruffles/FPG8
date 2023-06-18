module alu (
    input [15:0] bus,
    input [15:0] y_shifted,
    output reg [15:0] ALU_out,
    input [2:0] ALU_control
);

// instantiation template
/*
alu alu_inst0(
    .bus(),
    .y_shifted(),
    .ALU_out(),
    .ALU_control()
);
*/

always @( * ) begin
    case (ALU_control)
        // alu_add
        3'b000: begin
            ALU_out = bus + y_shifted;
        end
        // alu_and
        3'b001: begin
            ALU_out = bus & y_shifted;
        end
        // alu_inc_Y_1
        3'b010: begin
            ALU_out = y_shifted + 1;
        end
        // alu_invert_bus_input
        3'b011: begin
            ALU_out = ~bus;
        end
        // alu_or
        3'b100: begin
            ALU_out = bus | y_shifted;
        end
        // alu_pass_Y
        3'b101: begin
            ALU_out = y_shifted;
        end
        // alu_subtract
        3'b110: begin
            ALU_out = bus - y_shifted;
        end
        // alu_add_decrement, needed so that PC + IR.offset is correct, not +1 what it's supposed to be
        3'b111: begin
            ALU_out = bus + y_shifted - 1;
        end
        default: begin
            ALU_out = 16'b0;
        end
    endcase
end

endmodule