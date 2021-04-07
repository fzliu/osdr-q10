////////////////////////////////////////////////////////////////////////////////
// Company: Orion Innovations
// Engineer: Frank Liu
//
// Description
// FT245 synchronous interface to AXI-stream converter. Downstream/upstream
// modules are ideally asynchronous FIFOs. See section 3.5.2 in the FT600
// datasheet for more information.
//
// Parameters
// N/A
//
// Signals
// enable  :  N/A
// reset   :  N/A
// latency :  1 cycle
// output  :  registered (phys control unregistered)
//
////////////////////////////////////////////////////////////////////////////////

module axis_ft245_sync (

  // core interface

  input             clk,

  output            tx_rdy,   // when high, this module can accept FT245 data
  input             tx_val,   // if high, data on `tx_data` is valid
  input   [ 15:0]   tx_data,

  input             rx_rdy,   // if high, downstream controller can accept data
  output            rx_val,   // when high, data on `rx_data` is valid
  output  [ 15:0]   rx_data,

  // physical (FT245) interface

  inout   [ 15:0]   adbus,
  inout   [  1:0]   be,

  input             rxf_n,    // if high, do not read data from FT245
  input             txe_n,    // if high, do not write data to FT245
  output            rd_n,     // only drive low when rxf_n = 1'b0 to read
  output            wr_n,     // only drive low when txe_n = 1'b0 to write
  output            oe_n,     // drive this low for before driving rd_n low

  output            siwu_n

);

  // internal states

  localparam  STATE_RESET = 3'd0;
  localparam  STATE_IDLE = 3'd1;
  localparam  STATE_RX_INIT = 3'd2;
  localparam  STATE_RX = 3'd3;
  localparam  STATE_TX = 3'd4;

  // internal registers

  reg     [  2:0]   state = STATE_IDLE;

  /* Controller state machine.
   * The state machine must encompass both read and write logic since both
   * reads and writes use the same data bus. To conform to the AXI-stream
   * protocol, the default state if data is available is RX. Furthermore, we
   * try to ensure continuity of active reads and writes to maximize transfer
   * efficiency.
   */

  always @(posedge clk) begin
    casez (state)
      STATE_IDLE: begin
        if (~txe_n & tx_val) begin
          state <= STATE_TX;
        end else if (~rxf_n) begin
          state <= STATE_RX_INIT;
        end else begin
          state <= STATE_IDLE;
        end
      end
      STATE_RX_INIT: begin
        if (~rxf_n) begin
          state <= STATE_RX;
        end else begin
          state <= STATE_IDLE;
        end
      end
      STATE_RX: begin
        if (~rxf_n) begin
          state <= STATE_RX;  // can only exit RX state once data is exhausted
        end else begin
          state <= STATE_IDLE;
        end
      end
      STATE_TX: begin
        if (~txe_n & tx_val) begin
          state <= STATE_TX;
        end else if (~rxf_n) begin
          state <= STATE_IDLE;  // enter IDLE state first, then RX from IDLE
        end else if (~txe_n) begin
          state <= STATE_TX;
        end else begin
          state <= STATE_IDLE;
        end
      end
      default: begin  // invalid state!
        state <= STATE_IDLE;
      end
    endcase
  end

  /* Set physical control signals.
   * These are fairly straightforward and mostly state-dependent.
   */

  assign rd_n = ~((state == STATE_RX) & rx_rdy); //~(rx_val & rx_rdy);
  assign wr_n = ~((state == STATE_TX) & tx_val); //~(tx_val & tx_rdy);
  assign oe_n = ~((state == STATE_RX_INIT) | (state == STATE_RX));

  /* Assign data I/O bits.
   * For `adbus`, a tri-state buffer is used to switch between `tx_data` and
   * `rx_data` depending on the output enable. We drive `adbus` only when
   * absolutely necessary, i.e. when we wish to write data to the FT245.
   */

  assign adbus = (state == STATE_TX) ? tx_data : 16'hzzzz;
  assign be = (state == STATE_TX) ? 2'b11 : 2'bzz;

  assign rx_data[15:8] = be[1] ? adbus[15:8] : 8'h00;
  assign rx_data[7:0] = be[0] ? adbus[7:0] : 8'h00;

  /* RX valid signal.
   * This signal (output from this module) goes high when data is valid,
   * regardless of whether or not the downstream module has asserted rx_rdy. As
   * a result, this signal is asserted whenever both data exists (`rxf` is high)
   * and the current state of the FSM is RX.
   */

  assign rx_val = (state == STATE_RX) & ~rxf_n;

  /* TX ready signal.
   * This signal (also an output from this module) denotes that the FT245 is
   * ready to accept the next batch of data. First, `txe` must be asserted on
   * the current clock cycle for ready to also be asserted. Second, we must be
   * in the TX state, otherwise `wr` will not go high and no data is latched by
   * the FT245 chip.
   */

  assign tx_rdy = (state == STATE_TX) & ~txe_n;

endmodule
