`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:49:44 11/21/2021 
// Design Name: 
// Module Name:    RegW 
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
module RegW(
	 input Req,
	 input [31:0] CP0_DOutM,
	 output reg [31:0] CP0_DOutW,

	 input [2:0] MemtoRegM,
	 input RegWriteM,
    input [31:0] MDM,
    input [31:0] AOM,
    input [4:0] WAM,
	 input [31:0] PCM,
	 input [31:0] HILO_resM,
	 input clk,
	 input reset,
	 output reg [2:0] MemtoRegW,
	 output reg RegWriteW,
    output reg [31:0] MDW,
    output reg [31:0] AOW,
    output reg [4:0] WAW,
	 output reg [31:0] HILO_resW,
	 output reg [31:0] PCW
    );
	
	always @(posedge clk) begin
		if(reset | (Req === 1'b1)) begin
			MemtoRegW <= 0;
			RegWriteW <= 0;
			MDW <= 0;
			AOW <= 0;
			WAW <= 0;
			PCW <= Req ? 32'h0000_4180: 32'h0000_3000;
			HILO_resW <= 0;
			
			CP0_DOutW <= 0;
		end
		else begin
			MemtoRegW <= MemtoRegM;
			RegWriteW <= RegWriteM;
			MDW <= MDM;
			AOW <= AOM;
			WAW <= WAM;
			PCW <= PCM;
			HILO_resW <= HILO_resM;
			
			CP0_DOutW <= CP0_DOutM;
		end
	end

endmodule
