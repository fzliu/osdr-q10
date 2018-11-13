////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: FFT-based cross-correlation top-level module. Unused for now.
//
// Revision: N/A
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module xcorr_mult_ifft #(

  parameter   NUM_TAGS = 20

) (

  // core interface

  input             clk,
  input             rst,

  // slave interface

  input             s_axis_tvalid,
  output            s_axis_tready,
  input   [ 32:0]   s_axis_tdata,
  input             s_axis_tlast,

  // coefficient interface



  // master interface

  output            m_axis_tvalid,
  input             m_axis_tready,
  output  [ 32:0]   m_axis_tdata,
  output            m_axis_tlast

);

  // multiply


  // inverse FFT


  // output


endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
