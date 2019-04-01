#!/usr/bin/python
#
# Copyright (c) 2017 University of Cambridge
# Copyright (c) 2017 Jong Hun Han
# All rights reserved.
#
# This software was developed by University of Cambridge Computer Laboratory
# under the ENDEAVOUR project (grant agreement 644960) as part of
# the European Union's Horizon 2020 research and innovation programme.
#
# @NETFPGA_LICENSE_HEADER_START@
#
# Licensed to NetFPGA Open Systems C.I.C. (NetFPGA) under one or more
# contributor license agreements. See the NOTICE file distributed with this
# work for additional information regarding copyright ownership. NetFPGA
# licenses this file to you under the NetFPGA Hardware-Software License,
# Version 1.0 (the License); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at:
#
# http://www.netfpga-cic.org
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
#
# @NETFPGA_LICENSE_HEADER_END@
################################################################################

import os
import re
import sys
import argparse
import random
import string
import numpy as np
from numpy import ndarray
from scapy.all import wrpcap
from scapy.layers.all import Ether, IP, TCP, UDP
from curses.ascii import *
from datetime import datetime
from time import gmtime, strftime
from decimal import *
script_dir = os.path.dirname(sys.argv[0])

#Input arguments
parser = argparse.ArgumentParser()
parser.add_argument("--packet_length", help="Length of packet in no of bytes")
parser.add_argument("--packet_no", help="No of packets")
parser.add_argument("--packet_type", type=str, help="TCP, UDP")
parser.add_argument("--file_name", type=str, help="File name for output pcap")
parser.add_argument("--src_mac", type=str, help="Source MAC address")
parser.add_argument("--dst_mac", type=str, help="Destination MAC address")
parser.add_argument("--src_ip", type=str, help="Source IP address")
parser.add_argument("--dst_ip", type=str, help="Destination IP address")
parser.add_argument("--sport_no", help="Source Port Number")
parser.add_argument("--dport_no", help="Destination Port Number")
parser.add_argument("--packet_ts", type=float, help="Packet timestamp")

args = parser.parse_args()

#Length of Packets
if (args.packet_length):
   pkt_length = args.packet_length
else:
   # Default length of packets
   pkt_length = '270'

if (args.packet_ts):
   pkt_timestamp = args.packet_ts
else:
   pkt_timestamp = 8

#No of packets
if (args.packet_no):
   no_pkt = args.packet_no
else:
	#Default number of packets
   no_pkt = 1

if (args.file_name):
   pcap_name = args.file_name
else:
   print "\n\nInput file name for output pcap file\n"
   sys.exit()

if (args.packet_type == 'udp' or args.packet_type == 'UDP'):
   pkt_type = 'udp'
   pkt_length = int(pkt_length) - 28 - 14
elif (args.packet_type == 'tcp' or args.packet_type == 'TCP'):
   pkt_type = 'tcp'
   pkt_length = int(pkt_length) - 40 
else:
   pkt_type = 'tcp'
   pkt_length = int(pkt_length) -28

print '\nPacket type ',str(pkt_type)

#Source and Destination IP address allocation
if (args.src_mac):
   src_mac_addr=args.src_mac
else:
	src_mac_addr='02:53:55:4d:45:00'

if (args.dst_mac):
	dst_mac_addr=args.dst_mac
else:
	dst_mac_addr='02:53:55:4d:45:00'

#Source and Destination IP address allocation
if (args.src_ip):
	src_ip_addr=args.src_ip
else:
	src_ip_addr='140.116.82.183'

if (args.dst_ip):
	dst_ip_addr=args.dst_ip
else:
	dst_ip_addr='140.116.82.189'

#Source and Destination port number
if (args.sport_no):
	ip_sport_no=int(args.sport_no)
else:
	ip_sport_no=59140

if (args.dport_no):
	ip_dport_no=int(args.dport_no)
else:
	ip_dport_no=5002

#Payload appended to packet header
#FIX Header
#fix_heartbeat_header_data = ''
fix_heartbeat_header_data = '8=FIX.4.4\x019=61\x0135=0\x01'

#fix_sending_data = ''
fix_sending_data = '49=EXECUTOR\x01'


#sending_time = strftime("%Y%m%d-%H:%M:%S.123456",gmtime())
#fix_sending_time_data = '52=' + sending_time 

#target ID 
fix_Target_ID = '56=CLIENT1\x01'


#Change for day
fix_ClOrd_ID = '11=CAC12DE4401A\x01'

#AUTOMATED EXECUTION ORDER PRIVATE No BROKER
fix_handl_Inst = '21=1\x01'

#LIMIT
fix_Ord_Type = '40=2\x01'

#number of Order 
Qty = random.randint(1,999)
str_Qty = str(Qty)
fix_order_Qty = '38='+ str_Qty

if Qty >= 100 :
        fix_order_Qty = '38=' + str_Qty + '\x01'
elif   Qty < 100 and Qty >= 10 :
        fix_order_Qty = '38=' + '0' + str_Qty + '\x01'
elif   Qty < 10 :
        fix_order_Qty = "38=" + '0' + '0' + str_Qty + '\x01'


#Side = str(random.randint(1,2))
#fix_order_side = '54=' + Side


#Price = random.randint(1,999999999)
#str_Price = str(Price)
#if Price >= 100000000 :
#        fix_order_price = '44=' + str_Price  + '\x01'
#elif   Price < 100000000 and Price >= 10000000 :
#        fix_order_price = '44=' + '0' + str_Price + '\x01'
#elif   Price < 10000000  and Price >= 1000000 :
#        fix_order_price = "44=" + '0' + '0' + str_Price + '\x01'
#elif   Price < 1000000   and Price >= 100000  :
#	fix_order_price = "44=" + '0' + '0' + '0' + str_Price + '\x01'
#elif   Price < 100000    and Price >= 10000   :
#	fix_order_price = "44=" + '0' + '0' + '0' + '0' +str_Price + '\x01'
#elif   Price < 10000     and Price >= 1000    :
#	fix_order_price = "44=" + '0' + '0' + '0' + '0' + '0' + str_Price + '\x01'
#elif   Price < 1000	 and Price >= 100     :
#        fix_order_price = "44=" + '0' + '0' + '0' + '0' + '0' + '0' +str_Price + '\x01'
#elif   Price < 100	 and Price >= 10      :
#        fix_order_price = "44=" + '0' + '0' + '0' + '0' + '0' + '0' + '0' + str_Price + '\x01'
#elif   Price < 10			      :
#        fix_order_price = "44=" + '0' + '0' + '0' + '0' + '0' + '0' + '0' + '0' + str_Price + '\x01'


fix_timeInForce = '59=0\x01'

#transactTime = strftime("%Y%m%d-%H:%M:%S",gmtime())
#fix_transactTime = '60=' + transactTime + '\x01'

text_file = open("Commodity.txt", "r")
#text_file = open("Stock_ID.txt" , "r")
#Stock_ID_lines = text_file.read().split('\t\n')
Warrants_ID_lines = text_file.read().split()
#print len(Stock_ID_lines)
#for i in range(int(len(Stock_ID_lines))):
#	Stock_ID_lines[i] = Stock_ID_lines[i].strip()
#print len(Warrants_ID_lines)
for i in range(int(len(Warrants_ID_lines))):
        Warrants_ID_lines[i] = Warrants_ID_lines[i].strip()
#for i in range(0, 65534):
#	j = random.randint(0,287)
#	fix_symbol[i] = '55='+Stock_ID_lines[j]+'\x01'

text_file_for_udp = open("Stock_ID.txt", "r")
Stock_ID_lines = text_file_for_udp.read().split('\t\n')
#print len(Stock_ID_lines)
for i in range(int(len(Stock_ID_lines))):
       Stock_ID_lines[i] = Stock_ID_lines[i].strip()



#print Stock_ID_lines[0]
#print Stock_ID_lines[11]
#print lines[0]
#print lines[11]
#print len(lines)
#text_file.close()



#fix_checksum_string  = fix_heartbeat_header_data + fix_sending_data + fix_sending_time_data + fix_Target_ID + fix_ClOrd_ID + fix_handl_Inst + fix_order_Qty + fix_Ord_Type + fix_order_side + fix_order_price + fix_timeInForce 


#fix_test = '8=FIX.4.4\x019=73\x0135=A\x0134=1\x0149=EXECUTOR\x0152=20180906-15:14:49.920671\x0156=CLIENT1\x0198=0\x01108=30\x01'                                            
#fix=fix_checksum_string.encode("ascii")

#fix=fix_test.encode("")
#fix_checksum_len = len(fix_checksum_string)
#fix_checksum_sum = (sum(bytearray(fix_test)))
#ff = hex(fix_checksum_sum).lstrip("0x")

##fix_checksum_sum = sum(bytearray(fix_test))%256
##str_fix = str(fix_checksum_sum)
##print fix_checksum_sum
##print str_fix

#fix_checksum_sum = sum(bytearray(fix_checksum_string))%256
#str_fix = str(fix_checksum_sum)
#bcd_fix_checksum = ''
#if fix_checksum_sum >= 100 :
#        bcd_fix_checksum = str_fix[0] + str_fix[1] + str_fix[2]
#elif   fix_checksum_sum < 100 and fix_checksum_sum >= 10 :
#        bcd_fix_checksum = '0' + str_fix[0] + str_fix[1]
#elif   fix_checksum_sum < 10 :
#	bcd_fix_checksum = '0' + '0' + str_fix[0]
#bcd_fix_checksum = '10=' + bcd_fix_checksum + '\x01'




pkts_tcp=[]
#A simple TCP/IP packet embedded in an Ethernet II frame
for i in range(int(no_pkt)):

   j = random.randint(0,1549)
#   if len(Stock_ID_lines[j]) >= 6 :
#	fix_symbol = '55='+Stock_ID_lines[j]+'\x01'
#   if len(Stock_ID_lines[j]) < 6 and len(Stock_ID_lines[j]) >= 5 :
#	fix_symbol = '55='+ '0' +Stock_ID_lines[j]+'\x01'
#   elif len(Stock_ID_lines[j]) < 5 and len(Stock_ID_lines[j]) >= 4 :
#        fix_symbol = '55='+ '0' + '0' + Stock_ID_lines[j]+'\x01'
#   elif len(Stock_ID_lines[j]) < 4 and len(Stock_ID_lines[j]) >= 3 :
#        fix_symbol = '55='+ '0' + '0' + '0' + Stock_ID_lines[j]+'\x01'


   fix_symbol= '55='+Warrants_ID_lines[j]+'\x01'
   tmp = i+1
   str_tmp = str(tmp)
   #fix_seq_num = '34='+ str_tmp + '\x01'
   if tmp >= 100000 :
	fix_seq_num = '34=' + str_tmp  + '\x01'
   elif   tmp < 100000 and tmp >= 10000 :
        fix_seq_num = '34=' + '0' + str_tmp + '\x01'
   elif   tmp < 10000  and tmp >= 1000 :
        fix_seq_num = "34=" + '0' + '0' + str_tmp + '\x01'
   elif   tmp < 1000   and tmp >= 100  :
        fix_seq_num = "34=" + '0' + '0' + '0' + str_tmp + '\x01'
   elif   tmp < 100    and tmp >= 10   :
        fix_seq_num = "34=" + '0' + '0' + '0' + '0' +str_tmp + '\x01'
   elif   tmp < 10    :
        fix_seq_num = "34=" + '0' + '0' + '0' + '0' + '0' + str_tmp + '\x01'


   sending_time = strftime("%Y%m%d-%H:%M:%S.123",gmtime())
   fix_sending_time_data = '52=' + sending_time + '\x01'


   Price = random.randint(1,999999999)
   str_Price = str(Price)

   if Price >= 100000000 :
        fix_order_price = '44=' + str_Price  + '\x01'
   elif   Price < 100000000 and Price >= 10000000 :
        fix_order_price = '44=' + '0' + str_Price + '\x01'
   elif   Price < 10000000  and Price >= 100000 :
        fix_order_price = "44=" + '0' + '0' + str_Price + '\x01'
   elif   Price < 100000   and Price >= 10000  :
        fix_order_price = "44=" + '0' + '0' + '0' + str_Price + '\x01'
   elif   Price < 10000    and Price >= 1000   :
        fix_order_price = "44=" + '0' + '0' + '0' + '0' +str_Price + '\x01'
   elif   Price < 1000	   and Price >= 100  :
        fix_order_price = "44=" + '0' + '0' + '0' + '0' + '0' + str_Price + '\x01'
   elif   Price < 100	   and Price >= 10   :
	fix_order_price = "44=" + '0' + '0' + '0' + '0' + '0' + '0' + str_Price + '\x01'
   elif   Price < 10 :
	fix_order_price = "44=" + '0' + '0' + '0' + '0' + '0' + '0' + '0' + str_Price  + '\x01'

   Qty = random.randint(1,999)
   str_Qty = str(Qty)
   fix_order_Qty = '38='+ str_Qty

   if Qty >= 100 :
        fix_order_Qty = '38=' + str_Qty + '\x01'
   elif   Qty < 100 and Qty >= 10 :
        fix_order_Qty = '38=' + '0' + str_Qty + '\x01'
   elif   Qty < 10 :
        fix_order_Qty = "38=" + '0' + '0' + str_Qty + '\x01'

   transactTime = strftime("%Y%m%d-%H:%M:%S",gmtime())
   fix_transactTime = '60=' + transactTime + '\x01'

   Side = str(random.randint(1,2))
   fix_order_side = '54=' + Side + '\x01'

   fix_header_data = '8=FIX.4.4\x01'  

   fix_Msg_Type  = '35=D\x01'


   fix_sendCom_ID = '49=CLIENT1\x01'

   fix_Target_ID  = '56=EXECUTOR\x01'

   order_ID_1 = random.choice(string.ascii_letters)
   order_ID_2 = str(random.randint(0,9))
   order_ID_3 = random.choice(string.ascii_letters)
   order_ID_4 = random.choice(string.ascii_letters)
   order_ID_5 = random.choice(string.ascii_letters)  

   fix_order_ID = '37=' + order_ID_1 + order_ID_2 + order_ID_3 + order_ID_4 + order_ID_5 + '\x01'


   fix_account = '1=8888885\x01'

   fix_ClOrd_ID = '11=D0C4D14D1BC4\x01'

   fix_handl_Inst = '21=1\x01'

   #LIMIT
   fix_Ord_Type = '40=2\x01'

   fix_TwseIvacnoFlag = '10000=1\x01'
  
   fix_TwseOrdType = '10001=0\x01'

   fix_TwseExCode  = '10002=0\x01'

   fix_TwseRejStaleOrd = '10004=N\x01'


   fix_body_length  = len(fix_seq_num + fix_sendCom_ID + fix_sending_time_data + fix_Target_ID + fix_ClOrd_ID + fix_order_ID + fix_account + fix_order_Qty + fix_Ord_Type + fix_order_side + fix_order_price + fix_timeInForce + fix_transactTime + fix_TwseIvacnoFlag + fix_TwseOrdType + fix_TwseExCode + fix_TwseRejStaleOrd)

   fix_body_length_string = str(fix_body_length)
  
   fix_body_length_final = '9=' + fix_body_length_string + '\x01'
   
   fix_checksum_string  = fix_header_data + fix_body_length_final + fix_Msg_Type + fix_seq_num + fix_sendCom_ID + fix_sending_time_data + fix_Target_ID + fix_ClOrd_ID + fix_order_ID + fix_account + fix_symbol + fix_Ord_Type + fix_order_Qty + fix_order_side + fix_order_price + fix_timeInForce + fix_transactTime + fix_TwseIvacnoFlag + fix_TwseOrdType + fix_TwseExCode + fix_TwseRejStaleOrd

   fix_checksum_sum = sum(bytearray(fix_checksum_string))%256
   str_fix = str(fix_checksum_sum)

   bcd_fix_checksum = ''

   if fix_checksum_sum >= 100 :
        bcd_fix_checksum = str_fix[0] + str_fix[1] + str_fix[2]
   elif   fix_checksum_sum < 100 and fix_checksum_sum >= 10 :
        bcd_fix_checksum = '0' + str_fix[0] + str_fix[1]
   elif   fix_checksum_sum < 10 :
        bcd_fix_checksum = '0' + '0' + str_fix[0]


   bcd_fix_checksum = '10=' + bcd_fix_checksum + '\x01'


   pkt = (Ether(src=src_mac_addr, dst=dst_mac_addr)/
          IP(src=src_ip_addr, dst=dst_ip_addr)/
          TCP(sport=ip_sport_no, dport=ip_dport_no , flags="PA" , options=[('NOP',None),('NOP',None),('Timestamp', (34498433, 3150184448))])/fix_header_data/fix_body_length_final/fix_Msg_Type/fix_seq_num/fix_sendCom_ID/fix_sending_time_data/fix_Target_ID/fix_ClOrd_ID/fix_order_ID/fix_account/fix_symbol/fix_Ord_Type/fix_order_Qty/fix_order_side/fix_order_price/fix_timeInForce/fix_transactTime/fix_TwseIvacnoFlag/fix_TwseOrdType/fix_TwseExCode/fix_TwseRejStaleOrd/bcd_fix_checksum)
   pkts_tcp.append(pkt)

   
   print i

pkts_udp=[]
#A simple UDP/IP packet embedded in an Ethernet frame
for i in range(int(no_pkt)):
   format_six_esc_code = '1b' 
   format_six_esc_code_string=format_six_esc_code.decode("hex")
   
   format_six_type = '01'
   format_six_type_string = format_six_type.decode("hex")
   format_six = '06'
   format_six_string = format_six.decode("hex")
   format_six_version='03'	
   format_six_version_string = format_six_version.decode("hex")
   

   checksum = ('ff').decode("hex")
        #checksumpkt=checksum.decode("hex")
   terminalcode = ('0D0A').decode("hex")
        #terminal_code_pkt = terminal_code.decode("hex")

   #format_six_seq_num = '00000001'
   tmp = i+1
   str_tmp = str(tmp)
   #fix_seq_num = '34='+ str_tmp + '\x01'
   #str_tmp_string = str_tmp.decode("hex") 
   
   if   tmp >= 10000000  :
        format_six_seq_num = str_tmp
   elif   tmp < 10000000     and tmp >= 1000000    :
        format_six_seq_num = '0' + str_tmp 
   elif   tmp < 1000000	 and tmp >= 100000     :
	format_six_seq_num = '0' + '0' + str_tmp
   elif   tmp <100000 and tmp >= 10000 :
 	format_six_seq_num = '0' + '0' + '0' + str_tmp
   elif   tmp < 10000 and tmp >= 1000 :
	format_six_seq_num = '0' + '0' + '0' + '0' + str_tmp
   elif   tmp < 1000  and tmp >= 100 :
	format_six_seq_num = '0' + '0' + '0' + '0' + '0' + str_tmp
   elif   tmp < 100 and tmp >= 10 :
	format_six_seq_num = '0' + '0' + '0' + '0' + '0' + '0' + str_tmp
   elif   tmp < 10 :
	format_six_seq_num = '0' + '0' + '0' + '0' + '0' + '0' + '0'+ str_tmp

   format_six_seq_num_string = format_six_seq_num.decode("hex")

   #format_six_seq_num_string = format_six_seq_num.decode("hex")

   #print format_six_seq_num_string  
 
   format_six_transction_time_ori = str(datetime.now())
   format_six_transction_time = re.sub('[-:. ]','',format_six_transction_time_ori)
  # print format_six_transction_time
   format_six_transction_time_final = format_six_transction_time[8:]
   #print format_six_transction_time_final
   #print format_six_transction_time_final
   format_six_transction_time_final_string = format_six_transction_time_final.decode("hex")
   #print format_six_transction_time_final_string 
   j = random.randint(0,288)
   #format_six_stock_id= Stock_ID_lines[j]
   if len(Stock_ID_lines[j]) >= 6 :
       format_six_stock_id = Stock_ID_lines[j]
   elif len(Stock_ID_lines[j]) < 6 and len(Stock_ID_lines[j]) >= 5 :
       format_six_stock_id =  Stock_ID_lines[j] + ' '
   elif len(Stock_ID_lines[j]) < 5 and len(Stock_ID_lines[j]) >= 4 :
        format_six_stock_id = Stock_ID_lines[j] + ' ' + ' '

   #for_mat_six_ob_7    = 0b10000000 | 0b01010000
   #for_mat_six_ob_6to4 = 0b01010000
   #for_mat_six_ob_3to1 = 0b00001010
   #for_mat_six_ob_0    = 0b00000000
   #for_mat_six_ob = 0b10000000 | 0b01010000 | 0b00001010 | 0b00000000
   #for_mat_six_ob_string = str(bin(for_mat_six_ob))
   #for_mat_six_ob_pkt    = for_mat_six_ob_string[2:]
   for_mat_six_ob_1 = '5a'   
   for_mat_six_ob_2 = 'da'

   n = random.randint(0,1)
   if n==0:
	for_mat_six_ob = for_mat_six_ob_1.decode("hex")
   else:
	for_mat_six_ob = for_mat_six_ob_2.decode("hex")


   for_mat_six_ud = '00'
   for_mat_six_ud_string = for_mat_six_ud.decode("hex")

   for_mat_six_state = '00' 
   for_mat_six_state_string = for_mat_six_state.decode("hex")

   for_mat_six_null = '00'
   for_mat_six_null_string = for_mat_six_null.decode("hex") 
   for_mat_six_Qty = random.randint(0,99999999)
   for_mat_six_Qty_str = str(for_mat_six_Qty)
   if for_mat_six_Qty > 1000000 and for_mat_six_Qty < 10000000:
	for_mat_six_Qty_str = '0'+for_mat_six_Qty_str 
   elif for_mat_six_Qty > 100000 and for_mat_six_Qty < 1000000:
	for_mat_six_Qty_str = '00'+for_mat_six_Qty_str 
   elif for_mat_six_Qty > 10000 and for_mat_six_Qty < 100000:
	for_mat_six_Qty_str = '000'+for_mat_six_Qty_str 
   elif for_mat_six_Qty > 1000  and for_mat_six_Qty < 10000 :
	for_mat_six_Qty_str = '0000'+for_mat_six_Qty_str 
   elif for_mat_six_Qty > 100   and for_mat_six_Qty < 1000 :
	for_mat_six_Qty_str = '00000'+for_mat_six_Qty_str 
   elif for_mat_six_Qty > 10	and for_mat_six_Qty < 100:
	for_mat_six_Qty_str = '000000'+for_mat_six_Qty_str 
   elif for_mat_six_Qty < 10 :
	for_mat_six_Qty_str = '0000000'+for_mat_six_Qty_str 
   for_mat_six_Qty_pkt = for_mat_six_Qty_str.decode("hex")
   
   if n==0:#5a
	payload_len = '0102'
	payload_len_str = payload_len.decode("hex")
	one_buy_price = random.randint(10,9900)
	one_buy_price_str = str(one_buy_price)
	one_buy_price_pkt = ''
	one_buy_Qty = random.randint(1,3000)
	one_buy_Qty_str = str(one_buy_Qty)
	two_buy_price = one_buy_price - 1
	two_buy_price_str = str(two_buy_price)
	two_buy_price_pkt = ''
        two_buy_Qty = random.randint(1,3000)
        two_buy_Qty_str = str(two_buy_Qty)
        three_buy_price = two_buy_price - 1
        three_buy_price_str = str(three_buy_price)
        three_buy_price_pkt = ''
        three_buy_Qty = random.randint(1,3000)
        three_buy_Qty_str = str(three_buy_Qty)
        four_buy_price = three_buy_price - 1
        four_buy_price_str = str(four_buy_price)
        four_buy_price_pkt = ''
        four_buy_Qty = random.randint(1,3000)
        four_buy_Qty_str = str(four_buy_Qty)

        five_buy_price = four_buy_price - 1
        five_buy_price_str = str(five_buy_price)
        five_buy_price_pkt = ''
        five_buy_Qty = random.randint(1,3000)
        five_buy_Qty_str = str(five_buy_Qty)

        one_sell_price = one_buy_price + 1
        one_sell_price_str = str(one_sell_price)
        one_sell_price_pkt = ''
        one_sell_Qty = random.randint(1,3000)
        one_sell_Qty_str = str(one_sell_Qty)
        two_sell_price = one_sell_price + 1
        two_sell_price_str = str(two_sell_price)
        two_sell_price_pkt = ''
        two_sell_Qty = random.randint(1,3000)
        two_sell_Qty_str = str(two_sell_Qty)
        three_sell_price = two_sell_price + 1
        three_sell_price_str = str(three_sell_price)
        three_sell_price_pkt = ''
        three_sell_Qty = random.randint(1,3000)
        three_sell_Qty_str = str(three_sell_Qty)
        four_sell_price = three_sell_price + 1
        four_sell_price_str = str(four_sell_price)
        four_sell_price_pkt = ''
        four_sell_Qty = random.randint(1,3000)
        four_sell_Qty_str = str(four_sell_Qty)
        five_sell_price = four_sell_price + 1
        five_sell_price_str = str(five_sell_price)
        five_sell_price_pkt = ''
        five_sell_Qty = random.randint(1,3000)
        five_sell_Qty_str = str(five_sell_Qty)



	if one_buy_Qty >= 1000 :
		one_buy_Qty_pkt = ('0000'+one_buy_Qty_str).decode("hex")  
	elif one_buy_Qty <1000 and one_buy_Qty >= 100 :
		one_buy_Qty_pkt = ('00000' +one_buy_Qty_str).decode("hex")
	elif one_buy_Qty < 100 and one_buy_Qty >= 10 :
		one_buy_Qty_pkt = ('000000' + one_buy_Qty_str).decode("hex")
	elif one_buy_Qty < 10 :
		one_buy_Qty_pkt = ('0000000' + one_buy_Qty_str).decode("hex")

###
	nowon_Qty_pkt = one_buy_Qty_pkt
###

        if two_buy_Qty >= 1000 :
                two_buy_Qty_pkt = ('0000'+two_buy_Qty_str).decode("hex")
        elif two_buy_Qty <1000 and two_buy_Qty >= 100 :
                two_buy_Qty_pkt = ('00000' +two_buy_Qty_str).decode("hex")
        elif two_buy_Qty < 100 and two_buy_Qty >= 10 :
                two_buy_Qty_pkt = ('000000' + two_buy_Qty_str).decode("hex")
        elif two_buy_Qty < 10 :
                two_buy_Qty_pkt = ('0000000' + two_buy_Qty_str).decode("hex")

        if three_buy_Qty >= 1000 :
                three_buy_Qty_pkt = ('0000'+three_buy_Qty_str).decode("hex")
        elif three_buy_Qty <1000 and three_buy_Qty >= 100 :
                three_buy_Qty_pkt = ('00000' +three_buy_Qty_str).decode("hex")
        elif three_buy_Qty < 100 and three_buy_Qty >= 10 :
               three_buy_Qty_pkt = ('000000' + three_buy_Qty_str).decode("hex")
        elif three_buy_Qty < 10 :
                three_buy_Qty_pkt = ('0000000' + three_buy_Qty_str).decode("hex")

        if four_buy_Qty >= 1000 :
                four_buy_Qty_pkt = ('0000'+four_buy_Qty_str).decode("hex")
        elif four_buy_Qty <1000 and four_buy_Qty >= 100 :
                four_buy_Qty_pkt = ('00000' +four_buy_Qty_str).decode("hex")
        elif four_buy_Qty < 100 and four_buy_Qty >= 10 :
                four_buy_Qty_pkt = ('000000' + four_buy_Qty_str).decode("hex")
        elif four_buy_Qty < 10 :
                four_buy_Qty_pkt = ('0000000' + four_buy_Qty_str).decode("hex")

        if five_buy_Qty >= 1000 :
                five_buy_Qty_pkt = ('0000'+five_buy_Qty_str).decode("hex")
        elif five_buy_Qty <1000 and five_buy_Qty >= 100 :
                five_buy_Qty_pkt = ('00000' +five_buy_Qty_str).decode("hex")
        elif five_buy_Qty < 100 and five_buy_Qty >= 10 :
                five_buy_Qty_pkt = ('000000' + five_buy_Qty_str).decode("hex")
        elif five_buy_Qty < 10 :
                five_buy_Qty_pkt = ('0000000' + five_buy_Qty_str).decode("hex")



        if one_sell_Qty >= 1000 :
                one_sell_Qty_pkt = ('0000'+one_sell_Qty_str).decode("hex")
        elif one_sell_Qty <1000 and one_sell_Qty >= 100 :
                one_sell_Qty_pkt = ('00000' +one_sell_Qty_str).decode("hex")
        elif one_sell_Qty < 100 and one_sell_Qty >= 10 :
                one_sell_Qty_pkt = ('000000' + one_sell_Qty_str).decode("hex")
        elif one_sell_Qty < 10 :
                one_sell_Qty_pkt = ('0000000' + one_sell_Qty_str).decode("hex")

        if two_sell_Qty >= 1000 :
                two_sell_Qty_pkt = ('0000'+two_sell_Qty_str).decode("hex")
        elif two_sell_Qty <1000 and two_sell_Qty >= 100 :
                two_sell_Qty_pkt = ('00000' +two_sell_Qty_str).decode("hex")
        elif two_sell_Qty < 100 and two_sell_Qty >= 10 :
                two_sell_Qty_pkt = ('000000' + two_sell_Qty_str).decode("hex")
        elif two_sell_Qty < 10 :
                two_sell_Qty_pkt = ('0000000' + two_sell_Qty_str).decode("hex")

        if three_sell_Qty >= 1000 :
                three_sell_Qty_pkt = ('0000'+three_sell_Qty_str).decode("hex")
        elif three_sell_Qty <1000 and three_sell_Qty >= 100 :
                three_sell_Qty_pkt = ('00000' +three_sell_Qty_str).decode("hex")
        elif three_sell_Qty < 100 and three_sell_Qty >= 10 :
               three_sell_Qty_pkt = ('000000' + three_sell_Qty_str).decode("hex")
        elif three_sell_Qty < 10 :
                three_sell_Qty_pkt = ('0000000' + three_sell_Qty_str).decode("hex")

        if four_sell_Qty >= 1000 :
                four_sell_Qty_pkt = ('0000'+four_sell_Qty_str).decode("hex")
        elif four_sell_Qty <1000 and four_sell_Qty >= 100 :
                four_sell_Qty_pkt = ('00000' +four_sell_Qty_str).decode("hex")
        elif four_sell_Qty < 100 and four_sell_Qty >= 10 :
                four_sell_Qty_pkt = ('000000' + four_sell_Qty_str).decode("hex")
        elif four_sell_Qty < 10 :
                four_sell_Qty_pkt = ('0000000' + four_sell_Qty_str).decode("hex")

        if five_sell_Qty >= 1000 :
                five_sell_Qty_pkt = ('0000'+five_sell_Qty_str).decode("hex")
        elif five_sell_Qty <1000 and five_sell_Qty >= 100 :
                five_sell_Qty_pkt = ('00000' +five_sell_Qty_str).decode("hex")
        elif five_sell_Qty < 100 and five_sell_Qty >= 10 :
                five_sell_Qty_pkt = ('000000' + five_sell_Qty_str).decode("hex")
        elif five_sell_Qty < 10 :
                five_sell_Qty_pkt = ('0000000' + five_sell_Qty_str).decode("hex")

	if one_buy_price>=1000:
		one_buy_price_pkt = (one_buy_price_str + '00').decode("hex")
	elif one_buy_price<1000 and one_buy_price >= 100 :
		one_buy_price_pkt = ('0'+one_buy_price_str + '00').decode("hex")
	elif one_buy_price<100 and one_buy_price >= 10 :
		one_buy_price_pkt = ('00'+one_buy_price_str + '00').decode("hex")
	elif one_buy_price <10 :
		one_buy_price_pkt = ('000'+one_buy_price_str+'00').decode("hex")
###
	nowon_price_pkt = one_buy_price_pkt
###

        if two_buy_price>=1000:
                two_buy_price_pkt = (two_buy_price_str + '00').decode("hex")
        elif two_buy_price<1000 and two_buy_price >= 100 :
                two_buy_price_pkt = ('0'+two_buy_price_str + '00').decode("hex")
        elif two_buy_price<100 and two_buy_price >= 10 :
                two_buy_price_pkt = ('00'+two_buy_price_str + '00').decode("hex")
        elif two_buy_price <10 :
                two_buy_price_pkt = ('000'+two_buy_price_str+'00').decode("hex")

        if three_buy_price>=1000:
                three_buy_price_pkt = (three_buy_price_str + '00').decode("hex")
        elif three_buy_price<1000 and three_buy_price >= 100 :
                three_buy_price_pkt = ('0'+three_buy_price_str + '00').decode("hex")
        elif three_buy_price<100 and three_buy_price >= 10 :
                three_buy_price_pkt = ('00'+three_buy_price_str + '00').decode("hex")
        elif three_buy_price <10 :
                three_buy_price_pkt = ('000'+three_buy_price_str+'00').decode("hex")

        if four_buy_price>=1000:
                four_buy_price_pkt = (four_buy_price_str + '00').decode("hex")
        elif four_buy_price<1000 and four_buy_price >= 100 :
                four_buy_price_pkt = ('0'+four_buy_price_str + '00').decode("hex")
        elif four_buy_price<100 and four_buy_price >= 10 :
                four_buy_price_pkt = ('00'+four_buy_price_str + '00').decode("hex")
        elif four_buy_price <10 :
                four_buy_price_pkt = ('000'+four_buy_price_str+'00').decode("hex")

        if five_buy_price>=1000:
                five_buy_price_pkt = (five_buy_price_str + '00').decode("hex")
        elif five_buy_price<1000 and five_buy_price >= 100 :
                five_buy_price_pkt = ('0'+five_buy_price_str + '00').decode("hex")
        elif five_buy_price<100 and five_buy_price >= 10 :
                five_buy_price_pkt = ('00'+five_buy_price_str + '00').decode("hex")
        elif five_buy_price <10 :
                five_buy_price_pkt = ('000'+five_buy_price_str+'00').decode("hex")

        if one_sell_price>=1000:
                one_sell_price_pkt = (one_sell_price_str + '00').decode("hex")
        elif one_sell_price<1000 and one_sell_price >= 100 :
                one_sell_price_pkt = ('0'+one_sell_price_str + '00').decode("hex")
        elif one_sell_price<100 and one_sell_price >= 10 :
                one_sell_price_pkt = ('00'+one_sell_price_str + '00').decode("hex")
        elif one_sell_price <10 :
                one_sell_price_pkt = ('000'+one_sell_price_str+'00').decode("hex")

        if two_sell_price>=1000:
                two_sell_price_pkt = (two_sell_price_str + '00').decode("hex")
        elif two_sell_price<1000 and two_sell_price >= 100 :
                two_sell_price_pkt = ('0'+two_sell_price_str + '00').decode("hex")
        elif two_sell_price<100 and two_buy_price >= 10 :
                two_sell_price_pkt = ('00'+two_sell_price_str + '00').decode("hex")
        elif two_sell_price <10 :
                two_sell_price_pkt = ('000'+two_sell_price_str+'00').decode("hex")

        if three_sell_price>=1000:
                three_sell_price_pkt = (three_sell_price_str + '00').decode("hex")
        elif three_sell_price<1000 and three_sell_price >= 100 :
                three_sell_price_pkt = ('0'+three_sell_price_str + '00').decode("hex")
        elif three_sell_price<100 and three_sell_price >= 10 :
                three_sell_price_pkt = ('00'+three_sell_price_str + '00').decode("hex")
        elif three_sell_price <10 :
                three_sell_price_pkt = ('000'+three_sell_price_str+'00').decode("hex")

        if four_sell_price>=1000:
                four_sell_price_pkt = (four_sell_price_str + '00').decode("hex")
        elif four_sell_price<1000 and four_sell_price >= 100 :
                four_sell_price_pkt = ('0'+four_sell_price_str + '00').decode("hex")
        elif four_sell_price<100 and four_sell_price >= 10 :
                four_sell_price_pkt = ('00'+four_sell_price_str + '00').decode("hex")
        elif four_sell_price <10 :
                four_sell_price_pkt = ('000'+four_sell_price_str+'00').decode("hex")

        if five_sell_price>=1000:
                five_sell_price_pkt = (five_sell_price_str + '00').decode("hex")
        elif five_sell_price<1000 and five_sell_price >= 100 :
                five_sell_price_pkt = ('0'+five_sell_price_str + '00').decode("hex")
        elif five_sell_price<100 and five_sell_price >= 10 :
                five_sell_price_pkt = ('00'+five_sell_price_str + '00').decode("hex")
        elif five_sell_price <10 :
                five_sell_price_pkt = ('000'+five_sell_price_str+'00').decode("hex")
        pkt = (Ether(src=src_mac_addr, dst=dst_mac_addr)/
                  IP(src=src_ip_addr, dst=dst_ip_addr)/
                  UDP(sport=ip_sport_no, dport=ip_dport_no)/format_six_esc_code_string/payload_len_str/format_six_type_string/format_six_string/format_six_version_string/format_six_seq_num_string/format_six_stock_id/format_six_transction_time_final_string/for_mat_six_ob/for_mat_six_ud_string/for_mat_six_state_string/for_mat_six_Qty_pkt/one_buy_price_pkt/one_buy_Qty_pkt/two_buy_price_pkt/two_buy_Qty_pkt/three_buy_price_pkt/three_buy_Qty_pkt/four_buy_price_pkt/four_buy_Qty_pkt/five_buy_price_pkt/five_buy_Qty_pkt/one_sell_price_pkt/one_sell_Qty_pkt/two_sell_price_pkt/two_sell_Qty_pkt/three_sell_price_pkt/three_sell_Qty_pkt/four_sell_price_pkt/four_sell_Qty_pkt/five_sell_price_pkt/five_sell_Qty_pkt/checksum/terminalcode)
        pkt.time = pkt_timestamp
        pkts_udp.append(pkt)


   else: #da
	payload_len = '0109'
        payload_len_str = payload_len.decode("hex")
        one_buy_price = random.randint(10,9900)
        one_buy_price_str = str(one_buy_price)
        one_buy_price_pkt = ''
        one_buy_Qty = random.randint(1,3000)
        one_buy_Qty_str = str(one_buy_Qty)

        two_buy_price = one_buy_price + 1
        two_buy_price_str = str(two_buy_price)
        two_buy_price_pkt = ''
        two_buy_Qty = random.randint(1,3000)
        two_buy_Qty_str = str(two_buy_Qty)
        three_buy_price = two_buy_price + 1
        three_buy_price_str = str(three_buy_price)
        three_buy_price_pkt = ''
        three_buy_Qty = random.randint(1,3000)
        three_buy_Qty_str = str(three_buy_Qty)
        four_buy_price = three_buy_price + 1
        four_buy_price_str = str(four_buy_price)
        four_buy_price_pkt = ''
        four_buy_Qty = random.randint(1,3000)
        four_buy_Qty_str = str(four_buy_Qty)
        five_buy_price = four_buy_price + 1
        five_buy_price_str = str(five_buy_price)
        five_buy_price_pkt = ''
        five_buy_Qty = random.randint(1,3000)
        five_buy_Qty_str = str(five_buy_Qty)


        one_sell_price = one_buy_price + 1
        one_sell_price_str = str(one_sell_price)
        one_sell_price_pkt = ''
        one_sell_Qty = random.randint(1,3000)
        one_sell_Qty_str = str(one_sell_Qty)
        two_sell_price = one_sell_price + 1
        two_sell_price_str = str(two_sell_price)
        two_sell_price_pkt = ''
        two_sell_Qty = random.randint(1,3000)
        two_sell_Qty_str = str(two_sell_Qty)
        three_sell_price = two_sell_price + 1
        three_sell_price_str = str(three_sell_price)
        three_sell_price_pkt = ''
        three_sell_Qty = random.randint(1,3000)
        three_sell_Qty_str = str(three_sell_Qty)
        four_sell_price = three_sell_price + 1
        four_sell_price_str = str(four_sell_price)
        four_sell_price_pkt = ''
        four_sell_Qty = random.randint(1,3000)
        four_sell_Qty_str = str(four_sell_Qty)
        five_sell_price = four_sell_price + 1
        five_sell_price_str = str(five_sell_price)
        five_sell_price_pkt = ''
        five_sell_Qty = random.randint(1,3000)
        five_sell_Qty_str = str(five_sell_Qty)


        if one_buy_Qty >= 1000 :
                one_buy_Qty_pkt = ('0000'+one_buy_Qty_str).decode("hex")
        elif one_buy_Qty <1000 and one_buy_Qty >= 100 :
                one_buy_Qty_pkt = ('00000' +one_buy_Qty_str).decode("hex")
        elif one_buy_Qty < 100 and one_buy_Qty >= 10 :
                one_buy_Qty_pkt = ('000000' + one_buy_Qty_str).decode("hex")
        elif one_buy_Qty < 10 :
                one_buy_Qty_pkt = ('0000000' + one_buy_Qty_str).decode("hex")

###
	nowon_Qty_pkt = one_buy_Qty_pkt
###

        if two_buy_Qty >= 1000 :
                two_buy_Qty_pkt = ('0000'+two_buy_Qty_str).decode("hex")
        elif two_buy_Qty <1000 and two_buy_Qty >= 100 :
                two_buy_Qty_pkt = ('00000' +two_buy_Qty_str).decode("hex")
        elif two_buy_Qty < 100 and two_buy_Qty >= 10 :
                two_buy_Qty_pkt = ('000000' + two_buy_Qty_str).decode("hex")
        elif two_buy_Qty < 10 :
                two_buy_Qty_pkt = ('0000000' + two_buy_Qty_str).decode("hex")

        if three_buy_Qty >= 1000 :
                three_buy_Qty_pkt = ('0000'+three_buy_Qty_str).decode("hex")
        elif three_buy_Qty <1000 and three_buy_Qty >= 100 :
                three_buy_Qty_pkt = ('00000' +three_buy_Qty_str).decode("hex")
        elif three_buy_Qty < 100 and three_buy_Qty >= 10 :
               three_buy_Qty_pkt = ('000000' + three_buy_Qty_str).decode("hex")
        elif three_buy_Qty < 10 :
                three_buy_Qty_pkt = ('0000000' + three_buy_Qty_str).decode("hex")
        if four_buy_Qty >= 1000 :
                four_buy_Qty_pkt = ('0000'+four_buy_Qty_str).decode("hex")
        elif four_buy_Qty <1000 and four_buy_Qty >= 100 :
                four_buy_Qty_pkt = ('00000' +four_buy_Qty_str).decode("hex")
        elif four_buy_Qty < 100 and four_buy_Qty >= 10 :
                four_buy_Qty_pkt = ('000000' + four_buy_Qty_str).decode("hex")
        elif four_buy_Qty < 10 :
                four_buy_Qty_pkt = ('0000000' + four_buy_Qty_str).decode("hex")

        if five_buy_Qty >= 1000 :
                five_buy_Qty_pkt = ('0000'+five_buy_Qty_str).decode("hex")
        elif five_buy_Qty <1000 and five_buy_Qty >= 100 :
                five_buy_Qty_pkt = ('00000' +five_buy_Qty_str).decode("hex")
        elif five_buy_Qty < 100 and five_buy_Qty >= 10 :
                five_buy_Qty_pkt = ('000000' + five_buy_Qty_str).decode("hex")
        elif five_buy_Qty < 10 :
                five_buy_Qty_pkt = ('0000000' + five_buy_Qty_str).decode("hex")

        if one_sell_Qty >= 1000 :
                one_sell_Qty_pkt = ('0000'+one_sell_Qty_str).decode("hex")
        elif one_sell_Qty <1000 and one_sell_Qty >= 100 :
                one_sell_Qty_pkt = ('00000' +one_sell_Qty_str).decode("hex")
        elif one_sell_Qty < 100 and one_sell_Qty >= 10 :
                one_sell_Qty_pkt = ('000000' + one_sell_Qty_str).decode("hex")
        elif one_sell_Qty < 10 :
                one_sell_Qty_pkt = ('0000000' + one_sell_Qty_str).decode("hex")

        if two_sell_Qty >= 1000 :
                two_sell_Qty_pkt = ('0000'+two_sell_Qty_str).decode("hex")
        elif two_sell_Qty <1000 and two_sell_Qty >= 100 :
                two_sell_Qty_pkt = ('00000' +two_sell_Qty_str).decode("hex")
        elif two_sell_Qty < 100 and two_sell_Qty >= 10 :
                two_sell_Qty_pkt = ('000000' + two_sell_Qty_str).decode("hex")
        elif two_sell_Qty < 10 :
                two_sell_Qty_pkt = ('0000000' + two_sell_Qty_str).decode("hex")

        if three_sell_Qty >= 1000 :
                three_sell_Qty_pkt = ('0000'+three_sell_Qty_str).decode("hex")
        elif three_sell_Qty <1000 and three_sell_Qty >= 100 :
                three_sell_Qty_pkt = ('00000' +three_sell_Qty_str).decode("hex")
        elif three_sell_Qty < 100 and three_sell_Qty >= 10 :
               three_sell_Qty_pkt = ('000000' + three_sell_Qty_str).decode("hex")
        elif three_sell_Qty < 10 :
                three_sell_Qty_pkt = ('0000000' + three_sell_Qty_str).decode("hex")

        if four_sell_Qty >= 1000 :
                four_sell_Qty_pkt = ('0000'+four_sell_Qty_str).decode("hex")
        elif four_sell_Qty <1000 and four_sell_Qty >= 100 :
                four_sell_Qty_pkt = ('00000' +four_sell_Qty_str).decode("hex")
        elif four_sell_Qty < 100 and four_sell_Qty >= 10 :
                four_sell_Qty_pkt = ('000000' + four_sell_Qty_str).decode("hex")
        elif four_sell_Qty < 10 :
                four_sell_Qty_pkt = ('0000000' + four_sell_Qty_str).decode("hex")

        if five_sell_Qty >= 1000 :
                five_sell_Qty_pkt = ('0000'+five_sell_Qty_str).decode("hex")
        elif five_sell_Qty <1000 and five_sell_Qty >= 100 :
                five_sell_Qty_pkt = ('00000' +five_sell_Qty_str).decode("hex")
        elif five_sell_Qty < 100 and five_sell_Qty >= 10 :
                five_sell_Qty_pkt = ('000000' + five_sell_Qty_str).decode("hex")
        elif five_sell_Qty < 10 :
                five_sell_Qty_pkt = ('0000000' + five_sell_Qty_str).decode("hex")


        if one_buy_price>=1000:
                one_buy_price_pkt = (one_buy_price_str + '00').decode("hex")
        elif one_buy_price<1000 and one_buy_price >= 100 :
                one_buy_price_pkt = ('0'+one_buy_price_str + '00').decode("hex")
        elif one_buy_price<100 and one_buy_price >= 10 :
                one_buy_price_pkt = ('00'+one_buy_price_str + '00').decode("hex")
        elif one_buy_price <10 :
                one_buy_price_pkt = ('000'+one_buy_price_str+'00').decode("hex")
###
	nowon_price_pkt = one_buy_price_pkt
###

        if two_buy_price>=1000:
                two_buy_price_pkt = (two_buy_price_str + '00').decode("hex")
        elif two_buy_price<1000 and two_buy_price >= 100 :
                two_buy_price_pkt = ('0'+two_buy_price_str + '00').decode("hex")
        elif two_buy_price<100 and two_buy_price >= 10 :
                two_buy_price_pkt = ('00'+two_buy_price_str + '00').decode("hex")
        elif two_buy_price <10 :
                two_buy_price_pkt = ('000'+two_buy_price_str+'00').decode("hex")

        if three_buy_price>=1000:
                three_buy_price_pkt = (three_buy_price_str + '00').decode("hex")
        elif three_buy_price<1000 and three_buy_price >= 100 :
                three_buy_price_pkt = ('0'+three_buy_price_str + '00').decode("hex")
        elif three_buy_price<100 and three_buy_price >= 10 :
                three_buy_price_pkt = ('00'+three_buy_price_str + '00').decode("hex")
        elif three_buy_price <10 :
                three_buy_price_pkt = ('000'+three_buy_price_str+'00').decode("hex")

        if four_buy_price>=1000:
                four_buy_price_pkt = (four_buy_price_str + '00').decode("hex")
        elif four_buy_price<1000 and four_buy_price >= 100 :
                four_buy_price_pkt = ('0'+four_buy_price_str + '00').decode("hex")
        elif four_buy_price<100 and four_buy_price >= 10 :
                four_buy_price_pkt = ('00'+four_buy_price_str + '00').decode("hex")
        elif four_buy_price <10 :
                four_buy_price_pkt = ('000'+four_buy_price_str+'00').decode("hex")

        if five_buy_price>=1000:
                five_buy_price_pkt = (five_buy_price_str + '00').decode("hex")
        elif five_buy_price<1000 and five_buy_price >= 100 :
                five_buy_price_pkt = ('0'+five_buy_price_str + '00').decode("hex")
        elif five_buy_price<100 and five_buy_price >= 10 :
                five_buy_price_pkt = ('00'+five_buy_price_str + '00').decode("hex")
        elif five_buy_price <10 :
                five_buy_price_pkt = ('000'+five_buy_price_str+'00').decode("hex")

        if one_sell_price>=1000:
                one_sell_price_pkt = (one_sell_price_str + '00').decode("hex")
        elif one_sell_price<1000 and one_sell_price >= 100 :
                one_sell_price_pkt = ('0'+one_sell_price_str + '00').decode("hex")
        elif one_sell_price<100 and one_sell_price >= 10 :
                one_sell_price_pkt = ('00'+one_sell_price_str + '00').decode("hex")
        elif one_sell_price <10 :
                one_sell_price_pkt = ('000'+one_sell_price_str+'00').decode("hex")

        if two_sell_price>=1000:
                two_sell_price_pkt = (two_sell_price_str + '00').decode("hex")
        elif two_sell_price<1000 and two_sell_price >= 100 :
                two_sell_price_pkt = ('0'+two_sell_price_str + '00').decode("hex")
        elif two_sell_price<100 and two_buy_price >= 10 :
                two_sell_price_pkt = ('00'+two_sell_price_str + '00').decode("hex")
        elif two_sell_price <10 :
                two_sell_price_pkt = ('000'+two_sell_price_str+'00').decode("hex")

        if three_sell_price>=1000:
                three_sell_price_pkt = (three_sell_price_str + '00').decode("hex")
        elif three_sell_price<1000 and three_sell_price >= 100 :
                three_sell_price_pkt = ('0'+three_sell_price_str + '00').decode("hex")
        elif three_sell_price<100 and three_sell_price >= 10 :
                three_sell_price_pkt = ('00'+three_sell_price_str + '00').decode("hex")
        elif three_sell_price <10 :
                three_sell_price_pkt = ('000'+three_sell_price_str+'00').decode("hex")

        if four_sell_price>=1000:
                four_sell_price_pkt = (four_sell_price_str + '00').decode("hex")
        elif four_sell_price<1000 and four_sell_price >= 100 :
                four_sell_price_pkt = ('0'+four_sell_price_str + '00').decode("hex")
        elif four_sell_price<100 and four_sell_price >= 10 :
                four_sell_price_pkt = ('00'+four_sell_price_str + '00').decode("hex")
        elif four_sell_price <10 :
                four_sell_price_pkt = ('000'+four_sell_price_str+'00').decode("hex")

        if five_sell_price>=1000:
                five_sell_price_pkt = (five_sell_price_str + '00').decode("hex")
        elif five_sell_price<1000 and five_sell_price >= 100 :
                five_sell_price_pkt = ('0'+five_sell_price_str + '00').decode("hex")
        elif five_sell_price<100 and five_sell_price >= 10 :
                five_sell_price_pkt = ('00'+five_sell_price_str + '00').decode("hex")
        elif five_sell_price <10 :
                five_sell_price_pkt = ('000'+five_sell_price_str+'00').decode("hex")

	
   #udp_body_length =udp_esc_code
	pkt = (Ether(src=src_mac_addr, dst=dst_mac_addr)/
	          IP(src=src_ip_addr, dst=dst_ip_addr)/
	          UDP(sport=ip_sport_no, dport=ip_dport_no)/format_six_esc_code_string/payload_len_str/format_six_type_string/format_six_string/format_six_version_string/format_six_seq_num_string/format_six_stock_id/format_six_transction_time_final_string/for_mat_six_ob/for_mat_six_ud_string/for_mat_six_state_string/for_mat_six_Qty_pkt/nowon_price_pkt/nowon_Qty_pkt/one_buy_price_pkt/one_buy_Qty_pkt/two_buy_price_pkt/two_buy_Qty_pkt/three_buy_price_pkt/three_buy_Qty_pkt/four_buy_price_pkt/four_buy_Qty_pkt/five_buy_price_pkt/five_buy_Qty_pkt/one_sell_price_pkt/one_sell_Qty_pkt/two_sell_price_pkt/two_sell_Qty_pkt/three_sell_price_pkt/three_sell_Qty_pkt/four_sell_price_pkt/four_sell_Qty_pkt/five_sell_price_pkt/five_sell_Qty_pkt/checksum/terminalcode)
	pkt.time = pkt_timestamp
	pkts_udp.append(pkt)

if (args.packet_type == 'udp' or args.packet_type == 'UDP'):
   pkts=pkts_udp
else:
   pkts=pkts_tcp

#Select packet type for axi stream data generation

wrpcap(os.path.join(script_dir, '%s.cap' % (str(pcap_name))), pkts)

print '\nFinish packet generation!\n'


