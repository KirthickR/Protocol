`timescale 1ns/1ps

`include "apb_master.v"
`include "apb_slave.v"

module apb_tb;
  parameter DATA_WIDTH = 8;  

  reg pclk;
  reg rst;
  
  // Master inputs
  reg read_write;
  reg [DATA_WIDTH-1:0] write_paddr;
  reg [DATA_WIDTH-1:0] write_pdata;
  reg [DATA_WIDTH-1:0] read_paddr;
  
  wire  pready;
  wire [DATA_WIDTH-1:0] prdata;
  wire [DATA_WIDTH-1:0] paddr;
  wire [DATA_WIDTH-1:0] pwdata;
  wire psel;
  wire pen;
  wire pwrite;

  apb_master #(DATA_WIDTH) master (
    .pclk(pclk),
    .rst(rst),
    .read_write(read_write),
    .write_paddr(write_paddr),
    .write_pdata(write_pdata),
    .read_paddr(read_paddr),
    .pready(pready),
    .pwrite(pwrite),
    .psel(psel),
    .pen(pen),
    .paddr(paddr),
    .pwdata(pwdata),
    .prdata(prdata)
  );

  apb_slave #(DATA_WIDTH) slave (
    .pclk(pclk),
    .psel(psel),
    .pen(pen),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready)
  );

  initial begin
    $dumpfile("waves.vcd");
    $dumpvars();
  end

  always #5 pclk = ~pclk;

  initial begin
    pclk = 0;
    rst  = 1; 
    read_write = 0;
    write_paddr = 8'b10011001;
    write_pdata = 8'b11001100;
    read_paddr  = 8'b10011001;

    #10;
    rst = 0;

    read_write = 1;
    #60;

    read_write = 0;
    #200;

    $finish;
  end
endmodule
