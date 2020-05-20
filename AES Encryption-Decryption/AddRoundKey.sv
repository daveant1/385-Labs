module AddRoundKey(
	input logic [127:0] in,
	input logic [127:0] RoundKey, 
	output logic [127:0] out
	);
	
always_comb
begin
	out = in ^ RoundKey;
end
endmodule
