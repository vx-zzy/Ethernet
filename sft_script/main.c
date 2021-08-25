
#include "soc_define.h"
int	ser_port = 4994;
char zzy[] = "zzy\r\n";
void SM3_WRITE(char a[], uint len_a){
	uint	i;
	for(i=0;i<len_a;i++){
		if(i == len_a - 1){
			ADDR_32(0x4020, 0) = (a[i] | 0x100);
		}
		else{
			ADDR_32(0x4020, 0) = a[i];
		}
	}
}
void main(){
	int i;
	uint32_t read_temp;
	uint32_t udp_state;
	uint32_t server_state;
	uint32_t client_state;
	int	udp_rx_len;
	int client_rx_len;
	int server_rx_len;
	bool udp_data_valid;
	uint32_t rx_data;
	uint32_t stat_data;
	uint32_t ctrl_data;
	int mul;
	ADDR_32(0x4020, 0) = '1';
	ADDR_32(0x4020, 0) = '2';
	ADDR_32(0x4020, 0) = '3' | 0x100;
//	client_rx_len = client_rx(client_rx_data);
//	server_tx(data, sizeof(data));
//	server_close();
	server_port(ser_port);
	server_start();
	ADDR_32(0x4020, 0) = '1'| 0x100;
	while(1){
		//server_state = server_stat();
		//server_state = server_stat();
		if(UDP_pkt_valid()){
			udp_rx_len = UDP_rx(UDP_rx_data);
			UDP_tx(UDP_rx_data, udp_rx_len);
			SM3_WRITE(UDP_rx_data, udp_rx_len);
			//UDP_tx_byte(udp_rx_len | 0x100);
			ser_port = ser_port + 1;
			if(udp_rx_len == 1){
				if(UDP_rx_data[0] == '1'){
					server_close();
					client_close();
					client_port(ser_port);
				}else
				if(UDP_rx_data[0] == '2'){
					UDP_tx(zzy, sizeof(zzy));
					server_start();
					client_start();
				}

			}
		}

		if(client_pkt_valid()){
			client_rx_len = client_rx(client_rx_data);
			client_tx(client_rx_data, client_rx_len);
		}
		if(server_pkt_valid()){
			server_rx_len = server_rx(server_rx_data);
			server_tx(server_rx_data, server_rx_len);
			}
	}

return;

}

uint32_t *irq(uint32_t *regs, uint32_t irqs)
{
	uint32_t sm3_data;
	char sm3_byte[32];
	
	if ((irqs & 1) != 0) {
		for(int i = 0; i < 8; i++){
			sm3_data = ADDR_32(0x4020, 8);
			for(int j = 3; j >= 0; j--){
				sm3_byte[i*4+3-j] = (sm3_data >> (j *8)) & 0xff;
			}
		}
		UDP_tx(sm3_byte, 32);
	}
	if ((irqs & 2) != 0) {
		UDP_tx_byte(0x02);
		UDP_tx_byte(regs[1]);
	}
	if ((irqs & 4) != 0) {
		UDP_tx_byte(0x03);
		UDP_tx_byte(regs[2]);
	}
	return regs;
}