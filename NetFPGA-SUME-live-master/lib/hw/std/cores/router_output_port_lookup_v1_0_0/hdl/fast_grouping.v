module fast_grouping
  #(parameter C_S_AXIS_DATA_WIDTH	= 256,
    parameter C_S_AXIS_TUSER_WIDTH	= 128,
    parameter NUM_QUEUES		= 8,
    parameter NUM_QUEUES_WIDTH		= log2(NUM_QUEUES)
  )
  (// --- interface to input fifo - fallthrough
    // Global Ports
    input axis_aclk,
    input axis_resetn,

    // Master Stream Ports (interface to data path)

    output [C_M_AXIS_DATA_WIDTH - 1:0]		m_axis_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0]	m_axis_tkeep,
    output [C_M_AXIS_TUSER_WIDTH-1:0]		m_axis_tuser,
    output m_axis_tvalid,
    input  m_axis_tready,
    output m_axis_tlast,
    // Slave Stream Ports (interface to RX queues)
    input [C_S_AXIS_DATA_WIDTH - 1:0]		s_axis_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0]	s_axis_tkeep,
    input [C_S_AXIS_TUSER_WIDTH-1:0]		s_axis_tuser,
    input  s_axis_tvalid,
    output s_axis_tready,
    input  s_axis_tlast,

);   

   reg         in_fifo_wr;
   reg         in_fifo_rd;
   wire        in_fifo_empty;
   wire        in_fifo_nearly_full;

   // Most longest length = 8Bytes = 64bits
   reg [31:0]			 fast_store_fourbyte_reg_notend;
   reg [31:0]            fast_store_fourbyte_reg_end;

   reg [23:0]			 fast_store_threebyte_reg_notend;
   reg [23:0]			 fast_store_threebyte_reg_1_end;
   reg [23:0]			 fast_store_threebyte_reg_2_end; 
    
   reg [15:0]            fast_store_twobyte_reg_1_notend;
   reg [15:0]            fast_store_twobyte_reg_1_end;
   reg [15:0] 			 fast_store_twobyte_reg_2_end;
   reg [15:0] 			 fast_store_twobyte_reg_3_end;

   reg [7: 0]			 fast_store_byte_reg_1_notend;
   reg [7: 0]			 fast_store_byte_reg_1_end;
   reg [7: 0]			 fast_store_byte_reg_2_end;
   reg [7: 0]			 fast_store_byte_reg_3_end;
   reg [7: 0]			 fast_store_byte_reg_4_end;

 
   //-------------------------------------
   //     Small FIFO to store fast field
   //-------------------------------------
     fallthrough_small_fifo #(.WIDTH(64), .MAX_DEPTH_BITS(12))
      order_output_fifo
        (.din           (),  // Data in
         .wr_en         (in_fifo_wr),             // Write enable
         .rd_en         (in_fifo_rd),    // Read the next word
         .dout          (),
         .full          (),
         .nearly_full   (in_fifo_nearly_full),
         .prog_full     (),
         .empty         (in_fifo_empty),
         .reset         (reset),
         .clk           (clk)
         );



   //------------------------- Modules-------------------------------


   stopbits_decoder
		stopbits_decoder_1
          (
  			.stopbits_in(),
    		.pre_end_in_this_module(end_in_decoder_8),
    		.end_in_this_module(end_in_decoder_1),

    		.next_wr_valid(next_wr_valid_1),
    		.rd_valid(rd_valid_1),
    		.data_valid(data_valid),

		    .fast_store_fourbyte_reg_notend(),
		    .fast_store_threebyte_reg_notend(),
		    .fast_store_twobyte_reg_notend(),
		    .fast_store_byte_reg_notend(),
		    .fast_store_fourbyte_reg_end(),
		    .fast_store_threebyte_reg_1_end(),
		    .fast_store_threebyte_reg_2_end(), 
		    .fast_store_twobyte_reg_1_end(),
		    .fast_store_twobyte_reg_2_end(),
		    .fast_store_twobyte_reg_3_end(),
		    .fast_store_byte_reg_1_end(),
		    .fast_store_byte_reg_2_end(),
		    .fast_store_byte_reg_3_end(),
		    .fast_store_byte_reg_4_end(),   

		    .pre_fast_store_fourbyte_reg_end(),
		    .pre_fast_store_threebyte_reg_1_end(),
		    .pre_fast_store_threebyte_reg_2_end(), 
		    .pre_fast_store_twobyte_reg_1_end(),
		    .pre_fast_store_twobyte_reg_2_end(),
		    .pre_fast_store_twobyte_reg_3_end(),
		    .pre_fast_store_byte_reg_1_end(),
		    .pre_fast_store_byte_reg_2_end(),
		    .pre_fast_store_byte_reg_3_end(),
		    .pre_fast_store_byte_reg_4_end(),   

            .clk(clk),
            .reset(reset)
          );

   stopbits_decoder
		stopbits_decoder_2
          (
  			.stopbits_in(),
    		.pre_end_in_this_module(end_in_decoder_1),
    		.end_in_this_module(end_in_decoder_2),

    		.next_wr_valid(next_wr_valid_2),
    		.rd_valid(rd_valid_2),
    		.data_valid(data_valid),

		    .fast_store_fourbyte_reg_notend(),
		    .fast_store_threebyte_reg_notend(),
		    .fast_store_twobyte_reg_notend(),
		    .fast_store_byte_reg_notend(),
		    .fast_store_fourbyte_reg_end(),
		    .fast_store_threebyte_reg_1_end(),
		    .fast_store_threebyte_reg_2_end(), 
		    .fast_store_twobyte_reg_1_end(),
		    .fast_store_twobyte_reg_2_end(),
		    .fast_store_twobyte_reg_3_end(),
		    .fast_store_byte_reg_1_end(),
		    .fast_store_byte_reg_2_end(),
		    .fast_store_byte_reg_3_end(),
		    .fast_store_byte_reg_4_end(),   

		    .pre_fast_store_fourbyte_reg_end(),
		    .pre_fast_store_threebyte_reg_1_end(),
		    .pre_fast_store_threebyte_reg_2_end(), 
		    .pre_fast_store_twobyte_reg_1_end(),
		    .pre_fast_store_twobyte_reg_2_end(),
		    .pre_fast_store_twobyte_reg_3_end(),
		    .pre_fast_store_byte_reg_1_end(),
		    .pre_fast_store_byte_reg_2_end(),
		    .pre_fast_store_byte_reg_3_end(),
		    .pre_fast_store_byte_reg_4_end(),   

            .clk(clk),
            .reset(reset)
          );
   stopbits_decoder
		stopbits_decoder_3
          (
  			.stopbits_in(),
    		.pre_end_in_this_module(end_in_decoder_2),
    		.end_in_this_module(end_in_decoder_3),

    		.next_wr_valid(next_wr_valid_3),
    		.rd_valid(rd_valid_3),
    		.data_valid(data_valid),

		    .fast_store_fourbyte_reg_notend(),
		    .fast_store_threebyte_reg_notend(),
		    .fast_store_twobyte_reg_notend(),
		    .fast_store_byte_reg_notend(),
		    .fast_store_fourbyte_reg_end(),
		    .fast_store_threebyte_reg_1_end(),
		    .fast_store_threebyte_reg_2_end(), 
		    .fast_store_twobyte_reg_1_end(),
		    .fast_store_twobyte_reg_2_end(),
		    .fast_store_twobyte_reg_3_end(),
		    .fast_store_byte_reg_1_end(),
		    .fast_store_byte_reg_2_end(),
		    .fast_store_byte_reg_3_end(),
		    .fast_store_byte_reg_4_end(),   

		    .pre_fast_store_fourbyte_reg_end(),
		    .pre_fast_store_threebyte_reg_1_end(),
		    .pre_fast_store_threebyte_reg_2_end(), 
		    .pre_fast_store_twobyte_reg_1_end(),
		    .pre_fast_store_twobyte_reg_2_end(),
		    .pre_fast_store_twobyte_reg_3_end(),
		    .pre_fast_store_byte_reg_1_end(),
		    .pre_fast_store_byte_reg_2_end(),
		    .pre_fast_store_byte_reg_3_end(),
		    .pre_fast_store_byte_reg_4_end(),   

            .clk(clk),
            .reset(reset)
          );

   stopbits_decoder
		stopbits_decoder_4
          (
  			.stopbits_in(),
    		.pre_end_in_this_module(end_in_decoder_3),
    		.end_in_this_module(end_in_decoder_4),
    		.next_wr_valid(next_wr_valid_4),
    		.rd_valid(rd_valid_4),
    		.data_valid(data_valid),

		    .fast_store_fourbyte_reg_notend(),
		    .fast_store_threebyte_reg_notend(),
		    .fast_store_twobyte_reg_notend(),
		    .fast_store_byte_reg_notend(),
		    .fast_store_fourbyte_reg_end(),
		    .fast_store_threebyte_reg_1_end(),
		    .fast_store_threebyte_reg_2_end(), 
		    .fast_store_twobyte_reg_1_end(),
		    .fast_store_twobyte_reg_2_end(),
		    .fast_store_twobyte_reg_3_end(),
		    .fast_store_byte_reg_1_end(),
		    .fast_store_byte_reg_2_end(),
		    .fast_store_byte_reg_3_end(),
		    .fast_store_byte_reg_4_end(),   

		    .pre_fast_store_fourbyte_reg_end(),
		    .pre_fast_store_threebyte_reg_1_end(),
		    .pre_fast_store_threebyte_reg_2_end(), 
		    .pre_fast_store_twobyte_reg_1_end(),
		    .pre_fast_store_twobyte_reg_2_end(),
		    .pre_fast_store_twobyte_reg_3_end(),
		    .pre_fast_store_byte_reg_1_end(),
		    .pre_fast_store_byte_reg_2_end(),
		    .pre_fast_store_byte_reg_3_end(),
		    .pre_fast_store_byte_reg_4_end(),   

            .clk(clk),
            .reset(reset)
          );

   stopbits_decoder
		stopbits_decoder_5
          (
  			.stopbits_in(),
    		.pre_end_in_this_module(end_in_decoder_4),
    		.end_in_this_module(end_in_decoder_5),
    		.next_wr_valid(next_wr_valid_5),
    		.rd_valid(rd_valid_5),
    		.data_valid(data_valid),

		    .fast_store_fourbyte_reg_notend(),
		    .fast_store_threebyte_reg_notend(),
		    .fast_store_twobyte_reg_notend(),
		    .fast_store_byte_reg_notend(),
		    .fast_store_fourbyte_reg_end(),
		    .fast_store_threebyte_reg_1_end(),
		    .fast_store_threebyte_reg_2_end(), 
		    .fast_store_twobyte_reg_1_end(),
		    .fast_store_twobyte_reg_2_end(),
		    .fast_store_twobyte_reg_3_end(),
		    .fast_store_byte_reg_1_end(),
		    .fast_store_byte_reg_2_end(),
		    .fast_store_byte_reg_3_end(),
		    .fast_store_byte_reg_4_end(),   

		    .pre_fast_store_fourbyte_reg_end(),
		    .pre_fast_store_threebyte_reg_1_end(),
		    .pre_fast_store_threebyte_reg_2_end(), 
		    .pre_fast_store_twobyte_reg_1_end(),
		    .pre_fast_store_twobyte_reg_2_end(),
		    .pre_fast_store_twobyte_reg_3_end(),
		    .pre_fast_store_byte_reg_1_end(),
		    .pre_fast_store_byte_reg_2_end(),
		    .pre_fast_store_byte_reg_3_end(),
		    .pre_fast_store_byte_reg_4_end(),   

            .clk(clk),
            .reset(reset)
          );
   stopbits_decoder
		stopbits_decoder_6
          (
  			.stopbits_in(),
    		.pre_end_in_this_module(end_in_decoder_5),
    		.end_in_this_module(end_in_decoder_6),
    		.next_wr_valid(next_wr_valid_6),
    		.rd_valid(rd_valid_6),
    		.data_valid(data_valid),

		    .fast_store_fourbyte_reg_notend(),
		    .fast_store_threebyte_reg_notend(),
		    .fast_store_twobyte_reg_notend(),
		    .fast_store_byte_reg_notend(),
		    .fast_store_fourbyte_reg_end(),
		    .fast_store_threebyte_reg_1_end(),
		    .fast_store_threebyte_reg_2_end(), 
		    .fast_store_twobyte_reg_1_end(),
		    .fast_store_twobyte_reg_2_end(),
		    .fast_store_twobyte_reg_3_end(),
		    .fast_store_byte_reg_1_end(),
		    .fast_store_byte_reg_2_end(),
		    .fast_store_byte_reg_3_end(),
		    .fast_store_byte_reg_4_end(),   

		    .pre_fast_store_fourbyte_reg_end(),
		    .pre_fast_store_threebyte_reg_1_end(),
		    .pre_fast_store_threebyte_reg_2_end(), 
		    .pre_fast_store_twobyte_reg_1_end(),
		    .pre_fast_store_twobyte_reg_2_end(),
		    .pre_fast_store_twobyte_reg_3_end(),
		    .pre_fast_store_byte_reg_1_end(),
		    .pre_fast_store_byte_reg_2_end(),
		    .pre_fast_store_byte_reg_3_end(),
		    .pre_fast_store_byte_reg_4_end(),   

            .clk(clk),
            .reset(reset)
          );
   stopbits_decoder
		stopbits_decoder_7
          (
  			.stopbits_in(),
    		.pre_end_in_this_module(end_in_decoder_6),
    		.end_in_this_module(end_in_decoder_7),

    		.next_wr_valid(next_wr_valid_7),
    		.rd_valid(rd_valid_7),
    		.data_valid(data_valid),
		    .fast_store_fourbyte_reg_notend(),
		    .fast_store_threebyte_reg_notend(),
		    .fast_store_twobyte_reg_notend(),
		    .fast_store_byte_reg_notend(),
		    .fast_store_fourbyte_reg_end(),
		    .fast_store_threebyte_reg_1_end(),
		    .fast_store_threebyte_reg_2_end(), 
		    .fast_store_twobyte_reg_1_end(),
		    .fast_store_twobyte_reg_2_end(),
		    .fast_store_twobyte_reg_3_end(),
		    .fast_store_byte_reg_1_end(),
		    .fast_store_byte_reg_2_end(),
		    .fast_store_byte_reg_3_end(),
		    .fast_store_byte_reg_4_end(),   

		    .pre_fast_store_fourbyte_reg_end(),
		    .pre_fast_store_threebyte_reg_1_end(),
		    .pre_fast_store_threebyte_reg_2_end(), 
		    .pre_fast_store_twobyte_reg_1_end(),
		    .pre_fast_store_twobyte_reg_2_end(),
		    .pre_fast_store_twobyte_reg_3_end(),
		    .pre_fast_store_byte_reg_1_end(),
		    .pre_fast_store_byte_reg_2_end(),
		    .pre_fast_store_byte_reg_3_end(),
		    .pre_fast_store_byte_reg_4_end(),   

            .clk(clk),
            .reset(reset)
          );
   stopbits_decoder
		stopbits_decoder_8
          (
  			.stopbits_in(),
    		.pre_end_in_this_module(end_in_decoder_7),
    		.end_in_this_module(end_in_decoder_8),
    		.next_wr_valid(next_wr_valid_8),
    		.rd_valid(rd_valid_8),
    		.data_valid(data_valid),
		    .fast_store_fourbyte_reg_notend(),
		    .fast_store_threebyte_reg_notend(),
		    .fast_store_twobyte_reg_notend(),
		    .fast_store_byte_reg_notend(),
		    .fast_store_fourbyte_reg_end(),
		    .fast_store_threebyte_reg_1_end(),
		    .fast_store_threebyte_reg_2_end(), 
		    .fast_store_twobyte_reg_1_end(),
		    .fast_store_twobyte_reg_2_end(),
		    .fast_store_twobyte_reg_3_end(),
		    .fast_store_byte_reg_1_end(),
		    .fast_store_byte_reg_2_end(),
		    .fast_store_byte_reg_3_end(),
		    .fast_store_byte_reg_4_end(),   

		    .pre_fast_store_fourbyte_reg_end(),
		    .pre_fast_store_threebyte_reg_1_end(),
		    .pre_fast_store_threebyte_reg_2_end(), 
		    .pre_fast_store_twobyte_reg_1_end(),
		    .pre_fast_store_twobyte_reg_2_end(),
		    .pre_fast_store_twobyte_reg_3_end(),
		    .pre_fast_store_byte_reg_1_end(),
		    .pre_fast_store_byte_reg_2_end(),
		    .pre_fast_store_byte_reg_3_end(),
		    .pre_fast_store_byte_reg_4_end(),   

            .clk(clk),
            .reset(reset)
          );

   always @(*) begin
   		case(state)
   		endcase
   end

   always @(posedge clk) begin
	if(reset)begin

	end
	else begin

	end	
   end
endmodule





