//
// Copyright (c) 2017 University of Cambridge
// Copyright (c) 2017 Yuta Tokusashi
// 
// All rights reserved.
//
// This software was developed by SRI International and the University of
// Cambridge Computer Laboratory under EPSRC INTERNET Project EP/H040536/1,
// National Science Foundation under Grant No. CNS-0855268, and Defense
// Advanced Research Projects Agency (DARPA) and Air Force Research Laboratory
// (AFRL), under contract FA8750-11-C-0249.
//
// @NETFPGA_LICENSE_HEADER_START@
//
// Licensed to NetFPGA Open Systems C.I.C. (NetFPGA) under one or more
// contributor license agreements. See the NOTICE file distributed with this
// work for additional information regarding copyright ownership. NetFPGA
// licenses this file to you under the NetFPGA Hardware-Software License,
// Version 1.0 (the "License"); you may not use this file except in compliance
// with the License. You may obtain a copy of the License at:
//
// http://www.netfpga-cic.org
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// @NETFPGA_LICENSE_HEADER_END@


`timescale 1ns/1ps
module prio_enc1 #(
	parameter DATA_WIDTH = 48
)(
	input wire clk,
	input wire rst_n,
	input wire en,

	input wire en_0,
	input wire [DATA_WIDTH-1:0] din_0,

	input wire en_1,
	input wire [DATA_WIDTH-1:0] din_1,

	input wire en_2,
	input wire [DATA_WIDTH-1:0] din_2,

	input wire en_3,
	input wire [DATA_WIDTH-1:0] din_3,


	output wire                  dout_en,
	output wire [DATA_WIDTH-1:0] dout
);


 reg [DATA_WIDTH-1:0] reg_din_0;
 reg                  reg_en_0;
 
 always @ (posedge clk or negedge rst_n)
	if (!rst_n) begin
		reg_din_0 <= 0;
		reg_en_0 <= 0;
	end else begin
		reg_din_0 <= din_0;
		reg_en_0 <= en_0;
	end

 reg [DATA_WIDTH-1:0] reg_din_1;
 reg                  reg_en_1;
 
 always @ (posedge clk or negedge rst_n)
	if (!rst_n) begin
		reg_din_1 <= 0;
		reg_en_1 <= 0;
	end else begin
		reg_din_1 <= din_1;
		reg_en_1 <= en_1;
	end

 reg [DATA_WIDTH-1:0] reg_din_2;
 reg                  reg_en_2;
 
 always @ (posedge clk or negedge rst_n)
	if (!rst_n) begin
		reg_din_2 <= 0;
		reg_en_2 <= 0;
	end else begin
		reg_din_2 <= din_2;
		reg_en_2 <= en_2;
	end

 reg [DATA_WIDTH-1:0] reg_din_3;
 reg                  reg_en_3;
 
 always @ (posedge clk or negedge rst_n)
	if (!rst_n) begin
		reg_din_3 <= 0;
		reg_en_3 <= 0;
	end else begin
		reg_din_3 <= din_3;
		reg_en_3 <= en_3;
	end
 
 reg reg_en;

 always @ (posedge clk or negedge rst_n)
	if (!rst_n) reg_en <= 0;
	else        reg_en <= en;

 assign dout = 	(!reg_en ) ? 0  : (
				(reg_en_0) ? reg_din_0 :
				(reg_en_1) ? reg_din_1 :
				(reg_en_2) ? reg_din_2 :
				(reg_en_3) ? reg_din_3 :
 				0);
 assign dout_en = reg_en;


endmodule

 // This file is generated by ./gen.sh
module prio_enc2 #(
	parameter DATA_WIDTH = 48
)(
	input wire clk,
	input wire rst_n,
	input wire en,

	input wire en_0,
	input wire [DATA_WIDTH-1:0] din_0,

	input wire en_1,
	input wire [DATA_WIDTH-1:0] din_1,

	input wire en_2,
	input wire [DATA_WIDTH-1:0] din_2,

	input wire en_3,
	input wire [DATA_WIDTH-1:0] din_3,

	input wire en_4,
	input wire [DATA_WIDTH-1:0] din_4,

	input wire en_5,
	input wire [DATA_WIDTH-1:0] din_5,

	input wire en_6,
	input wire [DATA_WIDTH-1:0] din_6,

	input wire en_7,
	input wire [DATA_WIDTH-1:0] din_7,


	output wire                  dout_en,
	output wire [DATA_WIDTH-1:0] dout
);


 reg [DATA_WIDTH-1:0] reg_din_0;
 reg                  reg_en_0;
 
 always @ (posedge clk or negedge rst_n)
	if (!rst_n) begin
		reg_din_0 <= 0;
		reg_en_0 <= 0;
	end else begin
		reg_din_0 <= din_0;
		reg_en_0 <= en_0;
	end

 reg [DATA_WIDTH-1:0] reg_din_1;
 reg                  reg_en_1;
 
 always @ (posedge clk or negedge rst_n)
	if (!rst_n) begin
		reg_din_1 <= 0;
		reg_en_1 <= 0;
	end else begin
		reg_din_1 <= din_1;
		reg_en_1 <= en_1;
	end

 reg [DATA_WIDTH-1:0] reg_din_2;
 reg                  reg_en_2;
 
 always @ (posedge clk or negedge rst_n)
	if (!rst_n) begin
		reg_din_2 <= 0;
		reg_en_2 <= 0;
	end else begin
		reg_din_2 <= din_2;
		reg_en_2 <= en_2;
	end

 reg [DATA_WIDTH-1:0] reg_din_3;
 reg                  reg_en_3;
 
 always @ (posedge clk or negedge rst_n)
	if (!rst_n) begin
		reg_din_3 <= 0;
		reg_en_3 <= 0;
	end else begin
		reg_din_3 <= din_3;
		reg_en_3 <= en_3;
	end

 reg [DATA_WIDTH-1:0] reg_din_4;
 reg                  reg_en_4;
 
 always @ (posedge clk or negedge rst_n)
	if (!rst_n) begin
		reg_din_4 <= 0;
		reg_en_4 <= 0;
	end else begin
		reg_din_4 <= din_4;
		reg_en_4 <= en_4;
	end

 reg [DATA_WIDTH-1:0] reg_din_5;
 reg                  reg_en_5;
 
 always @ (posedge clk or negedge rst_n)
	if (!rst_n) begin
		reg_din_5 <= 0;
		reg_en_5 <= 0;
	end else begin
		reg_din_5 <= din_5;
		reg_en_5 <= en_5;
	end

 reg [DATA_WIDTH-1:0] reg_din_6;
 reg                  reg_en_6;
 
 always @ (posedge clk or negedge rst_n)
	if (!rst_n) begin
		reg_din_6 <= 0;
		reg_en_6 <= 0;
	end else begin
		reg_din_6 <= din_6;
		reg_en_6 <= en_6;
	end

 reg [DATA_WIDTH-1:0] reg_din_7;
 reg                  reg_en_7;
 
 always @ (posedge clk or negedge rst_n)
	if (!rst_n) begin
		reg_din_7 <= 0;
		reg_en_7 <= 0;
	end else begin
		reg_din_7 <= din_7;
		reg_en_7 <= en_7;
	end
 
 reg reg_en;

 always @ (posedge clk or negedge rst_n)
	if (!rst_n) reg_en <= 0;
	else        reg_en <= en;

 assign dout = 	(!reg_en ) ? 0  : (
				(reg_en_0) ? reg_din_0 :
				(reg_en_1) ? reg_din_1 :
				(reg_en_2) ? reg_din_2 :
				(reg_en_3) ? reg_din_3 :
				(reg_en_4) ? reg_din_4 :
				(reg_en_5) ? reg_din_5 :
				(reg_en_6) ? reg_din_6 :
				(reg_en_7) ? reg_din_7 :
 				0);
 assign dout_en = reg_en;


endmodule

