/*******************************************************************************
*
* Copyright (C) 2010, 2011 The Board of Trustees of The Leland Stanford
*                          Junior University
* Copyright (C) grg, Gianni Antichi
* All rights reserved.
*
* This software was developed by
* Stanford University and the University of Cambridge Computer Laboratory
* under National Science Foundation under Grant No. CNS-0855268,
* the University of Cambridge Computer Laboratory under EPSRC INTERNET Project EP/H040536/1 and
* by the University of Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-11-C-0249 ("MRC2"), 
* as part of the DARPA MRC research programme.
*
* @NETFPGA_LICENSE_HEADER_START@
*
* Licensed to NetFPGA C.I.C. (NetFPGA) under one or more contributor
* license agreements. See the NOTICE file distributed with this work for
* additional information regarding copyright ownership. NetFPGA licenses this
* file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
* "License"); you may not use this file except in compliance with the
* License. You may obtain a copy of the License at:
*
* http://www.netfpga-cic.org
*
* Unless required by applicable law or agreed to in writing, Work distributed
* under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
* CONDITIONS OF ANY KIND, either express or implied. See the License for the
* specific language governing permissions and limitations under the License.
*
* @NETFPGA_LICENSE_HEADER_END@
*
*******************************************************************************/


  module order_id_mapping
    #(parameter C_S_AXIS_DATA_WIDTH	= 256,
      parameter LUT_DEPTH		= 512,
      parameter LUT_DEPTH_BITS		= log2(LUT_DEPTH)
      )
   (
    // --- Interface to registers
    // --- Read port
    input [12:0]                                     order_id_mapping_rd_addr,
    input                                            order_id_mapping_rd_req,
    output reg [47:0]                                order_id_mapping_rd_data,
    output reg                                       order_id_mapping_rd_ack,

    // --- Write port
    input [11:0]		                     order_id_mapping_wr_addr,
    input                                            order_id_mapping_wr_req,
    input [47:0]                                     order_id_mapping_wr_data,
    output reg                                       order_id_mapping_wr_ack,

    input 					     order_match_req,
    output reg					     order_match_ack,
    input [13:0]				     order_match_addr,
    output reg [47:0]				     order_match_data,
//    output reg [199:0]				     order_content,
    output reg [201:0]				     order_content,

    // --- order content
    output reg	  			order_rd,
//     input [198:0] 			order_out,
    input [234:0]			order_out,

    input        			order_vld,


    // --- Read port
    input [12:0]                                     order_id_store_rd_addr,
    input                                            order_id_store_rd_req,
    output reg [202:0]                                order_id_store_rd_data,
    output reg                                       order_id_store_rd_ack,

    // --- Write port
    input [11:0]                                     order_id_store_wr_addr,
    input                                            order_id_store_wr_req,
    input [202:0]                                     order_id_store_wr_data,
    output reg                                       order_id_store_wr_ack,

    
    // --- Misc
    input                              reset,
    input                              clk
   );


   function integer log2;
      input integer number;
      begin
         log2=0;
         while(2**log2<number) begin
            log2=log2+1;
         end
      end
   endfunction // log2

   localparam	WAIT	= 1;
   localparam	READ_0	= 2;
   localparam	READ_1	= 4;
   localparam	WRITE_0	= 8;
   localparam	WRITE_1	= 16;
   localparam   WRITE_2 = 32;
   localparam	DONE	= 64;
   localparam   WRITE_BUY_TABLE = 128;
   localparam   WRITE_SELL_TABLE= 256;
   localparam   WRITE_3 = 258;
   //---------------------- Wires and regs----------------------------

   reg  [47:0] commodity_code_compare;
   reg  [47:0] commodity_code_compare_reg;


   reg         in_fifo_wr;
   //reg         in_fifo_rd;
   reg  [47:0] stock_code_in;
   wire [47:0] stock_code_out;
   wire        in_fifo_empty;
   wire        in_fifo_nearly_full;
   reg         write_en;

   reg  [47:0]				 din_data_a;
   reg  [9:0]				 addr_a;
   reg  [9:0]				 addr_a_reg;
   wire [47:0] 				 dout_a;
   wire        				 vld_a;
   reg					 we_a;
   
   reg  [47:0]				 din_data_b;
   reg  [9:0]				 addr_b;
   reg  [9:0]				 addr_b_reg;
   wire [47:0] 				 dout_b;
   wire        				 vld_b;
   reg					 we_b;
   
   reg  [47:0]				 din_data_c;
   reg  [9:0]				 addr_c;
   reg  [9:0]				 addr_c_reg;
   wire [47:0] 				 dout_c;
   wire        				 vld_c;
   reg					 we_c;
   
   reg  [47:0]				 din_data_d;
   reg  [9:0]				 addr_d;
   reg  [9:0]				 addr_d_reg;
   wire [47:0] 				 dout_d;
   wire        				 vld_d;
   reg					 we_d;
   
   wire			match_a;
   wire			match_b;
   wire			match_c;
   wire			match_d;
   
   reg [15:0]                             state,state_next;

   reg [47:0]  order_id_mapping_rd_data_logic;
   reg         order_id_mapping_rd_ack_logic;
   reg [47:0]  order_id_mapping_wr_data_logic;
   reg         order_id_mapping_wr_ack_logic;

   reg [47:0]  order_match_data_logic;
   reg	       order_match_ack_logic;

   reg         in_fifo_wr_ci;
   reg         in_fifo_rd_ci;
   reg  [71:0] commodity_index_in;
//   wire [21:0] commodity_index_out;
   wire        in_fifo_empty_ci;
   wire        in_fifo_nearly_full_ci;

   reg  [3:0]  current_owner;
   reg  [3:0]  current_owner_reg;

   wire [5:0]  total_commodity;
   reg  [60:0] order_index_in;
   //wire [11:0] order_index_out;
   reg  [5:0]  counter;
   reg  [5:0]  counter_reg;


   reg  [47:0] order_code_hash;
   reg  [47:0] order_code_hash_reg;
   reg  [47:0] order_code_compare;
   reg  [47:0] order_code_compare_reg;
   wire [9:0]  hash_addr_a;
   wire [9:0]  hash_addr_b;
   wire [9:0]  hash_addr_c;
   wire [9:0]  hash_addr_d;
   reg [3:0]   wait_hash_reg;
   reg [3:0]   wait_hash;








   //reg [199:0]  order_content_logic;
   reg [201:0]  order_content_logic;

//new 
   

/* old
   reg  [199:0]				 order_din_data_a;
 

   reg  [11:0]				 order_addr_a;
   reg  [11:0]				 order_addr_a_reg;
   wire [199:0] 				 order_dout_a;

   wire        				 order_vld_a;
   reg					 order_we_a;
   
   reg  [199:0]				 order_din_data_b;

   reg  [11:0]				 order_addr_b;
   reg  [11:0]				 order_addr_b_reg;
   wire [199:0] 				 order_dout_b;


   wire        				 order_vld_b;
   reg					 order_we_b;
*/

//new
   reg  [792:0]                          order_din_data_a;


   reg  [11:0]                           order_addr_a;
   reg  [11:0]                           order_addr_a_reg;
   wire [792:0]                                  order_dout_a;

   wire                                  order_vld_a;
   reg                                   order_we_a;

   reg  [792:0]                          order_din_data_b;

   reg  [11:0]                           order_addr_b;
   reg  [11:0]                           order_addr_b_reg;
   wire [792:0]                                  order_dout_b;


   reg  [11:0]				 order_price_addr_a ;
   reg  [11:0]				 order_price_addr_a_reg;
   reg  [11:0]				 order_price_addr_b ;
   reg  [11:0]				 order_price_addr_b_reg;


   wire                                  order_vld_b;
   reg                                   order_we_b;

   reg  [182:0]				 order_price_din_data_a;
   reg  [182:0]				 order_price_din_data_b;
   wire  [182:0]		         order_price_dout_a;
   wire  [182:0]			 order_price_dout_b;

   reg 					 order_price_we_a ; 
   reg					 order_price_we_b;

   reg   [792:0]			 order_din_reg_a ; 
   reg   [792:0]			 order_din_reg_b ;
 
   reg   [182:0]			 order_price_din_reg_a;
   reg   [182:0]			 order_price_din_reg_b;


  
   reg [202:0]  order_id_store_rd_data_logic;
   reg         order_id_store_rd_ack_logic;
   reg [202:0]  order_id_store_wr_data_logic;
   reg         order_id_store_wr_ack_logic;


   reg   [792:0]                         order_dout_reg_a ;
   reg   [792:0]                         order_dout_reg_b ;

   reg   [182:0]                         order_price_dout_reg_a;
   reg   [182:0]                         order_price_dout_reg_b;

   reg   [792:0]			 order_din_reg_a_seq;
   reg   [792:0]			 order_din_reg_b_seq;
  
   reg   [182:0]			 order_price_din_reg_a_seq;
   reg   [182:0]			 order_price_din_reg_b_seq;

   //------------------------- Modules-------------------------------




   //----------------------------
   //     4 HASH UNITS
   //----------------------------
   one_at_a_time0
      one_at_a_time0
          (.clk(clk),
           .reset(reset),
           .in_data(order_code_hash_reg),
           .out_data(hash_addr_a)
          );

   one_at_a_time1
      one_at_a_time1
          (.clk(clk),
           .reset(reset),
           .in_data(order_code_hash_reg),
           .out_data(hash_addr_b)
          );
   one_at_a_time2
      one_at_a_time2
          (.clk(clk),
           .reset(reset),
           .in_data(order_code_hash_reg),
           .out_data(hash_addr_c)
          );

   one_at_a_time3
      one_at_a_time3
          (.clk(clk),
           .reset(reset),
           .in_data(order_code_hash_reg),
           .out_data(hash_addr_d)
          );





   warrants_code_1024x48   // --- order table
      warrants_code_1024x48_0
      (.addr_a  (addr_a_reg),
       .din_a   (din_data_a),
       .dout_a  (dout_a),
       .clk_a   (clk),
       .we_a    (we_a)
      );
      
   warrants_code_1024x48  // --- order table
      warrants_code_1024x48_1
      (.addr_a  (addr_b_reg),
       .din_a   (din_data_b),
       .dout_a  (dout_b),
       .clk_a   (clk),
       .we_a    (we_b)
      );
   warrants_code_1024x48  // --- order table
      warrants_code_1024x48_2
      (.addr_a  (addr_c_reg),
       .din_a   (din_data_c),
       .dout_a  (dout_c),
       .clk_a   (clk),
       .we_a    (we_c)
      );
   warrants_code_1024x48  // --- order table 
      warrants_code_1024x48_3
      (.addr_a  (addr_d_reg),
       .din_a   (din_data_d),
       .dout_a  (dout_d),
       .clk_a   (clk),
       .we_a    (we_d)
      );

/*
   order_content_4096x200
      order_content_4096x200_0 // buy table
      (.addr_a  (order_addr_a_reg),
       .din_a   (order_din_data_a),
       .dout_a  (order_dout_a),
       .clk_a   (clk),
       .we_a    (order_we_a)
      );

   order_content_4096x200
      order_content_4096x200_1 // sell table
      (.addr_a  (order_addr_b_reg),
       .din_a   (order_din_data_b),
       .dout_a  (order_dout_b),
       .clk_a   (clk),
       .we_a    (order_we_b)
      );
*/


   order_content_4096x793
      order_content_4096x793_0 // buy table
      (.addr_a  (order_addr_a_reg),
       .din_a   (order_din_data_a),
       .dout_a  (order_dout_a),
       .clk_a   (clk),
       .we_a    (order_we_a)
      );

   order_content_4096x793
      order_content_4096x793_1 // sell table
      (.addr_a  (order_addr_b_reg),
       .din_a   (order_din_data_b),
       .dout_a  (order_dout_b),
       .clk_a   (clk),
       .we_a    (order_we_b)
      );


    order_content_price_4096x183
	order_content_price_4096x183_0
       (.addr_a  (order_price_addr_a_reg),
        .din_a   (order_price_din_data_a),
        .dout_a  (order_price_dout_a),
        .clk_a   (clk),
        .we_a    (order_price_we_a)
       );


    order_content_price_4096x183
        order_content_price_4096x183_1
       (.addr_a  (order_price_addr_b_reg),
        .din_a   (order_price_din_data_b),
        .dout_a  (order_price_dout_b),
        .clk_a   (clk),
        .we_a    (order_price_we_b)
       );





//------- Logic -------------------//
	assign match_a          =   dout_a == order_code_compare_reg;
        assign match_b          =   dout_b == order_code_compare_reg;
	assign match_c          =   dout_c == order_code_compare_reg;
        assign match_d          =   dout_d == order_code_compare_reg;



    always @(*) begin
        
        state_next = state;
	din_data_a = 48'h0;
	addr_a     = addr_a_reg;
	we_a       = 'b0;
	din_data_b = 48'h0;
	addr_b     = addr_b_reg;
	we_b       = 'b0;
	din_data_c = 48'h0;
	addr_c     = addr_c_reg;
	we_c       = 'b0;
	din_data_d = 48'h0;
	addr_d     = addr_d_reg;
	we_d       = 'b0;
	order_id_mapping_rd_ack_logic  =  order_id_mapping_rd_ack;
        order_id_mapping_wr_ack_logic  =  order_id_mapping_wr_ack;
        order_id_mapping_rd_data_logic   =  order_id_mapping_rd_data;
	order_match_data_logic		 =  order_match_data;
	order_match_ack_logic		 =  order_match_ack;
	order_content_logic              =  order_content;
	in_fifo_wr = 1'b0;
	// hash counter
        wait_hash                      =  4'd0;
	order_code_hash = order_code_hash_reg;
	order_code_compare = order_code_compare_reg;
	order_addr_a = order_addr_a_reg;
//	order_din_data_a = 200'h0;
        order_din_data_a = 793'h0;
        order_we_a = 'b0; 
	order_addr_b = order_addr_b_reg;
//	order_din_data_b = 200'h0;
	order_din_data_b = 793'h0;
        order_we_b = 'b0; 
        current_owner = 4'd1;
    	counter = counter_reg;    
	order_rd = 'b0;
 
	order_price_din_data_a = 183'h0;
	order_price_din_data_b = 183'h0; 
        order_price_we_a = 'b0;
	order_price_we_b = 'b0;

	order_price_addr_a = order_price_addr_a_reg;
	order_price_addr_b = order_price_addr_b_reg;

        order_id_store_rd_ack_logic  =  order_id_store_rd_ack;
        order_id_store_rd_data_logic   =  order_id_store_rd_data;


        order_din_reg_a =  order_din_reg_a_seq;
        order_price_din_reg_a = order_price_din_reg_a_seq;
        order_din_reg_b  =  order_din_reg_b_seq;
        order_price_din_reg_b = order_price_din_reg_b_seq;

        case(state)
                WAIT: begin
                        if(order_id_mapping_wr_req && current_owner_reg != 4'd4 && current_owner_reg != 4'd8 && current_owner_reg != 4'd10) begin
                                addr_a = order_id_mapping_wr_addr[9:0];
                                addr_b = order_id_mapping_wr_addr[9:0];
                                addr_c = order_id_mapping_wr_addr[9:0];
                                addr_d = order_id_mapping_wr_addr[9:0];
                                state_next = WRITE_0;
				current_owner      =  4'd2;
                        end
                        else if(order_id_mapping_rd_req&& current_owner_reg != 4'd4 && current_owner_reg != 4'd8 && current_owner_reg != 4'd10) begin
                                state_next = READ_0;
                                addr_a = order_id_mapping_rd_addr[9:0];
                                addr_b = order_id_mapping_rd_addr[9:0];
                                addr_c = order_id_mapping_rd_addr[9:0];
                                addr_d = order_id_mapping_rd_addr[9:0];
				order_addr_a = order_id_mapping_rd_addr;
				order_addr_b = order_id_mapping_rd_addr;
				order_price_addr_a = order_id_mapping_rd_addr;
				order_price_addr_b = order_id_mapping_rd_addr;
				current_owner      =  4'd2;
                        end
			else if(order_match_req && current_owner_reg != 4'd2 && current_owner_reg != 4'd8 && current_owner_reg != 4'd10) begin // warrants
                                state_next = READ_0;
                                addr_a = order_match_addr[9:0];
                                addr_b = order_match_addr[9:0];
                                addr_c = order_match_addr[9:0];
                                addr_d = order_match_addr[9:0];
				order_addr_a = order_match_addr;
				order_addr_b = order_match_addr;
				order_price_addr_a = order_match_addr;
				order_price_addr_b = order_match_addr;
				current_owner      =  4'd4;
			end
                        else if(order_id_store_rd_req && current_owner_reg != 4'd4 && current_owner_reg != 4'd8 && current_owner_reg != 4'd2) begin
                                state_next = READ_0;
                                addr_a = order_id_store_rd_addr[9:0];
                                addr_b = order_id_store_rd_addr[9:0];
                                addr_c = order_id_store_rd_addr[9:0];
                                addr_d = order_id_store_rd_addr[9:0];
                                order_addr_a = order_id_store_rd_addr;
                                order_addr_b = order_id_store_rd_addr;
				order_price_addr_a = order_id_store_rd_addr;
				order_price_addr_b = order_id_store_rd_addr;
                                current_owner      =  4'd10;
                        end

			else if(order_vld && current_owner_reg != 4'd2 && current_owner_reg != 4'd4 && current_owner_reg != 4'd10) begin  // store order
	

                                order_code_hash = order_out[98:51];
                                order_code_compare = order_out[98:51];

				addr_a = hash_addr_a;
				addr_b = hash_addr_b;
				addr_c = hash_addr_c;
				addr_d = hash_addr_d;
				wait_hash          =  wait_hash_reg + 4'd1;
				current_owner      =  4'd8;
				if(wait_hash_reg == 4'd8) begin
					state_next = WRITE_0;
				end
			end
                end
                WRITE_0: begin
			current_owner =  current_owner_reg;
                        state_next    =  WRITE_1;  
                end
                WRITE_1: begin 
		    if(current_owner_reg == 4'd2) begin // load order_id_mapping table
                    	if(order_id_mapping_wr_addr[11:10] == 2'b00) begin
                		we_a       = 'b1;
                		din_data_a = order_id_mapping_wr_data;
                   	end
                    	else if(order_id_mapping_wr_addr[11:10] == 2'b01) begin
                		we_b       = 'b1;
                		din_data_b = order_id_mapping_wr_data;
                    	end
                    	else if(order_id_mapping_wr_addr[11:10] == 2'b10) begin
                		we_c       = 'b1;
                		din_data_c = order_id_mapping_wr_data;
                    	end
                    	else if(order_id_mapping_wr_addr[11:10] == 2'b11) begin
                		we_d       = 'b1;
                		din_data_d = order_id_mapping_wr_data;
                    	end
	                order_id_mapping_wr_ack_logic = 'b1;
		    	state_next = DONE;
		    end
		    else if(current_owner_reg == 4'd8) begin // write order content into order content table
			if(match_a) begin
				order_addr_a     = {2'b00, addr_a_reg};
				order_addr_b     = {2'b00, addr_a_reg};
                                order_price_addr_a  = {2'b00, addr_a_reg};
                                order_price_addr_b = {2'b00, addr_a_reg};
			end
			else if(match_b) begin
				order_addr_a     = {2'b01, addr_b_reg};
				order_addr_b     = {2'b01, addr_b_reg};
                                order_price_addr_a     = {2'b01, addr_b_reg};
                                order_price_addr_b     = {2'b01, addr_b_reg};

			end
			else if(match_c) begin
				order_addr_a     = {2'b10, addr_c_reg};
				order_addr_b     = {2'b10, addr_c_reg};
                                order_price_addr_a     = {2'b10, addr_c_reg};
                                order_price_addr_b     = {2'b10, addr_c_reg};
			end
			else if(match_d) begin
				order_addr_a     = {2'b11, addr_d_reg};
				order_addr_b     = {2'b11, addr_d_reg};
                                order_price_addr_a     = {2'b11, addr_d_reg};
                                order_price_addr_b     = {2'b11, addr_d_reg};

			end
		    	state_next = WRITE_2;
        	        
		    end
		end

		WRITE_2: begin  //If Side is buy or sell 
/*
		    case(order_out[50:49])
                    2'b01: begin
				case(order_price_dout_reg_a[182:180])
				3'b000:begin
                                 order_din_reg_a[792:745] = order_out[98:51];
                                 order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],596'b0};
                                 order_price_din_reg_a = {3'b001,order_out[48:13],144'b0};
				 state_next = WRITE_BUY_TABLE;
				end
				3'b001:begin
                                 if(order_out[48:13]>order_price_dout_reg_a[179:144])begin
                                         order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],order_dout_reg_a[744:596],447'b0} ;
                                         order_price_din_reg_a = {3'b010,order_out[48:13],order_price_dout_reg_a[179:144],108'b0};
					 state_next = WRITE_BUY_TABLE;
                                 end
                                 else begin
                                         order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_dout_reg_a[744:596],order_out[234:99],order_out[12:0],447'b0};
                                         order_price_din_reg_a = {3'b010,order_price_dout_reg_a[179:144],order_out[48:13],108'b0};
					 state_next = WRITE_BUY_TABLE;
                                 end
				end
				3'b010:begin
                                 if(order_out[48:13]>order_price_dout_reg_a[179:144])begin
                                         order_din_reg_a[792:745] = order_out[98:51];
                                        order_din_reg_a[744:0]={order_out[234:99],order_out[12:0],order_dout_reg_a[744:447],298'b0};
                                        order_price_din_reg_a = {3'b011,order_out[48:13],order_price_dout_reg_a[179:108],72'b0};
					state_next = WRITE_BUY_TABLE;
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_reg_a[143:108])begin
                                                order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_reg_a[744:596],order_out[234:99],order_out[12:0],order_dout_reg_a[595:447],298'b0};
                                                order_price_din_reg_a = {3'b011,order_price_dout_reg_a[179:144],order_out[48:13],order_price_dout_reg_a[143:108],72'b0};
						state_next = WRITE_BUY_TABLE;
                                        end
                                        else begin // A  B in
                                                order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_reg_a[744:447],order_out[234:99],order_out[12:0],298'b0};
                                                order_price_din_reg_a = {3'b011,order_price_dout_reg_a[179:108],order_out[48:13],72'b0};
						state_next = WRITE_BUY_TABLE ;
                                        end
                                 end
				end
				3'b011:begin
                                 if(order_out[48:13]>order_price_dout_reg_a[179:144])begin
                                         order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],order_dout_reg_a[744:298],149'b0} ;
                                         order_price_din_reg_a = {3'b100,order_out[48:13],order_price_dout_reg_a[179:72],36'b0};
					 state_next = WRITE_BUY_TABLE;
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_reg_a[143:108])begin
                                                order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_reg_a[744:596],order_out[234:99],order_out[12:0],order_dout_reg_a[595:298],149'b0};
                                                order_price_din_reg_a = {3'b100,order_price_dout_reg_a[179:144],order_out[48:13],order_price_dout_reg_a[143:72],36'b0};
						state_next = WRITE_BUY_TABLE;
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_reg_a[107:72])begin
                                                         order_din_reg_a[792:745] = order_out[98:51];
                                                         order_din_reg_a[744:0] = {order_dout_reg_a[744:447],order_out[234:99],order_out[12:0],order_dout_reg_a[446:298],149'b0};
                                                         order_price_din_reg_a = {3'b100,order_price_dout_reg_a[179:108],order_out[48:13],order_price_dout_reg_a[107:72],36'b0};
							state_next = WRITE_BUY_TABLE;
                                                end
                                                else begin
                                                        order_din_reg_a[792:745] = order_out[98:51];
                                                        order_din_reg_a[744:0] = { order_dout_reg_a[744:298],order_out[234:99],order_out[12:0],149'b0};
                                                        order_price_din_reg_a = {3'b100,order_price_dout_reg_a[179:72],order_out[48:13],36'b0};
							state_next = WRITE_BUY_TABLE;
                                                end

                                        end
                                 end
				end
				3'b100:begin
                                 if(order_out[48:13]>order_price_dout_reg_a[179:144])begin //0:4
                                         order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],order_dout_reg_a[744:149]};
                                         order_price_din_reg_a = {3'b101,order_out[48:13],order_price_dout_reg_a[179:36]};
					 state_next = WRITE_BUY_TABLE;
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_reg_a[143:108])begin //1:3
                                                order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_reg_a[744:596],order_out[234:99],order_out[12:0],order_dout_reg_a[595:149]};
                                                order_price_din_reg_a = {3'b101,order_price_dout_reg_a[179:144],order_out[48:13],order_price_dout_reg_a[143:36]};
						state_next = WRITE_BUY_TABLE;
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_reg_a[107:72])begin //2:2
                                                        order_din_reg_a[792:745] = order_out[98:51];
                                                        order_din_reg_a[744:0]= {order_dout_reg_a[744:447],order_out[234:99],order_out[12:0],order_dout_reg_a[446:149]};
                                                        order_price_din_reg_a = {3'b101,order_price_dout_reg_a[179:108],order_out[48:13],order_price_dout_reg_a[107:36]};
							state_next = WRITE_BUY_TABLE ;
                                                end
                                                else begin
                                                        if(order_out[48:13]>order_price_dout_reg_a[71:36])begin  //3:1
                                                                order_din_reg_a[792:745] = order_out[98:51];
                                                                order_din_reg_a[744:0]={order_dout_reg_a[744:298],order_out[234:99],order_out[12:0],order_dout_reg_a[297:149]};
                                                                order_price_din_reg_a = {3'b101,order_price_dout_reg_a[179:72],order_out[48:13],order_price_dout_reg_a[71:36]};
								state_next = WRITE_BUY_TABLE ;
                                                        end
                                                        else begin
                                                                order_din_reg_a[792:745] = order_out[98:51];
                                                                order_din_reg_a[744:0] = {order_dout_reg_a[744:149],order_out[234:99],order_out[12:0]};
                                                                order_price_din_reg_a = {3'b101,order_price_dout_reg_a[179:36],order_out[48:13]};
								state_next = WRITE_BUY_TABLE ;
                                                        end
                                                end
                                        end
                                 end
				end
				3'b101:begin
                                 if(order_out[48:13]>order_price_dout_reg_a[179:144])begin //0:4
                                         order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],order_dout_reg_a[595:0]};
                                         order_price_din_reg_a = {3'b101,order_out[48:13],order_price_dout_reg_a[143:0]};
					 state_next = WRITE_BUY_TABLE ;
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_reg_a[143:108])begin //1:3
                                                order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_a[744:596],order_out[234:99],order_out[12:0],order_dout_reg_a[446:0]};
                                                order_price_din_reg_a = {3'b101,order_price_dout_reg_a[179:144],order_out[48:13],order_price_dout_reg_a[107:0]};
						state_next = WRITE_BUY_TABLE ;
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_reg_a[107:72])begin //2:2
                                                        order_din_reg_a[792:745] = order_out[98:51];
                                                        order_din_reg_a[744:0]= {order_dout_reg_a[744:447],order_out[234:99],order_out[12:0],order_dout_reg_a[297:0]};
                                                        order_price_din_reg_a = {3'b101,order_price_dout_reg_a[179:108],order_out[48:13],order_price_dout_reg_a[71:0]};
							state_next = WRITE_BUY_TABLE ;
                                                end
                                                else begin
                                                        if(order_out[48:13]>order_price_dout_reg_a[71:36])begin  //3:1
                                                                order_din_reg_a[792:745] = order_out[98:51];
                                                                order_din_reg_a[744:0]={order_dout_reg_a[744:298],order_out[234:99],order_out[12:0],order_dout_reg_a[148:0]};
                                                                order_price_din_reg_a = {3'b101,order_price_dout_reg_a[179:72],order_out[48:13],order_price_dout_reg_a[36:0]};
								state_next = WRITE_BUY_TABLE;
                                                        end
                                                        else begin
                                                                order_din_reg_a[792:745] = order_out[98:51];
                                                                order_din_reg_a[744:0] = {order_dout_reg_a[744:149],order_out[234:99],order_out[12:0]};
                                                                order_price_din_reg_a = {3'b101,order_price_dout_reg_a[179:36],order_out[48:13]};
								state_next = WRITE_BUY_TABLE ;
                                                        end
                                                end
                                        end
                                 end
				end
				default:begin
					order_din_reg_a = 'h0;
					order_price_din_reg_a = 'h0;
				end
				endcase
		    end
		    2'b10:begin
                                case(order_price_dout_reg_b[182:180])
                                3'b000:begin
                                 	order_din_reg_b[792:745] = order_out[98:51];
                                 	order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],596'b0};
                                 	order_price_din_reg_b = {3'b001,order_out[48:13],144'b0};
				 	state_next = WRITE_SELL_TABLE;
                                end
                                3'b001:begin
                                 if(order_out[48:13]>order_price_dout_reg_b[179:144])begin
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],order_dout_reg_b[744:596],447'b0} ;
                                         order_price_din_reg_b = {3'b010,order_out[48:13],order_price_dout_reg_b[179:144],108'b0};
					 state_next = WRITE_SELL_TABLE;
                                 end
                                 else begin
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_dout_reg_b[744:596],order_out[234:99],order_out[12:0],447'b0};
                                         order_price_din_reg_b = {3'b010,order_price_dout_reg_b[179:144],order_out[48:13],108'b0};
					 state_next = WRITE_SELL_TABLE;
                                 end
                                end
                                3'b010:begin
                                 if(order_out[48:13]>order_price_dout_reg_b[179:144])begin
                                         order_din_reg_b[792:745] = order_out[98:51];
                                        order_din_reg_b[744:0]={order_out[234:99],order_out[12:0],order_dout_reg_b[744:447],298'b0};
                                        order_price_din_reg_b = {3'b011,order_out[48:13],order_price_dout_reg_b[179:108],72'b0};
					state_next = WRITE_SELL_TABLE;
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_reg_b[143:108])begin
                                                order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_reg_b[744:596],order_out[234:99],order_out[12:0],order_dout_reg_b[595:447],298'b0};
                                                order_price_din_reg_b = {3'b011,order_price_dout_reg_b[179:144],order_out[48:13],order_price_dout_reg_b[143:108],72'b0};
						state_next = WRITE_SELL_TABLE;
                                        end
                                        else begin // A  B in
                                                order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_reg_b[744:447],order_out[234:99],order_out[12:0],298'b0};
                                                order_price_din_reg_b = {3'b011,order_price_dout_reg_b[179:108],order_out[48:13],72'b0};
						state_next = WRITE_SELL_TABLE;
                                        end
                                 end
                                end
                                3'b011:begin
                                 if(order_out[48:13]>order_price_dout_reg_b[179:144])begin
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],order_dout_reg_b[744:298],149'b0} ;
                                         order_price_din_reg_b = {3'b100,order_out[48:13],order_price_dout_reg_b[179:72],36'b0};
					 state_next = WRITE_SELL_TABLE;
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_reg_b[143:108])begin
                                                order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_reg_b[744:596],order_out[234:99],order_out[12:0],order_dout_reg_b[595:298],149'b0};
                                                order_price_din_reg_b = {3'b100,order_price_dout_reg_b[179:144],order_out[48:13],order_price_dout_reg_b[143:72],36'b0};
						state_next = WRITE_SELL_TABLE;
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_reg_b[107:72])begin
                                                         order_din_reg_b[792:745] = order_out[98:51];
                                                         order_din_reg_b[744:0] = {order_dout_reg_b[744:447],order_out[234:99],order_out[12:0],order_dout_reg_b[446:298],149'b0};
                                                         order_price_din_reg_b = {3'b100,order_price_dout_reg_b[179:108],order_out[48:13],order_price_dout_reg_b[107:72],36'b0};
							 state_next = WRITE_SELL_TABLE;
                                                end
                                                else begin
                                                        order_din_reg_b[792:745] = order_out[98:51];
                                                        order_din_reg_b[744:0] = { order_dout_reg_b[744:298],order_out[234:99],order_out[12:0],149'b0};
                                                        order_price_din_reg_b = {3'b100,order_price_dout_reg_b[179:72],order_out[48:13],36'b0};
							state_next = WRITE_SELL_TABLE;
                                                end

                                        end
                                 end
                                end

                                3'b100:begin
                                 if(order_out[48:13]>order_price_dout_reg_b[179:144])begin //0:4
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],order_dout_reg_b[744:149]};
                                         order_price_din_reg_b = {3'b101,order_out[48:13],order_price_dout_reg_b[179:36]};
					 state_next = WRITE_SELL_TABLE;
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_reg_b[143:108])begin //1:3
                                                order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_reg_b[744:596],order_out[234:99],order_out[12:0],order_dout_reg_b[595:149]};
                                                order_price_din_reg_b = {3'b101,order_price_dout_reg_b[179:144],order_out[48:13],order_price_dout_reg_b[143:36]};
						state_next = WRITE_SELL_TABLE;
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_reg_b[107:72])begin //2:2
                                                        order_din_reg_b[792:745] = order_out[98:51];
                                                        order_din_reg_b[744:0]= {order_dout_reg_b[744:447],order_out[234:99],order_out[12:0],order_dout_reg_b[446:149]};
                                                        order_price_din_reg_b = {3'b101,order_price_dout_reg_b[179:108],order_out[48:13],order_price_dout_reg_b[107:36]};
							state_next = WRITE_SELL_TABLE ;
                                                end
                                                else begin
                                                        if(order_out[48:13]>order_price_dout_reg_b[71:36])begin  //3:1
                                                                order_din_reg_b[792:745] = order_out[98:51];
                                                                order_din_reg_b[744:0]={order_dout_reg_b[744:298],order_out[234:99],order_out[12:0],order_dout_reg_b[297:149]};
                                                                order_price_din_reg_b = {3'b101,order_price_dout_reg_b[179:72],order_out[48:13],order_price_dout_reg_b[71:36]};
								state_next = WRITE_SELL_TABLE;
                                                        end
                                                        else begin
                                                                order_din_reg_b[792:745] = order_out[98:51];
                                                                order_din_reg_b[744:0] = {order_dout_reg_b[744:149],order_out[234:99],order_out[12:0]};
                                                                order_price_din_reg_b = {3'b101,order_price_dout_reg_b[179:36],order_out[48:13]};
								state_next = WRITE_SELL_TABLE;
                                                        end
                                                end
                                        end
                                 end
                                end
                                3'b101:begin
                                 if(order_out[48:13]>order_price_dout_reg_b[179:144])begin //0:4
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],order_dout_reg_b[595:0]};
                                         order_price_din_reg_b = {3'b101,order_out[48:13],order_price_dout_reg_b[143:0]};
					 state_next = WRITE_SELL_TABLE ;
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_reg_b[143:108])begin //1:3
                                                order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_reg_b[744:596],order_out[234:99],order_out[12:0],order_dout_reg_b[446:0]};
                                                order_price_din_reg_b = {3'b101,order_price_dout_reg_b[179:144],order_out[48:13],order_price_dout_reg_b[107:0]};
						state_next = WRITE_SELL_TABLE;
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_reg_b[107:72])begin //2:2
                                                        order_din_reg_b[792:745] = order_out[98:51];
                                                        order_din_reg_b[744:0]= {order_dout_reg_b[744:447],order_out[234:99],order_out[12:0],order_dout_reg_b[297:0]};
                                                        order_price_din_reg_b = {3'b101,order_price_dout_reg_b[179:108],order_out[48:13],order_price_dout_reg_b[71:0]};
							state_next = WRITE_SELL_TABLE;
                                                end
                                                else begin
                                                        if(order_out[48:13]>order_price_dout_reg_b[71:36])begin  //3:1
                                                                order_din_reg_b[792:745] = order_out[98:51];
                                                                order_din_reg_b[744:0]={order_dout_reg_b[744:298],order_out[234:99],order_out[12:0],order_dout_reg_b[148:0]};
                                                                order_price_din_reg_b = {3'b101,order_price_dout_reg_b[179:72],order_out[48:13],order_price_dout_reg_b[36:0]};
								state_next = WRITE_SELL_TABLE;
                                                        end
                                                        else begin
                                                                order_din_reg_b[792:745] = order_out[98:51];
                                                                order_din_reg_b[744:0] = {order_dout_reg_b[744:149],order_out[234:99],order_out[12:0]};
                                                                order_price_din_reg_b = {3'b101,order_price_dout_reg_b[179:36],order_out[48:13]};
								state_next = WRITE_SELL_TABLE;
                                                        end
                                                end
                                        end
                                 end
				end
				default:begin
					order_din_reg_b = 'h0;
					order_price_din_reg_b = 'h0;
				end
				endcase

		    end
		    default:begin

				state_next = DONE;
		    end
		    endcase
*/



		    case(order_out[50:49])
                    2'b01: begin
				case(order_price_dout_a[182:180])
				3'b000:begin
                                 order_din_reg_a[792:745] = order_out[98:51];
                                 order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],596'b0};
                                 order_price_din_reg_a = {3'b001,order_out[48:13],144'b0};
				end
				3'b001:begin
                                 if(order_out[48:13]>order_price_dout_a[179:144])begin
                                         order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],order_dout_a[744:596],447'b0} ;
                                         order_price_din_reg_a = {3'b010,order_out[48:13],order_price_dout_a[179:144],108'b0};
                                 end
                                 else begin
                                         order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_dout_a[744:596],order_out[234:99],order_out[12:0],447'b0};
                                         order_price_din_reg_a = {3'b010,order_price_dout_a[179:144],order_out[48:13],108'b0};
                                 end
				end
				3'b010:begin
                                 if(order_out[48:13]>order_price_dout_a[179:144])begin
                                         order_din_reg_a[792:745] = order_out[98:51];
                                        order_din_reg_a[744:0]={order_out[234:99],order_out[12:0],order_dout_a[744:447],298'b0};
                                        order_price_din_reg_a = {3'b011,order_out[48:13],order_price_dout_a[179:108],72'b0};
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_a[143:108])begin
                                                order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_a[744:596],order_out[234:99],order_out[12:0],order_dout_a[595:447],298'b0};
                                                order_price_din_reg_a = {3'b011,order_price_dout_a[179:144],order_out[48:13],order_price_dout_a[143:108],72'b0};
                                        end
                                        else begin // A  B in
                                                order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_a[744:447],order_out[234:99],order_out[12:0],298'b0};
                                                order_price_din_reg_a = {3'b011,order_price_dout_a[179:108],order_out[48:13],72'b0};
                                        end
                                 end
				end
				3'b011:begin
                                 if(order_out[48:13]>order_price_dout_a[179:144])begin
                                         order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],order_dout_a[744:298],149'b0} ;
                                         order_price_din_reg_a = {3'b100,order_out[48:13],order_price_dout_a[179:72],36'b0};

                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_a[143:108])begin
                                                order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_a[744:596],order_out[234:99],order_out[12:0],order_dout_a[595:298],149'b0};
                                                order_price_din_reg_a = {3'b100,order_price_dout_a[179:144],order_out[48:13],order_price_dout_a[143:72],36'b0};
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_a[107:72])begin
                                                         order_din_reg_a[792:745] = order_out[98:51];
                                                         order_din_reg_a[744:0] = {order_dout_a[744:447],order_out[234:99],order_out[12:0],order_dout_a[446:298],149'b0};
                                                         order_price_din_reg_a = {3'b100,order_price_dout_a[179:108],order_out[48:13],order_price_dout_a[107:72],36'b0};
                                                end
                                                else begin
                                                        order_din_reg_a[792:745] = order_out[98:51];
                                                        order_din_reg_a[744:0] = { order_dout_a[744:298],order_out[234:99],order_out[12:0],149'b0};
                                                        order_price_din_reg_a = {3'b100,order_price_dout_a[179:72],order_out[48:13],36'b0};
                                                end

                                        end
                                 end
				end
				3'b100:begin
                                 if(order_out[48:13]>order_price_dout_a[179:144])begin //0:4
                                         order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],order_dout_a[744:149]};
                                         order_price_din_reg_a = {3'b101,order_out[48:13],order_price_dout_a[179:36]};
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_a[143:108])begin //1:3
                                                order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_a[744:596],order_out[234:99],order_out[12:0],order_dout_a[595:149]};
                                                order_price_din_reg_a = {3'b101,order_price_dout_a[179:144],order_out[48:13],order_price_dout_a[143:36]};
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_a[107:72])begin //2:2
                                                        order_din_reg_a[792:745] = order_out[98:51];
                                                        order_din_reg_a[744:0]= {order_dout_a[744:447],order_out[234:99],order_out[12:0],order_dout_a[446:149]};
                                                        order_price_din_reg_a = {3'b101,order_price_dout_a[179:108],order_out[48:13],order_price_dout_a[107:36]};
                                                end
                                                else begin
                                                        if(order_out[48:13]>order_price_dout_a[71:36])begin  //3:1
                                                                order_din_reg_a[792:745] = order_out[98:51];
                                                                order_din_reg_a[744:0]={order_dout_a[744:298],order_out[234:99],order_out[12:0],order_dout_a[297:149]};
                                                                order_price_din_reg_a = {3'b101,order_price_dout_a[179:72],order_out[48:13],order_price_dout_a[71:36]};
                                                        end
                                                        else begin
                                                                order_din_reg_a[792:745] = order_out[98:51];
                                                                order_din_reg_a[744:0] = {order_dout_a[744:149],order_out[234:99],order_out[12:0]};
                                                                order_price_din_reg_a = {3'b101,order_price_dout_a[179:36],order_out[48:13]};
                                                        end
                                                end
                                        end
                                 end
				end
				3'b101:begin
                                 if(order_out[48:13]>order_price_dout_a[179:144])begin //0:4
                                         order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],order_dout_a[595:0]};
                                         order_price_din_reg_a = {3'b101,order_out[48:13],order_price_dout_a[143:0]};
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_a[143:108])begin //1:3
                                                order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_a[744:596],order_out[234:99],order_out[12:0],order_dout_a[446:0]};
                                                order_price_din_reg_a = {3'b101,order_price_dout_a[179:144],order_out[48:13],order_price_dout_a[107:0]};
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_a[107:72])begin //2:2
                                                        order_din_reg_a[792:745] = order_out[98:51];
                                                        order_din_reg_a[744:0]= {order_dout_a[744:447],order_out[234:99],order_out[12:0],order_dout_a[297:0]};
                                                        order_price_din_reg_a = {3'b101,order_price_dout_a[179:108],order_out[48:13],order_price_dout_a[71:0]};
                                                end
                                                else begin
                                                        if(order_out[48:13]>order_price_dout_a[71:36])begin  //3:1
                                                                order_din_reg_a[792:745] = order_out[98:51];
                                                                order_din_reg_a[744:0]={order_dout_a[744:298],order_out[234:99],order_out[12:0],order_dout_a[148:0]};
                                                                order_price_din_reg_a = {3'b101,order_price_dout_a[179:72],order_out[48:13],order_price_dout_a[36:0]};
                                                        end
                                                        else begin
                                                                order_din_reg_a[792:745] = order_out[98:51];
                                                                order_din_reg_a[744:0] = {order_dout_a[744:149],order_out[234:99],order_out[12:0]};
                                                                order_price_din_reg_a = {3'b101,order_price_dout_a[179:36],order_out[48:13]};
                                                        end
                                                end
                                        end
                                 end
				end
				default:begin
					order_din_reg_a = 'h0;
					order_price_din_reg_a = 'h0;
				end
				endcase
				state_next = WRITE_BUY_TABLE ;
		    end
		    2'b10:begin
                                case(order_price_dout_b[182:180])
                                3'b000:begin
                                 order_din_reg_b[792:745] = order_out[98:51];
                                 order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],596'b0};
                                 order_price_din_reg_b = {3'b001,order_out[48:13],144'b0};
                                end
                                3'b001:begin
                                 if(order_out[48:13]>order_price_dout_b[179:144])begin
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],order_dout_b[744:596],447'b0} ;
                                         order_price_din_reg_b = {3'b010,order_out[48:13],order_price_dout_b[179:144],108'b0};
                                 end
                                 else begin
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_dout_b[744:596],order_out[234:99],order_out[12:0],447'b0};
                                         order_price_din_reg_b = {3'b010,order_price_dout_b[179:144],order_out[48:13],108'b0};
                                 end
                                end
                                3'b010:begin
                                 if(order_out[48:13]>order_price_dout_b[179:144])begin
                                         order_din_reg_b[792:745] = order_out[98:51];
                                        order_din_reg_b[744:0]={order_out[234:99],order_out[12:0],order_dout_b[744:447],298'b0};
                                        order_price_din_reg_b = {3'b011,order_out[48:13],order_price_dout_b[179:108],72'b0};
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_b[143:108])begin
                                                order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_b[744:596],order_out[234:99],order_out[12:0],order_dout_b[595:447],298'b0};
                                                order_price_din_reg_b = {3'b011,order_price_dout_b[179:144],order_out[48:13],order_price_dout_b[143:108],72'b0};
                                        end
                                        else begin // A  B in
                                                order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_b[744:447],order_out[234:99],order_out[12:0],298'b0};
                                                order_price_din_reg_b = {3'b011,order_price_dout_b[179:108],order_out[48:13],72'b0};
                                        end
                                 end
                                end
                                3'b011:begin
                                 if(order_out[48:13]>order_price_dout_b[179:144])begin
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],order_dout_a[744:298],149'b0} ;
                                         order_price_din_reg_b = {3'b100,order_out[48:13],order_price_dout_b[179:72],36'b0};

                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_b[143:108])begin
                                                order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_b[744:596],order_out[234:99],order_out[12:0],order_dout_b[595:298],149'b0};
                                                order_price_din_reg_b = {3'b100,order_price_dout_b[179:144],order_out[48:13],order_price_dout_b[143:72],36'b0};
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_b[107:72])begin
                                                         order_din_reg_b[792:745] = order_out[98:51];
                                                         order_din_reg_b[744:0] = {order_dout_b[744:447],order_out[234:99],order_out[12:0],order_dout_b[446:298],149'b0};
                                                         order_price_din_reg_b = {3'b100,order_price_dout_b[179:108],order_out[48:13],order_price_dout_b[107:72],36'b0};
                                                end
                                                else begin
                                                        order_din_reg_b[792:745] = order_out[98:51];
                                                        order_din_reg_b[744:0] = { order_dout_b[744:298],order_out[234:99],order_out[12:0],149'b0};
                                                        order_price_din_reg_b = {3'b100,order_price_dout_b[179:72],order_out[48:13],36'b0};
                                                end

                                        end
                                 end
                                end

                                3'b100:begin
                                 if(order_out[48:13]>order_price_dout_b[179:144])begin //0:4
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],order_dout_b[744:149]};
                                         order_price_din_reg_b = {3'b101,order_out[48:13],order_price_dout_b[179:36]};
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_b[143:108])begin //1:3
                                                order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_b[744:596],order_out[234:99],order_out[12:0],order_dout_b[595:149]};
                                                order_price_din_reg_b = {3'b101,order_price_dout_b[179:144],order_out[48:13],order_price_dout_b[143:36]};
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_b[107:72])begin //2:2
                                                        order_din_reg_b[792:745] = order_out[98:51];
                                                        order_din_reg_b[744:0]= {order_dout_b[744:447],order_out[234:99],order_out[12:0],order_dout_b[446:149]};
                                                        order_price_din_reg_b = {3'b101,order_price_dout_b[179:108],order_out[48:13],order_price_dout_b[107:36]};
                                                end
                                                else begin
                                                        if(order_out[48:13]>order_price_dout_b[71:36])begin  //3:1
                                                                order_din_reg_b[792:745] = order_out[98:51];
                                                                order_din_reg_b[744:0]={order_dout_b[744:298],order_out[234:99],order_out[12:0],order_dout_b[297:149]};
                                                                order_price_din_reg_b = {3'b101,order_price_dout_b[179:72],order_out[48:13],order_price_dout_b[71:36]};
                                                        end
                                                        else begin
                                                                order_din_reg_b[792:745] = order_out[98:51];
                                                                order_din_reg_b[744:0] = {order_dout_b[744:149],order_out[234:99],order_out[12:0]};
                                                                order_price_din_reg_b = {3'b101,order_price_dout_b[179:36],order_out[48:13]};
                                                        end
                                                end
                                        end
                                 end
                                end
                                3'b101:begin
                                 if(order_out[48:13]>order_price_dout_b[179:144])begin //0:4
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],order_dout_b[595:0]};
                                         order_price_din_reg_b = {3'b101,order_out[48:13],order_price_dout_b[143:0]};
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_b[143:108])begin //1:3
                                                order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_b[744:596],order_out[234:99],order_out[12:0],order_dout_b[446:0]};
                                                order_price_din_reg_b = {3'b101,order_price_dout_b[179:144],order_out[48:13],order_price_dout_b[107:0]};
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_b[107:72])begin //2:2
                                                        order_din_reg_b[792:745] = order_out[98:51];
                                                        order_din_reg_b[744:0]= {order_dout_b[744:447],order_out[234:99],order_out[12:0],order_dout_b[297:0]};
                                                        order_price_din_reg_b = {3'b101,order_price_dout_b[179:108],order_out[48:13],order_price_dout_b[71:0]};
                                                end
                                                else begin
                                                        if(order_out[48:13]>order_price_dout_b[71:36])begin  //3:1
                                                                order_din_reg_b[792:745] = order_out[98:51];
                                                                order_din_reg_b[744:0]={order_dout_b[744:298],order_out[234:99],order_out[12:0],order_dout_b[148:0]};
                                                                order_price_din_reg_b = {3'b101,order_price_dout_b[179:72],order_out[48:13],order_price_dout_b[36:0]};
                                                        end
                                                        else begin
                                                                order_din_reg_b[792:745] = order_out[98:51];
                                                                order_din_reg_b[744:0] = {order_dout_b[744:149],order_out[234:99],order_out[12:0]};
                                                                order_price_din_reg_b = {3'b101,order_price_dout_b[179:36],order_out[48:13]};
                                                        end
                                                end
                                        end
                                 end
				end
				default:begin
					order_din_reg_b = 'h0;
					order_price_din_reg_b = 'h0;
				end
				endcase

				state_next = WRITE_SELL_TABLE ;
		    end
		    default:begin
				state_next = DONE;
		    end
		    endcase


/*
                    if(order_out[50:49] == 2'b01)begin
			    
                            if(order_price_dout_a[182:180]==3'b000)begin // No order in BRAM
				 order_din_reg_a[792:745] = order_out[98:51];
                                 order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],596'b0};
                                 order_price_din_reg_a = {3'b001,order_out[48:13],144'b0};
                            end
                            else if (order_price_dout_a[182:180]==3'b001)begin
                                 if(order_out[48:13]>order_price_dout_a[179:144])begin
					 order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],order_dout_a[744:596],447'b0} ;
                                         order_price_din_reg_a = {3'b010,order_out[48:13],order_price_dout_a[179:144],108'b0};
                                 end
                                 else begin
                                         order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_dout_a[744:596],order_out[234:99],order_out[12:0],447'b0};
                                         order_price_din_reg_a = {3'b010,order_price_dout_a[179:144],order_out[48:13],108'b0};
                                 end
                            end
                            else if (order_price_dout_a[182:180]==3'b010)begin
                                 if(order_out[48:13]>order_price_dout_a[179:144])begin
                                         order_din_reg_a[792:745] = order_out[98:51];
                                        order_din_reg_a[744:0]={order_out[234:99],order_out[12:0],order_dout_a[744:447],298'b0};
                                        order_price_din_reg_a = {3'b011,order_out[48:13],order_price_dout_a[179:108],72'b0};
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_a[143:108])begin
	                                        order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_a[744:596],order_out[234:99],order_out[12:0],order_dout_a[595:447],298'b0};
                                                order_price_din_reg_a = {3'b011,order_price_dout_a[179:144],order_out[48:13],order_price_dout_a[143:108],72'b0};
                                        end
                                        else begin // A  B in
	                                        order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_a[744:447],order_out[234:99],order_out[12:0],298'b0};
                                                order_price_din_reg_a = {3'b011,order_price_dout_a[179:108],order_out[48:13],72'b0};
                                        end
                                 end
                            end

                            else if (order_price_dout_a[182:180]==3'b011)begin
                                 if(order_out[48:13]>order_price_dout_a[179:144])begin
                                         order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],order_dout_a[744:298],149'b0} ;
                                         order_price_din_reg_a = {3'b100,order_out[48:13],order_price_dout_a[179:72],36'b0};

                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_a[143:108])begin 
                                                order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_a[744:596],order_out[234:99],order_out[12:0],order_dout_a[595:298],149'b0};
                                                order_price_din_reg_a = {3'b100,order_price_dout_a[179:144],order_out[48:13],order_price_dout_a[143:72],36'b0};
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_a[107:72])begin
                                                         order_din_reg_a[792:745] = order_out[98:51];
                                                         order_din_reg_a[744:0] = {order_dout_a[744:447],order_out[234:99],order_out[12:0],order_dout_a[446:298],149'b0};
                                                         order_price_din_reg_a = {3'b100,order_price_dout_a[179:108],order_out[48:13],order_price_dout_a[107:72],36'b0};
                                                end
                                                else begin
	                                                order_din_reg_a[792:745] = order_out[98:51];
                                                        order_din_reg_a[744:0] = { order_dout_a[744:298],order_out[234:99],order_out[12:0],149'b0};
                                                        order_price_din_reg_a = {3'b100,order_price_dout_a[179:72],order_out[48:13],36'b0};
                                                end

                                        end
                                 end

                            end
                            else if (order_price_dout_a[182:180]==3'b100)begin
                                 if(order_out[48:13]>order_price_dout_a[179:144])begin //0:4
                                         order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],order_dout_a[744:149]};
                                         order_price_din_reg_a = {3'b101,order_out[48:13],order_price_dout_a[179:36]};
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_a[143:108])begin //1:3
                                                order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_a[744:596],order_out[234:99],order_out[12:0],order_dout_a[595:149]};
                                                order_price_din_reg_a = {3'b101,order_price_dout_a[179:144],order_out[48:13],order_price_dout_a[143:36]};                                            
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_a[107:72])begin //2:2
		                                        order_din_reg_a[792:745] = order_out[98:51];
                                                        order_din_reg_a[744:0]= {order_dout_a[744:447],order_out[234:99],order_out[12:0],order_dout_a[446:149]};
                                                        order_price_din_reg_a = {3'b101,order_price_dout_a[179:108],order_out[48:13],order_price_dout_a[107:36]};
                                                end
                                                else begin
                                                        if(order_out[48:13]>order_price_dout_a[71:36])begin  //3:1
		                                                order_din_reg_a[792:745] = order_out[98:51];
                                                                order_din_reg_a[744:0]={order_dout_a[744:298],order_out[234:99],order_out[12:0],order_dout_a[297:149]};
                                                                order_price_din_reg_a = {3'b101,order_price_dout_a[179:72],order_out[48:13],order_price_dout_a[71:36]};
                                                        end
                                                        else begin
		                                                order_din_reg_a[792:745] = order_out[98:51];
                                                                order_din_reg_a[744:0] = {order_dout_a[744:149],order_out[234:99],order_out[12:0]};
                                                                order_price_din_reg_a = {3'b101,order_price_dout_a[179:36],order_out[48:13]};
                                                        end
                                                end
                                        end
                                 end
                            end
                            else if (order_price_dout_a[182:180]==3'b101)begin
                                 if(order_out[48:13]>order_price_dout_a[179:144])begin //0:4
                                         order_din_reg_a[792:745] = order_out[98:51];
                                         order_din_reg_a[744:0] = {order_out[234:99],order_out[12:0],order_dout_a[595:0]};
                                         order_price_din_reg_a = {3'b101,order_out[48:13],order_price_dout_a[143:0]};
                                 end
                                 else begin
                                        if(order_out[48:13]>order_price_dout_a[143:108])begin //1:3
                                                order_din_reg_a[792:745] = order_out[98:51];
                                                order_din_reg_a[744:0] = {order_dout_a[744:596],order_out[234:99],order_out[12:0],order_dout_a[446:0]};
                                                order_price_din_reg_a = {3'b101,order_price_dout_a[179:144],order_out[48:13],order_price_dout_a[107:0]};
                                        end
                                        else begin
                                                if(order_out[48:13]>order_price_dout_a[107:72])begin //2:2
                                                        order_din_reg_a[792:745] = order_out[98:51];
                                                        order_din_reg_a[744:0]= {order_dout_a[744:447],order_out[234:99],order_out[12:0],order_dout_a[297:0]};
                                                        order_price_din_reg_a = {3'b101,order_price_dout_a[179:108],order_out[48:13],order_price_dout_a[71:0]};
                                                end
                                                else begin
                                                        if(order_out[48:13]>order_price_dout_a[71:36])begin  //3:1
                                                                order_din_reg_a[792:745] = order_out[98:51];
                                                                order_din_reg_a[744:0]={order_dout_a[744:298],order_out[234:99],order_out[12:0],order_dout_a[148:0]};
                                                                order_price_din_reg_a = {3'b101,order_price_dout_a[179:72],order_out[48:13],order_price_dout_a[36:0]};
                                                        end
                                                        else begin
                                                                order_din_reg_a[792:745] = order_out[98:51];
                                                                order_din_reg_a[744:0] = {order_dout_a[744:149],order_out[234:99],order_out[12:0]};
                                                                order_price_din_reg_a = {3'b101,order_price_dout_a[179:36],order_out[48:13]};
                                                        end
                                                end
                                        end
                                 end

                            end



                            state_next = WRITE_BUY_TABLE;
                    end

                    else if(order_out[50:49] == 2'b10)begin
			    
                            if(order_price_dout_b[182:180]==3'b000)begin // No order in BRAM
				 order_din_reg_b[792:745] = order_out[98:51];
                                 order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],596'b0};
                                 order_price_din_reg_b = {3'b001,order_out[48:13],144'b0};
                            end
                            else if (order_price_dout_b[182:180]==3'b001)begin
                                 if(order_out[48:13]<order_price_dout_b[179:144])begin
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],order_dout_b[744:596],447'b0} ;
                                         order_price_din_reg_b = {3'b010,order_out[48:13],order_price_dout_b[179:144],108'b0};
                                 end
                                 else begin
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_dout_b[744:596],order_out[234:99],order_out[12:0],447'b0};
                                         order_price_din_reg_b = {3'b010,order_price_dout_b[179:144],order_out[48:13],108'b0};
                                 end
                            end
                            else if (order_price_dout_b[182:180]==3'b010)begin
                                 if(order_out[48:13]<order_price_dout_b[179:144])begin
                                         order_din_reg_b[792:745] = order_out[98:51];
                                        order_din_reg_b[744:0]={order_out[234:99],order_out[12:0],order_dout_b[744:447],298'b0};
                                        order_price_din_reg_b = {3'b011,order_out[48:13],order_price_dout_b[179:108],72'b0};
                                 end
                                 else begin
                                        if(order_out[48:13]<order_price_dout_b[143:108])begin
                                        	order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_b[744:596],order_out[234:99],order_out[12:0],order_dout_b[595:447],298'b0};
                                                order_price_din_reg_b = {3'b011,order_price_dout_b[179:144],order_out[48:13],order_price_dout_b[143:108],72'b0};
                                        end
                                        else begin // A< in < B
                                                order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_b[744:447],order_out[234:99],order_out[12:0],298'b0};
                                                order_price_din_reg_b = {3'b011,order_price_dout_b[179:108],order_out[48:13],72'b0};
                                        end
                                 end
                            end

                            else if (order_price_dout_b[182:180]==3'b011)begin
                                 if(order_out[48:13]<order_price_dout_b[179:144])begin
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],order_dout_b[744:298],149'b0} ;
                                         order_price_din_reg_b = {3'b100,order_out[48:13],order_price_dout_b[179:72],36'b0};

                                 end
                                 else begin
                                        if(order_out[48:13]<order_price_dout_b[143:108])begin
                                         	order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_b[744:596],order_out[234:99],order_out[12:0],order_dout_b[595:298],149'b0};
                                                order_price_din_reg_b = {3'b100,order_dout_b[179:144],order_out[48:13],order_price_dout_b[143:72],36'b0};
                                        end
                                        else begin
                                                if(order_out[48:13]<order_price_dout_b[107:72])begin
                                         		 order_din_reg_b[792:745] = order_out[98:51];
                                                         order_din_reg_b[744:0] = {order_dout_b[744:447],order_out[234:99],order_out[12:0],order_dout_b[446:298],149'b0};
                                                         order_price_din_reg_b = {3'b100,order_price_dout_b[179:108],order_out[48:13],order_price_dout_b[107:72],36'b0};
                                                end
                                                else begin
                                         		order_din_reg_b[792:745] = order_out[98:51];
                                                        order_din_reg_b[744:0] = { order_dout_b[744:298],order_out[234:99],order_out[12:0],149'b0};
                                                        order_price_din_reg_b = {3'b100,order_price_dout_b[179:72],order_out[48:13],36'b0};
                                                end

                                        end
                                 end

                            end
                            else if (order_price_dout_b[182:180]==3'b100)begin
                                 if(order_out[48:13]<order_price_dout_b[179:144])begin //0:4
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],order_dout_b[744:149]};
                                         order_price_din_reg_b = {3'b101,order_out[48:13],order_price_dout_b[179:36]};
                                 end
                                 else begin
                                        if(order_out[48:13]<order_price_dout_b[143:108])begin //1:3
                                         	order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_b[744:596],order_out[234:99],order_out[12:0],order_dout_b[595:149]};
                                                order_price_din_reg_b = {3'b101,order_price_dout_b[179:144],order_out[48:13],order_price_dout_b[143:36]};                                            
                                        end
                                        else begin
                                                if(order_out[48:13]<order_price_dout_b[107:72])begin //2:2
                                         		order_din_reg_b[792:745] = order_out[98:51];
                                                        order_din_reg_b[744:0]= {order_dout_b[744:447],order_out[234:99],order_out[12:0],order_dout_b[446:149]};
                                                        order_price_din_reg_b = {3'b101,order_price_dout_b[179:108],order_out[48:13],order_price_dout_b[107:36]};
                                                end
                                                else begin
                                                        if(order_out[48:13]<order_price_dout_b[71:36])begin  //3:1
                                         			order_din_reg_b[792:745] = order_out[98:51];
                                                                order_din_reg_b[744:0]={order_dout_b[744:298],order_out[234:99],order_out[12:0],order_dout_b[297:149]};
                                                                order_price_din_reg_b = {3'b101,order_price_dout_b[179:72],order_out[48:13],order_price_dout_b[71:36]};
                                                        end
                                                        else begin
                                         			order_din_reg_b[792:745] = order_out[98:51];
                                                                order_din_reg_b[744:0] = {order_dout_b[744:149],order_out[234:99],order_out[12:0]};
                                                                order_price_din_reg_b = {3'b101,order_price_dout_b[179:36],order_out[48:13]};
                                                        end
                                                end
                                        end
                                 end
                            end
			    else if (order_price_dout_b[182:180]==3'b101)begin
                                 if(order_out[48:13]<order_price_dout_b[179:144])begin //0:4
                                         order_din_reg_b[792:745] = order_out[98:51];
                                         order_din_reg_b[744:0] = {order_out[234:99],order_out[12:0],order_dout_b[595:0]};
                                         order_price_din_reg_b = {3'b101,order_out[48:13],order_price_dout_b[143:0]};
                                 end
                                 else begin
                                        if(order_out[48:13]<order_price_dout_b[143:108])begin //1:3
                                                order_din_reg_b[792:745] = order_out[98:51];
                                                order_din_reg_b[744:0] = {order_dout_b[744:596],order_out[234:99],order_out[12:0],order_dout_b[446:0]};
                                                order_price_din_reg_b = {3'b101,order_price_dout_b[179:144],order_out[48:13],order_price_dout_b[107:0]};
                                        end
                                        else begin
                                                if(order_out[48:13]<order_price_dout_b[107:72])begin //2:2
                                                        order_din_reg_b[792:745] = order_out[98:51];
                                                        order_din_reg_b[744:0]= {order_dout_b[744:447],order_out[234:99],order_out[12:0],order_dout_b[297:0]};
                                                        order_price_din_reg_b = {3'b101,order_price_dout_b[179:108],order_out[48:13],order_price_dout_b[71:0]};
                                                end
                                                else begin
                                                        if(order_out[48:13]<order_price_dout_b[71:36])begin  //3:1
                                                                order_din_reg_b[792:745] = order_out[98:51];
                                                                order_din_reg_b[744:0]={order_dout_b[744:298],order_out[234:99],order_out[12:0],order_dout_b[148:0]};
                                                                order_price_din_reg_b = {3'b101,order_price_dout_b[179:72],order_out[48:13],order_price_dout_b[36:0]};
                                                        end
                                                        else begin
                                                                order_din_reg_b[792:745] = order_out[98:51];
                                                                order_din_reg_b[744:0] = {order_dout_b[744:149],order_out[234:99],order_out[12:0]};
                                                                order_price_din_reg_b = {3'b101,order_price_dout_b[179:36],order_out[48:13]};
                                                        end
                                                end
                                        end
                                 end

			    end


                            state_next = WRITE_SELL_TABLE;
                    end
*/


//                    state_next  = DONE ;
//                    order_rd    = 1'b1;


//old
/*
                    order_we_a = (order_out[14:13] == 2'b01)? 'b1: 'b0;
                    order_we_b = (order_out[14:13] == 2'b10)? 'b1: 'b0;
 
                    order_din_data_a = {order_out, 1'b1};
                    order_din_data_b = {order_out, 1'b1};
		    state_next = DONE;
		    order_rd = 1'b1;
*/
		 

		end

		WRITE_BUY_TABLE : begin
			    order_din_data_a = order_din_reg_a ;
			    order_price_din_data_a= order_price_din_reg_a;
			    order_we_a = 1'b1;
			    order_price_we_a = 1'b1;
			    state_next = DONE  ;
			    order_rd = 1'b1;
		end

		

		WRITE_SELL_TABLE : begin
			    order_din_data_b = order_din_reg_b;
			    order_price_din_data_b=order_price_din_reg_b;
			    order_we_b = 1'b1;
			    order_price_we_b = 1'b1;
			    state_next = DONE;
			    order_rd = 1'b1;
		end


                          
		READ_0: begin
		            // wait one cycle to obtain result from BRAM
                        state_next    =  READ_1;  
			current_owner =  current_owner_reg;
		end
                READ_1: begin
		    if(current_owner_reg == 4'd4) begin
			   if(order_match_addr[11:10] == 2'b00) begin
			   	order_match_data_logic = dout_a;
			   end
			   else if(order_match_addr[11:10] == 2'b01) begin
			   	order_match_data_logic = dout_b;
			   end
			   else if(order_match_addr[11:10] == 2'b10) begin
			   	order_match_data_logic = dout_c;
			   end
			   else if(order_match_addr[11:10] == 2'b11) begin
			   	order_match_data_logic = dout_d;
			   end
			   // after sending cancel, clear the entry
                    	   //order_we_a       = 'b1;
                    	   //order_din_data_a = 217'0;
			   if(order_match_addr[13:12] == 2'b01) begin // buy
				   //order_content_logic = order_dout_a;
                                   //Symbol ClordID OrderID TWSEFields SIDE Valid bits 202bits
                                   if(order_price_dout_a[182:180]!=3'd0)begin
                                         order_content_logic = {order_dout_a[792:596],2'b01,order_price_dout_a[182:180]};
                                         order_price_din_data_a[182:180]  = order_price_dout_a[182:180] - 3'b001 ;
					 order_price_din_data_a[179:0] = {order_price_dout_a[143:0],36'b0};
					 order_din_data_a = {order_dout_a[792:745],order_dout_a[595:0],149'b0};
					 
                                   end
                        	   else begin
                                         order_content_logic = 202'b0;
                    		   end
				   order_we_a = 'b1;
				   order_price_we_a = 'b1;
			   end
			   else if(order_match_addr[13:12] == 2'b10) begin // sell
                                   
                                   if(order_price_dout_b[182:180]!=3'd0)begin
                                        order_content_logic = {order_dout_b[792:596],2'b10,order_price_dout_b[182:180]};
                                        order_price_din_data_b[182:180]  = order_price_dout_b[182:180] -3'b001 ;
                                        order_price_din_data_b[179:0] = {order_price_dout_b[143:0],36'b0};
                                        order_din_data_b = {order_dout_b[792:745],order_dout_b[595:0],149'b0};
                                   end

                                   else begin
                                        order_content_logic = 202'h0;
                                   end
				   order_we_b = 'b1;
				   order_price_we_b = 'b1;

			   end
			   else begin
				   order_content_logic = 'h0;
			   end
			  //state_next =DONE;
			  order_match_ack_logic = 'b1;
                    end
		    else if (current_owner_reg == 4'd2) begin

			if(order_id_mapping_rd_addr[12] == 'b0) begin
			    //order_id_mapping_rd_data_logic = order_dout_a[80:33];
			    order_id_mapping_rd_data_logic = order_dout_a[792:745];
			    order_id_mapping_rd_ack_logic = 'b1;
			end
                        else begin
                            //order_id_mapping_rd_data_logic = order_dout_b[80:33];
                            order_id_mapping_rd_data_logic = order_dout_b[792:745];
                            order_id_mapping_rd_ack_logic = 'b1;
                        end
			//state_next = DONE;

		    end
		    else if (current_owner_reg == 4'd10)begin
			if(order_id_store_rd_addr[12] == 'b0) begin
			    order_id_store_rd_data_logic = {order_price_dout_a[182:180],order_dout_a[648:609],order_dout_a[499:460],order_dout_a[350:311],order_dout_a[201:162],order_dout_a[52:13]};
			    order_id_store_rd_ack_logic = 'b1;
			    //state_next = DONE ;
			end
			else begin
                            order_id_store_rd_data_logic = {order_price_dout_b[182:180],order_dout_b[648:609],order_dout_b[499:460],order_dout_b[350:311],order_dout_b[201:162],order_dout_b[52:13]};
                            order_id_store_rd_ack_logic = 'b1;
			    //state_next = DONE;
			end
		    end
	
		    else begin
			    order_match_ack_logic = 'b0;
			    order_id_mapping_rd_ack_logic ='b0;
			    order_id_store_rd_ack_logic = 'b0;
		    end

		    state_next = DONE;
		end
		DONE: begin
			        order_id_mapping_wr_ack_logic = 'b0;
			        order_id_mapping_rd_ack_logic = 'b0;

				order_id_store_wr_ack_logic = 'b0;
				order_id_store_rd_ack_logic = 'b0;

				order_match_ack_logic         = 'b0;
/*	
        		        order_din_reg_a = 0;
        		        order_price_din_reg_a = 0;
		                order_din_reg_b  = 0 ;
		                order_price_din_reg_b = 0;
*/
/*
				order_dout_reg_a = 0;
				order_dout_reg_b = 0;
				order_price_dout_reg_a = 0;
				order_price_dout_reg_b = 0;

*/			        state_next = WAIT;
		end
        endcase
     end
   

    always @(posedge clk) begin
        if(reset) begin
                state <= WAIT;
		addr_a_reg <= 'h0;
		addr_b_reg <= 'h0;
		addr_c_reg <= 'h0;
		addr_d_reg <= 'h0;
		order_id_mapping_rd_data        <=  'd0;
            	order_id_mapping_rd_ack       <=  1'b0;
            	order_id_mapping_wr_ack       <=  1'b0;
		current_owner_reg             <=  4'd1;
		counter_reg                   <=  6'h0;
		order_match_data              <=  48'h0;
		order_match_ack		      <=  1'b0;
		wait_hash_reg                 <=  4'd0;
		order_code_hash_reg           <=  48'h0;
		order_code_compare_reg	      <=  48'h0;
		order_addr_a_reg <= 'h0;
		order_addr_b_reg <= 'h0;

		order_price_addr_a_reg<= 'h0;
		order_price_addr_b_reg <= 'h0;
		order_content    <= 'h0;
		
                order_id_store_rd_data        <=  'd0;
                order_id_store_rd_ack       <=  1'b0;
                order_id_store_wr_ack       <=  1'b0;
			
		order_din_reg_a_seq	    <= 'b0;
		order_din_reg_b_seq	    <= 'b0;
		order_price_din_reg_a_seq   <= 'b0;
		order_price_din_reg_b_seq   <= 'b0;
		
	    end
        else begin
		addr_a_reg <= addr_a;
		addr_b_reg <= addr_b;
		addr_c_reg <= addr_c;
		addr_d_reg <= addr_d;
                state <= state_next;
		order_id_mapping_rd_data        <=  order_id_mapping_rd_data_logic;
            	order_id_mapping_rd_ack       <=  order_id_mapping_rd_ack_logic;
            	order_id_mapping_wr_ack       <=  order_id_mapping_wr_ack_logic;
		current_owner_reg             <=  current_owner;
		order_match_data              <=  order_match_data_logic;
		order_match_ack		      <=  order_match_ack_logic;
		wait_hash_reg                 <=  wait_hash;
		counter_reg                   <=  counter;
		order_code_hash_reg           <=  order_code_hash;
		order_code_compare_reg	      <=  order_code_compare;
		order_addr_a_reg <= order_addr_a;
		order_addr_b_reg <= order_addr_b;
		order_price_addr_a_reg<=order_price_addr_a;
		order_price_addr_b_reg<=order_price_addr_b;
		order_content    <= order_content_logic;

                order_id_store_rd_data        <=  order_id_store_rd_data_logic;
                order_id_store_rd_ack       <=  order_id_store_rd_ack_logic;
                order_id_store_wr_ack       <=  order_id_store_wr_ack_logic;

                order_din_reg_a_seq         <=  order_din_reg_a;
                order_din_reg_b_seq         <=  order_din_reg_b;
                order_price_din_reg_a_seq   <=  order_price_din_reg_a;
                order_price_din_reg_b_seq   <=  order_price_din_reg_b;
	    end
   end

endmodule // stock_id_mapping



