////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// Anchor LED control module.
//
////////////////////////////////////////////////////////////////////////////////


module anchor_led_ctrl (

  // core interface

  input             clk,

  // data input & output flags

  input             valid_0,
  input             valid_1,
  input             valid_2,
  input             valid_3,
  input             valid_sf,
  input             ebi_ready,

  // voltage & temperature alarms

  // led outputs

  output  [  7:0]   led_out

);

  // assign outputs

  assign led_out[0] = valid_1;
  assign led_out[1] = valid_0;
  assign led_out[2] = valid_2;
  assign led_out[3] = valid_3;
  assign led_out[6] = valid_sf;
  assign led_out[7] = ebi_ready;

endmodule
