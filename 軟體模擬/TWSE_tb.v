`timescale 1ns/1ps

`define CYCLE 10


module TWSE_tb();

reg clk, reset;

// Master AXI Stream Data Width
parameter C_M_AXIS_DATA_WIDTH=256;
parameter C_S_AXIS_DATA_WIDTH=256;
parameter C_M_AXIS_TUSER_WIDTH=128;
parameter C_S_AXIS_TUSER_WIDTH=128;
parameter NUM_QUEUES=5;

// AXI Registers Data Width
parameter C_S_AXI_DATA_WIDTH    = 32;
parameter C_S_AXI_ADDR_WIDTH    = 12;
parameter C_USE_WSTRB       = 0;
parameter C_DPHASE_TIMEOUT  = 0;
parameter C_NUM_ADDRESS_RANGES  = 1;
parameter C_TOTAL_NUM_CE    = 1;
parameter C_S_AXI_MIN_SIZE  = 32'h0000_FFFF;
parameter C_FAMILY      = "virtex7";
parameter C_BASEADDR            = 32'h00000000;
parameter C_HIGHADDR        = 32'h0000FFFF;

// Master Stream Ports (interface to testbench)
wire [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_tdata;
wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tkeep;
wire [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_tuser;
wire m_axis_tvalid;
wire m_axis_tready;
wire m_axis_tlast;

// Master Stream Ports (interface to endianess manager)
wire [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_tdata_ia;
wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tkeep_ia;
wire [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_tuser_ia;
wire m_axis_tvalid_ia;
wire m_axis_tready_ia;
wire m_axis_tlast_ia;

// Master Stream Ports (interface to router output port lookup)
wire [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_tdata_em;
wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tkeep_em;
wire [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_tuser_em;
wire m_axis_tvalid_em;
wire m_axis_tready_em;
wire m_axis_tlast_em;

wire [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_tdata_op;
wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tkeep_op;
wire [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_tuser_op;
wire m_axis_tvalid_op;
wire m_axis_tready_op;
wire m_axis_tlast_op;

// Slave Stream Ports (interface to testbench)
reg [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_0_tdata;
reg [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_0_tkeep;
reg [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_0_tuser;
reg  s_axis_0_tvalid;
wire s_axis_0_tready;
reg  s_axis_0_tlast;

reg [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_1_tdata;
reg [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_1_tkeep;
reg [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_1_tuser;
reg  s_axis_1_tvalid;
wire s_axis_1_tready;
reg  s_axis_1_tlast;

reg [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_2_tdata;
reg [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_2_tkeep;
reg [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_2_tuser;
reg  s_axis_2_tvalid;
wire s_axis_2_tready;
reg  s_axis_2_tlast;

reg [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_3_tdata;
reg [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_3_tkeep;
reg [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_3_tuser;
reg  s_axis_3_tvalid;
wire s_axis_3_tready;
reg  s_axis_3_tlast;

reg [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_4_tdata;
reg [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_4_tkeep;
reg [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_4_tuser;
reg  s_axis_4_tvalid;
wire s_axis_4_tready;
reg  s_axis_4_tlast;

reg [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_0_tdata_next;
reg [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_0_tkeep_next;
reg [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_0_tuser_next;
reg  s_axis_0_tvalid_next;
reg  s_axis_0_tlast_next;

reg [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_1_tdata_next;
reg [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_1_tkeep_next;
reg [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_1_tuser_next;
reg  s_axis_1_tvalid_next;
reg  s_axis_1_tlast_next;

reg [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_2_tdata_next;
reg [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_2_tkeep_next;
reg [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_2_tuser_next;
reg  s_axis_2_tvalid_next;
reg  s_axis_2_tlast_next;

reg [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_3_tdata_next;
reg [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_3_tkeep_next;
reg [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_3_tuser_next;
reg  s_axis_3_tvalid_next;
reg  s_axis_3_tlast_next;

reg [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_4_tdata_next;
reg [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_4_tkeep_next;
reg [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_4_tuser_next;
reg  s_axis_4_tvalid_next;
reg  s_axis_4_tlast_next;

// AXI-Lite
reg                                 S_AXI_ACLK;
reg                                 S_AXI_ARESETN;
reg [C_S_AXI_ADDR_WIDTH-1 : 0]      S_AXI_AWADDR;
reg                                 S_AXI_AWVALID;
reg [C_S_AXI_DATA_WIDTH-1 : 0]      S_AXI_WDATA;
reg [C_S_AXI_DATA_WIDTH/8-1 : 0]    S_AXI_WSTRB;
reg                                 S_AXI_WVALID;
reg                                 S_AXI_BREADY;
reg [C_S_AXI_ADDR_WIDTH-1 : 0]      S_AXI_ARADDR;
reg                                 S_AXI_ARVALID;
reg                                 S_AXI_RREADY;
wire                                S_AXI_ARREADY;
wire [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_RDATA;
wire [1 : 0]                        S_AXI_RRESP;
wire                                S_AXI_RVALID;
wire                                S_AXI_WREADY;
wire [1 : 0]                        S_AXI_BRESP;
wire                                S_AXI_BVALID;
wire                                S_AXI_AWREADY;


input_arbiter
    input_arbiter_i
    (
        .axis_aclk(clk),
        .axis_resetn(~reset),

        .m_axis_tdata(m_axis_tdata_ia),
        .m_axis_tkeep(m_axis_tkeep_ia),
        .m_axis_tuser(m_axis_tuser_ia),
        .m_axis_tvalid(m_axis_tvalid_ia),
        .m_axis_tready(m_axis_tready_ia),
        .m_axis_tlast(m_axis_tlast_ia),

        .s_axis_0_tdata(s_axis_0_tdata),
        .s_axis_0_tkeep(s_axis_0_tkeep),
        .s_axis_0_tuser(s_axis_0_tuser),
        .s_axis_0_tvalid(s_axis_0_tvalid),
        .s_axis_0_tready(s_axis_0_tready),
        .s_axis_0_tlast(s_axis_0_tlast),

        .s_axis_1_tdata(s_axis_1_tdata),
        .s_axis_1_tkeep(s_axis_1_tkeep),
        .s_axis_1_tuser(s_axis_1_tuser),
        .s_axis_1_tvalid(s_axis_1_tvalid),
        .s_axis_1_tready(s_axis_1_tready),
        .s_axis_1_tlast(s_axis_1_tlast),

        .s_axis_2_tdata(s_axis_2_tdata),
        .s_axis_2_tkeep(s_axis_2_tkeep),
        .s_axis_2_tuser(s_axis_2_tuser),
        .s_axis_2_tvalid(s_axis_2_tvalid),
        .s_axis_2_tready(s_axis_2_tready),
        .s_axis_2_tlast(s_axis_2_tlast),

        .s_axis_3_tdata(s_axis_3_tdata),
        .s_axis_3_tkeep(s_axis_3_tkeep),
        .s_axis_3_tuser(s_axis_3_tuser),
        .s_axis_3_tvalid(s_axis_3_tvalid),
        .s_axis_3_tready(s_axis_3_tready),
        .s_axis_3_tlast(s_axis_3_tlast),

        .s_axis_4_tdata(s_axis_4_tdata),
        .s_axis_4_tkeep(s_axis_4_tkeep),
        .s_axis_4_tuser(s_axis_4_tuser),
        .s_axis_4_tvalid(s_axis_4_tvalid),
        .s_axis_4_tready(s_axis_4_tready),
        .s_axis_4_tlast(s_axis_4_tlast)
    );

nf_endianess_manager
    nf_endianess_manager_i_1
    (
        .ACLK(clk),
        .ARESETN(~reset),

        .M_AXIS_INT_TDATA(m_axis_tdata_em),
        .M_AXIS_INT_TKEEP(m_axis_tkeep_em),
        .M_AXIS_INT_TUSER(m_axis_tuser_em),
        .M_AXIS_INT_TVALID(m_axis_tvalid_em),
        .M_AXIS_INT_TREADY(m_axis_tready_em),
        .M_AXIS_INT_TLAST(m_axis_tlast_em),

        .S_AXIS_TDATA(m_axis_tdata_ia),
        .S_AXIS_TKEEP(m_axis_tkeep_ia),
        .S_AXIS_TUSER(m_axis_tuser_ia),
        .S_AXIS_TVALID(m_axis_tvalid_ia),
        .S_AXIS_TREADY(m_axis_tready_ia),
        .S_AXIS_TLAST(m_axis_tlast_ia)
    );

router_output_port_lookup
    router_output_port_lookup_i
    (
        .axis_aclk(clk),
        .axis_resetn(~reset),

        .m_axis_tdata(m_axis_tdata_op),
        .m_axis_tkeep(m_axis_tkeep_op),
        .m_axis_tuser(m_axis_tuser_op),
        .m_axis_tvalid(m_axis_tvalid_op),
        .m_axis_tready(m_axis_tready_op),
        .m_axis_tlast(m_axis_tlast_op),

        .s_axis_tdata(m_axis_tdata_em),
        .s_axis_tkeep(m_axis_tkeep_em),
        .s_axis_tuser(m_axis_tuser_em),
        .s_axis_tvalid(m_axis_tvalid_em),
        .s_axis_tready(m_axis_tready_em),
        .s_axis_tlast(m_axis_tlast_em),

        .S_AXI_ACLK(clk),
        .S_AXI_ARESETN(~reset),
        .S_AXI_AWADDR(S_AXI_AWADDR),
        .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_WDATA(S_AXI_WDATA),
        .S_AXI_WSTRB(S_AXI_WSTRB),
        .S_AXI_WVALID(S_AXI_WVALID),
        .S_AXI_BREADY(S_AXI_BREADY),
        .S_AXI_ARADDR(S_AXI_ARADDR),
        .S_AXI_ARVALID(S_AXI_ARVALID),
        .S_AXI_RREADY(S_AXI_RREADY),
        .S_AXI_ARREADY(S_AXI_ARREADY),
        .S_AXI_RDATA(S_AXI_RDATA),
        .S_AXI_RRESP(S_AXI_RRESP),
        .S_AXI_RVALID(S_AXI_RVALID),
        .S_AXI_WREADY(S_AXI_WREADY),
        .S_AXI_BRESP(S_AXI_BRESP),
        .S_AXI_BVALID(S_AXI_BVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY)
    );

nf_endianess_manager
    nf_endianess_manager_i_2
    (
        .ACLK(clk),
        .ARESETN(~reset),

        .M_AXIS_TDATA(m_axis_tdata),
        .M_AXIS_TKEEP(m_axis_tkeep),
        .M_AXIS_TUSER(m_axis_tuser),
        .M_AXIS_TVALID(m_axis_tvalid),
        .M_AXIS_TREADY(m_axis_tready),
        .M_AXIS_TLAST(m_axis_tlast),

        .S_AXIS_INT_TDATA(m_axis_tdata_op),
        .S_AXIS_INT_TKEEP(m_axis_tkeep_op),
        .S_AXIS_INT_TUSER(m_axis_tuser_op),
        .S_AXIS_INT_TVALID(m_axis_tvalid_op),
        .S_AXIS_INT_TREADY(m_axis_tready_op),
        .S_AXIS_INT_TLAST(m_axis_tlast_op)
    );

assign m_axis_tready = 1;

reg [7:0] state;
reg [7:0] state_next;

localparam INIT = 8'h0;
localparam CONNECT = 8'h1;
localparam R_REG = 8'h2;
localparam DELAY1 = 8'h3;
localparam R_ORDER = 8'h4;
localparam DELAY2 = 8'h5;
localparam C_SYN = 8'h6;
localparam DELAY3 = 8'h7;
localparam S_SYN_ACK = 8'h8;
localparam DELAY4 = 8'h9;
localparam S_ACK_1 = 8'ha;
localparam S_LOGON = 8'hb;
localparam END = 8'hc;
localparam DELAY_CYCLE = 8'hd;
localparam R_UDP = 8'he;
localparam DELAY5 = 8'hf;
localparam S_ACK_2_1 = 8'h31;
localparam S_ACK_2_2 = 8'h32;
localparam S_ACK_2_3 = 8'h33;
localparam S_REPORT_1 = 8'h21;
localparam S_REPORT_2 = 8'h22;
localparam S_REPORT_3 = 8'h23;
localparam S_REPORT_4 = 8'h24;
localparam S_REPORT_5 = 8'h25;
localparam S_REPORT_6 = 8'h26;
localparam S_REPORT_7 = 8'h27;
localparam S_REPORT_8 = 8'h28;
localparam DELAY6 = 8'h12;
localparam MY_DELAY = 8'h13;


reg isConnect;

integer i;

reg [31:0] fp_r [0:5];
reg [31:0] fp_w;
reg [31:0] fp_all_w;
reg fp_eof[0:5];
reg input_rden [0:5];
reg output_wren;

wire [31:0] totalIn;
reg [31:0] pktIn [0:4];
reg [31:0] pktOut;
reg [31:0] idleCount;
reg firstPacketOut;

reg input_user;
reg catch_order;

reg [31:0] delay_counter;
reg [31:0] delay_counter_reg;
reg [31:0] delay_counter_max;
reg [7:0] state_after_delay;

assign totalIn = pktIn[0] + pktIn[1] + pktIn[2];


always #(`CYCLE / 2) clk = ~clk;

initial begin
    reset = 1;
    #100 reset = 0;
end

initial begin
    $timeformat(-8, 0, " cyles", 10);
    $display("[%0t]  MYINFO: Start testbench", $time);
    clk = 0;
    //reset = 0;

    s_axis_3_tdata = 0;
    s_axis_3_tkeep = 32'hFFFFFFFF;
    s_axis_3_tuser = 0;
    s_axis_3_tvalid = 0;
    s_axis_3_tlast = 0;

    s_axis_4_tdata = 0;
    s_axis_4_tkeep = 32'hFFFFFFFF;
    s_axis_4_tuser = 0;
    s_axis_4_tvalid = 0;
    s_axis_4_tlast = 0;

    pktOut = 0;

    fp_r[0] = $fopen("input_0.axi", "r");
    fp_r[1] = $fopen("input_1.axi", "r");
    fp_r[2] = $fopen("input_2.axi", "r");

    fp_r[5] = $fopen("input_reg.axi", "r");

    fp_w = $fopen("output.axi", "w");
    fp_all_w = $fopen("output_all.axi", "w");

    for(i=0;i<6;i=i+1)
        input_rden[i] = 0;

    output_wren = 1;

end

//control AXI-Lite input
always @ (*) begin
    state_next = state;
    //state_after_delay = state;
    //delay_counter_max = 0;
    //delay_counter_reg = 0;
    /*
    S_AXI_AWADDR = 0;
    S_AXI_AWVALID = 0;
    S_AXI_WDATA = 0;
    S_AXI_WSTRB = 0;
    S_AXI_WVALID = 0;
    S_AXI_BREADY = 1;
    S_AXI_ARADDR = 0;
    S_AXI_ARVALID = 0;
    S_AXI_RREADY = 1;
    */

    input_user = 0;
    input_rden[0] = 0;
    input_rden[1] = 0;
    input_rden[5] = 0;

    case(state)
        INIT: begin
            if(~reset) begin
                #(`CYCLE * 10)
                state_next = CONNECT;
            end
        end

        CONNECT: begin
            S_AXI_AWVALID = 1;
            S_AXI_WVALID = 1;

            state_next = R_REG;
            input_rden[5] = 1;
        end

        R_REG: begin
                S_AXI_AWVALID = 1;
                S_AXI_WVALID = 1;
                state_next = DELAY1;
                input_rden[5] = 0;
        end

        DELAY1: begin
            S_AXI_AWVALID = 1;
            S_AXI_WVALID = 1;
            if(fp_eof[5]) begin
                state_next = R_ORDER;
                input_rden[5] = 0;
                input_rden[1] = 1;
            end
            else begin
                state_next = R_REG;
                input_rden[5] = 1;
            end
        end

        R_ORDER: begin
            S_AXI_AWVALID = 0;
            S_AXI_WVALID = 0;
            if(fp_eof[1]) begin
                state_next = DELAY_CYCLE;
                input_rden[1] = 0;
            end
            else if(s_axis_1_tlast) begin
                //$display("[%0t]  MYINFO: SEND ORDER %d", $time, pktIn[1]);
                state_next = DELAY2;
                input_rden[1] = 0;
            end
            else begin
                state_next = R_ORDER;
                input_rden[1] = 1;
            end
        end

        DELAY2: begin
            //#(`CYCLE)
            if(fp_eof[1]) begin
                state_next = DELAY_CYCLE;
                input_rden[1] = 0;
            end
            else begin
                //#(`CYCLE * 200)
                state_next = R_ORDER;
                input_rden[1] = 1;
            end
        end

        DELAY_CYCLE: begin
            #(`CYCLE * 200)
            state_next = C_SYN;
            S_AXI_AWVALID = 1;
            S_AXI_WVALID = 1;
        end

        C_SYN: begin
            $display("[%0t]  MYINFO: CONNECT Signal", $time);
            S_AXI_AWADDR = 32'h88;
            S_AXI_AWVALID = 1;
            S_AXI_WDATA = 1;
            S_AXI_WSTRB = 4'hf;
            S_AXI_WVALID = 1;

            isConnect = 1;

            state_next = DELAY3;
        end

        DELAY3: begin
            #(`CYCLE * 100) 
            state_next = S_SYN_ACK;
            input_rden[0] = 1;
        end

        S_SYN_ACK: begin
            if(s_axis_0_tlast) begin
                $display("[%0t]  MYINFO: Server SEND SYN_ACK", $time);
                state_next = DELAY4;
                input_rden[0] = 0;
            end
            else begin
                state_next = S_SYN_ACK;
                input_rden[0] = 1;    
            end
        end

        DELAY4: begin
            #(`CYCLE * 200)
            state_next = S_ACK_1;
            input_rden[0] = 1;
        end

        S_ACK_1: begin
            if(s_axis_0_tlast) begin
                $display("[%0t]  MYINFO: Server SEND ACK", $time);
                state_next = S_LOGON;
                input_rden[0] = 1;
            end
            else begin
                state_next = S_ACK_1;
                input_rden[0] = 1;    
            end
        end

        S_LOGON: begin
            if(s_axis_0_tlast) begin
                $display("[%0t]  MYINFO: Server SEND LOGON", $time);
                state_next = DELAY6;
                input_rden[0] = 0;
            end
            else begin
                state_next = S_LOGON;
                input_rden[0] = 1;    
            end
        end

        DELAY6: begin
            #(`CYCLE * 200)
            state_next = R_UDP;
            input_rden[2] = 1;
        end

        R_UDP: begin
            if(fp_eof[2]) begin
                state_next = END;
                input_rden[2] = 0;
            end
            else if(s_axis_2_tlast) begin
                $display("[%0t]  MYINFO: SEND UDP %d %d", $time, pktIn[2], pktOut);
                state_next = DELAY5;
                delay_counter_reg = 0;
                delay_counter_max = 200;
                input_rden[2] = 0;
            end
            else begin
                state_next = R_UDP;
                input_rden[2] = 1;    
            end
        end

        DELAY5: begin
            if(delay_counter < delay_counter_max) begin
                if(catch_order) begin
                    state_next = S_ACK_2_1;
                    delay_counter_reg = 0;
                    //catch_order = 0;
                end
                else begin
                    state_next = DELAY5;
                    delay_counter_reg = delay_counter + 1;
                end
            end

            else if(fp_eof[2]) begin
                state_next = END;
                input_rden[2] = 0;
            end
            else begin
                state_next = R_UDP;
                input_rden[2] = 1;
            end
        end
        
        S_ACK_2_1: begin
            input_user = 1;
            s_axis_0_tdata = 256'h748cb952748cab7c06400040b9ff34000045000810906dec021403454d555302;
            s_axis_0_tkeep = 32'hffffffff;
            s_axis_0_tuser[23:16]  = 8'h40;
            s_axis_0_tvalid = 1;
            s_axis_0_tlast = 0;
            state_next = S_ACK_2_2;
        end

        S_ACK_2_2: begin
            input_user = 1;
            s_axis_0_tdata = 256'h0e024edbf50b0a080101000085beeb001080100300001cd118d704e78a13bd52;
            s_axis_0_tkeep = 32'hffffffff;
            s_axis_0_tuser[23:16]  = 8'h40;
            s_axis_0_tvalid = 1;
            s_axis_0_tlast = 0;
            state_next = S_ACK_2_3;
        end

        S_ACK_2_3: begin
            input_user = 1;
            s_axis_0_tdata = 256'h0e024edbf50b0a080101000085beeb001080100300001cd118d704e78a138767;
            s_axis_0_tkeep = 32'h3;
            s_axis_0_tuser[23:16]  = 8'h40;
            s_axis_0_tvalid = 1;
            s_axis_0_tlast = 1;

            state_next = MY_DELAY;
            delay_counter_max = 10;
            delay_counter_reg = 0;
            state_after_delay = S_REPORT_1;
        end

        S_REPORT_1: begin
            input_user = 1;
            s_axis_0_tdata = 256'h748cb952748cfb7b06400040baffe3000045000810906dec021403454d555302;
            s_axis_0_tkeep = 32'hffffffff;
            s_axis_0_tuser[23:16]  = 8'h40;
            s_axis_0_tvalid = 1;
            s_axis_0_tlast = 0;
            state_next = S_REPORT_2;
        end

        S_REPORT_2: begin
            input_user = 1;
            s_axis_0_tdata = 256'h0e024edbf50b0a080101000034bfeb001880100300001cd118d704e78a13bd52;
            s_axis_0_tkeep = 32'hffffffff;
            s_axis_0_tuser[23:16]  = 8'h40;
            s_axis_0_tvalid = 1;
            s_axis_0_tlast = 0;
            state_next = S_REPORT_3;
        end

        S_REPORT_3: begin
            input_user = 1;
            s_axis_0_tdata = 256'h453d393401383d343301383d3533013235313d3901342e342e5849463d388767;
            s_axis_0_tkeep = 32'hffffffff;
            s_axis_0_tuser[23:16]  = 8'h40;
            s_axis_0_tvalid = 1;
            s_axis_0_tlast = 0;
            state_next = S_REPORT_4;
        end

        S_REPORT_4: begin
            input_user = 1;
            s_axis_0_tdata = 256'h3638392e30343a30303a33302d36303131383130323d323501524f5455434558;
            s_axis_0_tkeep = 32'hffffffff;
            s_axis_0_tuser[23:16]  = 8'h40;
            s_axis_0_tvalid = 1;
            s_axis_0_tlast = 0;
            state_next = S_REPORT_5;
        end

        S_REPORT_5: begin
            input_user = 1;
            s_axis_0_tdata = 256'h3d313101303d3601353838383838383d310131544e45494c433d363501343133;
            s_axis_0_tkeep = 32'hffffffff;
            s_axis_0_tuser[23:16]  = 8'h40;
            s_axis_0_tvalid = 1;
            s_axis_0_tlast = 0;
            state_next = S_REPORT_6;
        end

        S_REPORT_6: begin
            input_user = 1;
            s_axis_0_tdata = 256'h3733013133343d323301313d373101303d3431013838313834323030305a3330;
            s_axis_0_tkeep = 32'hffffffff;
            s_axis_0_tuser[23:16]  = 8'h40;
            s_axis_0_tvalid = 1;
            s_axis_0_tlast = 0;
            state_next = S_REPORT_7;
        end

        S_REPORT_7: begin
            input_user = 1;
            s_axis_0_tdata = 256'h3531013530393537303d353501313d343501343d3933013133343d383301313d;
            s_axis_0_tkeep = 32'hffffffff;
            s_axis_0_tuser[23:16]  = 8'h40;
            s_axis_0_tvalid = 1;
            s_axis_0_tlast = 0;
            
            state_next = S_REPORT_8;
        end

        S_REPORT_8: begin
            $display("[%0t]  MYINFO: Server SEND Report", $time);
            input_user = 1;
            s_axis_0_tdata = 256'h3531013530393537303d353501313d013531313d303101303d31353101343d30;
            s_axis_0_tkeep = 32'h1ffff;
            s_axis_0_tuser[23:16]  = 8'h40;
            s_axis_0_tvalid = 1;
            s_axis_0_tlast = 1;
            
            delay_counter_max = 1000;
            delay_counter_reg = 0;
            catch_order = 0;
            state_next = DELAY5;
        end


        END: begin
            state_next = END;
        end

        MY_DELAY: begin
           if(delay_counter >= delay_counter_max) begin
                state_next = state_after_delay;
                delay_counter_reg = 0;
           end
           else begin
                state_next = MY_DELAY;
                delay_counter_reg = delay_counter + 1;
           end
        end

    endcase
end

always @ (posedge clk) begin
    if(reset) begin
        state <= INIT;
        isConnect <= 0;
        delay_counter <= 0;

        s_axis_0_tdata <= 0;
        s_axis_0_tkeep <= 0;
        s_axis_0_tuser <= 0;
        s_axis_0_tvalid <= 0;
        s_axis_0_tlast <= 0;

        s_axis_1_tdata <= 0;
        s_axis_1_tkeep <= 0;
        s_axis_1_tuser <= 0;
        s_axis_1_tvalid <= 0;
        s_axis_1_tlast <= 0;

        s_axis_2_tdata <= 0;
        s_axis_2_tkeep <= 0;
        s_axis_2_tuser <= 0;
        s_axis_2_tvalid <= 0;
        s_axis_2_tlast <= 0;
    end
    else begin
        state <= state_next;
        delay_counter <= delay_counter_reg;
        /*
        s_axis_0_tdata <= s_axis_0_tdata_next;
        s_axis_0_tkeep <= s_axis_0_tkeep_next;
        s_axis_0_tuser <= s_axis_0_tuser_next;
        s_axis_0_tvalid <= s_axis_0_tvalid_next;
        s_axis_0_tlast <= s_axis_0_tlast_next;

        s_axis_1_tdata <= s_axis_1_tdata_next;
        s_axis_1_tkeep <= s_axis_1_tkeep_next;
        s_axis_1_tuser <= s_axis_1_tuser_next;
        s_axis_1_tvalid <= s_axis_1_tvalid_next;
        s_axis_1_tlast <= s_axis_1_tlast_next;

        s_axis_2_tdata <= s_axis_2_tdata_next;
        s_axis_2_tkeep <= s_axis_2_tkeep_next;
        s_axis_2_tuser <= s_axis_2_tuser_next;
        s_axis_2_tvalid <= s_axis_2_tvalid_next;
        s_axis_2_tlast <= s_axis_2_tlast_next;*/
    end
end


//read axi_reg
always @ (posedge clk) begin
    if(reset) begin
        fp_eof[5] <= 0;
        S_AXI_AWADDR <= 0;
        S_AXI_AWVALID <= 0;
        S_AXI_WDATA <= 0;
        S_AXI_WSTRB <= 0;
        S_AXI_WVALID <= 0;
    end
    else begin
        if(~fp_eof[5] && input_rden[5]) begin
            if(32'h2 != $fscanf(fp_r[5], "%x %x", S_AXI_AWADDR, S_AXI_WDATA)) begin
                fp_eof[5] <= 1;
                $display("[%0t]  MYINFO: finished register stimulus file(S_AXI)", $time);
                $fclose(fp_r[5]);
                S_AXI_AWADDR <= 0;
                S_AXI_AWVALID <= 0;
                S_AXI_WDATA <= 0;
                S_AXI_WSTRB <= 0;
                S_AXI_WVALID <= 0;
            end
            else begin
                S_AXI_AWVALID <= 1;
                S_AXI_WSTRB <= 4'hf;
                S_AXI_WVALID <= 1;
            end
        end
        else begin
            S_AXI_AWADDR <= S_AXI_AWADDR;
            S_AXI_AWVALID <= S_AXI_AWVALID;
            S_AXI_WDATA <= S_AXI_WDATA;
            S_AXI_WSTRB <= S_AXI_WSTRB;
            S_AXI_WVALID <= S_AXI_WVALID;
        end

    end
end

//read s_axis_0
always @ (negedge clk) begin
    if(reset) begin
        fp_eof[0] <= 0;
        pktIn[0] <= 0;
        s_axis_0_tdata <= 0;
        s_axis_0_tkeep <= 0;
        s_axis_0_tuser <= 0;
        s_axis_0_tvalid <= 0;
        s_axis_0_tlast <= 0;
    end
    else begin
        if(s_axis_0_tready && ~fp_eof[0] && input_rden[0]) begin
            if(32'h3 != $fscanf(fp_r[0], "%x %x %x", s_axis_0_tlast, s_axis_0_tkeep, s_axis_0_tdata)) begin
                fp_eof[0] <= 1;
                $display("[%0t]  MYINFO: finished packet stimulus file(s_axis_0)", $time);
                $fclose(fp_r[0]);
                s_axis_0_tdata <= 0;
                s_axis_0_tkeep <= 0;
                s_axis_0_tuser <= 0;
                s_axis_0_tvalid <= 0;
                s_axis_0_tlast <= 0;
            end
            else begin
                $fwrite(fp_all_w, "%x %x %x\n", s_axis_0_tlast, s_axis_0_tkeep, s_axis_0_tdata);

                s_axis_0_tvalid <= 1;
                s_axis_0_tuser[23:16] <= 8'h08;
                if(s_axis_0_tlast) pktIn[0] <= pktIn[0] + 1;
            end
        end
        else if(s_axis_0_tready && input_user) begin
            s_axis_0_tdata <= s_axis_0_tdata;
            s_axis_0_tkeep <= s_axis_0_tkeep;
            s_axis_0_tuser <= s_axis_0_tuser;
            s_axis_0_tvalid <= s_axis_0_tvalid;
            s_axis_0_tlast <= s_axis_0_tlast;
        end
        else begin
            s_axis_0_tdata <= 0;
            s_axis_0_tkeep <= 0;
            s_axis_0_tuser <= 0;
            s_axis_0_tvalid <= 0;
            s_axis_0_tlast <= 0;
        end
    end
end


//read s_axis_1
always @ (posedge clk) begin
    if(reset) begin
        fp_eof[1] <= 0;
        pktIn[1] <= 0;
        s_axis_1_tdata <= 0;
        s_axis_1_tkeep <= 0;
        s_axis_1_tuser <= 0;
        s_axis_1_tvalid <= 0;
        s_axis_1_tlast <= 0;
    end
    else begin
        if(s_axis_1_tready && ~fp_eof[1] && input_rden[1]) begin
            if(32'h3 != $fscanf(fp_r[1], "%x %x %x", s_axis_1_tlast, s_axis_1_tkeep, s_axis_1_tdata)) begin
                fp_eof[1] <= 1;
                $display("[%0t]  MYINFO: finished packet stimulus file(s_axis_1)", $time);
                $fclose(fp_r[1]);
                s_axis_1_tdata <= 0;
                s_axis_1_tkeep <= 0;
                s_axis_1_tuser <= 0;
                s_axis_1_tvalid <= 0;
                s_axis_1_tlast <= 0;
            end
            else begin
                s_axis_1_tvalid <= 1;
                s_axis_1_tuser[23:16] <= 8'h04; //order from nf3
                s_axis_1_tuser[63:48] <= pktIn[1];
                if(s_axis_1_tlast) pktIn[1] <=  pktIn[1] + 1;
            end
        end
        else begin
            s_axis_1_tdata <= 0;
            s_axis_1_tkeep <= 0;
            s_axis_1_tuser <= 0;
            s_axis_1_tvalid <= 0;
            s_axis_1_tlast <= 0;
        end
    end
end

//read s_axis_2
always @ (posedge clk) begin
    if(reset) begin
        fp_eof[2] <= 0;
        pktIn[2] <= 0;
        s_axis_2_tdata <= 0;
        s_axis_2_tkeep <= 0;
        s_axis_2_tuser <= 0;
        s_axis_2_tvalid <= 0;
        s_axis_2_tlast <= 0;
    end
    else begin
        if(s_axis_2_tready && ~fp_eof[2] && input_rden[2]) begin
            if(32'h3 != $fscanf(fp_r[2], "%x %x %x", s_axis_2_tlast, s_axis_2_tkeep, s_axis_2_tdata)) begin
                fp_eof[2] <= 1;
                $display("[%0t]  MYINFO: finished packet stimulus file(s_axis_2)", $time);
                $fclose(fp_r[2]);
                s_axis_2_tdata <= 0;
                s_axis_2_tkeep <= 0;
                s_axis_2_tuser <= 0;
                s_axis_2_tvalid <= 0;
                s_axis_2_tlast <= 0;
            end
            else begin
                s_axis_2_tvalid <= 1;
                s_axis_2_tuser[23:16] <= 8'h01;
                if(s_axis_2_tlast) pktIn[2] <= pktIn[2] + 1;
            end
        end
        else begin
            s_axis_2_tdata <= 0;
            s_axis_2_tkeep <= 0;
            s_axis_2_tuser <= 0;
            s_axis_2_tvalid <= 0;
            s_axis_2_tlast <= 0;
        end
    end
end

//write m_axis
always @ (posedge clk) begin
    if(reset) begin
        catch_order <= 0;
        //do nothing
    end
    else begin
        if(m_axis_tvalid && output_wren) begin
            if(m_axis_tdata[183:144] == 40'h01463d3533) begin
                $display("[%0t]  MYINFO: catch order", $time);
                catch_order <= 1;
            end 
            //$display("%x %x %x\n", m_axis_tlast, m_axis_tkeep, m_axis_tdata);
            $fwrite(fp_w, "%x %x %x\n", m_axis_tlast, m_axis_tkeep, m_axis_tdata);
            $fwrite(fp_all_w, "%x %x %x\n", m_axis_tlast, m_axis_tkeep, m_axis_tdata);
            if(m_axis_tlast) begin 
                $display("[%0t]  MYINFO: packet out", $time);
                pktOut <= (pktOut + 1);
            end
        end
        else begin
            catch_order <= catch_order;
        end
    end
end

always @ (posedge clk) begin
    if(reset) begin
        idleCount <= 0;
        firstPacketOut <= 0;
    end
    else begin
        if(m_axis_tvalid && m_axis_tlast) begin
            idleCount <= 0;
            firstPacketOut <= 1;
        end
        else begin
            if(firstPacketOut) begin
                firstPacketOut <= 1;
                idleCount <= (idleCount + 1);

                if((fp_eof[0] == 1) && (fp_eof[1] == 1) && (fp_eof[2] == 1) && (totalIn == pktOut)) begin
                    $display("[%0t]  MYINFO: finished packet verification file(m_axis)", $time);
                    $fclose(fp_w);
                    $fclose(fp_all_w);
                    $finish(1);
                end
                else if( (idleCount >= 10000) && (fp_eof[2] == 1) ) begin
                    $display("[%0t]  MYINFO: stopping simulation after 10000 idle cycles", $time);
                    $display("[%0t]  MYINFO: pktIn = %d, pktOut = %d", $time, totalIn, pktOut);
                    $fclose(fp_w);
                    $fclose(fp_all_w);
                    $finish(1);
                end
            end
        end
    end
end


endmodule
