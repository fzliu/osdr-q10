////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Performs synchronization of external control signals.
//
////////////////////////////////////////////////////////////////////////////////

module anchor_ext_sync (

  input      d_clk,
  input      m_clk,
  input      c_clk,

  input      ebi_nrde,
  output     rd_ena

);

  // read enable

  xpm_cdc_single #(
    .DEST_SYNC_FF (2),
    .SRC_INPUT_REG (0)
  ) xpm_cdc_single_rd_ena (
    .src_clk (),
    .src_in (~ebi_nrde),
    .dest_clk (c_clk),
    .dest_out (rd_ena)
  );

endmodule
