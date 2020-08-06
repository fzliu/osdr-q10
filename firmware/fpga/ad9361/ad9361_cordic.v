//////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Lu Yizhou
// 
// Description: 
// 接收来自前端4个通道的波形数据(i+jq)，
// 分别对4个通道计算并输出(i+jq)*e^(jθ)。
//
// 由于e^(jθ)=cosθ+jsinθ，
// 实际计算i=(icosθ-qsinθ)、q=(isinθ+qcosθ)。
// 使用cordic计算三角函数，单独计算复数加减法。
// 对valid信号进行相应时延以对应有效数据。
// 
//////////////////////////////////////////////////////////////////////////////////


module ad9361_cordic #(

  //parameters

  parameter             ARG_BIT = 16,            /* 角度位宽 */
  parameter             WAVE_BIT_WIDTH = 12,     /* 波形位宽 */
  parameter             OUPUT_BIT_WIDTH = 16,    /* 16位输出 */
  parameter             VALID_DELAY_TIME = 18,   /* valid时延 */
  
  //local parameters
  
  localparam            BA = ARG_BIT - 1,
  localparam            BO = OUPUT_BIT_WIDTH - 1,
  localparam            BW = WAVE_BIT_WIDTH - 1,
  localparam            DV = VALID_DELAY_TIME

  
)(
  input                   clk,
  input                   valid_ci_0,
  input      [ BW:0]      data_ci_i0,
  input      [ BW:0]      data_ci_q0,
  input                   valid_ci_1,
  input      [ BW:0]      data_ci_i1,
  input      [ BW:0]      data_ci_q1,
  input                   valid_ci_2,
  input      [ BW:0]      data_ci_i2,
  input      [ BW:0]      data_ci_q2,
  input                   valid_ci_3,
  input      [ BW:0]      data_ci_i3,
  input      [ BW:0]      data_ci_q3,
  output                  valid_co_0,
  output     [ BW:0]      data_co_i0,
  output     [ BW:0]      data_co_q0,
  output                  valid_co_1,
  output     [ BW:0]      data_co_i1,
  output     [ BW:0]      data_co_q1,
  output                  valid_co_2,
  output     [ BW:0]      data_co_i2,
  output     [ BW:0]      data_co_q2,
  output                  valid_co_3,
  output     [ BW:0]      data_co_i3,
  output     [ BW:0]      data_co_q3,
  input      [ BA:0]      arg_in
);

  /* cordic输出 */

  wire       [ BO:0]      cos_out_i0;
  wire       [ BO:0]      sin_out_i0;
  wire       [ BO:0]      cos_out_q0;
  wire       [ BO:0]      sin_out_q0;
  wire       [ BO:0]      cos_out_i1;
  wire       [ BO:0]      sin_out_i1;
  wire       [ BO:0]      cos_out_q1;
  wire       [ BO:0]      sin_out_q1;
  wire       [ BO:0]      cos_out_i2;
  wire       [ BO:0]      sin_out_i2;
  wire       [ BO:0]      cos_out_q2;
  wire       [ BO:0]      sin_out_q2;
  wire       [ BO:0]      cos_out_i3;
  wire       [ BO:0]      sin_out_i3;
  wire       [ BO:0]      cos_out_q3;
  wire       [ BO:0]      sin_out_q3;
  
  /* 复数计算结果 */
  
  wire       [ BO:0]      data_mid_i0;
  wire       [ BO:0]      data_mid_q0;
  wire       [ BO:0]      data_mid_i1;
  wire       [ BO:0]      data_mid_q1;
  wire       [ BO:0]      data_mid_i2;
  wire       [ BO:0]      data_mid_q2;
  wire       [ BO:0]      data_mid_i3;
  wire       [ BO:0]      data_mid_q3;
  
  /* 复数计算结果截取
   * 16位截取至12位
   * 超过(-2048,2047)的值取-2048、2047
   */
   
  wire                    data_co_i0_pos;
  wire                    data_co_i0_neg;
  wire       [ BW:0]      data_co_i0_val;
  wire       [ BW:0]      data_co_i0_ngv;
  wire                    data_co_q0_pos;
  wire                    data_co_q0_neg;
  wire       [ BW:0]      data_co_q0_val;
  wire       [ BW:0]      data_co_q0_ngv;
  wire                    data_co_i1_pos;
  wire                    data_co_i1_neg;
  wire       [ BW:0]      data_co_i1_val;
  wire       [ BW:0]      data_co_i1_ngv;
  wire                    data_co_q1_pos;
  wire                    data_co_q1_neg;
  wire       [ BW:0]      data_co_q1_val;
  wire       [ BW:0]      data_co_q1_ngv;
  wire                    data_co_i2_pos;
  wire                    data_co_i2_neg;
  wire       [ BW:0]      data_co_i2_val;
  wire       [ BW:0]      data_co_i2_ngv;
  wire                    data_co_q2_pos;
  wire                    data_co_q2_neg;
  wire       [ BW:0]      data_co_q2_val;
  wire       [ BW:0]      data_co_q2_ngv;
  wire                    data_co_i3_pos;
  wire                    data_co_i3_neg;
  wire       [ BW:0]      data_co_i3_val;
  wire       [ BW:0]      data_co_i3_ngv;
  wire                    data_co_q3_pos;
  wire                    data_co_q3_neg;
  wire       [ BW:0]      data_co_q3_val;
  wire       [ BW:0]      data_co_q3_ngv;
  
  /* valid时延位移寄存器 */
  
  reg        [ DV:0]      valid_d_0;
  reg        [ DV:0]      valid_d_1;
  reg        [ DV:0]      valid_d_2;
  reg        [ DV:0]      valid_d_3;
  
  /* 计算valid时延 与有效输出对齐
   * 时延18周期(16计算周期+1个输入周期+1个输出周期)
   */
  
  genvar i;
  generate
    for (i = 0; i < DV;i = i + 1)
    begin:valid_delay
      always @(posedge clk) begin
        valid_d_0[i+1] <= valid_d_0[i];
        valid_d_1[i+1] <= valid_d_1[i];
        valid_d_2[i+1] <= valid_d_2[i];
        valid_d_3[i+1] <= valid_d_3[i];
      end
    end
  endgenerate
  
  always @(posedge clk) begin
    valid_d_0[0] <= valid_ci_0;
    valid_d_1[0] <= valid_ci_1;
    valid_d_2[0] <= valid_ci_2;
    valid_d_3[0] <= valid_ci_3;
  end
  
  assign valid_co_0 = valid_d_0[DV];
  assign valid_co_1 = valid_d_1[DV];
  assign valid_co_2 = valid_d_2[DV];
  assign valid_co_3 = valid_d_3[DV];
    
  /* 计算0通道 */
  
  /* 计算复数乘法 */
    
  assign data_mid_i0 = cos_out_i0 - sin_out_q0;
  assign data_mid_q0 = sin_out_i0 + cos_out_q0;
    
  /* 0通道结果截取
   * 计算结果16位,截取到12位
   * 值超过范围直接赋极值(-2048,+2047)
   */
  
  assign data_co_i0_pos = (data_mid_i0 > 16'd2047)&&(!data_mid_i0[BO]);
  assign data_co_i0_neg = (data_mid_i0 < -16'd2048)&&(data_mid_i0[BO]);
  assign data_co_i0_val = {data_mid_i0[BO],data_mid_i0[BW-1:0]};
  assign data_co_i0_ngv = (data_co_i0_neg)? -12'd2048:data_co_i0_val;
  assign data_co_i0 = (data_co_i0_pos)? 12'd2047:data_co_i0_ngv;
                     
  assign data_co_q0_pos = (data_mid_q0 > 16'd2047)&&(!data_mid_q0[BO]);
  assign data_co_q0_neg = (data_mid_q0 < -16'd2048)&&(data_mid_q0[BO]);
  assign data_co_q0_val = {data_mid_q0[BO],data_mid_q0[BW-1:0]};
  assign data_co_q0_ngv = (data_co_q0_neg)? -12'd2048:data_co_q0_val;
  assign data_co_q0 = (data_co_q0_pos)? 12'd2047:data_co_q0_ngv;
      
  /* 0通道codic,求sin与cos */
                      
  math_cordic #(
    .WAVE_BIT_WIDTH(WAVE_BIT_WIDTH),
    .OUPUT_BIT_WIDTH(OUPUT_BIT_WIDTH)
  ) math_cordic_i0(
    .clk(clk),
    .arg_in(arg_in),
    .wave_num_in(data_ci_i0),
    .real_out(cos_out_i0),
    .imag_out(sin_out_i0)
  );
  
  math_cordic #(
    .WAVE_BIT_WIDTH(WAVE_BIT_WIDTH),
    .OUPUT_BIT_WIDTH(OUPUT_BIT_WIDTH)
  ) math_cordic_q0(
    .clk(clk),
    .arg_in(arg_in),
    .wave_num_in(data_ci_q0),
    .real_out(cos_out_q0),
    .imag_out(sin_out_q0)
  );
  
  /* 计算1通道 */
  
  /* 计算复数乘法 */
    
  assign data_mid_i1 = cos_out_i1 - sin_out_q1;
  assign data_mid_q1 = sin_out_i1 + cos_out_q1;
    
  /* 1通道结果截取
   * 计算结果16位,截取到12位
   * 值超过范围直接赋极值(-2048,+2047)
   */
  
  assign data_co_i1_pos = (data_mid_i1 > 16'd2047)&&(!data_mid_i1[BO]);
  assign data_co_i1_neg = (data_mid_i1 < -16'd2048)&&(data_mid_i1[BO]);
  assign data_co_i1_val = {data_mid_i1[BO],data_mid_i1[BW-1:0]};
  assign data_co_i1_ngv = (data_co_i1_neg)? -12'd2048:data_co_i1_val;
  assign data_co_i1 = (data_co_i1_pos)? 12'd2047:data_co_i1_ngv;
  
  assign data_co_q1_pos = (data_mid_q1 > 16'd2047)&&(!data_mid_q1[BO]);
  assign data_co_q1_neg = (data_mid_q1 < -16'd2048)&&(data_mid_q1[BO]);
  assign data_co_q1_val = {data_mid_q1[BO],data_mid_q1[BW-1:0]};
  assign data_co_q1_ngv = (data_co_q1_neg)? -12'd2048:data_co_q1_val;
  assign data_co_q1 = (data_co_q1_pos)? 12'd2047:data_co_q1_ngv;
                      
  /* 1通道codic,求sin与cos */             
                      
  math_cordic #(
    .WAVE_BIT_WIDTH(WAVE_BIT_WIDTH),
    .OUPUT_BIT_WIDTH(OUPUT_BIT_WIDTH)
  ) math_cordic_i1(
    .clk(clk),
    .arg_in(arg_in),
    .wave_num_in(data_ci_i1),
    .real_out(cos_out_i1),
    .imag_out(sin_out_i1)
  );
  
  math_cordic #(
    .WAVE_BIT_WIDTH(WAVE_BIT_WIDTH),
    .OUPUT_BIT_WIDTH(OUPUT_BIT_WIDTH)
  ) math_cordic_q1(
    .clk(clk),
    .arg_in(arg_in),
    .wave_num_in(data_ci_q1),
    .real_out(cos_out_q1),
    .imag_out(sin_out_q1)
  );
  
  /* 计算2通道 */
  
  /* 计算复数乘法 */
    
  assign data_mid_i2 = cos_out_i2 - sin_out_q2;
  assign data_mid_q2 = sin_out_i2 + cos_out_q2;
    
  /* 2通道结果截取
   * 计算结果16位,截取到12位
   * 值超过范围直接赋极值(-2048,+2047)
   */
  
  assign data_co_i2_pos = (data_mid_i2 > 16'd2047)&&(!data_mid_i2[BO]);
  assign data_co_i2_neg = (data_mid_i2 < -16'd2048)&&(data_mid_i2[BO]);
  assign data_co_i2_val = {data_mid_i2[BO],data_mid_i2[BW-1:0]};
  assign data_co_i2_ngv = (data_co_i2_neg)? -12'd2048:data_co_i2_val;
  assign data_co_i2 = (data_co_i2_pos)? 12'd2047:data_co_i2_ngv;
    
  assign data_co_q2_pos = (data_mid_q2 > 16'd2047)&&(!data_mid_q2[BO]);
  assign data_co_q2_neg = (data_mid_q2 < -16'd2048)&&(data_mid_q2[BO]);
  assign data_co_q2_val = {data_mid_q2[BO],data_mid_q2[BW-1:0]};
  assign data_co_q2_ngv = (data_co_q2_neg)? -12'd2048:data_co_q2_val;
  assign data_co_q2 = (data_co_q2_pos)? 12'd2047:data_co_q2_ngv;
 
  /* 2通道codic,求sin与cos */
  
  math_cordic #(
    .WAVE_BIT_WIDTH(WAVE_BIT_WIDTH),
    .OUPUT_BIT_WIDTH(OUPUT_BIT_WIDTH)
  ) math_cordic_i2(
    .clk(clk),
    .arg_in(arg_in),
    .wave_num_in(data_ci_i2),
    .real_out(cos_out_i2),
    .imag_out(sin_out_i2)
  );
  
  math_cordic #(
    .WAVE_BIT_WIDTH(WAVE_BIT_WIDTH),
    .OUPUT_BIT_WIDTH(OUPUT_BIT_WIDTH)
  ) math_cordic_q2(
    .clk(clk),
    .arg_in(arg_in),
    .wave_num_in(data_ci_q2),
    .real_out(cos_out_q2),
    .imag_out(sin_out_q2)
  );
  
  
  /* 计算3通道 */
  
  /* 计算复数乘法 */
  
  assign data_mid_i3 = cos_out_i3 - sin_out_q3;
  assign data_mid_q3 = sin_out_i3 + cos_out_q3;
  
  /* 3通道结果截取
   * 计算结果16位,截取到12位
   * 值超过范围直接赋极值(-2048,+2047)
   */
  
  assign data_co_i3_pos = (data_mid_i3 > 16'd2047)&&(!data_mid_i3[BO]);
  assign data_co_i3_neg = (data_mid_i3 < -16'd2048)&&(data_mid_i3[BO]);
  assign data_co_i3_val = {data_mid_i3[BO],data_mid_i3[BW-1:0]};
  assign data_co_i3_ngv = (data_co_i3_neg)? -12'd2048:data_co_i3_val;
  assign data_co_i3 = (data_co_i3_pos)? 12'd2047:data_co_i3_ngv;
    
  assign data_co_q3_pos = (data_mid_q3 > 16'd2047)&&(!data_mid_q3[BO]);
  assign data_co_q3_neg = (data_mid_q3 < -16'd2048)&&(data_mid_q3[BO]);
  assign data_co_q3_val = {data_mid_q3[BO],data_mid_q3[BW-1:0]};
  assign data_co_q3_ngv = (data_co_q3_neg)? -12'd2048:data_co_q3_val;
  assign data_co_q3 = (data_co_q3_pos)? 12'd2047:data_co_q3_ngv;
  
  /* 3通道codic,求sin与cos */
  
  math_cordic #(
    .WAVE_BIT_WIDTH(WAVE_BIT_WIDTH),
    .OUPUT_BIT_WIDTH(OUPUT_BIT_WIDTH)
  ) math_cordic_i3(
    .clk(clk),
    .arg_in(arg_in),
    .wave_num_in(data_ci_i3),
    .real_out(cos_out_i3),
    .imag_out(sin_out_i3)
  );
  
  math_cordic #(
    .WAVE_BIT_WIDTH(WAVE_BIT_WIDTH),
    .OUPUT_BIT_WIDTH(OUPUT_BIT_WIDTH)
  ) math_cordic_q3(
    .clk(clk),
    .arg_in(arg_in),
    .wave_num_in(data_ci_q3),
    .real_out(cos_out_q3),
    .imag_out(sin_out_q3)
  );  
  
endmodule
