#ifndef _USER_UART_H_
#define _USER_UART_H_

#include <stdint.h>
#include <stdbool.h>

#define reg_rx_data (*(volatile uint32_t *)0x31000000)
#define reg_tx_data (*(volatile uint32_t *)0x31000004)
#define reg_uart_stat (*(volatile uint32_t *)0x31000008)
#define reg_uart_clkdiv (*(volatile uint32_t *)0x3100000c)

#define FIFO_DEPTH 8
extern int UART_BUF[FIFO_DEPTH];

#endif