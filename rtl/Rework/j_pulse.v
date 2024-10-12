//`include "defs.v"

module j_pulse
(
	input [7:0] a,
	input [6:0] b,
	input stop,
	input clk,
	input resetl,
	output pulse,
	input sys_clk // Generated
);
wire [7:0] ab;
wire start;
reg pulse_ = 1'b0;
assign pulse = pulse_;

// DAC.NET (82) - ab[0-6] : en
// DAC.NET (83) - ab[7] : iv
assign ab[7:0] = ~(a[7:0] ^ {1'b1,b[6:0]}); //ab[7] = ~a[7];

// DAC.NET (84) - startl : nd8
// DAC.NET (85) - start : iv
assign start = (&ab[7:0]);

// DAC.NET (87) - pulse : fjk2
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;

	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			pulse_ <= 1'b0;
		end else begin
			if (~start & stop) begin
				pulse_ <= 1'b0;
			end else if (start & ~stop) begin
				pulse_ <= 1'b1;
			end else if (start & stop) begin
				pulse_ <= ~pulse;
			end
		end
	end
end
endmodule