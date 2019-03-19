////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 耿慧��?
//
// Description
// Synchronous AXI-stream FIFO.
//
// Signals
// enable  :  N/A
// reset   :  active-high
// latency :  multiple
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module axis_fifo #(

  // parameters

  parameter   DATA_WIDTH = 8,
  parameter   FIFO_DEPTH = 16,

  // derived parameters

  localparam  ADDR_WIDTH = log2(FIFO_DEPTH - 1),

  // bit width parameters

  localparam  WD = DATA_WIDTH - 1,
  localparam  DF = FIFO_DEPTH - 1,
  localparam  WA = ADDR_WIDTH - 1

 ) (

  // core interface

  input             clk,
  input             ena,
  input             rst,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ WD:0]   s_axis_tdata,

  // master interace

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ WD:0]   m_axis_tdata

 );

  `include "func_log2.vh"

  // internal memories

  reg     [ WD:0]   mem  [0:DF];

  // internal registers

  reg               wr_flag = 1'b0; // Flag write pointer to point to the top.
  reg               rd_flag = 1'b0; // Flag read pointer to point to the top.
  reg     [ WD:0]   fifo_dout = 'b0;
  reg               fifo_valid = 1'b0;
  reg               fifo_full = 1'b0;
  reg               fifo_empty = 1'b1;
  reg     [ WD:0]   fifo_reg = 'b0;

  // internal signals

  wire              fifo_write;
  wire              fifo_read;
  wire    [ WD:0]   fifo_din;
  wire    [ WA:0]   wr_addr;
  wire    [ WA:0]   rd_addr;

  // fifo glue logic

  assign fifo_write = s_axis_tvalid & s_axis_tready;
  assign fifo_din = s_axis_tdata;
  assign fifo_read = (~m_axis_tvalid | (m_axis_tvalid & m_axis_tready)) & !fifo_empty;
  assign m_axis_tvalid = fifo_valid;
  assign m_axis_tdata = fifo_dout;

  /*
   *FIFO_DEPTH == 1,does not use the address pointer,
   * can simplify the logic.Others must use an address
   * pointer to identify the location of the read and write.
  */

  genvar n;
  generate
  if (FIFO_DEPTH == 1) begin

    always @(posedge clk) begin
      if (rst) begin
        fifo_reg <= 'b0;
      end else if (ena & fifo_write) begin
        fifo_reg <= fifo_din;
      end else begin
        fifo_reg <= fifo_reg;
      end
    end

    always @(posedge clk) begin
      if (rst) begin
        fifo_empty <= 1'b1;
      end else if (ena & (!fifo_empty | fifo_write) & !fifo_read) begin
        fifo_empty <= 1'b0;
      end else begin
        fifo_empty <= 1'b1;
      end
    end

    assign s_axis_tready = fifo_empty;

    always @(posedge clk) begin
      if (rst) begin
        fifo_dout <= 'b0;
        fifo_valid <= 1'b0;
      end else if (ena & fifo_read) begin
        fifo_dout <= fifo_reg;
        fifo_valid <= 1'b1;
      end else begin
        fifo_dout <= 'b0;
        fifo_valid <= fifo_valid;
      end
    end

  end else begin

    // slave interface

    assign s_axis_tready = ~fifo_full;

    always @(posedge clk) begin
      if (~m_axis_tvalid | (m_axis_tvalid & m_axis_tready)) begin
        fifo_valid <= ~fifo_empty;
      end else begin
        fifo_valid <= fifo_valid;
      end
    end

    /* Write pointer
     * Always points to the next unit to be written
     * when reset, points to the first unit.
     */

    counter #(
      .LOWER (0),
      .UPPER (DF),
      .WRAPAROUND (1),
      .INIT_VALUE (0)
    ) counter_wr_addr (
      .clk (clk),
      .rst (rst),
      .ena (ena & fifo_write),
      .value (wr_addr)
    );

    // Write flag logic

    always @(posedge clk) begin
      if (rst) begin
        wr_flag <= 1'b0;
      end else if (wr_addr == DF & fifo_write) begin
        wr_flag <= wr_flag + 1'b1;
      end else begin
        wr_flag <= wr_flag;
      end
    end

    /* Write to fifo
     * No data is written at reset.
     */

    always @(posedge clk) begin
      if (rst) begin
        mem[wr_addr] <= 'b0;
      end else if (ena & fifo_write) begin
        mem[wr_addr] <= fifo_din;
      end else begin
        mem[wr_addr] <= mem[wr_addr];
      end
    end

    /* Read pointer
     * Always points to the next unit to be read
     * when reset, points to the first unit
     */

    counter #(
      .LOWER (0),
      .UPPER (DF),
      .WRAPAROUND (1),
      .INIT_VALUE (0)
    ) counter_rd_addr (
      .clk (clk),
      .rst (rst),
      .ena (ena & fifo_read),
      .value (rd_addr)
    );

    // Read flag logic

    always @(posedge clk) begin
      if (rst) begin
        rd_flag <= 1'b0;
      end else if (rd_addr == DF & fifo_read) begin
        rd_flag <= rd_flag + 1'b1;
      end else begin
        rd_flag <= rd_flag;
      end
    end

    /* Read from fifo
     * Readout is 0 when the reset or fifo status is empty
     */

    always @(posedge clk) begin
      if (rst | fifo_empty) begin
        fifo_dout <= 'b0;
      end else if (ena & fifo_read) begin
        fifo_dout <= mem[rd_addr];
      end else begin
        fifo_dout <= 'b0;
      end
    end

    /* fifo status
     * When the read pointer and the write pointer are
     * the same, if the two pointer flags are different,
     * it means that the write pointer is folded back
     * more than the read pointer and is full.
     * if the two pointer flags are the same,it
     * means that the two pointers are folded back
     * the same number of times and are empty.
     */
     always @* begin
       if ((wr_addr == rd_addr) & (rd_flag == !wr_flag)) begin
         fifo_full = 1'b1;
       end else begin
         fifo_full = 1'b0;
       end
     end

     always @* begin
        if ((wr_addr == rd_addr) & (rd_flag == wr_flag)) begin
          fifo_empty = 1'b1;
        end else begin
          fifo_empty = 1'b0;
        end
      end
    end

  endgenerate
endmodule
