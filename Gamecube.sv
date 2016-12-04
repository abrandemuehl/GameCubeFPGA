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
	logic poll;
	ClockDivider div0(.Clk50(CLOCK_50), .Compare(32'd24), .Period(32'd49), .Reset('0), .Output(ioClk));
	ClockDivider div2(.Clk50(CLOCK_50), .Compare(32'd50), .Period(32'd300000), .Reset('0), .Output(poll));

	assign EXT_IO[0] = ioClk;
	logic Reset;
	logic Poll;
	logic Rumble;
	logic START;
	logic Y;
	logic X;
	logic B;
	logic A;
	logic L;
	logic R;
	logic Z;
	logic dUP;
	logic dDOWN;
	logic dRIGHT;
	logic dLEFT;
	logic [7:0] joyX;
	logic [7:0] joyY;
	logic [7:0] cstickX;
	logic [7:0] cstickY;
	logic [7:0] lButton;
	logic [7:0] rButton;
	initial begin
		Reset = '0;
		Rumble = '1;
		Poll = '0;
	end
	GameCubeIO gc0(.*, .usClock(ioClk), .Reset(~KEY[0]), .Poll(poll), .Rumble(Rumble), .GPIO(EXT_IO[3]), .extra(EXT_IO[2]));

endmodule
