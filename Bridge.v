`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:35:04 12/11/2021 
// Design Name: 
// Module Name:    Bridge 
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
module Bridge(
	 input [31:0] m_data_addr_in,
	 output [31:0] m_data_addr_out,
	 
    input [3:0] m_data_byteen_in,
	 output [3:0] m_data_byteen_out,
	 
	 input [31:0] m_data_rdata_in,
    output [31:0] m_data_rdata_out,
    
    output TCWE1,
    output TCWE2,
	 
	 input [31:0] TCOut1,
	 input [31:0] TCOut2,
	 
	 input IntFromOut
	 );
	  
	 wire WE;
	 assign WE = | m_data_byteen_in;
	 
	 assign TCWE1 = ((m_data_addr_in >= 32'h0000_7f00 && m_data_addr_in <= 32'h0000_7f0b) && WE);
	 assign TCWE2 = ((m_data_addr_in >= 32'h0000_7f10 && m_data_addr_in <= 32'h0000_7f1b) && WE);
		
	 assign m_data_byteen_out 	= 	IntFromOut ? 4'b1111:
											(m_data_addr_in >= 32'h0000_0000 && m_data_addr_in <= 32'h0000_2fff) ? m_data_byteen_in : 4'd0;
			
	 assign m_data_rdata_out	=	(m_data_addr_in >= 32'h0000_7f00 && m_data_addr_in <= 32'h0000_7f0b) ? TCOut1:
											(m_data_addr_in >= 32'h0000_7f10 && m_data_addr_in <= 32'h0000_7f1b) ? TCOut2:
											m_data_rdata_in;
											
	 assign m_data_addr_out		=	IntFromOut ? 32'h0000_7f20: m_data_addr_in;
	 
endmodule



    /*input wire [31:2] PrAddr,
	 input wire [31:0] PrWD,			// CPU 写的数据
	 input wire PrWE,
	 
	 input wire [31:0] DMRD,
	 input wire [31:0] TCRD1,
	 input wire [31:0] TCRD2,
	 
	 output wire [31:0] PrRD,			// CPU 读的数据
	
	 output wire [31:2] DEV_Addr,
	 output wire [31:0] DEV_WD,
	 
	 output wire DMWE,
	 output wire TCWE1,
	 output wire TCWE2*/
	 
	 	 /*wire [31:0] tmp_PrAddr;
	 wire TC1Sel, TC2Sel, DMSel;
	 
	 assign DEV_Addr = PrAddr;
	 assign tmp_PrAddr = {PrAddr, 2'b00};
	 
	 assign DMSel	=	(tmp_PrAddr >= 32'h0000 && tmp_PrAddr <= 32'h2fff)	?	1'b1: 1'b0;
	 assign TC1Sel = 	(tmp_PrAddr >= 32'h7f00 && tmp_PrAddr <= 32'h7f0b)	?	1'b1: 1'b0;
	 assign TC2Sel = 	(tmp_PrAddr >= 32'h7f10 && tmp_PrAddr <= 32'h7f1b)	?	1'b1: 1'b0;
	 
	 assign DEV_WD = PrWD;
	 
	 assign DMWE 	= 	PrWE & DMSel;
	 assign TCWE1 	= 	PrWE & TC1Sel;
	 assign TCWE2 	= 	PrWE & TC2Sel;

	 assign PrRD = DMSel	 	?	DMRD	:
						TC1Sel	? 	TCRD1	:
						TC2Sel 	? 	TCRD2	:
										32'b0	;*/