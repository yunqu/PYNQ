`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////
// gpio_sel[3:0] 
//          0000 = GPIO
//          0001 = Interrupt In
//          0010 = PWM (output only)
//          0011 = Output Compare/GCLK (output) 
//          0100 = SPICK (output ony)
//          0101 = MISO (input only)
//          0110 = MOSI (output only)
//          0111 = SS (output only)
//			1000 = UART
//          1001 = I2C SDA0
//          1010 = I2C SCL0
//          1011 = I2C SDA1
//          1100 = I2C SCL1
//          1101 = Input Capture (input)
//          rest for future expansion

module rp_switch_bit(
// configuration
    input [3:0] gpio_sel,
// connector side
    input rp_i_in,
    output reg rp_o_out,
    output reg rp_t_out,
// PL side
    // digital I/O
    output gpio_i_out,
    input gpio_o_in,
    input gpio_t_in,
    // UART 
    output uart_rx_i_out,
    input uart_tx_o_in,
    input uart_tx_t_in,
    // SPI
    output  spick_i_out,
    input  spick_o_in,
    input  spick_t_in,
    output  miso_i_out,
    input  miso_o_in,
    input  miso_t_in,
    output  mosi_i_out,
    input  mosi_o_in,
    input  mosi_t_in,
    output  ss_i_out,
    input  ss_o_in,
    input  ss_t_in,
    // Interrupts
    output interrupt_i_out,
    // i2c on pins 27 (sda0, ID_SD) and 28 (scl0, ID_SC)
    output sda0_i_out,
    input sda0_o_in,
    input sda0_t_in,
    output scl0_i_out,
    input scl0_o_in,
    input scl0_t_in,
    // i2c on pins 3 (sda1) and 5 (scl1)
    output sda1_i_out,
    input sda1_o_in,
    input sda1_t_in,
    output scl1_i_out,
    input scl1_o_in,
    input scl1_t_in,
    // PWM
    input  pwm_o_in,
    input  pwm_t_in,
    // Timer
    output  timer_i_out, // Input capture
    input  timer_o_in,  // output compare
    input  timer_t_in
    );

    reg [11:0] tri_i_out_demux;
    assign {scl1_i_out, sda1_i_out, scl0_i_out, sda0_i_out, uart_rx_i_out,ss_i_out,mosi_i_out,miso_i_out,spick_i_out,timer_i_out,interrupt_i_out,gpio_i_out} = tri_i_out_demux;

    always @(gpio_sel, uart_tx_o_in, sda1_o_in, scl1_o_in, sda0_o_in, scl0_o_in, gpio_o_in, pwm_o_in, timer_o_in, spick_o_in, miso_o_in, mosi_o_in, ss_o_in)
       case (gpio_sel)
          4'h0: rp_o_out = gpio_o_in;
          4'h1: rp_o_out = 1'b0;       // interrupt is input only 
          4'h2: rp_o_out = pwm_o_in;
          4'h3: rp_o_out = timer_o_in;
          4'h4: rp_o_out = spick_o_in;
          4'h5: rp_o_out = miso_o_in;
          4'h6: rp_o_out = mosi_o_in;
          4'h7: rp_o_out = ss_o_in;
		  4'h8: rp_o_out = uart_tx_o_in;
		  4'h9: rp_o_out = sda0_o_in;
		  4'ha: rp_o_out = scl0_o_in;
		  4'hb: rp_o_out = sda1_o_in;
		  4'hc: rp_o_out = scl1_o_in;
          default: rp_o_out = gpio_o_in;
       endcase

    always @(gpio_sel, rp_i_in)
    begin
       tri_i_out_demux = {12{1'b0}};
       case (gpio_sel)
          4'h0: tri_i_out_demux[0] = rp_i_in;
          4'h1: tri_i_out_demux[1] = rp_i_in;
 //         4'h2: tri_i_out_demux[2] = rp_i_in;   // PWMx is output only hence not fed back to PL
 //         4'h3: tri_i_out_demux[2] = rp_i_in;   // not used to input
          4'h4: tri_i_out_demux[3] = rp_i_in;
          4'h5: tri_i_out_demux[4] = rp_i_in;
          4'h6: tri_i_out_demux[5] = rp_i_in;
          4'h7: tri_i_out_demux[6] = rp_i_in;
		  4'h8: tri_i_out_demux[7] = rp_i_in;
          4'h9: tri_i_out_demux[8] = rp_i_in;
          4'ha: tri_i_out_demux[9] = rp_i_in;
          4'hb: tri_i_out_demux[10] = rp_i_in;
          4'hc: tri_i_out_demux[11] = rp_i_in;
          4'hd: tri_i_out_demux[2] = rp_i_in;	// input capture when gpio_sel=4'hd
          default: tri_i_out_demux[0] = rp_i_in;
       endcase
    end

    always @(gpio_sel, uart_tx_t_in, sda1_t_in, scl1_t_in, sda0_t_in, scl0_t_in, gpio_t_in, pwm_t_in, timer_t_in, spick_t_in, miso_t_in, mosi_t_in, ss_t_in)
       case (gpio_sel)
          4'h0: rp_t_out = gpio_t_in;
          4'h1: rp_t_out = 1'b1;   // interrupt is input only so tristate it
          4'h2: rp_t_out = pwm_t_in;
          4'h3: rp_t_out = timer_t_in;
          4'h4: rp_t_out = spick_t_in;
          4'h5: rp_t_out = miso_t_in;
          4'h6: rp_t_out = mosi_t_in;
          4'h7: rp_t_out = ss_t_in;
		  4'h8: rp_t_out = uart_tx_t_in;
		  4'h9: rp_t_out = sda0_t_in;
		  4'ha: rp_t_out = scl0_t_in;
		  4'hb: rp_t_out = sda1_t_in;
		  4'hc: rp_t_out = scl1_t_in;
          default: rp_t_out = gpio_t_in;
       endcase
    
endmodule
