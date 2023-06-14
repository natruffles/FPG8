module control_unit (
    input clk,
    input reset,
    input [3:0] opcode,
    input [2:0] PSW_bits,
    input [2:0] IR_Rs2,
    input timeout,
    output [4:0] REG_OUT_CONTROL_UNIT,
    output [2:0] ALU_control,
    output con_ROM_out,
    output GPR_in,
    output GPR_out,
    output [2:0] GPR_select,
    output IR_in,
    output MAR_in,
    output MDR_in,
    output MDR_out,
    output PSW_in,
    output PSW_out,
    output RAM_enable_read,
    output RAM_enable_write,
    output timer_in,
    output Y_in,
    output Y_out,
    output Y_offset_in,
    output Y_shift_left,
    output Y_shift_right,
    output Z_in,
    output Z_out
);

// initialization template
/*
do last
*/

// all states labelled
localparam STATE_F1     = 5'd0;
localparam STATE_F2     = 5'd1;
localparam STATE_F3     = 5'd2;
localparam STATE_E11_1       = 5'd3;
localparam STATE_E12_1       = 5'd4;
localparam STATE_E12_2       = 5'd5;
localparam STATE_E13_1       = 5'd6;
localparam STATE_E6_1       = 5'd7;
localparam STATE_E7_1       = 5'd8;
localparam STATE_E7_2       = 5'd9;
localparam STATE_E8_2       = 5'd10;
localparam STATE_E14_2       = 5'd11;
localparam STATE_E15_2       = 5'd12;
localparam STATE_E0_1       = 5'd13;
localparam STATE_E0_2       = 5'd14;
localparam STATE_E1_2       = 5'd15;
localparam STATE_E2_2       = 5'd16;
localparam STATE_E3_2       = 5'd17;
localparam STATE_E4_1       = 5'd18;
localparam STATE_D5A       = 5'd19;
localparam STATE_D5B       = 5'd20;
localparam STATE_E0_3       = 5'd21;
localparam STATE_PCV1       = 5'd22;
localparam STATE_T1       = 5'd23;
localparam STATE_PCV2       = 5'd24;
localparam STATE_PCV3       = 5'd25;
localparam STATE_PCV4       = 5'd26;
localparam STATE_PCV5       = 5'd27;
localparam STATE_PCV6       = 5'd28;
localparam STATE_PCV7       = 5'd29;
localparam STATE_PCV8       = 5'd30;

// used to store the current state of the control unit
reg [4:0] state;

// inbetween wires that will be combined into GPR_select and ALU_select
wire GPR_select_0; wire GPR_select_PC;
wire GPR_select_Rd_1; wire GPR_select_Rd_2; 
wire GPR_select_Rs1; wire GPR_select_Rs2; 
wire ALU_add; wire ALU_and;
wire ALU_inc_Y_2; wire ALU_invert_bus_input;
wire ALU_or; wire ALU_pass_Y;
wire ALU_subtract;

// give PSW bits readable names
wire CC_N; wire CC_Z; wire privileged;
assign CC_Z = PSW_bits[0];
assign CC_N = PSW_bits[1];
assign privileged = PSW_bits[2];

always @ (posedge clk or posedge reset) begin
    // On reset, return to idle state
    if (reset == 1'b1) begin
        state <= STATE_F1;
        
    // Define the state transitions
    end else begin
        case (state)
            STATE_F1: state <= STATE_F2;

            STATE_F2: state <= STATE_F3;

            STATE_F3: begin
                if (opcode == 11 || opcode == 9 && CC_N || opcode == 10 && CC_Z) begin
                    state <= STATE_E11_1;
                end else if (opcode == 12) begin
                    state <= STATE_E12_1;
                end else if (opcode == 13) begin
                    state <= STATE_E13_1;
                end else if (opcode == 6) begin
                    state <= STATE_E6_1;
                end else if (((opcode == 14 || opcode == 15) && privileged) || opcode == 7 || opcode == 8) begin
                    state <= STATE_E7_1;
                end else if (opcode >= 0 && opcode <= 3) begin
                    state <= STATE_E0_1;
                end else if (opcode == 4) begin
                    state <= STATE_E4_1;
                end else if (opcode == 5 && IR_Rs2 == 0) begin
                    state <= STATE_D5A;
                end else if (opcode == 5 && IR_Rs2 != 0) begin
                    state <= STATE_D5B;
                end else if ((opcode == 9 && !CC_N) || (opcode == 10 && !CC_Z)) begin
                    if (privileged || (!privileged && !timeout)) begin
                        state <= STATE_F1;
                    end else begin
                        state <= STATE_T1;
                    end
                end else begin
                    state <= STATE_PCV1;
                end
            end
            
            STATE_E11_1,
            STATE_E6_1,
            STATE_E7_2,
            STATE_E8_2,
            STATE_E14_2,
            STATE_E15_2,
            STATE_E0_3: begin
                if (privileged || (!privileged && !timeout)) begin
                        state <= STATE_F1;
                end else begin
                    state <= STATE_T1;
                end
            end

            STATE_E12_1: state <= STATE_E12_2;

            STATE_E12_2,
            STATE_E13_1: state <= STATE_E11_1;

            STATE_E7_1: begin
                if (opcode == 7) begin
                    state <= STATE_E7_2;
                end else if (opcode == 8) begin
                    state <= STATE_E8_2;
                end else if (opcode == 14) begin
                    state <= STATE_E14_2;
                end else begin // opcode == 15
                    state <= STATE_E15_2;
                end 
            end

            STATE_E0_1: begin
                if (opcode == 0) begin
                    state <= STATE_E0_2;
                end else if (opcode == 1) begin
                    state <= STATE_E1_2;
                end else if (opcode == 2) begin
                    state <= STATE_E2_2;
                end else begin // opcode == 3
                    state <= STATE_E3_2;
                end 
            end

            STATE_E0_2,
            STATE_E1_2,
            STATE_E2_2,
            STATE_E3_2,
            STATE_E4_1,
            STATE_D5A,
            STATE_D5B: state <= STATE_E0_3;

            STATE_PCV1,
            STATE_T1: state <= STATE_PCV2;
            STATE_PCV2: state <= STATE_PCV3;
            STATE_PCV3: state <= STATE_PCV4;
            STATE_PCV4: state <= STATE_PCV5;
            STATE_PCV5: state <= STATE_PCV6;
            STATE_PCV6: state <= STATE_PCV7;
            STATE_PCV7: state <= STATE_PCV8;
            STATE_PCV8: state <= STATE_F1;

            
            // Go to initial fetch if in unknown state
            default: state <= STATE_F1;
        endcase
    end
end

// assign control signals 
assign ALU_add = (state == STATE_F3 || state == STATE_E13_1 || state == STATE_E0_2);
assign ALU_and = (state == STATE_E2_2);
assign ALU_inc_Y_2 = (state == STATE_F1 || state == STATE_PCV2 || state == STATE_PCV4 || state == STATE_PCV6);
assign ALU_invert_bus_input = (state == STATE_E4_1);
assign ALU_or = (state == STATE_E3_2);
assign ALU_pass_Y = (state == STATE_D5A || state == STATE_D5B);
assign ALU_subtract = (state == STATE_E1_2);
assign con_ROM_out = (state == STATE_T1);
assign GPR_in = (state == STATE_F3 || state == STATE_E11_1 || state == STATE_E12_2 || state == STATE_E6_1 || state == STATE_E7_2 || state == STATE_PCV8 || state == STATE_E0_3);
assign GPR_out = (state == STATE_F1 || state == STATE_E12_1 || state == STATE_E13_1 || state == STATE_E8_2 || state == STATE_PCV1 || state == STATE_PCV4 || state == STATE_E0_1 || state == STATE_E0_2 || state == STATE_E1_2 || state == STATE_E2_2 || state == STATE_E3_2 || state == STATE_E4_1 || state == STATE_D5A || state == STATE_D5B);
assign GPR_select_0 = (state == STATE_PCV1);
assign GPR_select_PC = (state == STATE_F1 || state == STATE_F3 || state == STATE_E11_1 || state == STATE_E12_1 || state == STATE_PCV4 || state == STATE_PCV8);
assign GPR_select_Rd_1 = (state == STATE_E0_3);
assign GPR_select_Rd_2 = (state == STATE_E12_2 || state == STATE_E13_1 || state == STATE_E6_1 || state == STATE_E7_2 || state == STATE_E8_2);
assign GPR_select_Rs1 = (state == STATE_E0_2 || state == STATE_E1_2 || state == STATE_E2_2 || state == STATE_E3_2 || state == STATE_E4_1 || state == STATE_D5A || state == STATE_D5B);
assign GPR_select_Rs2 = (state == STATE_E0_1);
assign IR_in = (state == STATE_F2);
assign MAR_in = (state == STATE_F1 || state == STATE_E7_1 || state == STATE_PCV1 || state == STATE_PCV3 || state == STATE_PCV5 || state == STATE_PCV7 || state == STATE_T1);
assign MDR_in = (state == STATE_E8_2 || state == STATE_PCV2 || state == STATE_PCV4);
assign MDR_out = (state == STATE_F2 || state == STATE_E7_2 || state == STATE_E14_2 || state == STATE_E15_2 || state == STATE_PCV6 || state == STATE_PCV8);
assign PSW_in = (state == STATE_E15_2 || state == STATE_PCV6);
assign PSW_out = (state == STATE_PCV2);
assign RAM_enable_read = (state == STATE_F1 || state == STATE_E7_1 || state == STATE_PCV5 || state == STATE_PCV7);
assign RAM_enable_write = (state == STATE_E8_2 || state == STATE_PCV2 || state == STATE_PCV4);
assign timer_in = (state == STATE_E14_2);
assign Y_in = (state == STATE_F1 || state == STATE_E12_1 || state == STATE_PCV1 || state == STATE_PCV3 || state == STATE_PCV5 || state == STATE_T1 || state == STATE_E0_1 || state == STATE_D5A || state == STATE_D5B);
assign Y_out = (state == STATE_E12_2 || state == STATE_E6_1);
assign Y_offset_in = (state == STATE_F2);
assign Y_shift_left = (state == STATE_E0_2 || state == STATE_E1_2 || state == STATE_E2_2 || state == STATE_E3_2 || state == STATE_D5A);
assign Y_shift_right = (state == STATE_D5B);
assign Z_in = (state == STATE_F1 || state == STATE_F3 || state == STATE_E13_1 || state == STATE_PCV2 || state == STATE_PCV4 || state == STATE_PCV6 || state == STATE_E0_2 || state == STATE_E1_2 || state == STATE_E2_2 || state == STATE_E3_2 || state == STATE_E4_1 || state == STATE_D5A || state == STATE_D5B);
assign Z_out = (state == STATE_F3 || state == STATE_E11_1 || state == STATE_PCV3 || state == STATE_PCV5 || state == STATE_PCV7 || state == STATE_E0_3);

// combine ALU and GPR assignments, priority encode them
assign ALU_control[2] = (ALU_or | ALU_pass_Y | ALU_subtract);
assign ALU_control[1] = (ALU_inc_Y_2 | ALU_invert_bus_input | ALU_subtract);
assign ALU_control[0] = (ALU_and | ALU_invert_bus_input | ALU_pass_Y);
assign GPR_select[2] = (GPR_select_Rs1 | GPR_select_Rs2);
assign GPR_select[1] = (GPR_select_Rd_1 | GPR_select_Rd_2);
assign GPR_select[0] = (GPR_select_PC | GPR_select_Rd_2 | GPR_select_Rs2);

endmodule