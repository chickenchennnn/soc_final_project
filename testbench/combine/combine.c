#include <defs.h>
#include <user_uart.h>
#include <irq_vex.h>
#include "combine.h"

int __attribute__ ( ( section ( ".mprjram" ) ) ) partition(int low,int hi){
	int pivot = Array[hi];
	int i = low-1,j;
	int temp;
	for(j = low;j<hi;j++){
		if(Array[j] < pivot){
			i = i+1;
			temp = Array[i];
			Array[i] = Array[j];
			Array[j] = temp;
		}
	}
	if(Array[hi] < Array[i+1]){
		temp = Array[i+1];
		Array[i+1] = Array[hi];
		Array[hi] = temp;
	}
	return i+1;
}

void __attribute__ ( ( section ( ".mprjram" ) ) ) sort(int low, int hi){
	if(low < hi){
		int p = partition(low, hi);
		sort(low,p-1);
		sort(p+1,hi);
	}
}

int* __attribute__ ( ( section ( ".mprjram" ) ) ) qsort(){
	sort(0,SIZE-1);
	return Array;
}



int* __attribute__ ( ( section ( ".mprjram" ) ) ) matmul()
{
	int i=0;
	int j;
	int k;
	int sum;
	int kk;
	unsigned int count = 0;
	for (i=0; i<SIZE_MAT; i++){
		for (j=0; j<SIZE_MAT; j++){
			sum = 0;
			for(k = 0;k<SIZE_MAT;k++)
				sum += A[(i*SIZE_MAT) + k] * B[(k*SIZE_MAT) + j];
			result[(i*SIZE_MAT)+ j] = sum;
		}
	}
	return result;
}


int __attribute__ ( ( section ( ".mprjram"))) mm_hw()
{
	config_mm = 1;
	d_mm_in = A[0];
	d_mm_in = A[1];
	d_mm_in = A[2];
	d_mm_in = A[3];
	d_mm_in = A[4];
	d_mm_in = A[5];
	d_mm_in = A[6];
	d_mm_in = A[7];
	d_mm_in = A[8];
	d_mm_in = A[9];
	d_mm_in = A[10];
	d_mm_in = A[11];
	d_mm_in = A[12];
	d_mm_in = A[13];
	d_mm_in = A[14];
	d_mm_in = A[15];


	d_mm_in = B[0];
	d_mm_in = B[1];
	d_mm_in = B[2];
	d_mm_in = B[3];
	d_mm_in = B[4];
	d_mm_in = B[5];
	d_mm_in = B[6];
	d_mm_in = B[7];
	d_mm_in = B[8];
	d_mm_in = B[9];
	d_mm_in = B[10];
	d_mm_in = B[11];
	d_mm_in = B[12];
	d_mm_in = B[13];
	d_mm_in = B[14];
	d_mm_in = B[15];


	output_mm = d_mm_out;
	// reg_mprj_datal = output_mm << 16;
	return output_mm;
}

int __attribute__ ( ( section ( ".mprjram"))) qs_hw()
{
	config_qs = 1;
	
	d_qs_in = Array[0];
	d_qs_in = Array[1];
	d_qs_in = Array[2];
	d_qs_in = Array[3];
	d_qs_in = Array[4];
	d_qs_in = Array[5];
	d_qs_in = Array[6];
	d_qs_in = Array[7];
	d_qs_in = Array[8];
	d_qs_in = Array[9];

	output_qs = d_qs_out;
	// reg_mprj_datal = output_qs << 16;
	

	return output_qs;

}


void __attribute__((section(".mprjram"))) initfir()
{
	// initial your fir
	outputsignal = 0;
}

int __attribute__ ( ( section ( ".mprjram" ) ) ) fir(){
	
	taps_0 = 0;
	taps_1 = -10;
	taps_2 = -9;
	taps_3 = 23;
	taps_4 = 56;
	taps_5 = 63;
	taps_6 = 56;
	taps_7 = 23;
	taps_8 = -9;
	taps_9 = -10;
	taps_10 = 0;

	datalength = 64;

	initfir();
	reg_mprj_datal = 0x00A50000;
	config = 0x00000001;
	int program_config; // this defines in def.h
	// write down your fir
	// for(int i = 0;i < N ; i++){
	// 	inputsignal[i] = 1;
	// }
	program_config = config;
	// for (int i = 0; i < N; i++)
	// {
	// 	// 3. RISC V sends X[n] to FIR (note: make sure FIR is readily to accept X[n))
	// 	//  while(!((program_config >> 4) & 0x00000001))/*not ready to send input to fir.v   -> check config[4]*/
	// 	//  	program_config = config; // refresh config
	// 	d_in = i;
	// 	// 4. RISC V receives Y[n] from FIR (note: make sure Y[n] is ready)
	// 	//  while(!((program_config >> 5) & 0x00000001)) /*not ready to read output from fir.v -> check config[5]*/
	// 	//  	program_config = config; // refresh config
	// 	outputsignal[i] = d_out;
	// }
	int i = 0;
	d_in = i;
	while (i < N - 1)
	{
		outputsignal = d_out;
		i++;
		d_in = i;
	}
	outputsignal = d_out;
	// 6. When finish, write final Y (Y[7:0] output to mprj [31:24]), EndMark ((?�h5A mprj [23:16]),
	program_config = config;
	reg_mprj_datal = ((0x000000ff && outputsignal) << 24) | 0x005A0000; // finish

	return outputsignal;
}
		




void __attribute__ ( ( section ( ".mprj" ) ) ) uart_write(int n)
{
    while(((reg_uart_stat>>3) & 1));
    reg_tx_data = n;
}

void __attribute__ ( ( section ( ".mprj" ) ) ) uart_write_char(char c)
{
	if (c == '\n')
		uart_write_char('\r');

    // wait until tx_full = 0
    while(((reg_uart_stat>>3) & 1));
    reg_tx_data = c;
}

void __attribute__ ( ( section ( ".mprj" ) ) ) uart_write_string(const char *s)
{
    while (*s)
        uart_write_char(*(s++));
}


char __attribute__ ( ( section ( ".mprj" ) ) ) uart_read_char()
{
	char num;
    if((((reg_uart_stat>>5) | 0) == 0) && (((reg_uart_stat>>4) | 0) == 0)){
        for(int i = 0; i < 1; i++)
            asm volatile ("nop");

        num = reg_rx_data;
    }

    return num;
}

int __attribute__ ( ( section ( ".mprj" ) ) ) uart_read()
{
    int num;
    if((((reg_uart_stat>>5) | 0) == 0) && (((reg_uart_stat>>4) | 0) == 0)){
        for(int i = 0; i < 1; i++)
            asm volatile ("nop");

        num = reg_rx_data;
    }

    return num;
}
