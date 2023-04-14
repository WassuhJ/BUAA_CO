`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:23:33 12/04/2021 
// Design Name: 
// Module Name:    BE 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module BE(
	 /*input AdEM,
	 output AdELM,
	 output AdESM,*/
	 input DMWE,
	
	 input [31:0] Addr32,
    //input [1:0] Addr,
    input [31:0] Din,
	 input [31:0] Dread,
    input [2:0] BEopM,
	 input [3:0] DM_typeM,
    output reg [31:0] store_res,
	 output reg [31:0] load_res,
	 output [3:0] Byte_EnM
    );
	 
	wire [1:0] Addr;
	assign Addr = Addr32[1:0];
	
	wire [7:0] B_Load, B_Store;
	wire [15:0] H_Load, H_Store;

	assign Byte_EnM	= 	(!DMWE)			?	4'b0000:
								(DM_typeM == 2)?	4'b1111:
								(DM_typeM == 4)?	((Addr[1] == 0)? 4'b0011: 4'b1100):
								(DM_typeM == 7)?	((Addr == 2'b00)? 4'b0001	:
														 (Addr == 2'b01)? 4'b0010	:
														 (Addr == 2'b10)? 4'b0100	:
																				4'b1000)	:
														4'b0000;
				
	assign B_Store = Din[7:0];
	assign H_Store = Din[15:0];
	
	always @* begin
		case (Byte_EnM)
			4'b0001: store_res = {24'b0, B_Store};
			4'b0010: store_res = {16'b0, B_Store, 8'b0};
			4'b0100: store_res = {8'b0, B_Store, 16'b0};
			4'b1000: store_res = {B_Store, 24'b0};
			4'b0011:	store_res = {16'b0, H_Store};
			4'b1100: store_res = {H_Store, 16'b0};
			4'b1111: store_res = Din;
		endcase
	end
	
	assign B_Load = (Addr == 0)? Dread[7:0]:
						 (Addr == 1)? Dread[15:8]:
						 (Addr == 2)? Dread[23:16]:
						 (Addr == 3)? Dread[31:24]:
										  8'd0;
	assign H_Load = (Addr[1] == 0)? Dread[15:0]:
						 (Addr[1] == 1)? Dread[31:16]:
											  16'd0;
											  
	always @* begin
		case (BEopM)
			3'd1: load_res = {{24{1'b0}}, B_Load};
			3'd2: load_res = {{24{B_Load[7]}}, B_Load};
			3'd3: load_res = {{16{1'b0}}, H_Load};
			3'd4: load_res = {{16{H_Load[15]}}, H_Load};
			default: load_res = Dread;
		endcase
	end
	
endmodule

	/*assign Store =	(DM_typeM == 2 || DM_typeM == 4 || DM_typeM == 7);
	assign Load	 =	(DM_typeM == 1 || DM_typeM == 3 || DM_typeM == 5 || DM_typeM == 6 || DM_typeM == 8);
	
	assign Word = 	(DM_typeM == 1 || DM_typeM == 2); 
	assign Half = 	(DM_typeM == 3 || DM_typeM == 4 || DM_typeM == 5);
	assign Byte = 	(DM_typeM == 6 || DM_typeM == 7 || DM_typeM == 8);
	
	assign NotAlign = (Word && (| Addr)) || (Half && Addr[0]);
	assign UseTimer = (Addr32 >= 32'h0000_7f00 && (Byte || Half));
	assign Overflow = AdEM;
	assign StoreinCount 	= 	(Addr32 >= 32'h0000_7f08 && Addr32 <= 32'h0000_7f0b) ||
									(Addr32 >= 32'h0000_7f18 && Addr32 <= 32'h0000_7f1b);
	assign OutofRange 	=	!( ((Addr32 >= 32'h0000_0000) && (Addr32 <= 32'h0000_2fff)) ||
										((Addr32 >= 32'h0000_7f00) && (Addr32 <= 32'h0000_7f0b)) ||
										((Addr32 >= 32'h0000_7f10) && (Addr32 <= 32'h0000_7f1b))	);
	
	assign AdELM =	Load && (NotAlign || UseTimer || Overflow || OutofRange);
	assign AdESM =	Store && (NotAlign || UseTimer || Overflow || StoreinCount || OutofRange);	 	
	*/