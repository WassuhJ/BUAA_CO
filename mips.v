`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:13:26 12/11/2021 
// Design Name: 
// Module Name:    mips 
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
module mips(
    input wire clk,										// ʱ���ź�
    input wire reset,									// ͬ����λ�ź�
    input wire interrupt,								// �ⲿ�ж��ź�
    output wire [31:0] macroscopic_pc,				// ��� PC�������ģ�
	 
    output wire [31:0] i_inst_addr,					// ȡָ PC
    input wire [31:0] i_inst_rdata,					// i_inst_addr ��Ӧ�� 32 λָ��

    output wire [31:0] m_data_addr,					// ���ݴ洢����д���ַ
    input wire [31:0] m_data_rdata,					// m_data_addr ��Ӧ�� 32 λ����
    output wire [31:0] m_data_wdata,				// ���ݴ洢����д������
    output wire [3:0] m_data_byteen,				// �ֽ�ʹ���ź�

    output wire [31:0] m_inst_addr,					// M ��PC
	 
    output wire w_grf_we,								// grf дʹ���ź�

    output wire [4:0] w_grf_addr,					// grf ��д��Ĵ������
    output wire [31:0] w_grf_wdata,					// grf ��д������
    
	 output wire [31:0] w_inst_addr					// W �� PC
    );
	 
	 wire [5:0] HWInt;
	 wire [31:0] PrRD, PrWD;
	 wire PrWE;
	/* wire [31:2] PrAddr, DEV_Addr;
	 wire [31:0] DEV_WD;
	 */
	 
	 // Timer
	 wire TCWE1, TCWE2;
	 wire [31:0] TCOut1, TCOut2;
	 wire IRQ1, IRQ2;
	 
	 //wire DMWE;
	 wire IntFromOut;
	 
	 assign HWInt = {3'b0, interrupt, IRQ2, IRQ1};
	 assign macroscopic_pc = m_inst_addr;
	
	 wire [3:0] m_data_byteen0;
	 wire [31:0] m_data_addr0; 
	 wire [31:0] m_data_rdata0;
	 //assign m_data_byteen = _IntFromOut ?	4'b1111:	(DMWE ? m_data_byteen0: 0);
	 
	 reg _IntFromOut;
	 
	 initial begin
		_IntFromOut <= 0;
	 end
	 always @(posedge clk)
		_IntFromOut <= IntFromOut;
    //assign m_data_addr = _IntFromOut ? 32'h7f20: m_data_addr0;
	
	 assign m_data_wdata = PrWD;
	 
	 CPU cpu(
		.clk					(clk),
		.reset				(reset),
		.i_inst_rdata		(i_inst_rdata),
		.m_data_rdata		(PrRD),
		.i_inst_addr		(i_inst_addr),
		.m_data_wdata		(PrWD),
		
		.m_data_addr		(m_data_addr0),
		.m_data_byteen		(m_data_byteen0),
		.m_inst_addr		(m_inst_addr),
		
		.w_grf_we			(w_grf_we),
		.w_grf_addr			(w_grf_addr),
		.w_grf_wdata		(w_grf_wdata),
		.w_inst_addr		(w_inst_addr),
		.HWInt				(HWInt),
		
		//.PrWE					(PrWE),
		//.PrRD					(PrRD),
		
		.IntFromOut			(IntFromOut)
	 );
 
	 Bridge bridge(
		.IntFromOut			(_IntFromOut),
		
		.m_data_addr_in	(m_data_addr0),
		.m_data_addr_out	(m_data_addr),
		
		.m_data_byteen_in	(m_data_byteen0),
		.m_data_byteen_out(m_data_byteen),
		
		.m_data_rdata_in	(m_data_rdata),
		.m_data_rdata_out	(PrRD),
		
		.TCWE1				(TCWE1),
		.TCWE2				(TCWE2),
		
		.TCOut1				(TCOut1),
		.TCOut2				(TCOut2)
	 );
	 
	 // assign 
	 
	 TC Timer1(
		.clk					(clk),
		.reset				(reset),
		.Addr					(m_data_addr[31:2]),
		.WE					(TCWE1),
		.Din					(PrWD),
		.Dout					(TCOut1),
		.IRQ					(IRQ1)
    );
	 
	 TC Timer2(
		.clk					(clk),
		.reset				(reset),
		.Addr					(m_data_addr[31:2]),
		.WE					(TCWE2),
		.Din					(PrWD),
		.Dout					(TCOut2),
		.IRQ					(IRQ2)
    );


endmodule