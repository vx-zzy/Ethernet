/*
 * soc_define.c
 *
 *  Created on: 2020Äê4ÔÂ29ÈÕ
 *      Author: zhaoz
 */

#include "soc_define.h"

int	Gpio_in(){
	return ADDR_32(Gpio_base_addr,Gpio_in_offset);
}
//set bit
void set_bit(uint32_t base_addr, uint32_t offset, int bit_num, bool logic){
	if(logic == 0){
		ADDR_32(base_addr,offset) &= ~(1 << bit_num);
	}
	else{
		ADDR_32(base_addr,offset) |= (1 << bit_num);
	}
}
bool get_bit(uint32_t base_addr, uint32_t offset, int bit_num){
	if(ADDR_32(base_addr,offset) & (1 << bit_num)){
		return 1;
	}
	else{
		return 0;
	}
}
void delay_1s(){
    for(int i=0;i<1000;i++){
		 for(int j=0;j<1500;j++){
		 }
    }
}

int UDP_stat(){
	return ADDR_32(Ethernet_base_addr, Ethernet_UDP_stat_offset);
}

int UDP_rx_byte(){
	return ADDR_32(Ethernet_base_addr, Ethernet_UDP_rx_offset);
}
int UDP_rx(char a[]){
	int i = 0;
	int rx_data = 0;
	int len = UDP_stat() & 0xffff;
	while(!(rx_data & (1 << 8))){
		rx_data = UDP_rx_byte();
		a[i] = rx_data;
		i = i + 1;
	}
	return len;
}
void UDP_tx(char a[], uint len_a){
	uint	i;
	for(i=0;i<len_a;i++){
		if(i == len_a - 1){
			UDP_tx_byte(a[i] | (1 << 8));
		}
		else{
			UDP_tx_byte(a[i]);
		}
	}
}
int client_stat(){
	return ADDR_32(Ethernet_base_addr, Ethernet_TCP_C_stat_offset);
}

int client_rx_byte(){
	return ADDR_32(Ethernet_base_addr, Ethernet_TCP_C_rx_offset);
}
int client_rx(char a[]){
	int i = 0;
	int rx_data = 0;
	int len = client_stat() & 0xffff;
	while(!(rx_data & (1 << 8))){
		rx_data = client_rx_byte();
		a[i] = rx_data;
		i = i + 1;
	}
	return len;
}
void client_tx(char a[], uint len_a){
	int	i;
	for(i=0;i<len_a;i++){
		if(i == len_a - 1){
			client_tx_byte(a[i] | (1 << 8));
		}
		else{
			client_tx_byte(a[i]);
		}
	}
}
void client_start(){
	set_bit(Ethernet_base_addr, Ethernet_TCP_C_ctrl_offset, 17, 0);
	set_bit(Ethernet_base_addr, Ethernet_TCP_C_ctrl_offset, 16, 1);
}
void client_close(){
	set_bit(Ethernet_base_addr, Ethernet_TCP_C_ctrl_offset, 16, 0);
	set_bit(Ethernet_base_addr, Ethernet_TCP_C_ctrl_offset, 17, 1);

}
void client_port(uint port){
	uint control;
	control = ADDR_32(Ethernet_base_addr, Ethernet_TCP_C_ctrl_offset);
	client_ctrl((control & 0xffff0000) | (port & 0xffff));
}
int server_stat(){
	return ADDR_32(Ethernet_base_addr, Ethernet_TCP_S_stat_offset);
}

int server_rx_byte(){
	return ADDR_32(Ethernet_base_addr, Ethernet_TCP_S_rx_offset);
}
int server_rx(char a[]){
	int i = 0;
	int rx_data = 0;
	int len = server_stat() & 0xffff;
	while(!(rx_data & (1 << 8))){
		rx_data = server_rx_byte();
		a[i] = rx_data;
		i = i + 1;
	}
	return len;
}
void server_tx(char a[], uint len_a){
	int	i;
	for(i=0;i<len_a;i++){
		if(i == len_a - 1){
			server_tx_byte(a[i] | (1 << 8));
		}
		else{
			server_tx_byte(a[i]);
		}
	}
}
void server_start(){
	set_bit(Ethernet_base_addr, Ethernet_TCP_S_ctrl_offset, 17, 0);
	set_bit(Ethernet_base_addr, Ethernet_TCP_S_ctrl_offset, 16, 1);
}
void server_close(){
	set_bit(Ethernet_base_addr, Ethernet_TCP_S_ctrl_offset, 16, 0);
	set_bit(Ethernet_base_addr, Ethernet_TCP_S_ctrl_offset, 17, 1);

}
void server_port(uint port){
	uint control;
	control = ADDR_32(Ethernet_base_addr, Ethernet_TCP_S_ctrl_offset);
	server_ctrl((control & 0xffff0000) | (port & 0xffff));
}
