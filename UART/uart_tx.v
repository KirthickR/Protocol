module uart_tx #(
    parameter CLOCK_RATE = 10,  
    parameter BAUD_RATE  = 9600, 
    parameter RESET      = 3'b001, 
    parameter IDLE       = 3'b010,
    parameter START_BIT  = 3'b011, 
    parameter DATA_BIT   = 3'b100, 
    parameter STOP_BIT   = 3'b101  
)(
    input tx_clk,                 
    input tx_en,                
    input tx_start,               
    input [7:0] tx_in,            
    output reg tx_out,            
    output reg tx_done,           
    output reg tx_busy            
);

    reg [2:0] state;
    reg [7:0] data;
    reg [2:0] bitIdx;
    reg [3:0] clockCount;

    always @(posedge tx_clk) begin
        if (!tx_en) begin
            state <= RESET;
        end else begin
            case (state)
                RESET: begin
                    tx_out      <= 1'b0;       
                    tx_done     <= 1'b0;
                    tx_busy     <= 1'b0;
                    clockCount  <= 4'd0;
                    bitIdx      <= 3'd0;
                    state       <= IDLE;
                end

                IDLE: begin
                    tx_done <= 1'b0;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        data        <= tx_in;
                        bitIdx      <= 3'd0;
                        clockCount  <= 4'd0;
                        state       <= START_BIT;
                    end
                end

                START_BIT: begin
                    tx_out <= 1'b0; 
                    tx_busy <= 1'b1;
                    if (clockCount == 4'd15) begin
                        clockCount <= 4'd0;
                        state <= DATA_BIT;
                    end else begin
                        clockCount <= clockCount + 1;
                    end
                end

                DATA_BIT: begin
                    tx_out <= data[bitIdx];
                    if (clockCount == 4'd15) begin
                        clockCount <= 4'd0;
                        bitIdx <= bitIdx + 1;
                        if (bitIdx == 3'd7) begin
                            state <= STOP_BIT;
                        end
                    end else begin
                        clockCount <= clockCount + 1;
                    end
                end

                STOP_BIT: begin
                    tx_out <= 1'b1; 
                    if (clockCount == 4'd15) begin
                        tx_busy <= 1'b0;
                        tx_done <= 1'b1;
                        clockCount <= 4'd0;
                        state <= RESET;
                    end else begin
                        clockCount <= clockCount + 1;
                    end
                end

                default: state <= RESET;
            endcase
        end
    end

endmodule
