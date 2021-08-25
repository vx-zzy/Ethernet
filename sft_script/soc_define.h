#include "stdint.h"
#include "stdbool.h"

#define uchar unsigned char
#define uint unsigned int

#define ADDR_8(base,offset) (*(volatile unsigned int *) (( (base)) + (offset) ))
#define ADDR_32(base,offset) (*(volatile unsigned int *) (( (base<<2)) + (offset<<2) ))

#define Gpio_base_addr 0x4000
#define Gpio_seg_offset 0x0
#define Gpio_enable_offset 0x1
#define Gpio_out_offset 0x2
#define Gpio_in_offset 0x3

#define Gpio_seg(value) (ADDR_32(Gpio_base_addr, Gpio_seg_offset)=(value))
#define Gpio_out(value) (ADDR_32(Gpio_base_addr, Gpio_out_offset)=(value))
#define Gpio_in_Enable(value) (ADDR_32(Gpio_base_addr, Gpio_enable_offset)=(value))

#define Ethernet_base_addr 0x4010
#define Ethernet_UDP_stat_offset 0x0
#define Ethernet_UDP_ctrl_offset 0x1
#define Ethernet_UDP_tx_offset 0x2
#define Ethernet_UDP_rx_offset 0x3
#define Ethernet_TCP_S_stat_offset 0x4
#define Ethernet_TCP_S_ctrl_offset 0x5
#define Ethernet_TCP_S_tx_offset 0x6
#define Ethernet_TCP_S_rx_offset 0x7
#define Ethernet_TCP_C_stat_offset 0x8
#define Ethernet_TCP_C_ctrl_offset 0x9
#define Ethernet_TCP_C_tx_offset 0xa
#define Ethernet_TCP_C_rx_offset 0xb

#define UDP_ctrl(value) (ADDR_32(Ethernet_base_addr, Ethernet_UDP_ctrl_offset)=(value))
#define UDP_tx_byte(value) (ADDR_32(Ethernet_base_addr, Ethernet_UDP_tx_offset)=(value))
#define UDP_pkt_valid() (!get_bit(Ethernet_base_addr, Ethernet_UDP_stat_offset, 22))
#define UDP_byte_valid() (!get_bit(Ethernet_base_addr, Ethernet_UDP_stat_offset, 23))

#define client_ctrl(value) (ADDR_32(Ethernet_base_addr, Ethernet_TCP_C_ctrl_offset)=(value))
#define client_tx_byte(value) (ADDR_32(Ethernet_base_addr, Ethernet_TCP_C_tx_offset)=(value))
#define client_pkt_valid() (!get_bit(Ethernet_base_addr, Ethernet_TCP_C_stat_offset, 22))
#define client_byte_valid() (!get_bit(Ethernet_base_addr, Ethernet_TCP_C_stat_offset, 23))

#define server_ctrl(value) (ADDR_32(Ethernet_base_addr, Ethernet_TCP_S_ctrl_offset)=(value))
#define server_tx_byte(value) (ADDR_32(Ethernet_base_addr, Ethernet_TCP_S_tx_offset)=(value))
#define server_pkt_valid() (!get_bit(Ethernet_base_addr, Ethernet_TCP_S_stat_offset, 22))
#define server_byte_valid() (!get_bit(Ethernet_base_addr, Ethernet_TCP_S_stat_offset, 23))

int	Gpio_in();
void set_bit(uint32_t base_addr, uint32_t offset, int bit_num,  bool logic);
bool get_bit(uint32_t base_addr, uint32_t offset, int bit_num);
void delay_1s();
int UDP_stat();
int UDP_rx_byte();
void UDP_tx(char a[], uint len_a);
int UDP_rx(char a[]);
char UDP_rx_data[2000];
void client_start();
void client_close();
int client_stat();
int client_rx_byte();
void client_tx(char a[], uint len_a);
int client_rx(char a[]);
char client_rx_data[2000];
char server_rx_data[2000];
int server_stat();
int server_rx_byte();
void server_tx(char a[], uint len_a);
int server_rx(char a[]);
void server_start();
void server_close();
void server_port(uint port);
void client_port(uint port);
