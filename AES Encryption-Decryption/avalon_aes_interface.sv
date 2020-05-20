module avalon_aes_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
);
	
	logic [15:0][31:0] REG;
	logic [127:0] AES_KEY, AES_MSG_ENC, AES_MSG_DEC;
	logic AES_START, AES_DONE;

assign AES_START = REG[14][0];
assign AES_KEY = {REG[0][31:0], REG[1][31:0], REG[2][31:0], REG[3][31:0]};
assign AES_MSG_ENC = {REG[4][31:0], REG[5][31:0], REG[6][31:0], REG[7][31:0]};

	always_ff @ (posedge CLK)
	begin
		REG[15][0] <= AES_DONE;
		if(RESET)
			begin
			REG[14] = 32'h0;
			end
		else if(AVL_WRITE && AVL_CS && (AVL_BYTE_EN[3:0] == 4'b1111) && (AVL_ADDR < 8 || AVL_ADDR > 11))
			begin
				REG[AVL_ADDR][31:0] <= AVL_WRITEDATA[31:0];
			end
		else
			begin
				REG[8] <= AES_MSG_DEC[127:96];
				REG[9] <= AES_MSG_DEC[95:64];
				REG[10] <= AES_MSG_DEC[63:32];
				REG[11] <= AES_MSG_DEC[31:0];
			end
	end
	
	assign EXPORT_DATA = {REG[0][31:16], REG[3][15:0]};
	assign AVL_READDATA = (AVL_READ && AVL_CS) ? REG[AVL_ADDR] : {32{1'bZ}};
	
AES decryptor(.*);

endmodule
