module reg_16  //A variable width register
	#(parameter width = 16)
	(input logic Reset, Clk, Load,
	input logic [width-1:0] Din,
	output logic[width-1:0] Dout
	);
	
	always_ff @ (posedge Clk)
	begin	
		if (Reset)
			Dout <= 16'h0000;
		else if (Load)
			Dout <= Din;
	end
endmodule


module reg_file(           //module for register file
	input logic Reset, Clk, Load,
	input logic [2:0] SR1in, SR2in, DRin, 
	input logic [15:0] BUS,
	output logic [15:0] SR1out, SR2out);
	
	logic [7:0][15:0] VAL;
	
	always_ff @ (posedge Clk)
	begin
	
	if (Reset)  //clear all registers to 0
		begin
			VAL [0] <= 16'h0;
			VAL [1] <= 16'h0;
			VAL [2] <= 16'h0;
			VAL [3] <= 16'h0;
			VAL [4] <= 16'h0;
			VAL [5] <= 16'h0;
			VAL [6] <= 16'h0;
			VAL [7] <= 16'h0;
		end
	
	else if (Load)   //Load Destination register
		case (DRin)
			3'b000: VAL [0] <= BUS;
			3'b001: VAL [1] <= BUS;
			3'b010: VAL [2] <= BUS;
			3'b011: VAL [3] <= BUS;
			3'b100: VAL [4] <= BUS;
			3'b101: VAL [5] <= BUS;
			3'b110: VAL [6] <= BUS;
			3'b111: VAL [7] <= BUS;
			default:;
		endcase
	
	end
		
	always_comb
	begin
	
	case (SR1in)     //Select Source register 1
		3'b000: SR1out = VAL [0];
		3'b001: SR1out = VAL [1];
		3'b010: SR1out = VAL [2];
		3'b011: SR1out = VAL [3];
		3'b100: SR1out = VAL [4];
		3'b101: SR1out = VAL [5];
		3'b110: SR1out = VAL [6];
		3'b111: SR1out = VAL [7];
		default:;
	endcase
	
	case (SR2in)      //Select Source register 2
		3'b000: SR2out = VAL [0];
		3'b001: SR2out = VAL [1];
		3'b010: SR2out = VAL [2];
		3'b011: SR2out = VAL [3];
		3'b100: SR2out = VAL [4];
		3'b101: SR2out = VAL [5];
		3'b110: SR2out = VAL [6];
		3'b111: SR2out = VAL [7];
		default:;
	endcase
	
	end
endmodule

module reg_nzp(
	input logic [15:0] BUS,
	input logic [15:0] IR,
	input logic LD_CC, LD_BEN, Clk, Reset,
	output logic BEN
	);
	
	logic N, Z, P, BENint, newN, newZ, newP;
	
	always_ff @ (posedge Clk)
	begin
		if (Reset)
		 begin
		 N <= 1'b0;
		 Z <= 1'b0;
		 P <= 1'b0;
		 BEN <= 1'b0;
		 end
		else if(LD_CC)
		 begin
		 N <= newN;
		 Z <= newZ;
		 P <= newP;
		 end
		else if(LD_BEN)
		 BEN <= (IR[11] & N) | (IR[10] & Z) | (IR[9] & P);
	end
	
	always_comb
	begin
		if(BUS[15])
			begin
			newN = 1'b1;
			newZ = 1'b0;
			newP = 1'b0;
			end
		else if(BUS[15:0] == 16'h0)
			begin
			newN = 1'b0;
			newZ = 1'b1;
			newP = 1'b0;
			end
		else
			begin
			newN = 1'b0;
			newZ = 1'b0;
			newP = 1'b1;
			end
	end

endmodule
	
	 
		
	
