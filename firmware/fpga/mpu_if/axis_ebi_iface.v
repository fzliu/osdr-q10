//////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Lu Yizhou
// 
// Description: 
// This module is a FPGA buffer, receive and temporarily keep calculated  wave
// data through axi-stream.
// MCU reads buffer or writes control bits through EBI.
// EBI includes four parts: read enable, write enable, read-write address and data.
// Several control registers are added beside the ram. See the definition in the 
// program for more information.
// The angle register is used to store the θ value required by CORDIC.
// 
// signals: (controlled by EBI)
// reset:active low
// WE:active high
//
// signals: (controlled by FPGA)
// RN:active high
// 
//////////////////////////////////////////////////////////////////////////////////


module axis_ebi_iface #(

  //parameters
  
  parameter MAX_ADDR_WIDTH = 15,         /* address data width */
  parameter MAX_ADDR_VALUE = 'h4000,   /* RAM depth */
  parameter MAX_DATA_WIDTH = 16,         /* bit width of RAM */
  parameter NUM_CHANNELS = 4,  
  parameter ADDER_WIDTH = 12,  
  
  //localparam
  
  localparam CHANNEL_WIDTH = 2 * ADDER_WIDTH,  
  localparam DATA_WIDTH = CHANNEL_WIDTH * NUM_CHANNELS,  
 
  localparam WAD = ADDER_WIDTH,
  localparam CN = NUM_CHANNELS * 2,
  localparam WD = DATA_WIDTH - 1,
  localparam DA = ADDER_WIDTH - 1,   
  localparam AW = MAX_ADDR_WIDTH - 1,
  localparam DW = MAX_DATA_WIDTH - 1,
  localparam AV = MAX_ADDR_VALUE - 1,
  localparam WE = MAX_ADDR_VALUE,        /* AXI write enable (same as tready) */
  localparam RN = MAX_ADDR_VALUE + 1,    /* EBI read enable (same as !tvalid) */
  localparam RSET = MAX_ADDR_VALUE + 2,  /* reset signal */
  localparam ADDL = MAX_ADDR_VALUE + 3,  /* low bits of the max address */
  localparam ADDH = MAX_ADDR_VALUE + 4,  /* high bits of the max address */
  localparam ARGR = MAX_ADDR_VALUE + 5   /* angle register */
)(

  /* clock signal */
  
  input                  clk_f,
  input                  clk_ebi,

  /* axi-stream controller */
    
  input     [ WD:0]      s_axis_tdata,
  input                  s_axis_tvalid,
  output                 s_axis_tready,
  
  /* ebi controller */
  
  inout     [ DW:0]      data_ebi, /* ebi data input/output */
  input                  nrd_ebi,  /* ebi read enable(mcu read buffer) */
  input                  nwe_ebi,  /* ebi write enable(mcu write buffer) */
  input     [ AW:0]      addr_ebi, /* ebi operate address */
  
  output    [ DW:0]      arg_out   /* angle output */

);

  /* reset signal */
  
  reg                    rst_ram;
  
  /* AXI write enable (same as tready) */
  
  wire                   we_ebi_in;
  
  /* Stack top address */
  
  reg       [ AW:0]      addr_in;
  
  /* ebi output */
  
  reg       [ DW:0]      dout;
  
  /* RAM data */

  reg       [ DA:0]      ramdata[0:20000];       
  
    /* angle register */
  
  reg       [ DW:0]      arg_data = 'b0;  
  
    /* EBI controller */
  
  reg                    read_enable;
  reg                    write_enable;
  reg       [ DW:0]      ch_counter = 'b0;
  
  reg       [ DA:0]      s_axis_tdata_depart[CN-1:0];
 // reg       [ DA:0]      s_axis_tdata_buff[CN-1:0];  
  
  reg                    depart_do;
//  wire                   depart_do_s;
  
  
  wire      [ DW:0]      arg_in;
  
  reg        [DW:0]            test_num;

  
  
  /* Initialization, reset AXI control signal  
   * Configure EBI read enable according to AXI status
   * Configure RN = ~ tvalid  
   */
      
  assign s_axis_tready = rst_ram && depart_do && write_enable;
  always @(posedge clk_f) begin             
    if (rst_ram && !(ch_counter >= CN)) begin
      if (s_axis_tready && s_axis_tvalid) begin
        depart_do <= 1'b0;
      end else begin
      end
    end else begin
      depart_do <= 1'b1;
    end
  end


  always @(posedge clk_f) begin             
    if (!rst_ram) begin
      read_enable <= 1'b0;
      arg_data <= 'b0;
    end else begin
      read_enable <= ~s_axis_tvalid;
      arg_data <= arg_in;
    end
  end   

  /* axi-stream input */



  genvar i;
  generate
    for (i = 0; i < CN; i = i + 1)
    begin:data_depart
      localparam i0 = WAD * i,i1 = i0 + DA;
      always @(posedge clk_f) begin
        if (s_axis_tready && s_axis_tvalid) begin
        //  s_axis_tdata_buff[i] <= ;
          s_axis_tdata_depart[i] <= s_axis_tdata[i1:i0];
        end else begin end
      end
    end
  endgenerate
 
    
  always @(posedge clk_f) begin
    if (rst_ram) begin
      if ((!depart_do) && (ch_counter < CN)) begin
        ramdata[addr_in] <= s_axis_tdata_depart[ch_counter];
        ch_counter <= ch_counter + 1'b1;
        if (addr_in >= AV) begin
          addr_in <= 'b0;
        end else begin
          addr_in <= addr_in + 1'b1;
        end
      end else begin
        ch_counter <= 'b0;
      end
    end else begin
      addr_in <= 'b0;
      ch_counter <= 'b0;
    end
  end   
  
  assign arg_out = (rst_ram)? 'b0:arg_data; 
   
////////////////////////firewall/////////////////////////////// 

  /* EBI read buffer */

  assign data_ebi = (nrd_ebi || (!nwe_ebi))? 'dz:dout; 

  always @(posedge clk_ebi) begin
    if (nrd_ebi || (!nwe_ebi)) begin
      dout <= 'b0;
    end else begin
      if ((addr_ebi < WE) && (read_enable)) begin
        if (DA < DW) begin
          dout[DA:0] <= ramdata[addr_ebi];
          dout[DW:DA+1] <= 'b0;
        end else begin
          dout <= ramdata[addr_ebi];
        end
      end else begin
        case (addr_ebi)
          RN:dout <= read_enable;
          WE:dout <= write_enable;
          RSET:dout <= rst_ram; 
          ADDL:dout <= addr_in;
          ADDH:dout <= test_num;
          ARGR:dout <= arg_data;
          default:dout <= 'b0;
        endcase
      end
    end
  end  
  
  /* EBI write control bits */

  assign arg_in = (!nwe_ebi && (addr_ebi == ARGR))? data_ebi : arg_in;
  assign we_ebi_in = nrd_ebi;
  
  always @(posedge clk_ebi) begin
    if (!rst_ram) begin
      write_enable <= 1'b0;
    end else begin
      write_enable <= we_ebi_in;
    end
  end    
  
  always @(posedge clk_ebi) begin
    if (nwe_ebi) begin
    end else begin
        case (addr_ebi)
     //     WE:write_enable <= data_ebi[0];
          RSET:rst_ram <= data_ebi[0]; 
      //    ARGR:arg_data <= data_ebi;
          default:begin end
        endcase
    end
  end            
  /*   */ 
endmodule
