module ClockDivider(input logic Clk50, 
					input logic [31:0] Compare, 
					input logic [31:0] Period, 
					input logic Reset, 
					output logic Output);
	logic [31:0] count;
	initial begin
		count <= '0;
	end
	always_ff @ (posedge Clk50) begin
		count <= count + 8'h01;
		if(count == 0) begin
			Output <= 1'b1;
		end
		else if(count >= Period) begin
			count <= '0;
		end
		else if(count == Compare) begin
			Output <= 1'b0;
		end
	end
endmodule 