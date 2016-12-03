module GameCubeIO(input logic usClock,
						input logic Reset,
						input logic Poll,
						input logic Rumble,
						inout GPIO,
						output logic [17:0] LEDR,
						output logic [8:0] LEDG
						/*output logic Y,
						output logic X,
						output logic B,
						output logic A,
						output logic L,
						output logic R,
						output logic Z,
						output logic dUP,
						output logic dDOWN,
						output logic dRIGHT,
						output logic dLEFT,
						output logic [7:0] joyX,
						output logic [7:0] joyY,
						output logic [7:0] cstickX,
						output logic [7:0] cstickY,
						output logic [7:0] lButton,
						output logic [7:0] rButton*/);
	logic [0:24] pollCmd = 24'b010000000000001100000011;
	logic [0:8] probeCmd = 9'b000000001;
	logic [0:] probeResp = 'b0000100100000000001000111;
	enum logic [4:0] {RESET, PROBE, WAIT, POLL, GET_RESPONSE, SEND0, SEND1, SEND2, RECV0, RECV1, RECV2, RECV3} state, next_state, command;
	logic [7:0] counter;
	logic to_send;
	logic connected;
	logic send;
	logic [7:0] run_count;

	logic GPIO_out;
	assign GPIO = send ? GPIO_out : 1'bz;
	assign LEDR = command;
	assign LEDG = state;

	initial begin
		counter = 0;
		state = PROBE;
		command = PROBE;
		connected = '0;
	end

	always_ff @ (posedge usClock) begin
		if(Reset) begin
			state <= RESET;
			counter <= '0;
			connected <= '0;
		end else begin
			if(state == PROBE || state == POLL || state == GET_RESPONSE) begin
				command <= state;
			end
			if(state == SEND2) begin
				counter <= counter + 8'd1;
			end
			
			if(counter == 8'd9 && state == PROBE) begin
				// Done sending a probe
				state <= WAIT;
				counter <= 0;
			end else if(counter == 8'd25 && state == POLL) begin
				// Done with message sending
				state <= WAIT;
				counter <= 0;
			end else state <= next_state;
		end
	end

	always_comb begin
		next_state = state;
		to_send = 1'b1;
		case(state)
			RESET: next_state = PROBE;//PROBE;
			WAIT: begin
//				if(Poll) begin
//					next_state = POLL;
//				end
			end
			POLL: begin
				case(counter)
					8'd0, 8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8,
					8'd9, 8'd10, 8'd11, 8'd12, 8'd13, 8'd14, 8'd15, 8'd16, 8'd17,
					8'd18, 8'd19, 8'd20, 8'd21, 8'd22, 8'd23, 8'd24: begin
						next_state = SEND0;
					end
				endcase
			end
			PROBE: begin
				case(counter)
					8'd0, 8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9: begin
						next_state = SEND0;
					end
				endcase
			end
			SEND0: begin
				next_state = SEND1;
			end
			SEND1: begin
				next_state = SEND2;
			end
			SEND2: begin
				next_state = command;
			end
			GET_RESPONSE: begin
				next_state = RECV0;
			end
		endcase
	end
	// Signalling logic
	always_comb begin
		// GPIO_out = 1'b1;
		send = 1'b0;
		case(state)
			POLL: begin
				GPIO_out = 1'b1;
				send = 1'b1;
			end
			PROBE: begin
				GPIO_out = 1'b1;
				send = 1'b1;
			end
			SEND0: begin
				GPIO_out = 1'b0;
				send = 1'b1;
			end
			SEND1: begin
				if(command == PROBE) GPIO_out = probeCmd[counter];
				else if(command == POLL) GPIO_out = pollCmd[counter];
				else GPIO_out = '0;
				send = 1'b1;
			end
			SEND2: begin
				if(command == PROBE) GPIO_out = probeCmd[counter];
				else if(command == POLL) GPIO_out = pollCmd[counter];
				else GPIO_out = '0;
				send = 1'b1;
			end
			default: GPIO_out = 'z;
		endcase
	end
endmodule

