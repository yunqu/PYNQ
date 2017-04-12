/*
 * if_arduino_cfg_pg_smg.c
 *
 *  Created on: Feb 16, 2017
 *      Author: parimalp
 */
#include "xparameters.h"
#include <stdio.h>
#include "xaxicdma.h"	// AXI CDMA is used to move Pattern data from DDR to Block RAM
#include "xaxidma.h"	// AXI DMA is used to move tracebuffer data into DDR
#include "xil_exception.h"	// if interrupt is used
#include "xintc.h"		// if AXI_INTC is used
#include "xil_cache.h"
#include "xil_io.h"

#define INTC_DEVICE_ID		XPAR_INTC_0_DEVICE_ID
#define XPAR_TRACE_CNTRL_BASEADDR XPAR_XTRACE_CNTRL_0_S_AXI_TRACE_CNTRL_BASEADDR
#define XPAR_CFG_0_BASEADDR XPAR_IOP3_CFG_0_CFG_0_S00_AXI_BASEADDR
#define XPAR_SMG_IO_SWITCH_BASEADDR XPAR_IOP3_SMG_0_SMG_IO_SWITCH_0_S00_AXI_BASEADDR

#define TRACE_CNTRL_ADDR_AP_CTRL 0x00	// [3:0] ap_ready, ap_idle, ap_done, ap_start
#define TRACE_CNTRL_DATA_COMPARE_LSW 0x10	// bits [31:0]
#define TRACE_CNTRL_DATA_COMPARE_MSW 0x14	// bits [63:32]
#define TRACE_CNTRL_LENGTH  0x1c	// 32-bit
#define TRACE_CNTRL_SAMPLE_RATE  0x24 // 32-bit

#define BUFFER_BASE 0x02000000
#define LENGTH XPAR_IOP3_AXI_BRAM_CTRL_0_S_AXI_HIGHADDR-XPAR_IOP3_AXI_BRAM_CTRL_0_S_AXI_BASEADDR+1  // 0x10000 source and destination buffers lengths in number of bytes

#define XPAR_SMG_BRAM_ENB_RSTB_BASEADDR XPAR_IOP3_SMG_0_SMG_BRAM_ENB_RSTB_BASEADDR
#define XPAR_GPIO_PG_TRI_CONTROL_BASEADDR XPAR_IOP3_PG_O_PG_AXI_GPIO_PG_TRI_CONTROL_BASEADDR
#define PG_CDMA_BRAM_MEMORY XPAR_IOP3_PG_O_AXI_BRAM_CTRL_0_S_AXI_BASEADDR // BRAM Port B mapped through 2nd BRAM Controller accessed by CDMA
#define SMG_CDMA_BRAM_MEMORY XPAR_IOP3_SMG_0_AXI_BRAM_CTRL_0_S_AXI_BASEADDR // BRAM Port B mapped through 2nd BRAM Controller accessed by CDMA
#define SMG_CDMA_BRAM_MEMORY_SIZE XPAR_IOP3_SMG_0_AXI_BRAM_CTRL_0_S_AXI_HIGHADDR-XPAR_IOP3_SMG_0_AXI_BRAM_CTRL_0_S_AXI_BASEADDR+1 // size in bytes
#define DDR_MEMORY 0x21000000
#define NUM_OF_SAMPLES 64			// 1048575 => 0x10_0000 64-bit words => 8,388,608 bytes

// commands and data from A9 to microblaze
#define MAILBOX_CMD_ADDR       (*(volatile u32 *)(0x0000FFFC))
#define MAILBOX_DATA(x)        (*(volatile u32 *)(0x0000F000 +((x)*4)))

// Commands
// CFG [3:0]
// PG  [7:4]
// FSM [11:8]
// ASM [15:12]
// CFG related commands, bits [11:4] used for sub-commands
#define DEFAULT_CFG_SWITCH      0x1
#define CONFIG_CFG_SWITCH		0x3

// PG related commands, bits [11:4] used for sub-commands
#define PG_ONLY					0x5
#define PG_ONLY_SINGLE			0x90
#define PG_ONLY_MULTIPLE		0xA0
#define PG_ONLY_STOP			0xB0
#define PG_ONLY_CONTINUE		0xC0

#define PG_TRACE				0x7
#define PG_TRACE_SINGLE			0x190
#define PG_TRACE_MULTIPLE		0x1A0
#define PG_TRACE_STOP			0x1B0
#define PG_TRACE_CONTINUE		0x1C0

// SMG related commands, bits [11:4] used for sub-commands
#define SMG_START				0x9
#define SMG_STOP				0xB
// The following command allows the SMG free running SMG.
// It assumes that SMG_START was executed prior to TRACE_ONLY
#define TRACE_ONLY				0xD

int main (void) {

	int CDMA_Status, Status;
    int numofsamples, stop_issued;
    u8 * source, * destination, * traceptr;
    u32 direction;
    u32 reg0, reg1, reg2, reg3, reg4, reg5, reg6;

    // CFG related
	u32 cmd, cmd1, cmd_to_send;
	u32 cfg_bank_init_value;

    // AXI CDMA related definitions
	XAxiCdma xcdma;
    XAxiCdma_Config * CdmaCfgPtr;

    // AXI DMA related definitions
    XAxiDma AxiDma;
	XAxiDma_Config *CfgPtr;

    // Set direction register of INTR and set it low
	Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR+4,0x0); // output
    Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);   // make sure it is low

	// Setup DMA Controller
    CdmaCfgPtr = XAxiCdma_LookupConfig(XPAR_IOP3_AXI_CDMA_0_DEVICE_ID);
   	if (!CdmaCfgPtr) {
   		return XST_FAILURE;
   	}

   	Status = XAxiCdma_CfgInitialize(&xcdma , CdmaCfgPtr, CdmaCfgPtr->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
		xil_printf("Status=%x\r\n",Status);
	}

	/* Initialize the XAxiDma device.	 */
	CfgPtr = XAxiDma_LookupConfig(XPAR_AXIDMA_0_DEVICE_ID);
	if (!CfgPtr) {
		xil_printf("No config found for %d\r\n", XPAR_AXIDMA_0_DEVICE_ID);
		return XST_FAILURE;
	}

	Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("Initialization failed %d\r\n", Status);
		return XST_FAILURE;
	}

	XAxiDma_Reset(&AxiDma);

	/* Disable interrupts, we use polling mode */
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
						XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
						XAXIDMA_DMA_TO_DEVICE);

	while(1) {
		while(MAILBOX_CMD_ADDR==0); // wait for CMD to be issued
		cmd = MAILBOX_CMD_ADDR;

		switch(cmd & 0x00f) {
	    case DEFAULT_CFG_SWITCH:
	        // Function implemented is D3 & D2 & D1 & D0, where D0 is LSB and D3 is MSB
	        // cfg_cmd registers are located at offset 0, 8, 0x10, 0x18, 0x20
	        // cfg_init registers are located at offset 4, 0xc, 0x14, 0x1C, 0x24
	    	Xil_Out32(XPAR_IOP3_FUNCTION_SEL_BASEADDR,0x00);					// function select to use CFG

	    	// group 0
	    	Xil_Out32(XPAR_CFG_0_BASEADDR+4, 0x008000);		// truth table
	    	Xil_Out32(XPAR_CFG_0_BASEADDR, 0x00001011);		// start=1
	    	Xil_Out32(XPAR_CFG_0_BASEADDR, 0x00001010);		// start=0

	    	// group 1
	    	Xil_Out32(XPAR_CFG_0_BASEADDR+0xc, 0x008000);		// truth table
	    	Xil_Out32(XPAR_CFG_0_BASEADDR+8, 0x00001021);		// start=1
	    	Xil_Out32(XPAR_CFG_0_BASEADDR+8, 0x00001020);		// start=0

	    	// group 2
	    	Xil_Out32(XPAR_CFG_0_BASEADDR+0x14, 0x008000);		// truth table
	    	Xil_Out32(XPAR_CFG_0_BASEADDR+0x10, 0x00001041);	// start=1
	    	Xil_Out32(XPAR_CFG_0_BASEADDR+0x10, 0x00001040);	// start=0

	    	// group 3
	    	Xil_Out32(XPAR_CFG_0_BASEADDR+0x1c, 0x008000);		// truth table
	    	Xil_Out32(XPAR_CFG_0_BASEADDR+0x18, 0x00001081);	// start=1
	    	Xil_Out32(XPAR_CFG_0_BASEADDR+0x18, 0x00001080);	// start=0

	    	// group 4 - this is push buttons input and RGBLD0 output
	    	Xil_Out32(XPAR_CFG_0_BASEADDR+0x24, 0x008000);		// truth table
	    	Xil_Out32(XPAR_CFG_0_BASEADDR+0x20, 0x00001101);	// start=1
	    	Xil_Out32(XPAR_CFG_0_BASEADDR+0x20, 0x00001100);	// start=0

            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
	    	MAILBOX_CMD_ADDR = 0x0;
			break;
	    case CONFIG_CFG_SWITCH:
	    	Xil_Out32(XPAR_IOP3_FUNCTION_SEL_BASEADDR,0x00);					// function select to use CFG
	    	cfg_bank_init_value=MAILBOX_DATA(0);
	    	cmd1 = (cmd >> 4) & 0x00000ff;										// use only bits 11:4
	    	switch(cmd1)
	    	{
	    		case 1:			// configuring group/bank 0
	    			cmd_to_send = cmd & 0xfffffff0;
	    			Xil_Out32(XPAR_CFG_0_BASEADDR+4, cfg_bank_init_value);
	    			Xil_Out32(XPAR_CFG_0_BASEADDR, cmd_to_send | 0x1);
	    			Xil_Out32(XPAR_CFG_0_BASEADDR, cmd_to_send);
	    			break;
	    		case 2:			// configuring group/bank 1
	    			cmd_to_send = cmd & 0xfffffff0;
	    			Xil_Out32(XPAR_CFG_0_BASEADDR+0xc, cfg_bank_init_value);
	    			Xil_Out32(XPAR_CFG_0_BASEADDR+8, cmd_to_send | 0x1);
	    			Xil_Out32(XPAR_CFG_0_BASEADDR+8, cmd_to_send);
	    			break;
	    		case 4:			// configuring group/bank 2
	    			cmd_to_send = cmd & 0xfffffff0;
	    			Xil_Out32(XPAR_CFG_0_BASEADDR+0x14, cfg_bank_init_value);
	    			Xil_Out32(XPAR_CFG_0_BASEADDR+0x10, cmd_to_send | 0x1);
	    			Xil_Out32(XPAR_CFG_0_BASEADDR+0x10, cmd_to_send);
	    			break;
	    		case 8:			// configuring group/bank 3
	    			cmd_to_send = cmd & 0xfffffff0;
	    			Xil_Out32(XPAR_CFG_0_BASEADDR+0x1c, cfg_bank_init_value);
	    			Xil_Out32(XPAR_CFG_0_BASEADDR+0x18, cmd_to_send | 0x1);
	    			Xil_Out32(XPAR_CFG_0_BASEADDR+0x18, cmd_to_send);
	    			break;
	    		case 16:		// configuring group/bank 4
	    			cmd_to_send = cmd & 0xfffffff0;
	    			Xil_Out32(XPAR_CFG_0_BASEADDR+0x24, cfg_bank_init_value);
	    			Xil_Out32(XPAR_CFG_0_BASEADDR+0x20, cmd_to_send | 0x1);
	    			Xil_Out32(XPAR_CFG_0_BASEADDR+0x20, cmd_to_send);
	    			break;
	    		default:
	    			MAILBOX_CMD_ADDR = 0x0;
	    			break;
	    	}
            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
			MAILBOX_CMD_ADDR = 0x0;
			break;
		case PG_ONLY:
			Xil_Out32(XPAR_IOP3_FUNCTION_SEL_BASEADDR,0x01);	// function select to use PG
			Xil_Out32(XPAR_SMG_BRAM_ENB_RSTB_BASEADDR,0x01);	 // make sure that SMG is not enabled Enable=0, RST=1
			cmd1 = cmd & 0x00000ff0;							// use bits 11:4
			direction = MAILBOX_DATA(0);						// I/O direction
			source = (u8 *)MAILBOX_DATA(1);						// DDR address where pattern is passed
			source = (u8 *) ((u32) source | 0x20000000);
			numofsamples = MAILBOX_DATA(2);
			// move pattern data from DDR memory to BlockRAM
			destination = (u8 *)PG_CDMA_BRAM_MEMORY;
			XAxiCdma_IntrDisable(&xcdma, XAXICDMA_XR_IRQ_ALL_MASK);
			Xil_DCacheFlushRange((UINTPTR)&source, numofsamples*4);
			Status = XAxiCdma_SimpleTransfer(&xcdma, (u32) source, (u32) destination, numofsamples*4, NULL, NULL);
			if (Status != XST_SUCCESS) {
				CDMA_Status = XAxiCdma_GetError(&xcdma);
				if (CDMA_Status != 0x0) {
					XAxiCdma_Reset(&xcdma);
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
					MAILBOX_DATA(0) = 0xFFFF0001;				// return error code
					break;
				}
			}
			while (XAxiCdma_IsBusy(&xcdma)); 					// Wait for DMA to complete
			CDMA_Status = XAxiCdma_GetError(&xcdma);
			if (CDMA_Status != 0x0) {
				XAxiCdma_Reset(&xcdma);
	            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
	            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
				MAILBOX_DATA(0) = 0xFFFF0002;					// return error code
				break;
			}
			switch(cmd1)
			{
				case PG_ONLY_SINGLE:							// Generate pattern one time only
					// Now we have pattern in block memory so issue generation command
					Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR,direction); 	// I/O direction to GPIO Channel 1 data
					Xil_Out32(XPAR_IOP3_PG_O_PG_AXI_GPIO_PG_NSAMPLES_SINGLE_BASEADDR,numofsamples); // number of samples
					Xil_Out32(XPAR_IOP3_PG_O_PG_AXI_GPIO_PG_NSAMPLES_SINGLE_BASEADDR+8,0);		// single time
					// issue start command to the PG
					Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x1);			// issue start pulse
					Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x0);			// issue start pulse
					stop_issued = 0;
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
					MAILBOX_CMD_ADDR = 0x0;
					break;
				case PG_ONLY_MULTIPLE:							// Generate pattern continuously until stop or single command issued
					// Now we have pattern in block memory so issue generation command
					Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR,direction); 	// I/O direction to GPIO Channel 1 data
					Xil_Out32(XPAR_IOP3_PG_O_PG_AXI_GPIO_PG_NSAMPLES_SINGLE_BASEADDR,numofsamples); // number of samples
					Xil_Out32(XPAR_IOP3_PG_O_PG_AXI_GPIO_PG_NSAMPLES_SINGLE_BASEADDR+8,1);		// continuously
					// issue start command to the PG
					Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x1);			// issue start pulse
					Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x0);			// issue start pulse
					stop_issued = 0;
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
					MAILBOX_CMD_ADDR = 0x0;
					break;
				case PG_ONLY_STOP:
					if(stop_issued == 0) {
						Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x4);		// issue stop pulse
						Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x0);		// issue stop pulse
						stop_issued = 1;
					}
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
					MAILBOX_CMD_ADDR = 0x0;
					break;
				case PG_ONLY_CONTINUE:
					if(stop_issued) {
						Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x2);		// issue continue pulse
						Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x0);		// issue continue pulse
						stop_issued = 0;
					}
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
					MAILBOX_CMD_ADDR = 0x0;
					break;
			}
			break;
		case PG_TRACE:
			Xil_Out32(XPAR_IOP3_FUNCTION_SEL_BASEADDR,0x01);	// function select to use PG
			Xil_Out32(XPAR_SMG_BRAM_ENB_RSTB_BASEADDR,0x01);	 	// make sure that SMG is not enabled Enable=0, RST=1
			cmd1 = cmd & 0x00000ff0;							// use bits 11:4
			direction = MAILBOX_DATA(0);						// I/O direction
			source = (u8 *)MAILBOX_DATA(1);						// DDR address where pattern is passed
			source = (u8 *) ((u32) source | 0x20000000);
			numofsamples = MAILBOX_DATA(2);
			traceptr = (u8 *)MAILBOX_DATA(3);					// DDR address where trace will be saved
			traceptr = (u8 *) ((u32) traceptr | 0x20000000);
			// move pattern data from DDR memory to BlockRAM
			destination = (u8 *)PG_CDMA_BRAM_MEMORY;
			XAxiCdma_IntrDisable(&xcdma, XAXICDMA_XR_IRQ_ALL_MASK);
			Xil_DCacheFlushRange((UINTPTR)&source, numofsamples*4);
			Status = XAxiCdma_SimpleTransfer(&xcdma, (u32) source, (u32) destination, numofsamples*4, NULL, NULL);
			if (Status != XST_SUCCESS) {
				CDMA_Status = XAxiCdma_GetError(&xcdma);
				if (CDMA_Status != 0x0) {
					XAxiCdma_Reset(&xcdma);
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
					MAILBOX_DATA(0) = 0xFFFF0003;					// return error code
					break;
				}
			}
			while (XAxiCdma_IsBusy(&xcdma)); // Wait for DMA to complete
			CDMA_Status = XAxiCdma_GetError(&xcdma);
			if (CDMA_Status != 0x0) {
				XAxiCdma_Reset(&xcdma);
	            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
	            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
				MAILBOX_DATA(0) = 0xFFFF0004;						// return error code
				break;
			}
			// Reset Stream DMA controller
			XAxiDma_Reset(&AxiDma);
			// Wait for reset to complete
			while(!XAxiDma_ResetIsDone(&AxiDma));
			// Configure Stream DMA controller
			Status = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) traceptr, numofsamples*8,
					XAXIDMA_DEVICE_TO_DMA);
			if (Status != XST_SUCCESS) {
	            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
	            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
				MAILBOX_DATA(0) = 0xFFFF0005;						// return error code
				break;
			}
			// pattern generator related code
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_LENGTH,numofsamples); // number of samples
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_DATA_COMPARE_MSW,0x00000); // MS word of trigger mask
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_DATA_COMPARE_LSW,0x00000); // LS word of trigger mask
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_ADDR_AP_CTRL,0x01); // Issue start, Start=1
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_ADDR_AP_CTRL,0x00); // Start=0
			switch(cmd1)
			{
				case PG_TRACE_SINGLE:								// Generate pattern one time only
					// Now we have pattern in block memory so issue generation command
					Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR,direction); 	// I/O direction to GPIO Channel 1 data
					Xil_Out32(XPAR_IOP3_PG_O_PG_AXI_GPIO_PG_NSAMPLES_SINGLE_BASEADDR,numofsamples); // number of samples
					Xil_Out32(XPAR_IOP3_PG_O_PG_AXI_GPIO_PG_NSAMPLES_SINGLE_BASEADDR+8,0);		// single time
					// issue start command to the PG
					Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x1);			// issue start pulse
					Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x0);			// issue start pulse
					stop_issued = 0;
					while(XAxiDma_Busy(&AxiDma,XAXIDMA_DEVICE_TO_DMA));
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
					MAILBOX_CMD_ADDR = 0x0;
					break;
				case PG_TRACE_MULTIPLE:								// Generate pattern continuously until stop or single command issued
					// Now we have pattern in block memory so issue generation command
					Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR,direction); 	// I/O direction to GPIO Channel 1 data
					Xil_Out32(XPAR_IOP3_PG_O_PG_AXI_GPIO_PG_NSAMPLES_SINGLE_BASEADDR,numofsamples); // number of samples
					Xil_Out32(XPAR_IOP3_PG_O_PG_AXI_GPIO_PG_NSAMPLES_SINGLE_BASEADDR+8,1);		// continuously
					// issue start command to the PG
					Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x1);			// issue start pulse
					Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x0);			// issue start pulse
					stop_issued = 0;
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
					MAILBOX_CMD_ADDR = 0x0;
					break;
				case PG_TRACE_STOP:
					if(stop_issued == 0) {
						Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x4);		// issue stop pulse
						Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x0);		// issue stop pulse
						stop_issued = 1;
					}
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
					MAILBOX_CMD_ADDR = 0x0;
					break;
				case PG_TRACE_CONTINUE:
					if(stop_issued) {
						Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x2);		// issue continue pulse
						Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x0);		// issue continue pulse
						stop_issued = 1;
					}
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
					MAILBOX_CMD_ADDR = 0x0;
					break;
			}
			break;
		case SMG_START:
			Xil_Out32(XPAR_IOP3_FUNCTION_SEL_BASEADDR,0x02);	// function select to use SMG
			reg0 = MAILBOX_DATA(0);								// input select for pins 0,1,2,3
			reg1 = MAILBOX_DATA(1);								// input select for pins 4,5,6,7
			reg2 = MAILBOX_DATA(2);								// output select for pins 0,1,2,3
			reg3 = MAILBOX_DATA(3);								// output select for pins 4,5,6,7
			reg4 = MAILBOX_DATA(4);								// output select for pins 8,9,10,11
			reg5 = MAILBOX_DATA(5);								// output select for pins 12,13,14,15
			reg6 = MAILBOX_DATA(6);								// output select for pins 16,17,18,19
			direction = MAILBOX_DATA(7);						// I/O direction
			Xil_Out32(XPAR_SMG_BRAM_ENB_RSTB_BASEADDR,0x01);	 	// Enable=0, RST=1

			source = (u8 *)MAILBOX_DATA(8);						// DDR address where pattern is passed
			source = (u8 *) ((u32) source | 0x20000000);
			traceptr = (u8 *)MAILBOX_DATA(9);					// DDR address where trace will be saved
			traceptr = (u8 *) ((u32) traceptr | 0x20000000);
			// move pattern data from DDR memory to BlockRAM
			destination = (u8 *)SMG_CDMA_BRAM_MEMORY;
			XAxiCdma_IntrDisable(&xcdma, XAXICDMA_XR_IRQ_ALL_MASK);
			Xil_DCacheFlushRange((UINTPTR)&source, SMG_CDMA_BRAM_MEMORY_SIZE);
			Status = XAxiCdma_SimpleTransfer(&xcdma, (u32) source, (u32) destination, SMG_CDMA_BRAM_MEMORY_SIZE, NULL, NULL);
			if (Status != XST_SUCCESS) {
				CDMA_Status = XAxiCdma_GetError(&xcdma);
				if (CDMA_Status != 0x0) {
					XAxiCdma_Reset(&xcdma);
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
		            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
					MAILBOX_DATA(0) = 0xFFFF0006;				// return error code
					break;
				}
			}
			while (XAxiCdma_IsBusy(&xcdma)); 					// Wait for DMA to complete
			CDMA_Status = XAxiCdma_GetError(&xcdma);
			if (CDMA_Status != 0x0) {
				XAxiCdma_Reset(&xcdma);
	            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
	            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
				MAILBOX_DATA(0) = 0xFFFF0007;					// return error code
				break;
			}
			numofsamples = MAILBOX_DATA(10);
			// Reset Stream DMA controller
			XAxiDma_Reset(&AxiDma);
			// Wait for reset to complete
			while(!XAxiDma_ResetIsDone(&AxiDma));
			// Configure Stream DMA controller
			Status = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) traceptr, numofsamples*8,
					XAXIDMA_DEVICE_TO_DMA);
			if (Status != XST_SUCCESS) {
	            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
	            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
				MAILBOX_DATA(0) = 0xFFFF0008;						// return error code
				break;
			}
			// Setup the trace controller
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_LENGTH,numofsamples); // number of samples
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_DATA_COMPARE_MSW,0x00000); // MS word of trigger mask
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_DATA_COMPARE_LSW,0x00000); // LS word of trigger mask
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_ADDR_AP_CTRL,0x01); // Issue start, Start=1
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_ADDR_AP_CTRL,0x00); // Start=0
			// Setup the SMG
			Xil_Out32(XPAR_SMG_IO_SWITCH_BASEADDR,reg0);		// configure to either use NS [8:5] or external pin
			Xil_Out32(XPAR_SMG_IO_SWITCH_BASEADDR+4,reg1);		// configure to use external pins
			Xil_Out32(XPAR_SMG_IO_SWITCH_BASEADDR+8,reg2);		// configure output bits [3:0]
			Xil_Out32(XPAR_SMG_IO_SWITCH_BASEADDR+0xc,reg3);	// configure output bits [7:4]
			Xil_Out32(XPAR_SMG_IO_SWITCH_BASEADDR+0x10,reg4);	// configure output bits [11:8]
			Xil_Out32(XPAR_SMG_IO_SWITCH_BASEADDR+0x14,reg5);	// configure output bits [15:12]
			Xil_Out32(XPAR_SMG_IO_SWITCH_BASEADDR+0x18,reg6);	// configure output bits [19:16]
			Xil_Out32(XPAR_SMG_IO_SWITCH_BASEADDR+0x1c,direction);	// configure direction for all 20 header pins

			Xil_Out32(XPAR_SMG_BRAM_ENB_RSTB_BASEADDR,0x02);	 	// Enable=1, RST=0
			// issue start command to the PG
			Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x1);			// issue start pulse
			Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x0);			// issue start pulse
			while(XAxiDma_Busy(&AxiDma,XAXIDMA_DEVICE_TO_DMA));
            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
			MAILBOX_CMD_ADDR = 0x0;
			break;
		case SMG_STOP:
			Xil_Out32(XPAR_IOP3_FUNCTION_SEL_BASEADDR,0x02);		// function select to use SMG
			Xil_Out32(XPAR_SMG_BRAM_ENB_RSTB_BASEADDR,0x01);	 	// Enable=0, RST=1
			Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x4);		// issue stop pulse
			Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x0);		// issue stop pulse
            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
			MAILBOX_CMD_ADDR = 0x0;
			break;
		case TRACE_ONLY:
			traceptr = (u8 *)MAILBOX_DATA(0);						// DDR address where trace will be saved
			traceptr = (u8 *) ((u32) traceptr | 0x20000000);
			numofsamples = MAILBOX_DATA(1);
			// Reset Stream DMA controller
			XAxiDma_Reset(&AxiDma);
			// Wait for reset to complete
			while(!XAxiDma_ResetIsDone(&AxiDma));
			// Configure Stream DMA controller
			Status = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) traceptr, numofsamples*8,
					XAXIDMA_DEVICE_TO_DMA);
			if (Status != XST_SUCCESS) {
				MAILBOX_DATA(0) = 0xFFFF0009;						// return error code
				break;
			}
			// Setup the trace controller
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_LENGTH,numofsamples); // number of samples
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_DATA_COMPARE_MSW,0x00000); // MS word of trigger mask
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_DATA_COMPARE_LSW,0x00000); // LS word of trigger mask
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_ADDR_AP_CTRL,0x01); // Issue start, Start=1
			Xil_Out32(XPAR_TRACE_CNTRL_BASEADDR+TRACE_CNTRL_ADDR_AP_CTRL,0x00); // Start=0
			// issue start command to the PG
			Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x1);			// issue start pulse
			Xil_Out32(XPAR_GPIO_PG_TRI_CONTROL_BASEADDR+8,0x0);			// issue start pulse
			while(XAxiDma_Busy(&AxiDma,XAXIDMA_DEVICE_TO_DMA));
            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x1);
            Xil_Out32(XPAR_IOP3_IOP3_INTR_BASEADDR,0x0);
			MAILBOX_CMD_ADDR = 0x0;
			break;
		default:
			MAILBOX_CMD_ADDR = 0x0;
			break;
		}
	}
	return 0;
}



