module Gamecube(input logic CLOCK_50,
					 inout [35:0] GPIO,
					 inout [6:0] EXT_IO,
                input logic [17:0] SW,
					 input logic [3:0] KEY,
					 output logic [17:0] LEDR,
					 output logic [8:0] LEDG,
					 output logic gp);
					 
	assign gp = EXT_IO[3];// == 'z ? '1 : GPIO[26];

	logic ioClk;
	ClockDivider div0(.Clk50(CLOCK_50), .Compare(16'd24), .Period(16'd49), .Reset('0), .usClock(ioClk));

	//assign LEDR[0] = ioClk;
	//assign LEDR[1] = '1;
	assign EXT_IO[0] = ioClk;
	logic Reset;
	logic Poll;
	logic Rumble;
	initial begin
		Reset = '0;
		Rumble = '1;
		Poll = '0;
	end
	GameCubeIO gc0(.*, .usClock(ioClk), .Reset(~KEY[0]), .Poll('0), .Rumble(Rumble), .GPIO(EXT_IO[3]/*GPIO[26]*/));

endmodule
