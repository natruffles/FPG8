// uart communication state machine
// adapted from here: https://github.com/cyrozap/osdvu

module uart (
    input clk, // 12 MHz clock, not divided
	input reset,
    input uart_in_and_send,
	input uart_out,
    input uart_receive,
    input rx, // Incoming serial line
    output reg tx, // Outgoing serial line
    output reg uart_done, // to control unit to signal sending/receiving is done
    inout [15:0] DATA
);

// instantiation template
/*
uart uart_inst0 (
    .clk(),
	.reset(),
    .uart_in_and_send(),
	.uart_out(),
    .uart_receive(),
    .rx(),
    .tx(),
    .uart_done(),
    .DATA()
);
*/



assign DATA = (uart_out) ? bytes : 16'bZZZZZZZZZZZZZZZZ;

reg [15:0] bytes; // Bytes to transmit/receive

parameter CLOCK_DIVIDE = 26; // clock rate (12Mhz) / (baud rate (115200) * 4)

// States for the state machine.
// These are just constants, not parameters to override.
parameter IDLE = 0;
parameter RX_IDLE = 1;
parameter RX_CHECK_START = 2;
parameter RX_READ_BITS = 3;
parameter RX_CHECK_STOP = 4;
parameter RX_DELAY_RESTART = 5;
parameter RX_ERROR = 6;
parameter RX_RECEIVED = 7;
parameter TX_IDLE = 8;
parameter TX_SENDING = 9;
parameter TX_DELAY_RESTART = 10;

// is high if sending/receiving most significant byte [15:8]
// is low if sending/receiving least significant byte [7:0]
reg byte_significance;

reg [4:0] clk_divider;
reg [5:0] countdown;
reg [3:0] bits_remaining;
reg [3:0] state;
reg [7:0] data;

always @(posedge clk) begin
	if (reset) begin
		state = IDLE;
        tx = 1;
        byte_significance = 1;
        clk_divider = CLOCK_DIVIDE;
        countdown = 0;
        bytes = 16'b0000000000000000;
        bits_remaining = 0;
        data = 8'b00000000;
        uart_done = 0;
	end
	
	// The clk_divider counter counts down from
	// the CLOCK_DIVIDE constant. Whenever it
	// reaches 0, 1/16 of the bit period has elapsed.
    // Countdown timers for the receiving and transmitting
	// state machines are decremented.
	clk_divider = clk_divider - 1;
	if (!clk_divider) begin
		clk_divider = CLOCK_DIVIDE;
		countdown = countdown - 1;
	end
	
	// Receive state machine
	case (state)
        IDLE: begin
            tx = 1;
			uart_done = 0;
			byte_significance = 1;
            if (uart_in_and_send) begin
                bytes = DATA;
                state = TX_IDLE;
            end else if (uart_receive) begin
                state = RX_IDLE;
            end
        end

		RX_IDLE: begin
			// A low pulse on the receive line indicates the
			// start of data.
			if (!rx) begin
				// Wait half the period - should resume in the
				// middle of this first pulse.
				clk_divider = CLOCK_DIVIDE;
				countdown = 2;
				state = RX_CHECK_START;
			end
		end
		RX_CHECK_START: begin
			if (!countdown) begin
				// Check the pulse is still there
				if (!rx) begin
					// Pulse still there - good
					// Wait the bit period to resume half-way
					// through the first bit.
					countdown = 4;
					bits_remaining = 8;
					state = RX_READ_BITS;
				end else begin
					// Pulse lasted less than half the period -
					// not a valid transmission.
					state = RX_ERROR;
				end
			end
		end
		RX_READ_BITS: begin
			if (!countdown) begin
				// Should be half-way through a bit pulse here.
				// Read this bit in, wait for the next if we
				// have more to get.
				data = {rx, data[7:1]};
				countdown = 4;
				bits_remaining = bits_remaining - 1;
				state = bits_remaining ? RX_READ_BITS : RX_CHECK_STOP;
			end
		end
		RX_CHECK_STOP: begin
			if (!countdown) begin
				// Should resume half-way through the stop bit
				// This should be high - if not, reject the
				// transmission and signal an error.
				state = rx ? RX_RECEIVED : RX_ERROR;
			end
		end
		RX_DELAY_RESTART: begin
			// Waits a set number of cycles before accepting
			// another transmission.
			state = countdown ? RX_DELAY_RESTART : RX_IDLE;
		end
		RX_ERROR: begin
			// There was an error receiving.
			// waits 2 bit periods before accepting another
			// transmission.
			countdown = 8;
			state = RX_DELAY_RESTART;
		end
		RX_RECEIVED: begin
			// Successfully received a byte.
			// Raises the received flag for one clock
			// cycle while in this state.
            if (byte_significance) begin
                bytes[15:8] = data;
            end else begin
                bytes[7:0] = data;
				uart_done = 1;
            end
            byte_significance = ~byte_significance;
            state = (byte_significance) ? IDLE : RX_IDLE;
		end
	
		TX_IDLE: begin
            if (byte_significance) begin
                data = bytes[15:8];
            end else begin
                data = bytes[7:0];
            end 
            // Send the initial, low pulse of 1 bit period
            // to signal the start, followed by the data
            clk_divider = CLOCK_DIVIDE;
            countdown = 4;
            tx = 0;
            bits_remaining = 8;
            state = TX_SENDING;
		end
		TX_SENDING: begin
			if (!countdown) begin
				if (bits_remaining) begin
					bits_remaining = bits_remaining - 1;
					tx = data[0];
					data = {1'b0, data[7:1]};
					countdown = 4;
					state = TX_SENDING;
				end else begin
					// Set delay to send out 2 stop bits.
					tx = 1;
					countdown = 8;
                    byte_significance = ~byte_significance;
					state = TX_DELAY_RESTART;
				end
			end
		end
		TX_DELAY_RESTART: begin
			// Wait until countdown reaches the end before
			// we send another transmission. This covers the
			// "stop bit" delay.
			if (byte_significance & ~countdown) uart_done = 1;
			state = (countdown) ? TX_DELAY_RESTART : 
                    (byte_significance) ? IDLE :
                    TX_IDLE;
		end
	endcase
end

endmodule
