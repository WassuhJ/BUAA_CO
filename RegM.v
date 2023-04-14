`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:42:35 11/21/2021 
// Design Name: 
// Module Name:    RegM 
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

module RegM(
	 input Req,
	 input eretE,
	 input CP0WriteE,
	 //input OvE,
	 input AdEE,
	 input BDE,
	 input [4:0] ExcCodeE,
	 output reg eretM,
	 output reg CP0WriteM,
	 //output reg OvM,
	 output reg AdEM,
	 output reg [4:0] ExcCodeM,
	 output reg BDM,
	 
	 input [2:0] MemtoRegE,
	 input RegWriteE,
	 input MemWriteE,
	 input MemReadE,
	 //input BranchE,
    input [31:0] PCE,
    input [31:0] AOE,
    input [31:0] WDE,
    input [4:0] WAE,
	 input [1:0] TnewE,
	 input [31:0] HILO_resE,
	 input [3:0] DM_typeE,
	 input [2:0] BEopE,
	 input [4:0] RdE,
	 /*input Tuse_rsE,
	 input [1:0] Tuse_rtE,*/
	 input clk,
	 input reset,
	 output reg [2:0] MemtoRegM,
	 output reg RegWriteM,
	 output reg MemWriteM,
	 output reg MemReadM,
	 //output BranchM,
    output reg [31:0] PCM,
    output reg [31:0] AOM,
    output reg [31:0] WDM,
    output reg [4:0] WAM,
	 output reg [3:0] DM_typeM,
	 output reg [31:0] HILO_resM,
	 output reg [1:0] TnewM,
	 output reg [2:0] BEopM,
	 output reg [4:0] RdM
	 /*output reg Tuse_rsM,
	 output reg [1:0] Tuse_rtM*/
    );
	 
	always @(posedge clk) begin
		if(reset | (Req === 1'b1)) begin
			eretM <= 0;
			CP0WriteM <= 0;
			//OvM <= 0;
			AdEM <= 0;
			ExcCodeM <= 0;
			BDM <= 0;
			
			MemtoRegM <= 0;
			RegWriteM <= 0;
			MemWriteM <= 0;
			MemReadM <= 0;
			PCM <= (Req === 1'b1) ? 32'h0000_4180: 0;
			AOM <= 0;
			WDM <= 0;
			WAM <= 0;
			TnewM <= 0;
			HILO_resM <= 0;
			DM_typeM <= 0;
			BEopM <= 0;
			RdM <= 0;
		end
		else begin
			eretM <= eretE;
			CP0WriteM <= CP0WriteE;
			//OvM <= OvE;
			AdEM <= AdEE;
			ExcCodeM <= ExcCodeE;
			BDM <= BDE;
		
			MemtoRegM <= MemtoRegE;
			RegWriteM <= RegWriteE;
			MemWriteM <= MemWriteE;
			MemReadM <= MemReadE;
			PCM <= PCE;
			AOM <= AOE;
			WDM <= WDE;
			WAM <= WAE;
			TnewM <= (TnewE != 0)? (TnewE - 1): 0;
			HILO_resM <= HILO_resE;
			DM_typeM <= DM_typeE;
			BEopM <= BEopE;
			RdM <= RdE;
		end
	end

endmodule
