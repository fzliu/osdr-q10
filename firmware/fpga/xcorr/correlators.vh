////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: List of correlators used by the system.
//
////////////////////////////////////////////////////////////////////////////////

localparam            CORR_LENGTH = 7,
localparam            LC = CORR_LENGTH - 1,

localparam  [ LC:0]   CORRELATORS = 
  {1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b1}
