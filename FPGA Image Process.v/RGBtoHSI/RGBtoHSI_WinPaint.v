`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/16 14:27:24
// Design Name: 
// Module Name: RGBtoHSI_WinPaint
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: ��ʽ��������Windows��ͼ"�༭��ɫ"���ת�������һ����.HSIȡֵ��ΧΪ:0-240.Ϊ�˷���FPGAʵ��,���ٲ���Ҫ�ĳ˳���,
//              ��ģ��ļ�����H��ȡֵ��Χ��ȻΪ0-240,S��I��ȡֵ��Χ��Ϊ��0-255,255��Ӧ240. 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:ʹ����3��Xilinx����ip:Divider.���Divider��Float Point IP�Ĳ�֮ͬ������,Dividerֻ֧���������������,��������̵��������ֺ������������̵��������ֺ�С������.
// 
//////////////////////////////////////////////////////////////////////////////////


module RGBtoHSI_WinPaint(
    input                clk,
    input      [7:0]     Rin,
    input      [7:0]     Gin,
    input      [7:0]     Bin,
    input            RGBinEn,
    output reg [7:0]       H,
    output reg [7:0]       S,
    output reg [7:0]       I,
    output          HSIoutEn   //�����ʱ25������
    );
    
    reg [7:0] max=0, min=0, diff0=0,diff1=0;
    reg [8:0] i=0, s_divisor=0;
    reg [7:0] I0=0,S0=0,I1=0;
    reg [17:0] H0=0,H1=0;
    reg [2:0] h_plus0=0;
    reg [7:0] R,G,B,dist_dividend1 = 0,dist_dividend2 = 0;
    wire [11:0] Shift20_q;
    wire [7:0] quotient_dist1,quotient_dist2;
    wire [9:0] fractional_dist1,fractional_dist2;
    reg  [4:0] oEnShift = 0;
    
    wire [8:0] iPlus0p5 = i + 1;
    wire [7:0] max_R = max - R;
    wire [7:0] max_G = max - G;
    wire [7:0] max_B = max - B;
    wire [2:0] h_plus20 = Shift20_q[10:8];
    wire       oEn = Shift20_q[11];
    
    assign HSIoutEn = oEnShift[4];
        
    always@(posedge clk)
    begin
    	R     <= Rin;                        //��ʱ1
    	G     <= Gin;                        //��ʱ1
    	B     <= Bin;                        //��ʱ1
    	max   <= MAX(Rin,Gin,Bin);           //��ʱ1
    	min   <= MIN(Rin,Gin,Bin);           //��ʱ1
    	i     <= max + min;                  //��ʱ2
    	diff0 <= max - min;                  //��ʱ2    
    	diff1 <= diff0;                      //��ʱ3
    	I0    <= iPlus0p5[8:1];              //��ʱ3  
    	s_divisor <= i < 255 ? i : 510 - i;  //��ʱ3
    	S0    <= sx256_sPlus0p5[8:1];        //��ʱ3+20+1 = 24
    	I1    <= Shift20_q[7:0];
    	oEnShift[0] <= oEn;
    	oEnShift[4:1] <= oEnShift[3:0];
    	    	
    	if(max == min) //diff == 0
    	begin
    	  h_plus0 <= 7; //h = 0
    	end
    	else
    	begin    	
    	  if(R == max)
    	  begin
    	  	dist_dividend1 <= max_B;         //��ʱ2
    	  	dist_dividend2 <= max_G;
    	  	h_plus0 <= 0;
    	  end
    	  else if(G == max)
    	  begin
    	  	dist_dividend1 <= max_R;
    	  	dist_dividend2 <= max_B;   	
    	  	h_plus0 <=	2;
    	  end
    	  else if(B == max)
    	  begin
    	  	dist_dividend1 <= max_G;
    	  	dist_dividend2 <= max_R;   
    	  	h_plus0 <=	4;	
    	  end   	
      end
    	
    	if(h_plus20 == 7)
    	begin
    		H0 <= 0;
    	end
    	else
    	begin
    		H0 <=  {0,h_plus20,10'b0} + {quotient_dist1,fractional_dist1} - {quotient_dist2,fractional_dist2};    		
    	end
    	
    	if(H0[17] == 1)
    	begin
    	  H1 <= H0 + {6,10'b0}; 
    	end
    	else if(H0 >= {6,10'b0})
    	begin
    	  H1 <= H0 - {6,10'b0};
    	end
    	else
    	  H1 <= H0;
    	
    	H <= hx40[17:10];
    	S <= S0;
    	I <= I1;
    end
    
    wire [17:0] hx40 = {H1[12:0],5'b0} + {H1[14:0],3'b0} + {8'b0,1'b1,9'b0};
    
    
    wire [8:0] divisorForS = s_divisor == 0 ? 1 : s_divisor; 
    wire [7:0] dividendForS = diff1; //��ʱ3
    wire [7:0] quotientForS;
    wire [9:0] fractionalForS;
    wire [17:0] quotient_fractionalForS = {quotientForS,fractionalForS};
    wire [17:0] sx256_s = {fractionalForS,8'b0} - quotient_fractionalForS;
    wire [8:0] sx256_sPlus0p5 = sx256_s[17:9] + 1;  
    wire [8:0] dist_divisor = {1'b0,diff0}; 
    
    
    Divider iDividerForS ( //��ʱ20�����ڳ����
	    .clk(clk), // input clk
	    .rfd(rfdForS), // output rfd
	    .dividend(dividendForS), // input [7 : 0] dividend
	    .divisor(divisorForS), // input [8 : 0] divisor
	    .quotient(quotientForS), // output [7 : 0] quotient
	    .fractional(fractionalForS)); // output [9 : 0] fractional
    
    Divider iDivider_dist1 (
	    .clk(clk), // input clk
	    .rfd(rfd_dist1), // output rfd
	    .dividend(dist_dividend1), // input [7 : 0] dividend
	    .divisor(dist_divisor), // input [8 : 0] divisor
	    .quotient(quotient_dist1), // output [7 : 0] quotient
	    .fractional(fractional_dist1)); // output [9 : 0] fractional
	 
	  Divider iDivider_dist2 (
	    .clk(clk), // input clk
	    .rfd(rfd_dist2), // output rfd
	    .dividend(dist_dividend2), // input [7 : 0] dividend
	    .divisor(dist_divisor), // input [8 : 0] divisor
	    .quotient(quotient_dist2), // output [7 : 0] quotient
	    .fractional(fractional_dist2)); // output [9 : 0] fractional
                                                                                   
  wire [11:0] Shift20_d = {RGBinEn,h_plus0,I0};  
  
  
  Shift20 i_h_plus0_I0 (//Ram-based Shift Register,delay 20
    .d(Shift20_d), // input [11 : 0] d
    .clk(clk), // input clk   
    .q(Shift20_q)); // output [11 : 0] q
    
    function [7:0] MAX;
      input [7:0] a,b,c;
      reg [7:0] Maxab;
      begin 
        Maxab = a > b ? a : b;
        MAX = Maxab > c ? Maxab : c;
      end
    endfunction
    
    function [7:0] MIN;
      input [7:0] a,b,c;
      reg [7:0] Minab;
      begin
        Minab = a < b ? a : b;
        MIN = Minab < c ? Minab : c;
      end
    endfunction
   
    
endmodule
