`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:44:32 11/14/2021 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
	 input MayAdEE,
	 input MayOvE,
	 output OvE,
	 output AdEE,

    input [31:0] SrcA,
    input [31:0] SrcB,
    input [3:0] ALU_Ctrl,
    output [31:0] ALU_res
    );

	assign ALU_res = res;
	reg [31:0] res;
	
	always @* begin
		case (ALU_Ctrl)
			4'd1: res = SrcB;															// lui
			4'd2: res = SrcA + SrcB;
			4'd3: res = SrcA - SrcB;
			4'd4: res = SrcA & SrcB;
			4'd5: res = SrcA | SrcB;
			4'd6: res = SrcA ^ SrcB;					
			4'd7: res = ~(SrcA | SrcB);											// nor
			4'd8: res = SrcA << SrcB;												// sll
			4'd9: res = SrcA >> SrcB;												// srl
			4'd10: res = $signed($signed(SrcA) >>> SrcB);					// sra
			4'd11: res = ($signed(SrcA) < $signed(SrcB))? 32'd1: 32'd0;	//	slt
			4'd12: res = (SrcA < SrcB)? 32'd1: 32'd0;							// sltu
			default: res = 0;
		endcase
	end
	
	wire [32:0] tmp_SrcA, tmp_SrcB;
	wire [32:0] res_Add, res_Sub;
	
	assign tmp_SrcA = {SrcA[31], SrcA};
	assign tmp_SrcB = {SrcB[31], SrcB};
	
	assign res_Add = tmp_SrcA + tmp_SrcB;
	assign res_Sub = tmp_SrcA - tmp_SrcB;
	
	assign OvE = MayOvE && (((ALU_Ctrl == 4'd2) && (res_Add[32] != res_Add[31])) || ((ALU_Ctrl == 4'd3) && (res_Sub[32] != res_Sub[31])));
								  
	assign AdEE = MayAdEE && ((ALU_Ctrl == 4'd2) && (res_Add[32] != res_Add[31]));
	
endmodule
