module uart_rx #(
    parameter CLOCK_RATE = 5, 
    parameter BAUD_RATE  = 100,
    parameter RESET     = 3'b000,
    parameter IDLE      = 3'b001,
    parameter START_BIT = 3'b010,
    parameter DATA_BIT  = 3'b011,
    parameter STOP_BIT  = 3'b100

)(
    input rx_clk,                
    input rx_en,                 
    input rx_in,                 
    input rx_start,              
  output reg [7:0] rx_out,     
    output reg rx_done,           
    output reg rx_busy,          
    output reg rx_err            
);

   
    reg [2:0] state;
    reg [7:0] data;
    reg [2:0] bitIdx;
    reg [3:0] clockCount;      

  
   
  always @(posedge rx_clk) begin
    $display("data=%b",data);
    if (!rx_en) begin
            state <= RESET;  
        end else begin
            case (state)
                RESET: begin
                    rx_out        <= 8'b0;
                    rx_done       <= 1'b0;
                    rx_busy       <= 1'b0;
                    rx_err        <= 1'b0;
                    data       <= 8'b0;
                    bitIdx     <= 3'b0;
                    clockCount <= 4'b0;
                    state      <= IDLE;
                end

                IDLE: begin
                    rx_done <= 1'b0;
                    rx_err  <= 1'b0;
                  if (rx_start && !rx_in) begin  
                        rx_busy       <= 1'b1;
                        clockCount <= 4'b0;  
                        state      <= START_BIT;
                    end
                end

                START_BIT: begin
                    if (clockCount == 4'b1111) begin  
                      if (!rx_in) begin  
                            clockCount <= 4'b0;
                            bitIdx     <= 3'b0;
                            state      <= DATA_BIT;
                        end else begin
                            rx_err   <= 1'b1; 
                            state <= RESET;
                        end
                    end else begin
                        clockCount <= clockCount + 1;
                    end
                end

                DATA_BIT: begin
                    if (clockCount == 4'b1111) begin  
                      data[bitIdx] <= rx_in;  
                        bitIdx        <= bitIdx + 1;
                        clockCount    <= 4'b0;
                        if (bitIdx == 3'b111) begin  
                            state <= STOP_BIT;
                        end
                    end else begin
                        clockCount <= clockCount + 1;
                    end
                end

                STOP_BIT: begin
                    if (clockCount == 4'b1111) begin  
                      if (rx_in) begin 
                            rx_out   <= data;
                            rx_done  <= 1'b1;  
                            rx_busy  <= 1'b0;  
                            state <= IDLE;
                        end else begin
                            rx_err   <= 1'b1;  
                            state <= RESET;
                        end
                        clockCount <= 4'b0;
                    end else begin
                        clockCount <= clockCount + 1;
                    end
                end

                default: state <= RESET;
            endcase
        end
    end

endmodule
