module GameCubeIO(input logic usClock,
						input logic Reset,
						input logic Poll,
						input logic Rumble,
						inout GPIO,
						inout extra,
						output logic [17:0] LEDR,
						output logic [8:0] LEDG,
						output logic START,
						output logic Y,
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
						output logic [7:0] rButton);
	logic [0:24] pollCmd = 24'b010000000000001100000011;
	logic [0:8] probeCmd = 9'b000000001;
	logic [0:24] probeResp = 25'b0000100100000000001000111;
	enum logic [4:0] {RESET, PROBE, PROBE_RECV, WAIT, POLL, POLL_RECV, TRANSITION, SEND0, SEND1, SEND2, RECV0, RECV1, RECV2} state, next_state, command;
	logic [7:0] counter;
	logic to_send;
	logic connected;
	logic send;
	logic [0:63] poll_response;
	logic [0:24] probe_response;
	logic received;

	logic GPIO_out;
	assign GPIO = send ? GPIO_out : 1'bz;
	assign START = poll_response[3];
	assign Y = poll_response[4];
	assign X = poll_response[5];
	assign B = poll_response[6];
	assign A = poll_response[7];
	assign L = poll_response[9];
	assign R = poll_response[10];
	assign Z = poll_response[11];
	assign dUP = poll_response[12];
	assign dDOWN = poll_response[13];
	assign dRIGHT = poll_response[14];
	assign dLEFT = poll_response[15];
	assign joyX = poll_response[16:23];
	assign joyY = poll_response[24:31];
	assign cstickX = poll_response[32:39];
	assign cstickY = poll_response[40:47];
	assign lButton = poll_response[48:55];
	assign rButton = poll_response[56:63];
	assign LEDR[7:0] = rButton;
	assign LEDR[17] = START;
	assign LEDR[16] = Y;
	assign LEDR[15] = X;
	assign LEDR[14] = B;
	assign LEDR[13] = A;
	assign LEDR[12] = L;
	assign LEDR[11] = R;
	assign LEDR[10] = Z;
	
	initial begin
		counter <= '0;
		state <= PROBE;
		command <= PROBE;
		connected <= '0;
	end
	assign extra = Poll;
	always_ff @ (posedge usClock) begin
		if(Reset) begin
			state <= RESET;
			counter <= '0;
			connected <= '0;
		end else if(state == WAIT && Poll == 1'b1) begin
			state <= POLL;
		end else begin
			if(state == PROBE || state == POLL || state == PROBE_RECV || state == POLL_RECV) begin
				command <= state;
			end
			// You would think that the counter shouldn't be incremented in the first round
			// but it doesn't work if it isn't
			// Probably because SEND2 relies on the counter value
			if(state == PROBE || state == POLL || state == TRANSITION || state == PROBE_RECV || state == POLL_RECV) begin
				counter <= counter + 8'd1;
			end
			if(command == POLL_RECV && state == RECV2) begin
				poll_response[counter] = received;
			end
			if(command == PROBE_RECV && state == RECV2) begin
				probe_response[counter] = received;
			end
			if(counter == 8'd9 && next_state == PROBE) begin
				// Done sending a probe
				state <= TRANSITION;
				command <= PROBE_RECV;
				counter <= 0;
			end else if(counter == 8'd25 && next_state == POLL) begin
				// Done with message sending
				state <= TRANSITION;
				command <= POLL_RECV;
				counter <= 0;
			end else if(state == POLL_RECV && counter == 8'd64) begin
				state <= WAIT;
				counter <= 0;
			end else if(state == PROBE_RECV && counter == 8'd25) begin
				state <= WAIT;
				counter <= 0;
			end else if(state == TRANSITION && counter == 8'd4) begin
				state <= command;
				counter <= 0;
			end else state <= next_state;
		end
	end

	always_comb begin
		next_state = state;
		to_send = 1'b1;
		case(state)
			RESET: 		next_state = POLL;
			WAIT: ;
			POLL:      	next_state = SEND0;
			POLL_RECV: 	next_state = RECV0;
			PROBE: 		next_state = SEND0;
			PROBE_RECV: next_state = RECV0;
			TRANSITION: ;
			SEND0: 		next_state = SEND1;
			SEND1: 		next_state = SEND2;
			SEND2: 		next_state = command;
			RECV0: 		next_state = RECV1;
			RECV1: 		next_state = RECV2;
			RECV2: 		next_state = command;
		endcase
	end
	// Signalling logic
	always_comb begin
		send = 1'b0;
		received = 1'b0;
		GPIO_out = 1'b1;
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
				else GPIO_out = '1;
				send = 1'b1;
			end
			SEND2: begin
				if(command == PROBE) GPIO_out = probeCmd[counter];
				else if(command == POLL) GPIO_out = pollCmd[counter];
				else GPIO_out = '1;
				send = 1'b1;
			end
			POLL_RECV: begin
			end
			PROBE_RECV: begin
			end
			RECV0: begin
				// Always low
			end
			RECV1: begin
				received = GPIO;
			end
			RECV2: begin
				received = GPIO;
			end
			TRANSITION: begin
			end
		endcase
	end
endmodule

