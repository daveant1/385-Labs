module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);

//state machine has control signal outputs MSG_select, Mix_select, and LD_MSG
logic [1407:0] KeySchedule;
logic[10:0][127:0] RoundKey;
logic [127:0] MSG, MSG_in, Sub_out, Mix_out, Shift_out, Add_out; //value to update MSG register, 
																					  //and function module outputs																				  
logic [31:0] Mix_in, Mix_int;					//Input to InvMixColumns and intermediate value before assigned to array
logic [3:0][31:0] Mix_array; 					//array of 4 32-bit words to be concatenated for Mix_out
logic [1:0] Mix_select, Array_select;		//our select for the input to MSG register as well as InvMix module
logic [2:0] MSG_select;
logic LD_MSG; 										//signal to load MSG register
logic[3:0] counter; 								//signal to count 9 loops of decryption round
enum logic [3:0] {Wait_state, Done_state, Sub_state, Sub_last, Mix_1, Mix_2, Mix_3, Mix_4, Mix_final, Shift_state, 
						Shift_last, Add_first, Count_state, Add_state, Add_last} curr_state, next_state;

//Instantiate modules and assign RoundKeys
reg_128 MSG_reg(.Clk(CLK), .Reset(RESET), .Load (LD_MSG), .Din(MSG_in), .Dout(MSG));

muxs3 #(128) MSG_mux(.D0(Add_out), .D1(Shift_out), .D2(Mix_out), .D3(Sub_out), .D4(AES_MSG_ENC), .Sel(MSG_select), .Dout(MSG_in));

muxs2 #(32) Mix_in_mux(.D0(MSG[127:96]), .D1(MSG[95:64]), .D2(MSG[63:32]), .D3(MSG[31:0]), .Sel(Mix_select), .Dout(Mix_in));

KeyExpansion expand_key(.clk(CLK), .Cipherkey(AES_KEY), .KeySchedule(KeySchedule));

array mix_array(.*);

assign Mix_out = {Mix_array[0], Mix_array[1], Mix_array[2], Mix_array[3]};  //concatenate intermediate array registers
 
assign RoundKey[10] = KeySchedule [1407:1280];
assign RoundKey[9] = KeySchedule [1279:1152];
assign RoundKey[8] = KeySchedule [1151:1024];
assign RoundKey[7] = KeySchedule [1023:896];
assign RoundKey[6] = KeySchedule [895:768];
assign RoundKey[5] = KeySchedule [767:640];
assign RoundKey[4] = KeySchedule [639:512];
assign RoundKey[3] = KeySchedule [511:384];
assign RoundKey[2] = KeySchedule [383:256];
assign RoundKey[1] = KeySchedule [255:128];
assign RoundKey[0] = KeySchedule [127:0];

AddRoundKey add_key(.in(MSG), .RoundKey(RoundKey[counter]), .out(Add_out));

InvShiftRows shift_rows(.data_in(MSG), .data_out(Shift_out)); 

InvMixColumns mix_msg(.in(Mix_in), .out(Mix_int));

InvSubBytes Sub1(.clk(CLK), .in(MSG[127:120]), .out(Sub_out[127:120]));
InvSubBytes Sub2(.clk(CLK), .in(MSG[119:112]), .out(Sub_out[119:112]));
InvSubBytes Sub3(.clk(CLK), .in(MSG[111:104]), .out(Sub_out[111:104]));
InvSubBytes Sub4(.clk(CLK), .in(MSG[103:96]), .out(Sub_out[103:96]));
InvSubBytes Sub5(.clk(CLK), .in(MSG[95:88]), .out(Sub_out[95:88]));
InvSubBytes Sub6(.clk(CLK), .in(MSG[87:80]), .out(Sub_out[87:80]));
InvSubBytes Sub7(.clk(CLK), .in(MSG[79:72]), .out(Sub_out[79:72]));
InvSubBytes Sub8(.clk(CLK), .in(MSG[71:64]), .out(Sub_out[71:64]));
InvSubBytes Sub9(.clk(CLK), .in(MSG[63:56]), .out(Sub_out[63:56]));
InvSubBytes Sub10(.clk(CLK), .in(MSG[55:48]), .out(Sub_out[55:48]));
InvSubBytes Sub11(.clk(CLK), .in(MSG[47:40]), .out(Sub_out[47:40]));
InvSubBytes Sub12(.clk(CLK), .in(MSG[39:32]), .out(Sub_out[39:32]));
InvSubBytes Sub13(.clk(CLK), .in(MSG[31:24]), .out(Sub_out[31:24]));
InvSubBytes Sub14(.clk(CLK), .in(MSG[23:16]), .out(Sub_out[23:16]));
InvSubBytes Sub15(.clk(CLK), .in(MSG[15:8]), .out(Sub_out[15:8]));
InvSubBytes Sub16(.clk(CLK), .in(MSG[7:0]), .out(Sub_out[7:0]));

assign AES_MSG_DEC = MSG;

always_ff @ (posedge CLK)
begin
	if (RESET)
		begin
		curr_state <= Wait_state;
		end
	else
		begin
		curr_state <= next_state;
		end
end

always_ff @ (posedge CLK)
begin
	case(curr_state)
	Wait_state:
		begin
		counter <= 4'b0000;  //reset counter and initialize MSG register in Wait state
		end
	
	Count_state:
		counter <= counter + 4'b0001; //update counter when we add round key
		
	Add_state:
		counter <= counter + 4'b0001; //update counter when we add round key
	endcase
end
		
always_comb
begin
	case(curr_state)
		Wait_state:
			if(AES_START)
				next_state= Add_first;
			else
				next_state = Wait_state;
		
		Add_first:
			next_state = Count_state;
		
		Count_state:
			next_state = Shift_state;
		
		Shift_state:
			next_state = Sub_state;
		
		Sub_state:
			next_state = Add_state;
		
		Add_state:
			next_state = Mix_1;
		
		Mix_1:
			next_state = Mix_2;
			
		Mix_2:
			next_state = Mix_3;
		
		Mix_3:
			next_state = Mix_4;
			
		Mix_4:
			next_state = Mix_final;
			
		Mix_final:
			if(counter == 4'b1010) //once we have executed the decryption round 9 times, we move to last round
				next_state = Shift_last;
			else
				next_state = Shift_state;
		
		Shift_last:
			next_state = Sub_last;
		
		Sub_last:
			next_state = Add_last;
		
		Add_last:
			next_state = Done_state;
	
		Done_state:
			if(AES_START)
				next_state= Done_state;
			else
				next_state= Wait_state;
		default:;		
	endcase
	
	LD_MSG = 1'b0;    //set defaults for default case
	AES_DONE = 1'b0;
	MSG_select = 3'b100;
	Mix_select = 2'b00;
	Array_select = 2'b00;
	
	case(curr_state)
		
		Wait_state: 
			begin
			AES_DONE = 1'b0;
			LD_MSG = 1'b1;
			end
		
		Done_state: 
			begin
			AES_DONE = 1'b1;
			LD_MSG = 1'b0;
			end
		
		Add_first:
			begin
			MSG_select = 2'b00;
			LD_MSG = 1'b1;
			end
		
		Count_state:
			begin
			LD_MSG = 1'b0;
			end
		
		Shift_state:
			begin
			MSG_select = 2'b01;
			LD_MSG = 1'b1;
			end
		
		Sub_state:
			begin
			MSG_select = 2'b11;
			LD_MSG = 1'b1;
			end
		
		Add_state:
			begin
			MSG_select = 2'b00;
			LD_MSG = 1'b1;
			end
			
		Mix_1:
			begin
			Mix_select = 2'b00;
			LD_MSG = 1'b0;			//we do not want to load message until entire InvMixColumns calculated
			Array_select = 2'b00;
			end
			
		Mix_2:
			begin
			Mix_select = 2'b01;
			LD_MSG = 1'b0;			//we do not want to load message until entire InvMixColumns calculated
			Array_select = 2'b01;
			end
		
		Mix_3:
			begin
			Mix_select = 2'b10;
			LD_MSG = 1'b0;			//we do not want to load message until entire InvMixColumns calculated
			Array_select = 2'b10;
			end
		
		Mix_4:
			begin
			Mix_select = 2'b11;
			LD_MSG = 1'b0;
			Array_select = 2'b11;
			end
			
		Mix_final:
			begin
			MSG_select = 2'b10;
			LD_MSG = 1'b1;
			end
		
		Shift_last:
			begin
			MSG_select = 2'b01;
			LD_MSG = 1'b1;
			end
		
		Sub_last:
			begin
			MSG_select = 2'b11;
			LD_MSG = 1'b1;
			end
		
		Add_last:
			begin
			MSG_select = 2'b00;
			LD_MSG = 1'b1;
			end
			
		default:;
	endcase
end

endmodule	
	
		
