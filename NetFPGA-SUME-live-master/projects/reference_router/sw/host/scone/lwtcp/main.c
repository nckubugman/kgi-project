
/*******************************************************************************
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
*
******************************************************************************/



#include "lwip/tcp.h"

struct netif *ip_route(struct ip_addr *dest)
{
}

err_t sr_ip_output(struct pbuf *p, struct ip_addr *src, struct ip_addr *dest,
		uint8_t ttl, uint8_t proto)
{
}

err_t sr_ip_output_if(struct pbuf *p, struct ip_addr *src, struct ip_addr *dest,
		   uint8_t ttl, uint8_t proto,
		   struct netif *netif)
{
}

static void
main_thread(void *arg)
{
    tcp_init();

    while(1)
    {
        tcp_input
    }
}

int main(int argc,char **argv)
{
    sys_init();
    mem_init();
    memp_init();
    pbuf_init();


    sys_thread_new((void *)(main_thread), NULL);
    pause();

    return 0;
}
