module testbench_w1();

timeunit 10ns;// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1

timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic [15:0] S;
logic	Clk, Reset, Run, Continue;
logic [11:0] LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
logic CE, UB, LB, OE, WE;
logic [19:0] ADDR;
wire [15:0] Data;

// Instantiating the DUT
// Make sure the module and signal names match with those in your design
lab6_toplevel SLC3 (.*);
logic [15:0] PC, MAR, MDR, IR; 

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin: CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
	Clk = 0;
end

always begin: INTERNAL_MONITORING
#2 PC = SLC3.my_slc.d0.pc.Dout;
MDR = SLC3.my_slc.d0.mdr.Dout;
MAR = SLC3.my_slc.d0.mar.Dout;
IR = SLC3.my_slc.d0.ir.Dout;
end

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
Reset = 0;		// reset system
Run = 1;			// keep run low
Continue = 1;

#2 Reset = 1;		// stop reset
	
#2 Run = 0;				// run
#1 Run = 1;

end

endmodule