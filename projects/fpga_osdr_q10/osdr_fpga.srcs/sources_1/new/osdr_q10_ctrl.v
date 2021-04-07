////////////////////////////////////////////////////////////////////////////////
// Company: ????
// Engineer: Frank Liu
//
// Description
// OSDR Q10 core control module.
//
////////////////////////////////////////////////////////////////////////////////


module osdr_q10_ctrl (

  input             clk,

  // clock reconfiguration

  output            cfg_rst,

  output            cfg_ena_a,
  output            cfg_wen_a,
  output  [  6:0]   cfg_addr_a,
  output  [ 31:0]   cfg_wdata_a,
  input   [ 31:0]   cfg_rdata_a,
  input             cfg_rdy_a,

  output            cfg_ena_b,
  output            cfg_wen_b,
  output  [  6:0]   cfg_addr_b,
  output  [ 31:0]   cfg_wdata_b,
  input   [ 31:0]   cfg_rdata_b,
  input             cfg_rdy_b,

  // sample data

  input             tx_done,
  output  [ 11:0]   tx_data_i0,
  output  [ 11:0]   tx_data_q0,
  output  [ 11:0]   tx_data_i1,
  output  [ 11:0]   tx_data_q1,
  output  [ 11:0]   tx_data_i2,
  output  [ 11:0]   tx_data_q2,
  output  [ 11:0]   tx_data_i3,
  output  [ 11:0]   tx_data_q3,

  input             rx_done,
  input   [ 11:0]   rx_data_i0,
  input   [ 11:0]   rx_data_q0,
  input   [ 11:0]   rx_data_i1,
  input   [ 11:0]   rx_data_q1,
  input   [ 11:0]   rx_data_i2,
  input   [ 11:0]   rx_data_q2,
  input   [ 11:0]   rx_data_i3,
  input   [ 11:0]   rx_data_q3,

  // EBI interface

  input   [ 14:0]   ebi_addr,
  input             ebi_nrde,
  input             ebi_nwre,
  output            ebi_irq,
  inout   [ 15:0]   ebi_data,

  // USB interface

  output            usb_val_out,
  input             usb_rdy_out,
  output  [ 15:0]   usb_data_out,

  input             usb_val_in,
  output            usb_rdy_in,
  input   [ 15:0]   usb_data_in,

  // top-level reset

  output            fifo_rst

  // misc signals

);

  // memory region selectors

  localparam  SELECT_RAM = 2'd0;
  localparam  SELECT_CFG_A = 2'd1;
  localparam  SELECT_CFG_B = 2'd2;
  localparam  SELECT_NONE = 2'd3;

  // internal memories

  reg     [ 15:0]   mem [0:32735];

  // internal signals

  wire              ebi_rde;
  wire              ebi_wre;
  wire    [  1:0]   ebi_sel;

  wire              reg_wr;
  wire              reg_wr_sh;

  wire              usb_frm_in;
  wire              usb_frm_out;

  wire              tx_end;
  wire              rx_end;

  wire              cmd_irq;
  wire              cmd_done;
  wire    [ 14:0]   cmd_addr;

  wire              data_done;
  wire    [ 14:0]   data_addr;

  wire    [  3:0]   drp_addr_a;
  wire              drp_ren_a;
  wire              drp_wen_a;
  wire    [ 15:0]   drp_rdata_a;
  wire    [ 15:0]   drp_wdata_a;

  wire    [  3:0]   drp_addr_b;
  wire              drp_ren_b;
  wire              drp_wen_b;
  wire    [ 15:0]   drp_rdata_b;
  wire    [ 15:0]   drp_wdata_b;

  wire    [ 15:0]   ebi_out;

  // internal registers

  reg               out_ena = 1'b0;
  reg     [  1:0]   out_sel = SELECT_RAM;

  reg               ena_int = 1'b1;
  reg               rst_int = 1'b0;

  reg     [  7:0]   n_chan = 'd1;

  reg     [  1:0]   tx_chan = 'b0;
  reg     [  1:0]   rx_chan = 'b0;

  reg     [ 15:0]   tx_data_0 = 'b0;
  reg     [ 15:0]   tx_data_1 = 'b0;
  reg     [ 15:0]   tx_data_2 = 'b0;
  reg     [ 15:0]   tx_data_3 = 'b0;

  reg     [  7:0]   tx_data_i0_reg = 'b0;
  reg     [  7:0]   tx_data_q0_reg = 'b0;
  reg     [  7:0]   tx_data_i1_reg = 'b0;
  reg     [  7:0]   tx_data_q1_reg = 'b0;
  reg     [  7:0]   tx_data_i2_reg = 'b0;
  reg     [  7:0]   tx_data_q2_reg = 'b0;
  reg     [  7:0]   tx_data_i3_reg = 'b0;
  reg     [  7:0]   tx_data_q3_reg = 'b0;

  reg     [ 15:0]   rx_data_0 = 'b0;
  reg     [ 15:0]   rx_data_1 = 'b0;
  reg     [ 15:0]   rx_data_2 = 'b0;
  reg     [ 15:0]   rx_data_3 = 'b0;

  reg     [  7:0]   rx_data_i = 'b0;
  reg     [  7:0]   rx_data_q = 'b0;

  reg               cmd_ack = 1'b0;

  reg               mem_ren = 1'b0;
  reg     [ 14:0]   mem_raddr = 'b0;
  reg     [ 15:0]   mem_rdata = 'b0;

  reg               mem_wen = 1'b0;
  reg     [ 14:0]   mem_waddr = 'b0;
  reg     [ 15:0]   mem_wdata = 'b0;

  /* EBI helper signals.
   */

  assign ebi_rde = ~ebi_nrde;
  assign ebi_wre = ~ebi_nwre;

  assign ebi_sel = ebi_addr[14:4] == 11'h7fe ? SELECT_CFG_A :
                   ebi_addr[14:4] == 11'h7ff ? SELECT_CFG_B :
                                               SELECT_RAM   ;

  always @(posedge clk) begin
    out_ena <= ebi_rde & ~ebi_wre;
  end

  always @(posedge clk) begin
    out_sel <= ebi_sel;
  end

  /* Command control logic.
   * The control logic for the FPGA is as follows: first, a full command is
   * received (0x8080). This pauses all external logic and puts this control
   * module into a command receive state. Once the command is ack'ed by the
   * MCU, this control module resumes normal operation.
   */

  pulse #(
    .WIDTH (1)
  ) pulse_fifo_rst (
    .clk (clk),
    .din (cmd_done),
    .dout (fifo_rst)
  );

  pulse #(
    .WIDTH (1)
  ) pulse_reg_wr (
    .clk (clk),
    .din (ebi_wre & (ebi_addr == 15'h7f05)),
    .dout (reg_wr)
  );

  shift_reg #(
    .WIDTH (1),
    .DEPTH (64),
    .USE_RAM (0)
  ) shift_reg_reg_wr_sh (
    .clk (clk),
    .rst (1'b0),
    .ena (1'b1),
    .din (reg_wr),
    .dout (reg_wr_sh)
  );

  /* Internal enable and internal reset.
   * When a command is received, disable the internals of this module and begin
   * receiving command data only. Once external modules have been reset, we can
   * perform an internal reset and re-enable this control module. The reset is
   * held high until the command has been ack'ed by the MCU.
   */

  always @(posedge clk) begin
    if (cmd_irq) begin
      ena_int <= 1'b0;
    end else if (reg_wr_sh) begin
      ena_int <= 1'b1;
    end else begin
      ena_int <= ena_int;
    end
  end

  always @(posedge clk) begin
    if (reg_wr_sh) begin
      rst_int <= 1'b1;
    end else if (usb_frm_out) begin  // 0x8080 sent to host
      rst_int <= 1'b0;
    end else begin
      rst_int <= rst_int;
    end
  end

  assign cfg_rst = ~ena_int;

  /* Special registers.
   * 0x7F30: stores the number of active channels
   */

  always @(posedge clk) begin
    if (ebi_wre & (ebi_addr == 15'h7f30)) begin
      n_chan <= ebi_data[7:0];
    end
  end

  /* Transmit data.
   * Apply a single element buffer to the output TX data to avoid updating the
   * sample data as it is being transmitted.
   */

  assign tx_end = tx_chan == n_chan - 1'b1;
  assign usb_rdy_in = ~ebi_wre & (~cmd_done | ~tx_end | tx_done);
  assign usb_frm_in = usb_val_in & usb_rdy_in;

  always @(posedge clk) begin
    if (tx_done) begin
      tx_chan <= 2'b00;
    end else if (ena_int & usb_frm_in) begin
      tx_chan <= tx_end ? 2'b00 : tx_chan + 1'b1;
    end else begin
      tx_chan <= tx_chan;
    end
  end

  always @(posedge clk) begin
    if (ena_int) begin
      casez (tx_chan)
        2'b00: tx_data_0 <= usb_data_in;
        2'b01: tx_data_1 <= usb_data_in;
        2'b10: tx_data_2 <= usb_data_in;
        2'b11: tx_data_3 <= usb_data_in;
      endcase
    end
  end

  always @(posedge clk) begin
    if (tx_done & tx_end & usb_val_in) begin
      {tx_data_i0_reg, tx_data_q0_reg} <= tx_data_0;
      {tx_data_i1_reg, tx_data_q1_reg} <= tx_data_1;
      {tx_data_i2_reg, tx_data_q2_reg} <= tx_data_2;
      {tx_data_i3_reg, tx_data_q3_reg} <= tx_data_3;
    end
  end

  assign tx_data_i0 = {tx_data_i0_reg, 4'h0};
  assign tx_data_q0 = {tx_data_q0_reg, 4'h0};
  assign tx_data_i1 = {tx_data_i1_reg, 4'h0};
  assign tx_data_q1 = {tx_data_q1_reg, 4'h0};
  assign tx_data_i2 = {tx_data_i2_reg, 4'h0};
  assign tx_data_q2 = {tx_data_q2_reg, 4'h0};
  assign tx_data_i3 = {tx_data_i3_reg, 4'h0};
  assign tx_data_q3 = {tx_data_q3_reg, 4'h0};

  /* Receive data.
   * When this module is actively receiving a command packet, disable the RX
   * datastream to improve USB-side congestion; when the command packet is
   * ack'ed by the MCU, force the data to a command ack and the valid to be
   * high.
   */

  assign rx_end = rx_chan == n_chan - 1'b1;
  assign usb_val_out = ena_int & (rst_int | ~rx_end | rx_done);
  assign usb_frm_out = usb_val_out & usb_rdy_out;

  always @(posedge clk) begin
    if (rx_done & rx_end & usb_rdy_out) begin
      rx_data_0 <= {rx_data_i0[11:4], rx_data_q0[11:4]};
      rx_data_1 <= {rx_data_i1[11:4], rx_data_q1[11:4]};
      rx_data_2 <= {rx_data_i2[11:4], rx_data_q2[11:4]};
      rx_data_3 <= {rx_data_i3[11:4], rx_data_q3[11:4]};
    end
  end

  always @(posedge clk) begin
    if (rx_done) begin
      rx_chan <= 2'b00;
    end else if (ena_int & usb_frm_out) begin
      rx_chan <= rx_end ? 2'b00 : rx_chan + 1'b1;
    end else begin
      rx_chan <= rx_chan;
    end
  end

  assign usb_data_out = (rst_int)          ? 16'h8080  :
                        (rx_chan == 2'b00) ? rx_data_0 :
                        (rx_chan == 2'b01) ? rx_data_1 :
                        (rx_chan == 2'b10) ? rx_data_2 :
                        (rx_chan == 2'b11) ? rx_data_3 :
                                             16'h0000  ;

  /* Command writeback logic.
   * A pair of bytes with a value of 0x8080 designates an reset; write the
   * next 4 bytes of data to internal registers so that the command may be
   * read by the MCU through the EBI interface.
   */

  assign cmd_irq = usb_val_in & (usb_data_in == 16'h8080);

  counter #(
    .LOWER ('h7f00),
    .UPPER ('h7f05),
    .WRAPAROUND (1),
    .INIT_VALUE ('h7f05)
  ) counter_cmd_addr (
    .clk (clk),
    .rst (1'b0),
    .ena ((cmd_irq | ~cmd_done) & usb_frm_in & ~ebi_wre),
    .done (cmd_done),
    .value (cmd_addr)
  );

  always @(posedge clk) begin
    if (~ebi_wre) begin
      cmd_ack <= ~cmd_done;
    end else begin
      cmd_ack <= cmd_ack;
    end
  end

  /* RX data loopback logic.
   * To facilitate the setting of input delays, loopback the RX data. If the
   * received waveform matches the TX waveform, then the frontend configuration
   * is valid.
   */

  counter #(
    .LOWER ('h0000),
    .UPPER ('h7f00),
    .WRAPAROUND (0),
    .INIT_VALUE ()
  ) counter_data_addr (
    .clk (clk),
    .rst (rst_int),
    .ena (ena_int & usb_frm_out),
    .done (data_done),
    .value (data_addr)
  );

  /* Clock reconfiguration, chip A.
   */

  assign drp_ren_a = ebi_rde & (ebi_sel == SELECT_CFG_A);
  assign drp_wen_a = ebi_wre & (ebi_sel == SELECT_CFG_A);
  assign drp_addr_a = ebi_addr[3:0];
  assign drp_wdata_a = ebi_data;

  mmcm_drp_bus #()
  mmcm_drp_bus_a (
    .clk (clk),
    .rst (cfg_rst),
    .cfg_ena (cfg_ena_a),
    .cfg_wen (cfg_wen_a),
    .cfg_addr (cfg_addr_a),
    .cfg_wdata (cfg_wdata_a),
    .cfg_rdata (cfg_rdata_a),
    .cfg_rdy (cfg_rdy_a),
    .bus_ren (drp_ren_a),
    .bus_wen (drp_wen_a),
    .bus_addr (drp_addr_a),
    .bus_rdata (drp_rdata_a),
    .bus_wdata (drp_wdata_a)
  );

  /* Clock reconfiguration, chip B.
   */

  assign drp_ren_b = ebi_rde & (ebi_sel == SELECT_CFG_B);
  assign drp_wen_b = ebi_wre & (ebi_sel == SELECT_CFG_B);
  assign drp_addr_b = ebi_addr[3:0];
  assign drp_wdata_b = ebi_data;

  mmcm_drp_bus #()
  mmcm_drp_bus_b (
    .clk (clk),
    .rst (cfg_rst),
    .cfg_ena (cfg_ena_b),
    .cfg_wen (cfg_wen_b),
    .cfg_addr (cfg_addr_b),
    .cfg_wdata (cfg_wdata_b),
    .cfg_rdata (cfg_rdata_b),
    .cfg_rdy (cfg_rdy_b),
    .bus_ren (drp_ren_b),
    .bus_wen (drp_wen_b),
    .bus_addr (drp_addr_b),
    .bus_rdata (drp_rdata_b),
    .bus_wdata (drp_wdata_b)
  );

  /* Internal memory.
   * By order of precedence, we first write MCU data, followed by command data
   * from the USB and finally loopback bytes from the AD9361s.
   */

  always @* begin
    mem_ren = ebi_rde & (ebi_sel == SELECT_RAM);
    mem_raddr = ebi_addr;
  end

  always @(posedge clk) begin
    if (mem_ren) begin
      mem_rdata <= mem[mem_raddr];
    end
  end

  always @(posedge clk) begin
    if (ebi_wre) begin
      mem_wen <= (ebi_sel == SELECT_RAM);
      mem_waddr <= ebi_addr;
      mem_wdata <= ebi_data;
    end else if (~cmd_done) begin
      mem_wen <= 1'b1;
      mem_waddr <= cmd_addr;
      mem_wdata <= usb_data_in;
    end else if (cmd_ack) begin
      mem_wen <= 1'b1;
      mem_waddr <= cmd_addr;
      mem_wdata <= 16'h8080;
    end else if (~data_done) begin
      mem_wen <= 1'b1;
      mem_waddr <= data_addr;
      mem_wdata <= usb_data_out;
    end else begin
      mem_wen <= 1'b0;
      mem_waddr <= 15'h0000;
      mem_wdata <= 16'h0000;
    end
  end

  always @(posedge clk) begin
    if (mem_wen) begin
      mem[mem_waddr] <= mem_wdata;
    end
  end

  /* Assign EBI output data.
   * Output data always has a one-cycle latency.
   */

  assign ebi_out = (out_sel == SELECT_CFG_A) ? drp_rdata_a :
                   (out_sel == SELECT_CFG_B) ? drp_rdata_b :
                                               mem_rdata   ;

  assign ebi_data = out_ena ? ebi_out : 16'hzzzz;

endmodule
