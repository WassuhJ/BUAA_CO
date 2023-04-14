`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:28:05 11/21/2021 
// Design Name: 
// Module Name:    FCtrl 
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
module FCtrl(
	 input [4:0] RsD,
	 input [4:0] RtD,
    input [4:0] RsE,
    input [4:0] RtE,
	 input [4:0] WAE,
    input [4:0] WAM,
    input [4:0] WAW,
	 input RegWriteE,
    input RegWriteM,
    input RegWriteW,
    output reg [1:0] FR1D,
    output reg [1:0] FR2D,
	 output reg [1:0] FSrcAE,
	 output reg [1:0] FSrcBE,
	 output reg FWDM
    );
	
	always @* begin
		// MFR1D
		/*if(RegWriteE && (WAE == RsD) && (RsD != 0)) FR1D = 2;
		else */
		if(RegWriteM && (WAM == RsD) && (RsD != 0)) FR1D = 1;
		else FR1D = 0;
		
		// MFR2D
		/*if(RegWriteE && (WAE == RtD) && (RtD != 0)) FR1D = 2;
		else */
		if(RegWriteM && (WAM == RtD) && (RtD != 0)) FR2D = 1;
		else FR2D = 0;
		
		// MFSrcAE
		if(RegWriteM && (WAM == RsE) && (RsE != 0)) FSrcAE = 2;
		else if(RegWriteW && (WAW == RsE) && (RsE != 0)) FSrcAE = 1;
		else FSrcAE = 0;
		
		// MFSrcBE
		if(RegWriteM && (WAM == RtE) && (RtE != 0)) FSrcBE = 2;
		else if(RegWriteW && (WAW == RtE) && (RtE != 0)) FSrcBE = 1;
		else FSrcBE = 0;
		
		// MFWDM
		if(RegWriteW && (WAW == WAM) && (WAM != 0)) FWDM = 1;
		else FWDM = 0;
	end

endmodule
	
/*
	// MFR1D
	 assign FR1D = (RegWriteM && (WAM == RsD) && WAM != 0)? 2'b10:
						(RegWriteW && (WAW == RsD) && WAW != 0)? 2'b01:
																			  2'b00;
															  
	 // MFR2D
	 assign FR2D = (RegWriteM && (WAM == RtD)&& WAM != 0)? 2'b10:
						(RegWriteW && (WAW == RtD)&& WAW != 0)? 2'b01:
															             2'b00;
															  
	// MFSrcAE
	assign FSrcAE = (RegWriteM && (WAM == RsE)&& WAM != 0)? 2'b10:
						 (RegWriteW && (WAW == RsE)&& WAW != 0)? 2'b01:
																			  2'b00;
	
	// MFSrcBE
	assign FSrcBE = (RegWriteM && (WAM == RtE) && WAM != 0)? 2'b10:
						 (RegWriteW && (WAW == RtE)&& WAW != 0)? 2'b01:
																			  2'b00;
																
	// MFWDM
	assign FWDM = (RegWriteW & (WAW == WAM) && WAM != 0)? 1'b1: 1'b0;
*/

/*
		// MFWDE
		if(RegWriteM & (WAM == WAE) & (WAE != 0)) FWDE = 2'b10;
		else if(RegWriteW & (WAW == WAE) & (WAE != 0)) FWDE = 2'b01;
		else FWDE = 2'b00;
*/

