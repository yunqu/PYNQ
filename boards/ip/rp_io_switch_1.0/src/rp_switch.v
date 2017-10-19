`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: rp_switch
// Project Name: PYNQ
// Description: Raspberry Pi switch
//////////////////////////////////////////////////////////////////////////////////
module rp_switch(
// configuration
    input [31:0] gpio_sel0,     // configures Digital I/O bits 0 through 7
    input [31:0] gpio_sel1,     // configures Digital I/O bits 8 through 15
    input [31:0] gpio_sel2,     // configures Digital I/O bits 16 through 23
    input [31:0] gpio_sel3,     // configures Digital I/O bits 24 through 27
   
// Connector side
    // digital channels
    input [27:0] rp2sw_data_in,
    output [27:0] sw2rp_data_out,
    output [27:0] sw2rp_tri_out,
    
// PL Side
    // GPIO
	output [27:0] gpio_i_out,
    input [27:0] gpio_o_in,
    input [27:0] gpio_t_in,
	// UART on pins 8 (TxD) and 10 (RxD)
	output uart_rx_i_out,
    input uart_tx_o_in,
    input uart_tx_t_in, 
    // Interrupts from all 28 GPIO pins
    output [27:0] interrupt_i_out,
	// i2c0 on pins 27 (sda0, ID_SD) and 28 (scl0, ID_SC)
	output sda0_i,
	input sda0_o,
	input sda0_t,
	output scl0_i,
	input scl0_o,
	input scl0_t,
	// i2c on pins 3 (sda1) and 5 (scl1)
	output sda1_i,
	input sda1_o,
	input sda1_t,
	output scl1_i,
	input scl1_o,
	input scl1_t,
    // SPI0 on pins 19 (MOSI), 21 (MISO), 23 (SCK), 24 (SS0), and 26 (SS1)
    output sck0_i,
    input sck0_o,
    input sck0_t,
    output mosi0_i,
    input mosi0_o,
    input mosi0_t,
    output miso0_i,
    input miso0_o,
    input miso0_t,
    input [1:0] ss0_o,
    input ss0_t,
    // SPI1 on pins 38 (MOSI), 35 (MISO), 40 (SCK), 36 (SS1)
    output sck1_i,
    input sck1_o,
    input sck1_t,
    output mosi1_i,
    input mosi1_o,
    input mosi1_t,
    output miso1_i,
    input miso1_o,
    input miso1_t,
//  output ss1_i,
    input ss1_o,
    input ss1_t,
    // PWM
    input [1:0] pwm_o,
    input [1:0] pwm_t,
    // Timer
    output [2:0] timer_i, // Input capture
    input [2:0] timer_o,  // output compare
    input [2:0] timer_t       
    );

// gpio_sel0 controlled   
    rp_switch_bit d0(		// Pin 27 => GPIO[0] => connected to GPIO, I2C (SDA0, ID_SD), Interrupts
    // configuration
    .gpio_sel(gpio_sel0[3:0]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[0]), .rp_t_out(sw2rp_tri_out[0]), .rp_i_in(rp2sw_data_in[0]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[0]), .gpio_t_in(gpio_t_in[0]), .gpio_i_out(gpio_i_out[0]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[0]), // output interrupt
	.uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(sda0_o), .sda0_t_in(sda0_t), .sda0_i_out(sda0_i),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

    rp_switch_bit d1(		// Pin 28 => GPIO[1] => connected to GPIO, I2C (SCL0, ID_SC), Interrupts
    // configuration
    .gpio_sel(gpio_sel0[7:4]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[1]), .rp_t_out(sw2rp_tri_out[1]), .rp_i_in(rp2sw_data_in[1]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[1]), .gpio_t_in(gpio_t_in[1]), .gpio_i_out(gpio_i_out[1]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[1]), // output interrupt
	.uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(scl0_o), .scl0_t_in(scl0_t), .scl0_i_out(scl0_i),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

    rp_switch_bit d2(		// Pin 3 => GPIO[2] => connected to GPIO, I2C (SDA1), Interrupts
    // configuration
    .gpio_sel(gpio_sel0[11:8]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[2]), .rp_t_out(sw2rp_tri_out[2]), .rp_i_in(rp2sw_data_in[2]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[2]), .gpio_t_in(gpio_t_in[2]), .gpio_i_out(gpio_i_out[2]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[2]), // output interrupt
	.uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output 
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(sda1_o), .sda1_t_in(sda1_t), .sda1_i_out(sda1_i),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

    rp_switch_bit d3(		// Pin 5 => GPIO[3] => connected to GPIO, I2C (SCL1), Interrupts
    // configuration
    .gpio_sel(gpio_sel0[15:12]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[3]), .rp_t_out(sw2rp_tri_out[3]), .rp_i_in(rp2sw_data_in[3]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[3]), .gpio_t_in(gpio_t_in[3]), .gpio_i_out(gpio_i_out[3]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[3]), // output interrupt
	.uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output 
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(scl1_o), .scl1_t_in(scl1_t), .scl1_i_out(scl1_i)  // input, input, output
    );

    rp_switch_bit d4(		// Pin 7 => GPIO[4] => connected to GPIO, GCLK0, Interrupts
    // configuration
    .gpio_sel(gpio_sel0[19:16]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[4]), .rp_t_out(sw2rp_tri_out[4]), .rp_i_in(rp2sw_data_in[4]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[4]), .gpio_t_in(gpio_t_in[4]), .gpio_i_out(gpio_i_out[4]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[4]), // output interrupt
	.uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(timer_o[0]), .timer_t_in(timer_t[0]), .timer_i_out(timer_i[0]), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

    rp_switch_bit d5(		// Pin 29 => GPIO[5] => connected to GPIO, GCLK1, Interrupts
    // configuration
    .gpio_sel(gpio_sel0[23:20]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[5]), .rp_t_out(sw2rp_tri_out[5]), .rp_i_in(rp2sw_data_in[5]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[5]), .gpio_t_in(gpio_t_in[5]), .gpio_i_out(gpio_i_out[5]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[5]), // output interrupt
	.uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(timer_o[1]), .timer_t_in(timer_t[1]), .timer_i_out(timer_i[1]), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );
 
     rp_switch_bit d6(		// Pin 31 => GPIO[6] => connected to GPIO, GCLK2, Interrupts
    // configuration
    .gpio_sel(gpio_sel0[27:24]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[6]), .rp_t_out(sw2rp_tri_out[6]), .rp_i_in(rp2sw_data_in[6]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[6]), .gpio_t_in(gpio_t_in[6]), .gpio_i_out(gpio_i_out[6]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[6]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(timer_o[2]), .timer_t_in(timer_t[2]), .timer_i_out(timer_i[2]), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

     rp_switch_bit d7(		// Pin 26 => GPIO[7] => connected to GPIO, SPI0_CE1, Interrupts
    // configuration
    .gpio_sel(gpio_sel0[31:28]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[7]), .rp_t_out(sw2rp_tri_out[7]), .rp_i_in(rp2sw_data_in[7]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[7]), .gpio_t_in(gpio_t_in[7]), .gpio_i_out(gpio_i_out[7]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[7]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(ss0_o[1]), .ss_t_in(ss0_t), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(), // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(), // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(), // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

// gpio_sel1 controlled   
    rp_switch_bit d8(		// Pin 24 => GPIO[8] => connected to GPIO, SPI0_CE0, Interrupts
    // configuration
    .gpio_sel(gpio_sel1[3:0]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[8]), .rp_t_out(sw2rp_tri_out[8]), .rp_i_in(rp2sw_data_in[8]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[8]), .gpio_t_in(gpio_t_in[8]), .gpio_i_out(gpio_i_out[8]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[8]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(ss0_o[0]), .ss_t_in(ss0_t), .ss_i_out(),  // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(), // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(), // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(), // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

    rp_switch_bit d9(		// Pin 21 => GPIO[9] => connected to GPIO, MISO0, Interrupts
    // configuration
    .gpio_sel(gpio_sel1[7:4]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[9]), .rp_t_out(sw2rp_tri_out[9]), .rp_i_in(rp2sw_data_in[9]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[9]), .gpio_t_in(gpio_t_in[9]), .gpio_i_out(gpio_i_out[9]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[9]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output 
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(miso0_o), .miso_t_in(miso0_t), .miso_i_out(miso0_i), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );
   
    rp_switch_bit d10(		// Pin 19 => GPIO[10] => connected to GPIO, MOSI0, Interrupts
    // configuration
   .gpio_sel(gpio_sel1[11:8]),
   // RaspberryPi connector side
   .rp_o_out(sw2rp_data_out[10]), .rp_t_out(sw2rp_tri_out[10]), .rp_i_in(rp2sw_data_in[10]), // output, output, input
   // PL side
   .gpio_o_in(gpio_o_in[10]), .gpio_t_in(gpio_t_in[10]), .gpio_i_out(gpio_i_out[10]), // input, input, output GPIO
   .interrupt_i_out(interrupt_i_out[10]), // output interrupt
   .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
   .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
   .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output 
   .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
   .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
   .mosi_o_in(mosi0_o), .mosi_t_in(mosi0_t), .mosi_i_out(mosi0_i), // input, input, output 
   .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
   .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
   .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
   .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
   .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
   );

    rp_switch_bit d11(		// Pin 23 => GPIO[11] => connected to GPIO, SCLK0, Interrupts
    // configuration
   .gpio_sel(gpio_sel1[15:12]),
   // RaspberryPi connector side
   .rp_o_out(sw2rp_data_out[11]), .rp_t_out(sw2rp_tri_out[11]), .rp_i_in(rp2sw_data_in[11]), // output, output, input
   // PL side
   .gpio_o_in(gpio_o_in[11]), .gpio_t_in(gpio_t_in[11]), .gpio_i_out(gpio_i_out[11]), // input, input, output GPIO
   .interrupt_i_out(interrupt_i_out[11]), // output interrupt
   .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
   .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
   .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
   .spick_o_in(sck0_o), .spick_t_in(sck0_t), .spick_i_out(sck0_i), // input, input, output 
   .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
   .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
   .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
   .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
   .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
   .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
   .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
   );

    rp_switch_bit d12(		// Pin 32 => GPIO[12] => connected to GPIO, PWM0, Interrupts
    // configuration
   .gpio_sel(gpio_sel1[19:16]),
   // RaspberryPi connector side
   .rp_o_out(sw2rp_data_out[12]), .rp_t_out(sw2rp_tri_out[12]), .rp_i_in(rp2sw_data_in[12]), // output, output, input
   // PL side
   .gpio_o_in(gpio_o_in[12]), .gpio_t_in(gpio_t_in[12]), .gpio_i_out(gpio_i_out[12]), // input, input, output GPIO
   .interrupt_i_out(interrupt_i_out[12]), // output interrupt
   .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
   .pwm_o_in(pwm_o[0]), .pwm_t_in(pwm_t[0]), // input, input PWM
   .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
   .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
   .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
   .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
   .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
   .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
   .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
   .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
   .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
   );

   rp_switch_bit d13(		// Pin 33 => GPIO[13] => connected to GPIO, PWM1, Interrupts
    // configuration
   .gpio_sel(gpio_sel1[23:20]),
   // RaspberryPi connector side
   .rp_o_out(sw2rp_data_out[13]), .rp_t_out(sw2rp_tri_out[13]), .rp_i_in(rp2sw_data_in[13]), // output, output, input
   // PL side
   .gpio_o_in(gpio_o_in[13]), .gpio_t_in(gpio_t_in[13]), .gpio_i_out(gpio_i_out[13]), // input, input, output GPIO
   .interrupt_i_out(interrupt_i_out[13]), // output interrupt
   .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
   .pwm_o_in(pwm_o[1]), .pwm_t_in(pwm_t[1]), // input, input PWM
   .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
   .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
   .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
   .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
   .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
   .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
   .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
   .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
   .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
   );

    rp_switch_bit d14(		// Pin 8 => GPIO[14] => connected to GPIO, TXD, Interrupts
    // configuration
   .gpio_sel(gpio_sel1[27:24]),
   // RaspberryPi connector side
   .rp_o_out(sw2rp_data_out[14]), .rp_t_out(sw2rp_tri_out[14]), .rp_i_in(rp2sw_data_in[14]), // output, output, input
   // PL side
   .gpio_o_in(gpio_o_in[14]), .gpio_t_in(gpio_t_in[14]), .gpio_i_out(gpio_i_out[14]), // input, input, output GPIO
   .interrupt_i_out(interrupt_i_out[14]), // output interrupt
   .uart_tx_o_in(uart_tx_o_in), .uart_tx_t_in(uart_tx_t_in), .uart_rx_i_out(), // input, input, output 
   .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
   .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output 
   .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
   .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
   .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
   .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
   .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
   .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
   .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
   .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
   );

    rp_switch_bit d15(		// Pin 10 => GPIO[15] => connected to GPIO, RXD, Interrupts
    // configuration
   .gpio_sel(gpio_sel1[31:28]),
   // RaspberryPi connector side
   .rp_o_out(sw2rp_data_out[15]), .rp_t_out(sw2rp_tri_out[15]), .rp_i_in(rp2sw_data_in[15]), // output, output, input
   // PL side
   .gpio_o_in(gpio_o_in[15]), .gpio_t_in(gpio_t_in[15]), .gpio_i_out(gpio_i_out[15]), // input, input, output GPIO
   .interrupt_i_out(interrupt_i_out[15]), // output interrupt
   .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(uart_rx_i_out), // input, input, output 
   .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
   .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
   .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
   .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
   .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
   .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
   .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
   .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
   .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
   .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
   );

// gpio_sel2 controlled   
    rp_switch_bit d16(		// Pin 36 => GPIO[16] => connected to GPIO, SPI1_CE2, Interrupts
    // configuration
    .gpio_sel(gpio_sel2[3:0]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[16]), .rp_t_out(sw2rp_tri_out[16]), .rp_i_in(rp2sw_data_in[16]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[16]), .gpio_t_in(gpio_t_in[16]), .gpio_i_out(gpio_i_out[16]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[16]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(ss1_o), .ss_t_in(ss1_t), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

    rp_switch_bit d17(		// Pin 11 => GPIO[17] => connected to GPIO, Interrupts
    // configuration
    .gpio_sel(gpio_sel2[7:4]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[17]), .rp_t_out(sw2rp_tri_out[17]), .rp_i_in(rp2sw_data_in[17]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[17]), .gpio_t_in(gpio_t_in[17]), .gpio_i_out(gpio_i_out[17]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[17]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

    rp_switch_bit d18(		// Pin 12 => GPIO[18] => connected to GPIO, Interrupts
    // configuration
    .gpio_sel(gpio_sel2[11:8]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[18]), .rp_t_out(sw2rp_tri_out[18]), .rp_i_in(rp2sw_data_in[18]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[18]), .gpio_t_in(gpio_t_in[18]), .gpio_i_out(gpio_i_out[18]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[18]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

    rp_switch_bit d19(		// Pin 35 => GPIO[19] => connected to GPIO, MISO1, Interrupts
    // configuration
    .gpio_sel(gpio_sel2[15:12]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[19]), .rp_t_out(sw2rp_tri_out[19]), .rp_i_in(rp2sw_data_in[19]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[19]), .gpio_t_in(gpio_t_in[19]), .gpio_i_out(gpio_i_out[19]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[19]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(miso1_o), .miso_t_in(miso1_t), .miso_i_out(miso1_i), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

    rp_switch_bit d20(		// Pin 38 => GPIO[20] => connected to GPIO, MOSI1, Interrupts
    // configuration
    .gpio_sel(gpio_sel2[19:16]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[20]), .rp_t_out(sw2rp_tri_out[20]), .rp_i_in(rp2sw_data_in[20]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[20]), .gpio_t_in(gpio_t_in[20]), .gpio_i_out(gpio_i_out[20]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[20]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(mosi1_o), .mosi_t_in(mosi1_t), .mosi_i_out(mosi1_i), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

    rp_switch_bit d21(		// Pin 40 => GPIO[21] => connected to GPIO, SPI1_SCLK, Interrupts
    // configuration
    .gpio_sel(gpio_sel2[23:20]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[21]), .rp_t_out(sw2rp_tri_out[21]), .rp_i_in(rp2sw_data_in[21]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[21]), .gpio_t_in(gpio_t_in[21]), .gpio_i_out(gpio_i_out[21]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[21]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(sck1_o), .spick_t_in(sck1_t), .spick_i_out(sck1_i), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

    rp_switch_bit d22(		// Pin 15 => GPIO[22] => connected to GPIO, Interrupts
    // configuration
    .gpio_sel(gpio_sel2[27:24]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[22]), .rp_t_out(sw2rp_tri_out[22]), .rp_i_in(rp2sw_data_in[22]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[22]), .gpio_t_in(gpio_t_in[22]), .gpio_i_out(gpio_i_out[22]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[22]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(pwm_o[0]), .pwm_t_in(pwm_t[0]), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

    rp_switch_bit d23(		// Pin 16 => GPIO[23] => connected to GPIO, Interrupts
    // configuration
    .gpio_sel(gpio_sel2[31:28]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[23]), .rp_t_out(sw2rp_tri_out[23]), .rp_i_in(rp2sw_data_in[23]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[23]), .gpio_t_in(gpio_t_in[23]), .gpio_i_out(gpio_i_out[23]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[23]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );
    
// gpio_sel3 controlled    
    rp_switch_bit d24(		// Pin 18 => GPIO[24] => connected to GPIO, Interrupts
    // configuration
    .gpio_sel(gpio_sel3[3:0]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[24]), .rp_t_out(sw2rp_tri_out[24]), .rp_i_in(rp2sw_data_in[24]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[24]), .gpio_t_in(gpio_t_in[24]), .gpio_i_out(gpio_i_out[24]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[24]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );
   
    rp_switch_bit d25(		// Pin 22 => GPIO[25] => connected to GPIO, Interrupts
    // configuration
    .gpio_sel(gpio_sel3[7:4]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[25]), .rp_t_out(sw2rp_tri_out[25]), .rp_i_in(rp2sw_data_in[25]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[25]), .gpio_t_in(gpio_t_in[25]), .gpio_i_out(gpio_i_out[25]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[25]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );

// gpio_sel3 controlled    
    rp_switch_bit d26(		// Pin 37 => GPIO[26] => connected to GPIO, Interrupts
    // configuration
    .gpio_sel(gpio_sel3[11:8]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[26]), .rp_t_out(sw2rp_tri_out[26]), .rp_i_in(rp2sw_data_in[26]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[26]), .gpio_t_in(gpio_t_in[26]), .gpio_i_out(gpio_i_out[26]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[26]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );
   
    rp_switch_bit d27(		// Pin 13 => GPIO[27] => connected to GPIO, Interrupts
    // configuration
    .gpio_sel(gpio_sel3[15:12]),
    // RaspberryPi connector side
    .rp_o_out(sw2rp_data_out[27]), .rp_t_out(sw2rp_tri_out[27]), .rp_i_in(rp2sw_data_in[27]), // output, output, input
    // PL side
    .gpio_o_in(gpio_o_in[27]), .gpio_t_in(gpio_t_in[27]), .gpio_i_out(gpio_i_out[27]), // input, input, output GPIO
    .interrupt_i_out(interrupt_i_out[27]), // output interrupt
    .uart_tx_o_in(1'b0), .uart_tx_t_in(1'b0), .uart_rx_i_out(), // input, input, output 
    .pwm_o_in(1'b0), .pwm_t_in(1'b0), // input, input PWM
    .timer_o_in(1'b0), .timer_t_in(1'b0), .timer_i_out(), // input, input, output : Timer Output Compare, Input Capture
    .spick_o_in(1'b0), .spick_t_in(1'b0), .spick_i_out(), // input, input, output 
    .miso_o_in(1'b0), .miso_t_in(1'b0), .miso_i_out(), // input, input, output 
    .mosi_o_in(1'b0), .mosi_t_in(1'b0), .mosi_i_out(), // input, input, output 
    .ss_o_in(1'b0), .ss_t_in(1'b0), .ss_i_out(), // input, input, output 
    .sda0_o_in(1'b0), .sda0_t_in(1'b0), .sda0_i_out(),  // input, input, output
    .scl0_o_in(1'b0), .scl0_t_in(1'b0), .scl0_i_out(),  // input, input, output
    .sda1_o_in(1'b0), .sda1_t_in(1'b0), .sda1_i_out(),  // input, input, output
    .scl1_o_in(1'b0), .scl1_t_in(1'b0), .scl1_i_out()  // input, input, output
    );
	
endmodule
