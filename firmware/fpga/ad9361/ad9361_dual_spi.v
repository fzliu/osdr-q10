////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description
// AD9361 SPI handler.
//
////////////////////////////////////////////////////////////////////////////////

module ad9361_dual_spi (

  // physical interface (spi_a)

  output            a_resetb,
  output            a_spi_sck,
  output            a_spi_di,
  input             a_spi_do,
  output            a_spi_cs,

  // physical interface (spi_b)

  output            b_resetb,
  output            b_spi_sck,
  output            b_spi_di,
  input             b_spi_do,
  output            b_spi_cs,

  // microprocessor interface

  input             reset_a,
  input             reset_b,
  input             spi_sck,
  input             spi_mosi,
  output            spi_miso,
  input             spi_cs_a,
  input             spi_cs_b

);

  /* Chip A SPI.
   */

  assign a_resetb = reset_a;
  assign a_spi_sck = spi_sck;
  assign a_spi_di = spi_mosi;
  assign a_spi_cs = spi_cs_a;

  /* Chip B SPI.
   */

  assign b_resetb = reset_b;
  assign b_spi_sck = spi_sck;
  assign b_spi_di = spi_mosi;
  assign b_spi_cs = spi_cs_b;

  /* MCU data input.
   */

  assign spi_miso = ~a_spi_cs ? a_spi_do : (~b_spi_cs ? b_spi_do : 1'b0);


endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
