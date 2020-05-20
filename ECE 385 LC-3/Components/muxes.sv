module muxs1		 //A variable width mux with 2-bit select
	#(parameter width = 16)
	(input logic [width-1:0] D0, D1,
	input logic Sel,
	output logic [width-1:0] Dout);
	
always_comb
begin
	case (Sel)
	1'b0: Dout = D0;
	1'b1: Dout = D1;
	default:;
	endcase
end
endmodule



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
	default:;
	endcase
end
endmodule



module trimux( 				//tristate mux for outputting to data bus
	input logic [15:0] D0, D1, D2, D3,
	input logic [3:0] Sel,
	output logic [15:0] Dout
	);
	
	always_comb
	begin
		case (Sel)
		4'b1000: Dout = D0;
		4'b0100: Dout = D1;
		4'b0010: Dout = D2;
		4'b0001: Dout = D3;
		default: Dout = 1'bx;
		endcase
	end
endmodule

