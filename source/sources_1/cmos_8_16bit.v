//////////////////////////////////////////////////////////////////////////////////
//  CMOS sensor 8bit data is converted to 16bit data                            //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2017/7/19     meisq          1.0         Original
//*******************************************************************************/

module cmos_8_16bit
#(
	parameter	SAMPLING_RATE		=	2
)
(
	input              rst,
	input              pclk,
	input			   cmos_vsync,
	input [7:0]        pdata_i,
	input              de_i,
	output reg[15:0]   pdata_o,
	output reg         hblank,
  output    reg	[5:0]	frame_cnt,
	output reg         de_o       
);
wire [11:0]pos_x;
reg[7:0] pdata_i_d0;
reg[11:0] x_cnt;
//reg[9:0] y_cnt;
reg cmos_vsync_d0;
reg cmos_vsync_d1;
reg[15:0]               h_data0[511:0];
reg[15:0]               h_data1[511:0];
reg[15:0]               h_data2[255:0];
integer                   i;
integer                   j;
wire	data_en		=	x_cnt[0];


wire	frame_start	=	( cmos_vsync_d0 == 1'b1 && cmos_vsync_d1 == 1'b0 );
assign pos_x = x_cnt>>1;
//assign pos_y = y_cnt;
//parameter	display_model	=	0;

always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		cmos_vsync_d0 <= 1'b0;
		cmos_vsync_d1 <= 1'b0;
	end
	else
	begin
		cmos_vsync_d0 <= cmos_vsync;
		cmos_vsync_d1 <= cmos_vsync_d0;
	end
end



always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
		frame_cnt <=	1'b0;
	else if( frame_start ) 
		begin
			if( frame_cnt == ( SAMPLING_RATE -1 ) )
				frame_cnt <=	1'b0;
			else
				frame_cnt <= 	frame_cnt	+	1'b1;
	end
end


always@(posedge pclk)
begin
	pdata_i_d0 <= pdata_i;
end

always@(posedge pclk or posedge rst)
begin
	if(rst)
		x_cnt <= 12'd0;
	else if(de_i)
		x_cnt <= x_cnt + 12'd1;
	else
		x_cnt <= 12'd0;
end

//always@(posedge pclk or posedge rst)
//begin
//	if(rst)
//		y_cnt <= 10'd0;
//	else if(frame_start)
//		y_cnt <= 0;
//	else if(de_i & (pos_x == 'd1023))
//		y_cnt <= y_cnt+1;
//          else
//             y_cnt <= 0;
//end


always@(posedge pclk or posedge rst)
begin
	if(rst)
		de_o <= 1'b0;
//	else if( de_i && data_en && ( frame_cnt == ( SAMPLING_RATE -1 ) ) )
	else if( de_i && data_en  )
		de_o <= 1'b1;
	else
		de_o <= 1'b0;
end

always@(posedge pclk or posedge rst)
begin
	if(rst)
		hblank <= 1'b0;
	else
		hblank <= de_i;
end

//always@(posedge pclk or posedge rst)
//begin
//	if(rst)
//		pdata_o_reg1 <= 16'd0;
//	else if(de_i && data_en)
//		pdata_o_reg1 <= {pdata_i_d0,pdata_i};
//	else
//		pdata_o_reg1 <= 16'd0;
//end

always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
    for(i=0;i<512;i=i+1)
        begin      
       h_data0[i] <= 0;
       h_data1[i] <= 0;
         end
    else if(de_i && data_en)
         begin
     if(pos_x<'d512)
       h_data0[pos_x] <= {pdata_i_d0,pdata_i};
     else
       h_data1[pos_x-'d512] <={pdata_i_d0,pdata_i};
         end
end

always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
          begin
		pdata_o <= 0;
          for(j=0;j<'d256;j=j+1)
                 h_data2[j] <= 0;
          end
	else if(de_i && data_en)
          begin
                  if(pos_x < 'd256)
                  pdata_o <= h_data2[pos_x];
                       else if(pos_x < 'd512)
                       pdata_o <=  h_data1[(pos_x-256)*2];
                             else if(pos_x < 'd768)
                                 begin
                                  pdata_o <=  h_data0[(pos_x-512)*2];
                                  h_data2[pos_x-512] <= h_data0[(pos_x-512)*2];
                                 end
                                    else
                                     pdata_o <=  h_data1[(pos_x-768)*2];

            end
	else
           begin
		 pdata_o <= 0;
            end
end

endmodule 