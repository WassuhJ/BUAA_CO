`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:36:17 11/21/2021 
// Design Name: 
// Module Name:    RegE 
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
module RegE(
	input RID,
	output reg RIE,
	
	 input Req,
	 input eretD,
	 input CP0WriteD,
	 input [4:0] ExcCodeD,
	 input BDD,
	 input MayOvD,
	 input MayAdED,
	 output reg eretE,
	 output reg CP0WriteE,
	 output reg [4:0] ExcCodeE,
	 output reg BDE,
	 output reg MayOvE,
	 output reg MayAdEE,
		
	 // WB
	 input [2:0] MemtoRegD,
	 input RegWriteD,
	 // Mem
	 input MemWriteD,
	 input MemReadD,
	 //input BranchD,
	 // Ex
	 input [1:0] ALUASrcD,
	 input [1:0] ALUBSrcD,
	 input [3:0] ALUCtrlD,
	 input [1:0] RegDstD,
	 input [4:0] shamtD,
    input [31:0] PCD,
    input [31:0] R1D,
    input [31:0] R2D,
    input [31:0] IMD,
	 input [4:0] RsD,
    input [4:0] RtD,
	 input [4:0] RdD,
	 /*input [1:0] Tuse_rsD,
	 input [1:0] Tuse_rtD,*/ 
	 input [1:0] TnewD,
	 input [3:0] HILO_typeD,
	 input [2:0] BEopD,
	 input [3:0] DM_typeD,
	 input clk, 
	 input reset,
	 input Stall,
	 output reg [2:0] MemtoRegE,
	 output reg RegWriteE,
	 output reg MemWriteE,
	 output reg MemReadE,
	 //output BranchE,
	 output reg [1:0] ALUASrcE,
	 output reg [1:0] ALUBSrcE,
	 output reg [3:0] ALUCtrlE,
	 output reg [1:0] RegDstE,
    output reg [31:0] PCE,
    output reg [31:0] R1E,
    output reg [31:0] R2E,
    output reg [31:0] IME,
	 output reg [4:0] RsE,
    output reg [4:0] RtE,
	 output reg [4:0] RdE,
	 /*output reg [1:0] Tuse_rsE,
	 output reg	[1:0] Tuse_rtE,*/
	 output reg [4:0] shamtE,
	 output reg [1:0] TnewE,
	 output reg	[3:0] HILO_typeE,
	 output reg [3:0] DM_typeE,
	 output reg [2:0] BEopE
	 );
	
	always @(posedge clk) begin
		if(reset | Stall | (Req === 1'b1)) begin
			MemtoRegE <= 0;
			RegWriteE <= 0;
			MemWriteE <= 0;
			MemReadE <= 0;
			//Branch <= 0;
			ALUASrcE <= 0;
			ALUBSrcE <= 0;
			ALUCtrlE <= 0;
			RegDstE <= 0;
			TnewE <= 0;
			HILO_typeE <= 0;
			DM_typeE <= 0;
			BEopE <= 0;
			
			RsE <= 0;
			RtE <= 0;
			RdE <= 0;
			shamtE <= 0;
			
			//PCE <= Stall? PCD: ((Req === 1'b1)? 32'h0000_4180: 0);
			PCE <= Req ? 32'h0000_4180: (Stall ? PCD: 32'h0000_3000);
			R1E <= 0;
			R2E <= 0;
			IME <= 0;
			
			RIE <= 0;
	
			ExcCodeE <= 0;
			BDE <= Stall? BDD: 0;
			eretE <= 0;
			CP0WriteE <= 0;
			MayOvE <= 0;
			MayAdEE <= 0; 
		end
		else begin
			MemtoRegE <= MemtoRegD;
			RegWriteE <= RegWriteD;
			MemWriteE <= MemWriteD;
			MemReadE <= MemReadD;
			//Branch <= BranchD;
			ALUASrcE <= ALUASrcD;
			ALUBSrcE <= ALUBSrcD;
			ALUCtrlE <= ALUCtrlD;
			RegDstE <= RegDstD;
			HILO_typeE <= HILO_typeD;
			BEopE <= BEopD;
			DM_typeE <= DM_typeD;
			
			RsE <= RsD;
			RtE <= RtD;
			RdE <= RdD;
			shamtE <= shamtD;
			TnewE <= TnewD;
			
			PCE <= PCD;
			R1E <= R1D;
			R2E <= R2D;
			IME <= IMD;
			
			RIE <= RID;
			ExcCodeE <= ExcCodeD;
			BDE <= BDD;
			eretE <= eretD;
			CP0WriteE <= CP0WriteD;
			MayOvE <= MayOvD;
			MayAdEE <= MayAdED; 
 		end
	end

endmodule
