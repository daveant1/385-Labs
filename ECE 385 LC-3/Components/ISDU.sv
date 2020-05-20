//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module ISDU (   input logic         Clk, 
									Reset,
									Run,
									Continue,
									
				input logic[3:0]    Opcode, 
				input logic         IR_5,
				input logic         IR_11,
				input logic         BEN,
				  
				output logic        LD_MAR,
									LD_MDR,
									LD_IR,
									LD_BEN,
									LD_CC,
									LD_REG,
									LD_PC,
									LD_LED, // for PAUSE instruction
									
				output logic        GatePC,
									GateMDR,
									GateALU,
									GateMARMUX,
									
				output logic [1:0]  PCMUX,
				output logic        DRMUX,
									SR1MUX,
									SR2MUX,
									ADDR1MUX,
				output logic [1:0]  ADDR2MUX,
									ALUK,
				  
				output logic        Mem_CE,
									Mem_UB,
									Mem_LB,
									Mem_OE,
									Mem_WE
				);

	enum logic [4:0] {  Halted, 
						PauseIR1, 
						PauseIR2, 
						S_18,
						S_33_0,
						S_33_1, 
						S_33_2, 
						S_35, 
						S_32, 
						S_01, S_05, S_09, S_06, S_25_0, S_25_1, S_25_2, S_27, S_07, S_23,
						S_16_0, S_16_1, S_16_2, S_00, S_22, S_12, S_04, S_21}   State, Next_state;   // Internal state logic
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= Halted;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = State;
		
		// Default controls signal values
		LD_MAR = 1'b0;
		LD_MDR = 1'b0;
		LD_IR = 1'b0;
		LD_BEN = 1'b0;
		LD_CC = 1'b0;
		LD_REG = 1'b0;
		LD_PC = 1'b0;
		LD_LED = 1'b0;
		 
		GatePC = 1'b0;
		GateMDR = 1'b0;
		GateALU = 1'b0;
		GateMARMUX = 1'b0;
		 
		ALUK = 2'b00;
		 
		PCMUX = 2'b00;
		DRMUX = 1'b0;
		SR1MUX = 1'b0;
		SR2MUX = 1'b0;
		ADDR1MUX = 1'b0;
		ADDR2MUX = 2'b00;
		 
		Mem_OE = 1'b1;
		Mem_WE = 1'b1;
	
		// Assign next state
		unique case (State)
			Halted : 
				if (Run) 
					Next_state = S_18;                      
			S_18 :
				Next_state = S_33_0;
			// Any states involving SRAM require more than one clock cycles.
			// The exact number will be discussed in lecture.
			S_33_0:
				Next_state = S_33_1;
			S_33_1 : 
				Next_state = S_33_2;
			S_33_2 : 
				Next_state = S_35;
			S_35 : 
				Next_state = S_32;    //Skip PauseIR1 and PauseIR2 for Week 2
			// PauseIR1 and PauseIR2 are only for Week 1 such that TAs can see 
			// the values in IR.
			PauseIR1 : 
				if (~Continue) 
					Next_state = PauseIR1;
				else 
					Next_state = PauseIR2;
			PauseIR2 : 
				if (Continue) 
					Next_state = PauseIR2;
				else 
					Next_state = S_18;
			S_32 : 
				case (Opcode)
					4'b0001: 
						Next_state = S_01;   //ADD
					4'b0101:
						Next_state = S_05;	//AND
					4'b1001:
						Next_state = S_09;	//NOT
					4'b0000:
						Next_state = S_00;	//BR
					4'b1100:
						Next_state = S_12;	//JMP
					4'b0100:
						Next_state = S_04;	//JSR
					4'b0110:
						Next_state = S_06;	//LDR
					4'b0111:
						Next_state = S_07;	//STR
					4'b1101:
						Next_state = PauseIR1;	//PSE
					default : 
						Next_state = S_18;
				endcase
			S_01: 		//ADD
				Next_state = S_18;
			S_05: 		//AND
				Next_state = S_18;
			S_09:			//NOT
				Next_state = S_18;
			S_00:			//BR
				if(BEN)
					Next_state = S_22;
				else
					Next_state = S_18;
			S_22:
				Next_state = S_18;
			S_12:			//JMP
				Next_state = S_18;
			S_04:			//JSR
				Next_state = S_21;
			S_21:
				Next_state = S_18;
			S_06: 		//LDR
				Next_state = S_25_0;
			S_25_0:
				Next_state = S_25_1;
			S_25_1:
				Next_state = S_25_2;
			S_25_2:
				Next_state = S_27;
			S_27:
				Next_state = S_18;
			S_07:			//STR
				Next_state = S_23;
			S_23:
				Next_state = S_16_0;
			S_16_0:
				Next_state = S_16_1;
			S_16_1:
				Next_state = S_16_2;
			S_16_2:
				Next_state = S_18;
				
			default : ;
		endcase
		
		// Assign control signals based on current state
		case (State)
			Halted: ;
			S_18 :                     //MAR <- PC, PC <- PC+1
				begin 
					GatePC = 1'b1;
					LD_MAR = 1'b1;
					PCMUX = 2'b00;
					LD_PC = 1'b1;					
				end
			
			S_33_0 :
					Mem_OE = 1'b0;
			S_33_1 : 						//MDR <- M
					Mem_OE = 1'b0;
			
			S_33_2 :                    
				begin 
					Mem_OE = 1'b1;
					LD_MDR = 1'b1;
				end
			
			S_35 :                      //IR <- MDR
				begin 
					GateMDR = 1'b1;
					LD_IR = 1'b1;
				end
			
			PauseIR1: 
					LD_LED = 1'b1;
			
			PauseIR2: ;
			
			S_32 : 
				LD_BEN = 1'b1;
			
			S_01 :                  //DR<- SR1 + OP2, setCC
				begin 
					SR2MUX = IR_5;		//SR2 or imm5
					SR1MUX = 1'b1;		//IR[8:6]
					ALUK = 2'b00;		//ADD signal
					GateALU = 1'b1;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
				end
			
			S_05:							//DR<- SR1 & OP2, setCC
				begin
					SR2MUX = IR_5;		//SR2 or imm5
					SR1MUX = 1'b1;		//IR[8:6]
					ALUK = 2'b01;		//AND signal
					GateALU = 1'b1;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
				end
				
			S_09:							//DR<-NOT(SR)
				begin
					SR1MUX = 1'b1; 	//IR[8:6]
					ALUK = 2'b10;		//NOT signal
					GateALU = 1'b1;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
				end
				
			S_00:	;						//[BEN] (No output signals for initial branch state 0)
			
			S_22:							//PC<- PC + off9
				begin
				ADDR1MUX	= 1'b0;		//PC
				ADDR2MUX = 2'b01;		//sext7 IR[8:0]
				PCMUX = 2'b10;			//ADDER
				LD_PC = 1'b1;
				end
			
			S_12:							//PC<- BaseR
				begin
				SR1MUX = 1'b1;			//IR[8:6]
				ADDR1MUX = 1'b1;		//SR1out/BaseR
				ADDR2MUX = 2'b11;		//16'h0
				PCMUX = 2'b10;			//ADDER
				LD_PC = 1'b1;
				end
			
			S_04:							//R7<- PC
				begin
				DRMUX = 1'b1;			//3'b111 (R7)
				GatePC = 1'b1;
				LD_REG = 1'b1;
				end
				
			S_21:							//PC<- PC + off11
				begin
				ADDR1MUX	= 1'b0;		//PC
				ADDR2MUX = 2'b00;		//sext5 IR[10:0]
				PCMUX = 2'b10;			//ADDER
				LD_PC = 1'b1;
				end
				
			S_06:							//MAR<- B + off6
				begin
				SR1MUX = 1'b1;			//IR[8:6]
				ADDR1MUX = 1'b1;		//SR1out/BaseR
				ADDR2MUX = 2'b10;		//sext10 IR[5:0]
				GateMARMUX = 1'b1;	
				LD_MAR = 1'b1;
				end
			
			S_25_0:
				begin
				Mem_OE = 1'b0;
				end
			S_25_1:						//MDR<- M[MAR]
				begin
				Mem_OE = 1'b0;
				end
				
			S_25_2:
				begin
				Mem_OE = 1'b1;
				LD_MDR = 1'b1;
				end
				
			S_27:							//DR<- MDR, setCC
				begin
				GateMDR = 1'b1;
				LD_REG = 1'b1;
				LD_CC = 1'b1;
				end
			
			S_07:							//MAR<- B + off6
				begin
				SR1MUX = 1'b1;			//IR[8:6]
				ADDR1MUX = 1'b1;		//SR1out/BaseR
				ADDR2MUX = 2'b10;		//sext10 IR[5:0]
				GateMARMUX = 1'b1;	
				LD_MAR = 1'b1;
				end
				
			S_23:							//MDR<- SR
				begin
				SR1MUX = 1'b0;			//IR[11:9]
				ALUK = 2'b11;			//PassA
				GateALU = 1'b1;
				LD_MDR = 1'b1;
				end
			S_16_0:
				begin
				Mem_WE = 1'b0;
				end
			S_16_1:						//M[MAR]<- MDR
				begin
				Mem_WE = 1'b0;
				end
			
			S_16_2:
				begin
				Mem_WE = 1'b1;
				end
			
			default: ;
		endcase
	end 

	 // These should always be active
	assign Mem_CE = 1'b0;
	assign Mem_UB = 1'b0;
	assign Mem_LB = 1'b0;
	
endmodule
