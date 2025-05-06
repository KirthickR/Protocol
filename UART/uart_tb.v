`include "uart_tx.sv"
`include "uart_rx.sv"
`timescale 1ns / 1ps

module uart_tx_rx_tb;

  reg clk;
  reg tx_en, rx_en;
  reg tx_start;
  reg [7:0] tx_in;
  wire tx_out, tx_done, tx_busy;

  wire rx_in;

  wire [7:0] rx_out;
  wire rx_done, rx_busy, rx_err;
  reg rx_start;

  uart_tx tx_inst (
    .tx_clk(clk),
    .tx_en(tx_en),
    .tx_start(tx_start),
    .tx_in(tx_in),
    .tx_out(tx_out),
    .tx_done(tx_done),
    .tx_busy(tx_busy)
  );

  uart_rx rx_inst (
    .rx_clk(clk),
    .rx_en(rx_en),
    .rx_in(tx_out),
    .rx_start(rx_start),
    .rx_out(rx_out),
    .rx_done(rx_done),
    .rx_busy(rx_busy),
    .rx_err(rx_err)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $dumpfile("uart.vcd");
    $dumpvars(0, uart_tx_rx_tb);
  end

  initial begin
    tx_en = 0;
    rx_en = 0;
    tx_start = 0;
    rx_start = 0;
    tx_in = 8'h00;

    #50;
    tx_en = 1;
    rx_en = 1;
    tx_in = 8'b10101010; 
    tx_start = 1;
    rx_start = 1;
    #20;
    tx_start = 0;
    rx_start = 0;

    wait (tx_done);
    $display("TX Done.");

    wait (rx_done);
    $display("RX Done. Data Received: %b", rx_out);

    if (rx_out == 8'b10101010)
      $display("Test PASSED");
    else
      $display("Test FAILED");

    #100;
    $finish;
  end

endmodule
