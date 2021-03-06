/*--  *******************************************************
--  Computer Architecture Course, Laboratory Sources 
--  Amirkabir University of Technology (Tehran Polytechnic)
--  Department of Computer Engineering (CE-AUT)
--  https://ce[dot]aut[dot]ac[dot]ir
--  *******************************************************
--  All Rights reserved (C) 2019-2020
--  *******************************************************
--  Student ID  : 
--  Student Name: 
--  Student Mail: 
--  *******************************************************
--  Additional Comments:
--
--*/

/*-----------------------------------------------------------
---  Module Name: Control Unit
---  Description: Module7:
-----------------------------------------------------------*/
`timescale 1 ns/1 ns

`define AAA 3'b001 // IDLE
`define BBB 3'b010 // ACTIVE
`define CCC 3'b011 // REQUEST
`define DDD 3'b100 // STORE
`define EEE 3'b101 // TRAP
`define FFF 3'b111 // FFF

`define STATE_IDLE    3'b001
`define STATE_ACTIVE  3'b010
`define STATE_REQUEST 3'b011
`define STATE_STORE   3'b100
`define STATE_TRAP    3'b101
`define STATE_OTHERS  3'b111


module ControlUnit (
	input         arst      , // async  reset
	input         clk       , // clock  posedge
	input         request   , // request input (asynch) 
	input         confirm   , // confirm input 
	input  [ 1:0] password  , // password from user
	input  [ 1:0] syskey    , // key  from memoty unit
	input  [34:0] configin  , // conf from user
	output [34:0] configout , // conf to memory unit
	output        write_en  , // conf mem write enable
	output [ 2:0] dbg_state   // current state (debug)
);

	reg [2:0] state; //current state
	reg write_en_reg;
	reg [34:0] configout_reg;
	wire equal;
	PassCheckUnit gate_1(password, syskey, equal);
		
	always @ (posedge clk or posedge arst or negedge request) begin
		if(arst | (~request)) begin 
			state = `STATE_IDLE;
			write_en_reg = 1'b0;
			configout_reg = 35'b00000000000000000000000000000000000;
		end
		else begin
			case (state) 				
				`STATE_IDLE : state = `STATE_ACTIVE;
				`STATE_ACTIVE : state = confirm ? (equal ? `STATE_REQUEST : `STATE_TRAP) : `STATE_ACTIVE;
				`STATE_TRAP : state = `STATE_TRAP;
				`STATE_REQUEST : state = confirm ? `STATE_STORE : `STATE_REQUEST;
				`STATE_STORE : state = `STATE_STORE;
				`STATE_OTHERS : state = `STATE_IDLE;
			endcase
			
			write_en_reg = (state == `STATE_STORE) ? 1'b1 : 1'b0;
			configout_reg = (state == `STATE_STORE) ? configin : 35'b00000000000000000000000000000000000;
		end
	end
	
	assign dbg_state = state;
	assign write_en = write_en_reg;
	assign configout = configout_reg;

endmodule
