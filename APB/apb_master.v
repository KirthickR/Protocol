module apb_master #(parameter DATA_WIDTH = 8)(
  input pclk,
  input rst,
  input read_write, // write=1  read =0
  input [DATA_WIDTH-1:0] write_paddr,
  input [DATA_WIDTH-1:0] write_pdata,
  input [DATA_WIDTH-1:0] read_paddr,
  input [DATA_WIDTH-1:0] prdata,
  input pready,

  output reg [DATA_WIDTH-1:0] read_data_out,
  output reg pwrite,
  output reg psel,
  output reg pen,
  output reg [DATA_WIDTH-1:0] paddr,
  output reg [DATA_WIDTH-1:0] pwdata
);

  parameter [1:0] IDLE = 2'b00;
  parameter [1:0] SETUP = 2'b01;
  parameter [1:0] ACCESS = 2'b10;

  reg [1:0] state, next_state;

  always @(posedge pclk or posedge rst) begin
    if (rst)
      state <= IDLE;
    else
      state <= next_state;
  end

  always @(*) begin
    next_state = state;
    case (state)
      IDLE: begin
        next_state = SETUP;
      end

      SETUP: begin
        next_state = ACCESS;
      end

      ACCESS: begin
        if (pready)
          next_state = IDLE;
      end
    endcase
  end

  always @(posedge pclk or posedge rst) begin
    if (rst) begin
      pwrite        <= 0;
      psel          <= 0;
      pen           <= 0;
      paddr         <= 0;
      pwdata        <= 0;
      read_data_out <= 0;
    end else begin
      case (next_state)
        IDLE: begin
          psel   <= 0;
          pen    <= 0;
          pwrite <= 0;
        end

        SETUP: begin
          psel <= 1;
          pen  <= 0;
          if (read_write) begin
            pwrite <= 1;
            paddr  <= write_paddr;
            pwdata <= write_pdata;
          end else begin
            pwrite <= 0;
            paddr  <= read_paddr;
          end
        end

        ACCESS: begin
          pen <= 1;
          if (!read_write && pready) begin
            read_data_out <= prdata;
          end
        end
      endcase
    end
  end

endmodule
