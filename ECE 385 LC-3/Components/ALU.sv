module ALU(
	input logic [15:0] A, B,
	input logic [1:0] ALUK,
	output logic [15:0] ALUout);
	
	always_comb
	begin
		case (ALUK)
			2'b00:  ALUout = A + B;
			
			2'b01:  ALUout = A & B;
			
			2'b10:  ALUout = ~A;
			
			2'b11: ALUout = A;
		endcase
	end
	
endmodule
	
	