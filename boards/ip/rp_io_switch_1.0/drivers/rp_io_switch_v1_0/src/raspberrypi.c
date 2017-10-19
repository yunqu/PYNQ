/******************************************************************************
 *  Copyright (c) 2016, Xilinx, Inc.
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *
 *  1.  Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *
 *  2.  Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *  3.  Neither the name of the copyright holder nor the names of its
 *      contributors may be used to endorse or promote products derived from
 *      this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 *  OR BUSINESS INTERRUPTION). HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 *  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 *  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 *  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *****************************************************************************/
/******************************************************************************
 *
 *
 * @file raspberrypi.c
 *
 * Implementing useful functions, including the IIC read and write,
 * initialization functions for SPI devices, delay functions, timer setup,
 * etc.
 *
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who  Date     Changes
 * ----- --- ------- -----------------------------------------------
 * 1.00a pp  10/09/17 release
 *
 * </pre>
 *
 *****************************************************************************/
#include "raspberrypi.h"

/*
 * Delay Timer related functions
 * Timer 1, counter 2 is used
 */
XTmrCtr TimerInst_0, TimerInst_1;

void delay_us(int usdelay){
    XTmrCtr_SetResetValue(&TimerInst_1, 1, usdelay*100);
    // Start the timer5 for usdelay us delay
    XTmrCtr_Start(&TimerInst_1, 1);
    // Wait for usdelay us to lapse
    while(!XTmrCtr_IsExpired(&TimerInst_1,1));
    // Stop the timer5
    XTmrCtr_Stop(&TimerInst_1, 1);
}

void delay_ms(int msdelay){
    delay_us(msdelay*1000);
}

int tmrctr_init(void) {
    int Status;

    // specify the device ID
    Status = XTmrCtr_Initialize(&TimerInst_0, XPAR_TMRCTR_0_DEVICE_ID);
    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // specify the device ID
    Status = XTmrCtr_Initialize(&TimerInst_1, XPAR_TMRCTR_1_DEVICE_ID);
    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    XTmrCtr_SetOptions(&TimerInst_1, 1,
        XTC_AUTO_RELOAD_OPTION | XTC_CSR_LOAD_MASK | XTC_CSR_DOWN_COUNT_MASK);
    return 0;
}

// SPI related functions
void spi_transfer(u32 BaseAddress, int bytecount,
                  u8* readBuffer, u8* writeBuffer) {
    int i;

    XSpi_WriteReg(BaseAddress,XSP_SSR_OFFSET, 0xfe);
    for (i=0; i<bytecount; i++){
        XSpi_WriteReg(BaseAddress,XSP_DTR_OFFSET, writeBuffer[i]);
    }
    while(((XSpi_ReadReg(BaseAddress,XSP_SR_OFFSET) & 0x04)) != 0x04);
    // delay for about 100 ns
    XTmrCtr_SetResetValue(&TimerInst_1, 1, 10);
    // Start the timer5
    XTmrCtr_Start(&TimerInst_1, 1);
    // Wait for the delay to lapse
    while(!XTmrCtr_IsExpired(&TimerInst_1,1));
    // Stop the timer5
    XTmrCtr_Stop(&TimerInst_1, 1);

    // Read SPI
    for(i=0;i< bytecount; i++){
       readBuffer[i] = XSpi_ReadReg(BaseAddress,XSP_DRR_OFFSET);
    }
    XSpi_WriteReg(BaseAddress, XSP_SSR_OFFSET, 0xff);
}

void spi_init(u32 BaseAddress, u32 clk_phase, u32 clk_polarity){
    u32 Control;

    // Soft reset SPI
    XSpi_WriteReg(BaseAddress, XSP_SRR_OFFSET, 0xa);
    // Master mode
    Control = XSpi_ReadReg(BaseAddress, XSP_CR_OFFSET);
    // Master Mode
    Control |= XSP_CR_MASTER_MODE_MASK;
    // Enable SPI
    Control |= XSP_CR_ENABLE_MASK;
    // Slave select manually
    Control |= XSP_INTR_SLAVE_MODE_MASK;
    // Enable Transmitter
    Control &= ~XSP_CR_TRANS_INHIBIT_MASK;
    // XSP_CR_CLK_PHASE_MASK
    if(clk_phase)
        Control |= XSP_CR_CLK_PHASE_MASK;
    // XSP_CR_CLK_POLARITY_MASK
    if(clk_polarity)
        Control |= XSP_CR_CLK_POLARITY_MASK;
    XSpi_WriteReg(BaseAddress, XSP_CR_OFFSET, Control);
}

// IIC related functions
int iic_read(u32 iic_baseaddr, u32 addr, u8* buffer, u8 numbytes){
    XIic_Recv(iic_baseaddr, addr, buffer, numbytes, XIIC_STOP);
    return 0;
}


int iic_write(u32 iic_baseaddr, u32 addr, u8* buffer, u8 numbytes){
       XIic_Send(iic_baseaddr, addr, buffer, numbytes, XIIC_STOP);
       return 0;
}

// Circular buffer related functions
int cb_init(circular_buffer *cb, volatile u32* log_start_addr,
            size_t capacity, size_t sz){
  cb->buffer = (volatile char*) log_start_addr;
  if(cb->buffer == NULL)
    return -1;
  cb->buffer_end = (char *)cb->buffer + capacity * sz;
  cb->capacity = capacity;
  cb->sz = sz;
  cb->head = cb->buffer;
  cb->tail = cb->buffer;

  // Mailbox API Initialization
  MAILBOX_DATA(0)  = 0xffffffff;
  MAILBOX_DATA(2)  = (u32) cb->head;
  MAILBOX_DATA(3)  = (u32) cb->tail;

  return 0;
}

void cb_push_back(circular_buffer *cb, const void *item){

  u8 i;
  u8* tail_ptr = (u8*) cb->tail;
  u8* item_ptr = (u8*) item;

  // update data
  for(i=0;i<cb->sz;i++){
    tail_ptr[i] = item_ptr[i];
  }

  cb_push_incr_ptrs(cb);

  // Mailbox API Update
  MAILBOX_DATA(0)  = (u32) item;
  MAILBOX_DATA(2)  = (u32) cb->head;
  MAILBOX_DATA(3)  = (u32) cb->tail;
}

void cb_push_back_float(circular_buffer *cb, const float *item){
  // update data
  float* tail_ptr = (float*) cb->tail;
  *tail_ptr = *item;

  cb_push_incr_ptrs(cb);

  // Mailbox API Update
  MAILBOX_DATA_FLOAT(0)  = *item;
}

void cb_push_incr_ptrs(circular_buffer *cb){

  // Update pointers
  cb->tail = (char*)cb->tail + cb->sz;
  if(cb->tail >= cb->buffer_end)
    cb->tail = cb->buffer;

  if((cb->tail == cb->head) ) {
    cb->head  = (char*)cb->head + cb->sz;
  }

  // Update mailbox API
  MAILBOX_DATA(2) = (u32) cb->head;
  MAILBOX_DATA(3) = (u32) cb->tail;
}

/*
 *  Switch Configuration
 *  Configuration is done by writing three 32 bit values and one 16 bit values
 *	to the switch.
 *  The 32-bit values represent as follows:
 *  raspberrypi GPIO0 = bits [3:0] -- register 0
 *  raspberrypi GPIO1 = bits [7:4]
 *  raspberrypi GPIO2 = bits [11:8]
 *  raspberrypi GPIO3 = bits [15:12]
 *  raspberrypi GPIO4 = bits [19:16]
 *  raspberrypi GPIO5 = bits [23:20]
 *  raspberrypi GPIO6 = bits [27:24] 
 *  raspberrypi GPIO7 = bits [31:28]
 *  raspberrypi GPIO8 = bits [3:0] -- register 1
 *  raspberrypi GPIO9 = bits [7:4]
 *  raspberrypi GPIO10 = bits [11:8]
 *  raspberrypi GPIO11 = bits [15:12]
 *  raspberrypi GPIO12 = bits [19:16]
 *  raspberrypi GPIO13 = bits [23:20]
 *  raspberrypi GPIO14 = bits [27:24] 
 *  raspberrypi GPIO15 = bits [31:28]
 *  raspberrypi GPIO16 = bits [3:0] -- register 2
 *  raspberrypi GPIO17 = bits [7:4]
 *  raspberrypi GPIO18 = bits [11:8]
 *  raspberrypi GPIO19 = bits [15:12]
 *  raspberrypi GPIO20 = bits [19:16]
 *  raspberrypi GPIO21 = bits [23:20]
 *  raspberrypi GPIO22 = bits [27:24] 
 *  raspberrypi GPIO23 = bits [31:28]
 *  raspberrypi GPIO24 = bits [3:0] -- register 3
 *  raspberrypi GPIO25 = bits [7:4]
 *  raspberrypi GPIO26 = bits [11:8]
 *  raspberrypi GPIO27 = bits [15:12]
 */
void config_raspberrypi_switch(char GPIO0, char GPIO1, char GPIO2, 
                           char GPIO3, char GPIO4, char GPIO5, 
                           char GPIO6, char GPIO7, char GPIO8,
                           char GPIO9, char GPIO10, char GPIO11, 
                           char GPIO12, char GPIO13, char GPIO14, 
                           char GPIO15, char GPIO16, char GPIO17, 
                           char GPIO18, char GPIO19, char GPIO20, 
                           char GPIO21, char GPIO22, char GPIO23, 
                           char GPIO24, char GPIO25, char GPIO26, char GPIO27) 
{

   u32 switchConfigValue0, switchConfigValue1;
   u32 switchConfigValue2, switchConfigValue3;

   // Calculate switch configuration values
   switchConfigValue0 = (GPIO7<<28)|(GPIO6<<24)|(GPIO5<<20)|(GPIO4<<16)| \
		   	   	   	    (GPIO3<<12)|(GPIO2<<8)|(GPIO1<<4)|(GPIO0);
   switchConfigValue1 = (GPIO15<<28)|(GPIO14<<24)|(GPIO13<<20)|(GPIO12<<16)| \
                        (GPIO11<<12)|(GPIO10<<8)|(GPIO9<<4)|(GPIO8);
   switchConfigValue2 = (GPIO23<<28)|(GPIO22<<24)|(GPIO21<<20)|(GPIO20<<16)| \
                        (GPIO19<<12)|(GPIO18<<8)|(GPIO17<<4)|(GPIO16);
   switchConfigValue3 = (GPIO27<<12)|(GPIO26<<8)|(GPIO25<<4)|(GPIO24);

   // Set GPIO configuration
   Xil_Out32(SWITCH_BASEADDR, switchConfigValue0);
   Xil_Out32(SWITCH_BASEADDR+4, switchConfigValue1);
   Xil_Out32(SWITCH_BASEADDR+8, switchConfigValue2);
   Xil_Out32(SWITCH_BASEADDR+0xc, switchConfigValue3);
}

void raspberrypi_init(u32 spi0_clk_phase, u32 spi0_clk_polarity,
                  u32 spi1_clk_phase, u32 spi1_clk_polarity) {
    spi_init(SPI0_BASEADDR, spi0_clk_phase, spi0_clk_polarity);
    spi_init(SPI1_BASEADDR, spi1_clk_phase, spi1_clk_polarity);
    tmrctr_init();
}
