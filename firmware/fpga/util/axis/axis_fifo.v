////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 耿慧慧
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
  parameter   FULL_THRESH = FIFO_DEPTH - 2,
  parameter   EMPTY_THRESH = 2,

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

  // status signals

  output            full,
  output            empty,

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
  reg               mem_full = 1'b0;
  reg               mem_empty = 1'b1;

  reg     [ WD:0]   mem_dout = 'b0;
  reg               mem_valid = 1'b0;

  reg               m_axis_tvalid_reg = 1'b0;
  reg     [ WD:0]   m_axis_tdata_reg = 'b0;

  reg     [ WA:0]   count = 'b0;

  // internal signals

  wire              m_axis_frame;

  wire              wr_ena;
  wire              rd_ena;
  wire              wr_max;
  wire              rd_max;
  wire    [ WA:0]   wr_addr;
  wire    [ WA:0]   rd_addr;

  /* Slave interface.
   */

  assign s_axis_tready = ~mem_full;

  /* FIFO glue logic.
   */

  assign wr_ena = s_axis_tvalid & s_axis_tready;
  assign rd_ena = (~m_axis_tvalid | m_axis_frame) & !mem_empty;

  /*
   * FIFO_DEPTH == 1,does not use the address pointer, can simplify the logic.
   * Others must use an address pointer to identify the location of the read
   * and write.
   */

  genvar n;
  generate
  if (FIFO_DEPTH == 1) begin

    /* "Write" logic.
     */

    always @(posedge clk) begin
      if (ena & wr_ena) begin
        mem[0] <= s_axis_tdata;
      end
    end

    /* Empty/full status.
     * Since this version of the FIFO has only one element, there is no need
     * for both mem_empty and mem_full signals; one is enough to track both
     * statuses.
     */

    always @(posedge clk) begin
      if (rst) begin
        mem_empty <= 1'b1;
      end else if (!ena) begin
        mem_empty <= mem_empty;
      end else if ((!mem_empty | wr_ena) & !rd_ena) begin
        mem_empty <= 1'b0;
      end else begin
        mem_empty <= 1'b1;
      end
    end

    always @* begin
      mem_full = ~mem_empty;
    end

    /* "Read" logic.
     */

    always @(posedge clk) begin
      if (rst) begin
        m_axis_tdata_reg <= 'b0;
        m_axis_tvalid_reg <= 1'b0;
      end else if (ena & rd_ena) begin
        m_axis_tdata_reg <= mem[0];
        m_axis_tvalid_reg <= 1'b1;
      end else begin
        m_axis_tdata_reg <= m_axis_tdata_reg;
        m_axis_tvalid_reg <= m_axis_tvalid;
      end
    end

    assign full = mem_full;
    assign empty = mem_empty;

  end else begin

    /* Write pointer
     * Always points to the next unit to be written when reset, points to the
     * first unit.
     */

    counter #(
      .LOWER (0),
      .UPPER (DF),
      .WRAPAROUND (1),
      .INIT_VALUE (0)
    ) counter_wr_addr (
      .clk (clk),
      .rst (rst),
      .ena (ena & wr_ena),
      .at_max (wr_max),
      .value (wr_addr)
    );

    // Write flag logic

    always @(posedge clk) begin
      if (rst) begin
        wr_flag <= 1'b0;
      end else if (ena & wr_ena & wr_max) begin
        wr_flag <= ~wr_flag;
      end else begin
        wr_flag <= wr_flag;
      end
    end

    /* Write to FIFO
     * No data is written at reset.
     */

    always @(posedge clk) begin
      if (ena & wr_ena) begin
        mem[wr_addr] <= s_axis_tdata;
      end
    end

    /* Read pointer
     * Always points to the next unit to be read when reset, points to the first
     * unit.
     */

    counter #(
      .LOWER (0),
      .UPPER (DF),
      .WRAPAROUND (1),
      .INIT_VALUE (0)
    ) counter_rd_addr (
      .clk (clk),
      .rst (rst),
      .ena (ena & rd_ena),
      .at_max (rd_max),
      .value (rd_addr)
    );

    // Read flag logic

    always @(posedge clk) begin
      if (rst) begin
        rd_flag <= 1'b0;
      end else if (ena & rd_ena & rd_max) begin
        rd_flag <= ~rd_flag;
      end else begin
        rd_flag <= rd_flag;
      end
    end

    /* Read from FIFO.
     */

    always @(posedge clk) begin
      if (ena & rd_ena) begin
        mem_dout <= mem[rd_addr];
      end
    end

    always @(posedge clk) begin
      if (rst) begin
        mem_valid <= 1'b0;
      end else if (ena & ~m_axis_tvalid | m_axis_frame) begin
        mem_valid <= ~mem_empty;
      end else begin
        mem_valid <= mem_valid;
      end
    end

    always @(posedge clk) begin
      if (rst) begin
        m_axis_tvalid_reg <= 1'b0;
        m_axis_tdata_reg <= 'b0;
      end else if (ena & ~m_axis_tvalid | m_axis_frame) begin
        m_axis_tvalid_reg <= mem_valid;
        m_axis_tdata_reg <= mem_dout;
      end else begin
        m_axis_tvalid_reg <= m_axis_tvalid;
        m_axis_tdata_reg <= m_axis_tdata;
      end
    end

    /* FIFO status.
     * When the read pointer and the write pointer are the same, if the two
     * pointer flags are different, it means that the write pointer is folded
     * back more than the read pointer and is full. if the two pointer flags are
     * the same, it means that the two pointers are folded back the same number
     * of times and are empty.
     */

    always @* begin
      if ((wr_addr == rd_addr) & (rd_flag == !wr_flag)) begin
        mem_full = 1'b1;
      end else begin
        mem_full = 1'b0;
      end
    end

    always @* begin
      if ((wr_addr == rd_addr) & (rd_flag == wr_flag)) begin
        mem_empty = 1'b1;
      end else begin
        mem_empty = 1'b0;
      end
    end

    /* Output status signals.
      */

    always @(posedge clk) begin
      casez ({ena, wr_ena, rd_ena})
        3'b110: count <= count + 1'b1;
        3'b101: count <= count - 1'b1;
        default: count <= count;
      endcase
    end

    assign full = (count >= FULL_THRESH);
    assign empty = (count <= EMPTY_THRESH);

  end
  endgenerate

  /* Master interface.
   */

   assign m_axis_frame = m_axis_tvalid & m_axis_tready;
   assign m_axis_tvalid = m_axis_tvalid_reg;
   assign m_axis_tdata = m_axis_tdata_reg;

endmodule
