module muxs2		 //A variable width mux with 2-bit select
	#(parameter width = 16)
	(input logic [width-1:0] D0, D1, D2, D3,
	input logic [1:0] Sel,
	output logic [width-1:0] Dout);
	
always_comb
begin
	case (Sel)
	2'b00: Dout = D0;
	2'b01: Dout = D1;
	2'b10: Dout = D2;
	2'b11: Dout = D3;
	default: Dout = 0;
	endcase
end
endmodule

module muxs3		 //A variable width mux with 2-bit select
	#(parameter width = 16)
	(input logic [width-1:0] D0, D1, D2, D3, D4,
	input logic [2:0] Sel,
	output logic [width-1:0] Dout);
	
always_comb
begin
	case (Sel)
	3'b000: Dout = D0;
	3'b001: Dout = D1;
	3'b010: Dout = D2;
	3'b011: Dout = D3;
	3'b100: Dout = D4;
	default: Dout = 0;
	endcase
end
endmodule

module array(
	input logic CLK,
	input logic [31:0] Mix_int,
	input logic [1:0] Array_select,
	output logic [3:0][31:0] Mix_array
	);

always_ff @ (posedge CLK)
begin
	case(Array_select)
	2'b00: 
	begin
		Mix_array[0] <= Mix_int;
	end
	2'b01: 
	begin
		Mix_array[1] <= Mix_int;
	end
	2'b10: 
	begin
		Mix_array[2] <= Mix_int;
	end
	2'b11: 
	begin
		Mix_array[3] <= Mix_int;
	end
	default: ;
	endcase
end
endmodule

module reg_128  //A 128-bit Register
	(input logic Reset, Clk, Load,
	input logic [127:0] Din,
	output logic[127:0] Dout
	);
	
	always_ff @ (posedge Clk)
	begin	
		if (Reset)
			Dout <= 128'h0;
		else if (Load)
			Dout <= Din;
	end
endmodule
