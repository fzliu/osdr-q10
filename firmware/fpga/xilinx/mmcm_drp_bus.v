////////////////////////////////////////////////////////////////////////////////
// Company: ????
// Engineer: Frank Liu
//
// Description
// MMCM/PLL dynamic reconfiguration through a memory bus interface.
//
////////////////////////////////////////////////////////////////////////////////


module mmcm_drp_bus (

  input             clk,
  input             rst,

  // clock reconfiguration

  output            cfg_ena,
  output            cfg_wen,
  output  [  6:0]   cfg_addr,
  output  [ 31:0]   cfg_wdata,
  input   [ 31:0]   cfg_rdata,
  input             cfg_rdy,

  // bus interface

  input             bus_ren,
  input             bus_wen,
  input   [  3:0]   bus_addr,
  output  [ 15:0]   bus_rdata,
  input   [ 15:0]   bus_wdata

);

  // memory region selectors

  localparam  STATE_IDLE = 3'd0;
  localparam  STATE_RESET = 3'd1;
  localparam  STATE_READ = 3'd2;
  localparam  STATE_WRITE = 3'd3;
  localparam  STATE_WAIT_RDY = 3'd4;

  // internal memories

  reg     [ 15:0]   mem [0:15];

  // internal signals

  wire              mem_wen;
  wire    [  3:0]   mem_waddr;
  wire    [ 15:0]   mem_wdata;

  // internal registers

  reg     [  2:0]   state = STATE_RESET;

  reg     [  3:0]   bus_addr_d = 'b0;
  reg     [ 15:0]   bus_wdata_d = 'b0;

  reg               rd_flag = 1'b1;

  reg     [  3:0]   mem_waddr_rs = 'b0;

  reg     [ 15:0]   bus_rdata_reg = 'b0;

  /* Flop inputs.
   * This is done to improve timing and is only applicable to writes.
   * Conveniently, this also aligns the data and address ports with the
   * internal state machine.
   */

  always @(posedge clk) begin
    bus_addr_d <= bus_addr;
    bus_wdata_d <= bus_wdata;
  end

  /* State machine.
   * We start this module in the `reset` state so that the default value for
   * all MMCM/PLL registers are set upon startup. Writes only happen during
   * reset, while sequential reads (writes to memory) begin immediately after
   * reset is deasserted.
   */

  always @(posedge clk) begin
    if (state == STATE_IDLE) begin
      if (rst) begin
        state <= STATE_RESET;
      end
    end else if (state == STATE_RESET) begin
      if (bus_wen) begin
        state <= STATE_WRITE;
      end else if (~rst) begin
        state <= STATE_READ;
      end
    end else if (state == STATE_READ) begin
      state <= STATE_WAIT_RDY;
    end else if (state == STATE_WRITE) begin
      state <= STATE_WAIT_RDY;
    end else if (state == STATE_WAIT_RDY) begin
      if (cfg_rdy) begin
        if (rd_flag) begin
          if (mem_waddr_rs == 4'hf) begin
            state <= STATE_IDLE;
          end else begin
            state <= STATE_READ;
          end
        end else begin  // to reset state first, then idle
          state <= STATE_RESET;
        end
      end
    end
  end

  always @(posedge clk) begin
    if (state == STATE_READ) begin
      rd_flag <= 1'b1;
    end else if (state == STATE_WRITE) begin
      rd_flag <= 1'b0;
    end
  end

  /* MMCM/PLL dynamic reconfiguration controller.
   */

  assign cfg_ena = (state == STATE_WRITE) | (state == STATE_READ);
  assign cfg_wen = (state == STATE_WRITE);

  assign cfg_addr = mem_waddr == 4'h0 ? 7'h14 :
                    mem_waddr == 4'h1 ? 7'h15 :
                    mem_waddr == 4'h2 ? 7'h08 :
                    mem_waddr == 4'h3 ? 7'h09 :
                    mem_waddr == 4'h4 ? 7'h0a :
                    mem_waddr == 4'h5 ? 7'h0b :
                    mem_waddr == 4'h6 ? 7'h0c :
                    mem_waddr == 4'h7 ? 7'h0d :
                    mem_waddr == 4'h8 ? 7'h0e :
                    mem_waddr == 4'h9 ? 7'h0f :
                    mem_waddr == 4'ha ? 7'h10 :
                    mem_waddr == 4'hb ? 7'h11 :
                    mem_waddr == 4'hc ? 7'h06 :
                    mem_waddr == 4'hd ? 7'h07 :
                    mem_waddr == 4'he ? 7'h12 :
                    mem_waddr == 4'hf ? 7'h13 :
                                        7'h00 ;

  assign cfg_wdata = {16'h0000, mem_wdata};

  /* Memory write address during read state.
   */

  always @(posedge clk) begin
    if (rst) begin
      mem_waddr_rs <= 4'h0;
    end else if (cfg_rdy) begin
      mem_waddr_rs <= mem_waddr_rs + 1'b1;
    end else begin
      mem_waddr_rs <= mem_waddr_rs;
    end
  end

  /* Memory controller.
   * There are two types of writes: 1) writes directly from the memory bus, and
   * 2) reads-after-reset from the MMCM/PLL followed immediately by a write to
   * memory. No direct reads from MMCM/PLLs occur - only reads from memory are
   * allowed.
   */

  assign mem_wen = (state == STATE_WRITE) ? 1'b1 : (cfg_rdy & rd_flag);
  assign mem_waddr = (state == STATE_WRITE) ? bus_addr_d : mem_waddr_rs;
  assign mem_wdata = (state == STATE_WRITE) ? bus_wdata_d : cfg_rdata[15:0];

  always @(posedge clk) begin
    if (mem_wen) begin
      mem[mem_waddr] <= mem_wdata;
    end
  end

  always @(posedge clk) begin
    if (bus_ren) begin
      bus_rdata_reg <= mem[bus_addr];
    end
  end

  assign bus_rdata = bus_rdata_reg;

endmodule
