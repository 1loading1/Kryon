`timescale 1ns / 1ps
`define W 48                     //Image Width  ������������Ҫ�����������ͼ��Ĵ�С���޸�. These two definitions need to be modified according to the size of the input test image.   
`define H 36                     //Image Height ���˸Ľ���ͻ᲻��ȷ                        If you forgot, the result will be wrong
`define S `W * `H * 3            //ͼ�����ݵ����ֽ���,������RGB����,����*3.                 Total bytes of the image
//This code comes from: https://github.com/becomequantum/kryon
//������ƪ���½�����FPGAͼ�����������,The following article talks about FPGA Image Process,it's in Chinese, but Google translate is good enough:
//https://zhuanlan.zhihu.com/p/38946857
//"tb1.txt"���ı���ʽ��ͼ�������ļ�,�����ŵ����ص��RGBֵ,����Ҫ�����ͼ���ļ�תΪ�ı���ʽ��Ϊ��������
//"tb1.txt" is the RGB value of the pixel data stored in the txt file. You need to convert your image file into text format for the simulation input.
module TestBench(

    );
    reg clk   ;          
    reg Vsync ;                  //��ֱͬ���ź�,Ҳ����֡��Ч�ź� Vertical Sync
    reg Hsync ;                  //ˮƽͬ���ź�,����Ч           Horizontal Sync
    reg DataEn;                  //����������Ч�ź�DE            Data Enable                    
    reg [7:0] R,G,B,GS,Dilation,Erosion,InBetween;                                                      
    reg [7:0] PicMem[0:`S-1];    //�����洢RGBͼ������ Used to store RGB image data                             
    integer h,l;                 //ѭ��index
    integer PicFile1,PicFile2,PicFile3,PicFile4,PicFile5,PicFile6;
    integer i1 = 0,i2 = 0, n = 0;
    
    GrayOperator3x3 iGrayOperator3x3
    (
     .clk      (clk),         
     .DataEn   (DataEn),
     .PixelData(G),          //ֱ�ӾͰ�Gֵ���Ҷ�������
     .DataOutEn()    
    );
    
    BinaryOperator9x9 iBinaryOperator9x9
    (
     .clk      (clk   ),         
     .DataEn   (DataEn),
     .PixelData(G<128 ),      //�ȽϺڵĵ��Ϊ1
     .DataOutEn()    
    );
    
    CCAL iCCAL
    (
     .clk       (clk   ),
     .Vsync     (Vsync ),
     .DataEn    (DataEn),
     .BinaryData(G<255 && R<255 && B<255),
     .OtherData (0),
     .DataOutEn (),
     .SumO      (),
     .XMaxO     (),
     .YMaxO     (),
     .XMinO     (),
     .YMinO     ()     
    );         
    
    always #5 clk = ~clk;
    
    initial begin
      clk   = 0;   
      Vsync = 0;
      Hsync = 0;
      DataEn= 0;
      R     = 0;
      G     = 0;
      B     = 0;
    	$readmemh("tb1.txt",PicMem);         //��tb1.txt�е�ͼ�����ݶ�ȡ��PicMem����
    	PicFile6 = $fopen("CCAL.txt","w");   //This output is not an image data.
    	SimInput;
    	SimInput;
    	
    	$fclose(PicFile1);              
    	$fclose(PicFile2);
    	$fclose(PicFile3);              
    	$fclose(PicFile4);
    	$fclose(PicFile5);
    	$fclose(PicFile6);
    	$finish; 
    end
    
    task SimInput;                  //ģ��VGAʱ���������ͼ������. VGA Timing
    begin
    	#777; 
      @(posedge clk);
      #1;
	  	Vsync = 1;
	  	repeat(6) @(posedge clk);
	  	for(l=0;l<`H;l=l+1)           //Verilog��Ҳ����дforѭ��,ֻ�����ǲ����ۺϴ���,ֻ����Test Bench��дд
	  	begin	  		
	  		Hsync = 1;
	  		repeat(5) @(posedge clk);             
	  		for(h=0;h<`W;h=h+1)  
	  		begin 
	  			#1;                       //����ʱʹ�ܺ������źŲ�Ҫ��ʱ�������ض���,��ͬ�ķ���������ܻ�Դ��в�ͬ��� 
	  			DataEn = 1;
	  			R = PicMem[l*`W*3 + h*3]; G = PicMem[l*`W*3 + h*3 + 1]; B = PicMem[l*`W*3 + h*3 + 2];
	  			@(posedge clk);
	  		end  
	  		#1;                  
	  		DataEn = 0;
	  		R = 0; G = 0; B = 0;  
	  		repeat(7) @(posedge clk); 
	  		Hsync = 0;
	  		if(l<`H-1)
	  		  repeat(152) @(posedge clk);
	  		else
	  		  repeat(6) @(posedge clk);
	  	end 
	  	Vsync = 0;
      #111;
      
    end
    endtask
    
    always@(posedge Vsync)                     
      n <= n + 1;
    
    always@(negedge iCCAL.DataOutEn)              //�����ͨ��ʶ���� Output connected component labeling results
      if(n == 1)
      begin
        $display("FPGA: Sum: %d XYmax: [%d,%d] XYmin: [%d,%d]\n",iCCAL.SumO,iCCAL.XMaxO,iCCAL.YMaxO,iCCAL.XMinO,iCCAL.YMinO); 
        $fwrite(PicFile6,"FPGA: Sum: %d XYmax: [%d,%d] XYmin: [%d,%d]\n",iCCAL.SumO,iCCAL.XMaxO,iCCAL.YMaxO,iCCAL.XMinO,iCCAL.YMinO);
      end
                                                               
    //�ѷ������ٴ�Ϊ�ı���ʽ��ͼ������                       
    initial                                                    
    begin                                                      
      PicFile1 = $fopen("GaussianBlur.txt","w");  //��˹ƽ�����,�ļ��������ISE,Vivado������ķ��湤��Ŀ¼�� Gauss smoothing results, files will appear in ISE, Vivado and other software's simulation work directory.
      PicFile2 = $fopen("Sobel.txt","w");         //��Ե����� Edge detection results
      $fwrite(PicFile1,"%h %h\n",`W,`H);
      $fwrite(PicFile2,"%h %h\n",`W,`H);
      @(posedge iGrayOperator3x3.DataOutEn);  //3x3�����ӽ�����ԭ������ʱһ��
      for(i1 = 0; i1 < `H; i1 = i1 + 1)
      begin
        @(posedge iGrayOperator3x3.DataOutEn)
        while(iGrayOperator3x3.DataOutEn == 1)
        begin
        	@(posedge clk); 
        	GS = iGrayOperator3x3.GaussianBlur;
        	$fwrite(PicFile1,"%H %H %H  ",GS, GS, GS); 
        	if(iGrayOperator3x3.Sobel == 0)
        	  $fwrite(PicFile2,"%H %H %H  ", GS, GS, GS);                //��Ե���Ľ�������ڸ�˹ƽ���Ľ������ʾ,��ԵΪ��ɫ       
        	else        
        	  $fwrite(PicFile2,"%H %H %H  ", 8'h0, 8'h0, 8'hff);  		   //����Ҫд8'h�������8λ��,�������32λ��.
        end     
          $fwrite(PicFile1,"\n");  
          $fwrite(PicFile2,"\n");
      end   
    end
    
    //����9x9��ֵ���ӵļ�����.��ͬ��initial���ǲ��е�.
    initial 
    begin 
      PicFile3 = $fopen("Dilation.txt" ,"w");  
      PicFile4 = $fopen("Erosion.txt"  ,"w");    
      PicFile5 = $fopen("InBetween.txt","w");      
      $fwrite(PicFile3,"%h %h\n",`W,`H);
      $fwrite(PicFile4,"%h %h\n",`W,`H);
      $fwrite(PicFile5,"%h %h\n",`W,`H);
      repeat(4) @(posedge iBinaryOperator9x9.DataOutEn);               //9x9�����ӽ�����ԭ������ʱ4��,��Ϊ���ĵ����滹��4��. The result of 9x9 is 4 rows later than the original data, because there are 4 rows below the center point.
      for(i2 = 0; i2 < `H; i2 = i2 + 1)                                //ѭ������Ҫ��һ��,���ܺ��������ͬ
      begin
        @(posedge iBinaryOperator9x9.DataOutEn)
        while(iBinaryOperator9x9.DataOutEn == 1)
        begin
        	@(posedge clk); 
        	Dilation  = iBinaryOperator9x9.Dilation  ? 8'h0 : 8'hff; 
        	Erosion   = iBinaryOperator9x9.Erosion   ? 8'h0 : 8'hff;
        	InBetween = iBinaryOperator9x9.InBetween ? 8'h0 : 8'hff;
        	$fwrite(PicFile3,"%H %H %H  ",Dilation , Dilation , Dilation ); 
        	$fwrite(PicFile4,"%H %H %H  ",Erosion  , Erosion  , Erosion  ); 
        	$fwrite(PicFile5,"%H %H %H  ",InBetween, InBetween, InBetween);  		
        end     
          $fwrite(PicFile3,"\n");  
          $fwrite(PicFile4,"\n");
          $fwrite(PicFile5,"\n");
      end 
    end  
    
endmodule