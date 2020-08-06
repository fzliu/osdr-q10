//////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Lu Yizhou
// 
// Description: 
// 输入θ角度与幅度值A，使用cordic算法计算三角函数，
// 输出Acosθ与Asinθ，
// cordic使用16次迭代计算，以0度为初始角，θ为目标角。
// 程序包含18个周期的延迟，
// 延迟包括1个输入周期，16个迭代计算周期以及1个输出周期。
// 
//////////////////////////////////////////////////////////////////////////////////


module math_cordic #(

  //parameters
  
  parameter             CYCLE_NUM = 16,       /* 迭代次数 */
  parameter             ARG_BIT = 16,         /* 输入角度位宽 */
  parameter             WAVE_BIT_WIDTH = 12,  /* 输入波形位宽 */
  parameter             EX_BIT = 16,          /* 扩展位宽,即*2^16进行计算 */
  parameter             OUPUT_BIT_WIDTH = 16, /* 16位输出 */
  
  /*cos补偿 0.607253*2^16=39797
   *二进制表示1001101101110101     
   */
                                               
  parameter             COS_COMP = 39797,     
  
  //local parameters
 
  /* 数据处理时数据的位宽
   * 为输出位宽+扩展位宽
   */ 
 
  localparam            RUN_WIDTH = EX_BIT + OUPUT_BIT_WIDTH,  
  
  localparam            BA = ARG_BIT - 1,
  localparam            NC = CYCLE_NUM - 1,
  localparam            BO = OUPUT_BIT_WIDTH - 1,
  localparam            WR = RUN_WIDTH - 1,
  localparam            BW = WAVE_BIT_WIDTH -1
  
  
)(

  /*时钟信号 */
  
  input                  clk,

  /*角度输入 */

  input      [BA:0]     arg_in,
  
  /* 波形数据输入 */
  
  input      [BW:0]     wave_num_in,
  
  /* 输出实部,即cos */
  
  output     [BO:0]     real_out,
  
  /* 输出虚部,即sin */
  
  output     [BO:0]     imag_out

);

  /* cordic迭代寄存器 */

  reg        [WR:0]     cordic_x[NC+1:0];
  reg        [WR:0]     cordic_y[NC+1:0];
  reg        [WR:0]     cordic_arg[NC:0];
  reg        [WR:0]     run_arg[NC+1:0];
  
  /* 初始值寄存器  */
  
  reg        [ BW:0]     rad_num;
  reg        [ BA:0]     target_arg;
  
  /* 符号位寄存器 */
  
  reg                    x_sign[NC+1:0];
  reg                    y_sign[NC+1:0];
  
  /* 符号位D触发器 */
  
  reg                    x_signal;
  reg                    y_signal;
  
  /* 输出寄存器 */
  
  reg        [BO:0]     res_real;
  reg        [BO:0]     res_imag;  
  
  /* 旋转角寄存器 */
  
  reg        [WR:0]     tan_arg[NC:0];  

  /* 旋转角arctan
   * 求arctan(2^(-i))*2^16 
   */
   
  wire       [WR:0]     comp_arg[NC:0];
  wire       [BO:0]     num_y;
  wire       [BO:0]     num_x;
  
  initial begin
    tan_arg[0] = 32'd2949120;
    tan_arg[1] = 32'd1740967;
    tan_arg[2] = 32'd919879;
    tan_arg[3] = 32'd466945;
    tan_arg[4] = 32'd234379;
    tan_arg[5] = 32'd117304;
    tan_arg[6] = 32'd58666;
    tan_arg[7] = 32'd29335;
    tan_arg[8] = 32'd14668;
    tan_arg[9] = 32'd7334;
    tan_arg[10] = 32'd3667;
    tan_arg[11] = 32'd1833;
    tan_arg[12] = 32'd917;
    tan_arg[13] = 32'd458;
    tan_arg[14] = 32'd229;
    tan_arg[15] = 32'd115;
  end
  
  /* 记录输入角对应点(x,y)的坐标符号
   * 以角度符号与波形符号判断输出值符号位
   */
  
  always @(posedge clk) begin
    if (!arg_in[BA]) begin
      if (arg_in[BA-1:0] > 15'd90) begin
        x_signal <= ~wave_num_in[BW];
        target_arg[BA-1:0] <= 15'd180 - arg_in[BA-1:0];
      end else begin
        x_signal <= wave_num_in[BW];
        target_arg[BA-1:0] <= arg_in[BA-1:0];
      end
      y_signal <= wave_num_in[BW];
      target_arg[BA] <= 1'b0;
    end else begin
      if ((~arg_in[BA-1:0]) > 15'd89) begin
        x_signal <= ~wave_num_in[BW];
        target_arg[BA-1:0] <= 15'd179 - (~arg_in[BA-1:0]);
      end else begin
        x_signal <= wave_num_in[BW];
        target_arg[BA-1:0] <= (~arg_in[BA-1:0]) + 1'b1;
      end
      y_signal <= ~wave_num_in[BW];
      target_arg[BA] <= 1'b0;
    end
  end
  
  /* cordic算法迭代计算cos,sin,共迭代16次 */
  
  genvar i;
  generate
    for (i = 0; i <= NC; i = i + 1)
    begin:cordic
      
      assign comp_arg[i] = cordic_arg[i] - run_arg[i];
      
      always @(posedge clk) begin  
        if (!(comp_arg[i][WR])) begin
          cordic_x[i+1] <= cordic_x[i] + ({(WR+1){cordic_x[i][WR]}} << (NC - i)) | (cordic_x[i] >> i);
          cordic_y[i+1] <= cordic_y[i] - ({(WR+1){cordic_y[i][WR]}} << (NC - i)) | (cordic_y[i] >> i);
          cordic_arg[i+1] <= cordic_arg[i] - tan_arg[i];
        end else begin
          cordic_x[i+1] <= cordic_x[i] - ({(WR+1){cordic_y[i][WR]}} << (NC - i)) | (cordic_y[i] >> i);
          cordic_y[i+1] <= cordic_y[i] + ({(WR+1){cordic_x[i][WR]}} << (NC - i)) | (cordic_x[i] >> i);
          cordic_arg[i+1] <= cordic_arg[i] + tan_arg[i];
        end
          run_arg[i+1] <= run_arg[i];
          x_sign[i+1] <= x_sign[i];
          y_sign[i+1] <= y_sign[i];
        
      end
    end
  endgenerate
  
  /* 计算波形幅度值
   * 取波形幅值绝对值并记录符号
   * 以波形符号与角度符号判断输出值符号位
   * 幅值绝对值作为初始cos
   */
  
  always @(posedge clk) begin
    rad_num[BW] <= 1'b0;
    if (wave_num_in[BW]) begin
      rad_num[BW-1:0] <= (~wave_num_in[BW-1:0]) + 1'b1;
    end else begin
      rad_num[BW-1:0] <= wave_num_in;
    end
  end
  
  /* 输入初始值
   * 初始角度为0,即cos=1,sin=0
   * 加上初始幅值后 幅值*cos=幅值,幅值*sin=0;
   */
  
  always @(posedge clk) begin
    cordic_x[0] <= (rad_num <<< 15) + (rad_num <<< 12) +
                   (rad_num <<< 11) + (rad_num <<< 9) +
                   (rad_num <<< 8) + (rad_num <<< 6) +
                   (rad_num <<< 5) + (rad_num <<< 4) +
                   (rad_num <<< 2) + rad_num;
    cordic_y[0] <= 'b0;
    cordic_arg[0] <= 'b0;
    x_sign[0] <= x_signal;
    y_sign[0] <= y_signal;
    run_arg[0] <= target_arg <<< EX_BIT;
  end
  
  /* 输出最终的cos与sin
   * 为cordic结果值加上符号位
   */
  
  assign real_out = res_real;
  assign imag_out = res_imag;
  assign num_y = (cordic_y[NC+1] >>> EX_BIT);
  assign num_x = (cordic_x[NC+1] >>> EX_BIT);
  
  always @(posedge clk) begin
    if (x_sign[NC+1] && (num_x != 'b0)) begin
      res_real <= 'b0 - num_x;
    end else begin
      res_real <= num_x;
    end
    if (y_sign[NC+1] && (num_y != 'b0)) begin
      res_imag <= 'b0 - num_y;
    end else begin
      res_imag <= num_y;
    end  
  end
  
endmodule

