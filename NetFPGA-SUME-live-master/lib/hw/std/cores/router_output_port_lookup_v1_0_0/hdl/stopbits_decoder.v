module stopbits_decoder
  #(parameter C_S_AXIS_DATA_WIDTH=256,
     parameter C_S_AXIS_TUSER_WIDTH= 128 
   )

  (

    input [3:0]          stopbits_in,
    input [1:0]          pre_end_in_this_module,
    output [1:0]         end_in_this_module,

    
    output               next_wr_valid,
    output               rd_valid,
    input                data_valid,


    output reg [31:0]    fast_store_fourbyte_reg_notend,
    output reg [23:0]      fast_store_threebyte_reg_notend,
    output reg [15:0]      fast_store_twobyte_reg_notend,
    output reg [7: 0]      fast_store_byte_reg_notend,




    output reg [31:0]    fast_store_fourbyte_reg_end,
    output reg [23:0]      fast_store_threebyte_reg_1_end,
    output reg [23:0]      fast_store_threebyte_reg_2_end, 
    output reg [15:0]      fast_store_twobyte_reg_1_end,
    output reg [15:0]      fast_store_twobyte_reg_2_end,
    output reg [15:0]      fast_store_twobyte_reg_3_end,
    output reg [7: 0]      fast_store_byte_reg_1_end,
    output reg [7: 0]      fast_store_byte_reg_2_end,
    output reg [7: 0]      fast_store_byte_reg_3_end,
    output reg [7: 0]      fast_store_byte_reg_4_end,

    input [31:0]      pre_fast_store_fourbyte_reg_end,
    input [23:0]      pre_fast_store_threebyte_reg_1_end,
    input [23:0]      pre_fast_store_threebyte_reg_2_end, 
    input [15:0]      pre_fast_store_twobyte_reg_1_end,
    input [15:0]      pre_fast_store_twobyte_reg_2_end,
    input [15:0]      pre_fast_store_twobyte_reg_3_end,
    input [7: 0]      pre_fast_store_byte_reg_1_end,
    input [7: 0]      pre_fast_store_byte_reg_2_end,
    input [7: 0]      pre_fast_store_byte_reg_3_end,
    input [7: 0]      pre_fast_store_byte_reg_4_end,


    input reset,
    input clk
   );


   // --- wade connect state machine

   // Most longest length = 8Bytes = 64bits
   reg [31:0]			   fast_store_fourbyte_reg_notend_logic;
   reg [31:0]        fast_store_fourbyte_reg_end_logic;

   reg [23:0]			   fast_store_threebyte_reg_notend_logic;
   reg [23:0]			   fast_store_threebyte_reg_1_end_logic;
   reg [23:0]			   fast_store_threebyte_reg_2_end_logic; 
    
   reg [15:0]        fast_store_twobyte_reg_notend_logic;
   reg [15:0]        fast_store_twobyte_reg_1_end_logic;
   reg [15:0] 			 fast_store_twobyte_reg_2_end_logic;
   reg [15:0] 			 fast_store_twobyte_reg_3_end_logic;

   reg [7: 0]			   fast_store_byte_reg_notend_logic;
   reg [7: 0]			   fast_store_byte_reg_1_end_logic;
   reg [7: 0]			   fast_store_byte_reg_2_end_logic;
   reg [7: 0]			   fast_store_byte_reg_3_end_logic;
   reg [7: 0]			   fast_store_byte_reg_4_end_logic;


   case(state) 
      //255:248 247:240 239:232 231:224 223:216 215:208 207:200 199:192 191:184 183:176 175:168 167:160 159:152 151:144 143:136 135:128 127:120 119:112 111:104 103:96 95:88 87:80 79:72 71:64 63:56 55:48 47:40 39:32 31:24 23:16 15:8 7:0
        4'b0000:begin
        	fast_store_fourbyte_reg_notend =  //255:248 247:240 239:232 231:224 Not Ending
        end
        4'b0001:begin
        	fast_store_fourbyte_reg_end =  //255:248 247:240 239:232 231:224 Ending
        end
        4'b0010:begin
        	//255:248 247:240 239:232 Ending 231:224 Not Ending
        	fast_store_threebyte_reg_end = 
        	fast_store_byte_reg_1_notend = 
        end
        4'b0011:begin
        	fast_store_threebyte_reg_end = 
        	fast_store_byte_reg_1_end =         	
        end
        4'b0100:begin
        	fast_store_twobyte_reg_1_end = 
        	fast_store_twobyte_reg_notend =
        end
        4'b0101:begin
        	fast_store_twobyte_reg_1_end = 
        	fast_store_twobyte_reg_2_end =
        end
        4'b0110:begin
        	fast_store_twobyte_reg_1_end = 
        	fast_store_byte_reg_1_end =
        	fast_store_byte_reg_1_notend =       	
        end
        4'b0111:begin
        	fast_store_twobyte_reg_1_end = 
        	fast_store_byte_reg_1_end =
        	fast_store_byte_reg_2_end =
        end
        4'b1000:begin
        	fast_store_byte_reg_1_end =
        	fast_store_threebyte_reg_notend =
        end
        4'b1001:begin
        	fast_store_byte_reg_1_end =
        	fast_store_threebyte_reg_end =
        end
        4'b1010:begin
        	fast_store_byte_reg_1_end =
        	fast_store_twobyte_reg_1_end =
        	fast_store_byte_reg_notend =
        end
        4'b1011:begin
        	fast_store_byte_reg_1_end =
        	fast_store_twobyte_reg_1_end =
        	fast_store_byte_reg_2_end =
        end
        4'b1100:begin
        	fast_store_byte_reg_1_end =
        	fast_store_byte_reg_2_end =
			fast_store_twobyte_reg_notend =
        end
        4'b1101:begin
         	fast_store_byte_reg_1_end =
        	fast_store_byte_reg_2_end =
			fast_store_twobyte_reg_1_end =       	
        end    
        4'b1110:begin
         	fast_store_byte_reg_1_end =
        	fast_store_byte_reg_2_end =
        	fast_store_byte_reg_3_end =
        	fast_store_byte_reg_notend =        		
        end
        4'b1111:begin
         	fast_store_byte_reg_1_end =
        	fast_store_byte_reg_2_end =
        	fast_store_byte_reg_3_end =
         	fast_store_byte_reg_4_end =           	
        end
        default:begin
            fast_store_byte_reg_notend_logic = 'b0;
          	fast_store_byte_reg_1_end_logic =  'b0;
        	  fast_store_byte_reg_2_end_logic =  'b0;
        	  fast_store_byte_reg_3_end_logic =  'b0;
         	  fast_store_byte_reg_4_end_logic =  'b0;
         	  fast_store_twobyte_reg_1_end_logic = 'b0;
         	  fast_store_twobyte_reg_2_end_logic = 'b0;
         	  fast_store_twobyte_reg_notend_logic = 'b0;
         	  fast_store_threebyte_reg_end_logic = 'b0;
         	  fast_store_threebyte_reg_notend_logic ='b0;
         	  fast_store_fourbyte_reg_end_logic =  'b0;
         	  fast_store_fourbyte_reg_notend_logic =	'b0;
        end
   
    endcase



    always @(posedge clk) begin
        if(reset) begin
                state <= WAIT;
                fast_store_fourbyte_reg_notend<='b0;
                fast_store_fourbyte_reg_end<='b0;
                fast_store_threebyte_reg_notend<='b0;
                fast_store_threebyte_reg_1_end<='b0;
                fast_store_threebyte_reg_2_end<='b0; 
                fast_store_twobyte_reg_notend<='b0;
                fast_store_twobyte_reg_1_end<='b0;
                fast_store_twobyte_reg_2_end<='b0;
                fast_store_twobyte_reg_3_end<='b0;
                fast_store_byte_reg_notend<='b0;
                fast_store_byte_reg_1_end<='b0;
                fast_store_byte_reg_2_end<='b0;
                fast_store_byte_reg_3_end<='b0;
                fast_store_byte_reg_4_end<='b0;                
    
        end
        else begin
                fast_store_fourbyte_reg_notend<=fast_store_fourbyte_reg_notend_logic;
                fast_store_fourbyte_reg_end<=fast_store_fourbyte_reg_end_logic;
                fast_store_threebyte_reg_notend<=fast_store_threebyte_reg_notend_logic;
                fast_store_threebyte_reg_1_end<=fast_store_threebyte_reg_1_end_logic;
                fast_store_threebyte_reg_2_end<=fast_store_threebyte_reg_2_end_logic; 
                fast_store_twobyte_reg_notend<=fast_store_twobyte_reg_notend_logic;
                fast_store_twobyte_reg_1_end<=fast_store_twobyte_reg_1_end_logic;
                fast_store_twobyte_reg_2_end<=fast_store_twobyte_reg_2_end_logic;
                fast_store_twobyte_reg_3_end<=fast_store_twobyte_reg_3_end_logic;
                fast_store_byte_reg_notend<=fast_store_byte_reg_1_notend_logic;
                fast_store_byte_reg_1_end<=fast_store_byte_reg_1_end_logic;
                fast_store_byte_reg_2_end<=fast_store_byte_reg_2_end_logic;
                fast_store_byte_reg_3_end<=fast_store_byte_reg_3_end_logic;
                fast_store_byte_reg_4_end<=fast_store_byte_reg_4_end_logic; 
        end

    end


endmodule