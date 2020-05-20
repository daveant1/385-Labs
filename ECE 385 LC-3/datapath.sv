module datapath(
		input logic Reset, Clk, MIO_EN, 
		input logic [15:0] MDR_In,   //input from MEM2IO   
		input logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED, 
		input logic GatePC, GateMDR, GateALU, GateMARMUX,
		input logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX,
	   input logic [1:0] PCMUX, ADDR2MUX, ALUK,
		output logic [15:0] MAR, MDR, IR, PC,
		output logic [11:0] LED,
		output logic BEN
		);

	
	logic [15:0] BUS;
	logic [15:0] MDRin, PCin;
	logic [2:0] SR1in, DRin;
	logic [15:0] ADDR1out, ADDR2out, ADDERout;
	logic [15:0] ALUout, SR1out, SR2out, SR2MUXout;
	logic [15:0] sext5, sext7, sext10, sext11;
	
	assign sext5 = {IR[10],IR[10],IR[10],IR[10],IR[10],IR [10:0]};
	assign sext7 = {IR[8],IR[8],IR[8],IR[8],IR[8],IR[8],IR[8],IR [8:0]};
	assign sext10 = {IR[5],IR[5],IR[5],IR[5],IR[5],IR[5],IR[5],IR[5],IR[5],IR[5],IR[5:0]};
	assign sext11 = {IR[4],IR[4],IR[4],IR[4],IR[4],IR[4],IR[4],IR[4],IR[4],IR[4],IR[4],IR [4:0]};
	
	
	//register names below are lowercase to avoid matching output names "MAR, MDR, ..."
	//memory interaction registers and IR
	reg_16 mar (.*, .Load (LD_MAR), .Din (BUS), .Dout (MAR));      //MAR
	
	reg_16 mdr (.*, .Load (LD_MDR), .Din (MDRin), .Dout (MDR));      //MDR
	
	muxs1 MDRmux (.D0 (BUS), .D1 (MDR_In), .Sel (MIO_EN), .Dout (MDRin));    //MIO.EN mux
	
	reg_16 ir (.*, .Load (LD_IR), .Din (BUS), .Dout (IR));          //IR
	
	
	//PC and PCmux instances
	reg_16 pc (.*, .Load (LD_PC), .Din (PCin), .Dout (PC));          //PC
	
	muxs2 PCmux (.D0 (PC+1), .D1 (BUS), .D2 (ADDERout), .D3 (16'hx), .Sel (PCMUX), .Dout (PCin));   //PCMUX
	
	
	
	trimux tristate (.D0 (PC), .D1 (MDR), .D2 (ADDERout), .D3 (ALUout),     //our tristate buffer mux
						  .Sel ({GatePC, GateMDR, GateMARMUX, GateALU}), .Dout (BUS));
	
	
	//Register File and input muxes
	reg_file REGFILE (.*, .Load (LD_REG), .SR2in (IR[2:0]));  //Register File
	
	muxs1 DRmux (.D0 (IR[11:9]), .D1 (3'b111), .Sel (DRMUX), .Dout (DRin));
	
	muxs1 SR1mux (.D0 (IR[11:9]), .D1 (IR[8:6]), .Sel (SR1MUX), .Dout (SR1in));
	
	
	//ADDR1, ADDR2, and ADDER (address calculator)
	muxs1 ADDR1 (.D0 (PC), .D1 (SR1out), .Sel (SR1MUX), .Dout (ADDR1out));
	
	muxs2 ADDR2 (.D0 (sext5), .D1 (sext7), .D2 (sext10), .D3 (16'h0), .Sel (ADDR2MUX), .Dout (ADDR2out));
	
	ALU ADDER (.A (ADDR2out), .B (ADDR1out), .ALUK (2'b00), .ALUout (ADDERout));
	
	
	//ALU and SR2mux input
	ALU alu (.*, .A (SR1out), .B (SR2MUXout));
	
	muxs1 SR2mux (.D0 (SR2out), .D1 (sext11), .Sel (SR2MUX), .Dout (SR2MUXout));
	
	//NZP and logic for setCC
	reg_nzp NZP(.*);
	
	always_ff @ (posedge Clk)   //logic for loading LED in Pause state
	begin
		if(LD_LED)
			LED <= IR[11:0];
		else
			LED <= 12'h0;
	end
	
	
endmodule
						
	
	
	