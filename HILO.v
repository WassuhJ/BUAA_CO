`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:52:10 12/04/2021 
// Design Name: 
// Module Name:    HILO 
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
module HILO(
	 input Req,
	
    input clk,
    input reset,
    input [31:0] R1E,
    input [31:0] R2E,
    input [3:0] HILO_type,
    output HILO_busy,
    output [31:0] HILO_res
    );

	
	reg busy;
	reg [31:0] hi, lo;
	reg [31:0] tmp_hi, tmp_lo;

	integer 	cycle 		= 	0;
	assign 	start			= 	(HILO_type == 4'd1) | (HILO_type == 4'd2) | 
									(HILO_type == 4'd3) | (HILO_type == 4'd4)	;	// mult | multu | div | divu
	assign 	HILO_busy	=	start | busy;
	assign	HILO_res		= 	(HILO_type == 4'd5)	? 	lo:
									(HILO_type == 4'd6)	? 	hi:
																	0;
	
	always @(posedge clk) begin
		if(reset) begin
			hi <= 0;			lo <= 0;
			cycle <= 0;		busy <= 0;
			tmp_hi <= 0;	tmp_lo <= 0;
		end
		else if(Req === 1'b0) begin
			if(cycle == 1) begin
				cycle <= 0;		busy 	<= 0;
				hi <= tmp_hi;	lo <= tmp_lo;
			end
			else if(cycle == 0) begin
				case(HILO_type)
					4'd1: begin														// mult
						busy <= 1; cycle <= 5;
						{tmp_hi, tmp_lo} <= $signed(R1E) * $signed(R2E);
 					end
					4'd2: begin 													// multu
						busy <= 1; cycle <= 5;
						{tmp_hi, tmp_lo} <= R1E * R2E;
					end
					4'd3: begin														// div
						busy <= 1; 	cycle <= 10;
						{tmp_hi, tmp_lo} <= {$signed(R1E) % $signed(R2E), $signed(R1E) / $signed(R2E)};	
					end
					4'd4: begin														// divu
						busy <= 1; 	cycle <= 10;
						{tmp_hi, tmp_lo} <= {R1E % R2E, R1E / R2E};
					end
					4'd7: begin														// mtlo
						lo <= R1E;												
					end				
					4'd8: begin 													// mthi
						hi <= R1E;
					end
					//4'd5: mflo 	4'd6: mfhi
				endcase
			end
			else cycle <= cycle - 1;
		end
	end

endmodule


/* 
	assign 	mult		= 	(HILO_type == 4'd1)? 1'b1: 1'b0;
	assign 	multu		= 	(HILO_type == 4'd2)? 1'b1: 1'b0;
	assign 	div		= 	(HILO_type == 4'd3)? 1'b1: 1'b0;
	assign 	divu		= 	(HILO_type == 4'd4)? 1'b1: 1'b0;
	assign 	mflo		= 	(HILO_type == 4'd5)? 1'b1: 1'b0;
	assign 	mfhi		= 	(HILO_type == 4'd6)? 1'b1: 1'b0;
	assign 	mtlo		= 	(HILO_type == 4'd7)? 1'b1: 1'b0;
	assign 	mthi		= 	(HILO_type == 4'd8)? 1'b1: 1'b0;
*/
	