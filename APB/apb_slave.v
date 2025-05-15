module apb_slave #(parameter DATA_WIDTH = 8)(
input pclk,
input psel,
input pen,
  input pwrite,
  input [DATA_WIDTH-1:0] paddr,
  input [DATA_WIDTH-1:0] pwdata,
  
  output reg [DATA_WIDTH-1:0] prdata,
output reg pready);
  
  reg [DATA_WIDTH-1:0] memory [0:255];
  
  always@(posedge pclk)begin
    
    pready <= 0;
    
    if(psel && pen)begin
      pready <= 1;
      
        if (pwrite) begin
        memory[paddr] <= pwdata;
      end else begin
        prdata <= memory[paddr];
      end
    end
  end

endmodule
