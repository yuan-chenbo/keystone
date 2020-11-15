//////////////////////////////////////////////////////////////////////////////////
 
//////////////////////////////////////////////////////////////////////////////////
module image_processing
#(
	parameter MEM_DATA_BITS = 64,
	parameter ADDR_BITS = 32
)
(
	input rst,                                 /*复位*/
	input mem_clk,                               /*接口时钟*/
    input     [2:0]          key_out,   	
    output reg rd_burst_req,                          /*读请求*/
	output reg wr_burst_req,                          /*写请求*/
	output reg[9:0] rd_burst_len,                     /*读数据长度*/
	output reg[9:0] wr_burst_len,                     /*写数据长度*/
	output reg[ADDR_BITS - 1:0] rd_burst_addr,        /*读首地址*/
	output reg[ADDR_BITS - 1:0] wr_burst_addr,        /*写首地址*/
	input rd_burst_data_valid,                  /*读出数据有效*/
	input wr_burst_data_req,                    /*写数据信号*/
	input[MEM_DATA_BITS - 1:0] rd_burst_data,   /*读出的数据*/
	output[MEM_DATA_BITS - 1:0] wr_burst_data,    /*写入的数据*/
	input rd_burst_finish,                      /*读完成*/
	input wr_burst_finish,                      /*写完成*/
	output	reg			image_addr_flag,
     output reg		[4:0]	display_model,
    // output reg		[15:0]	display_number,
	output reg		[10:0]   threshold,
	output reg error
);
parameter IDLE = 3'd0;
parameter MEM_READ = 3'd1;
parameter MEM_WRITE  = 3'd2;
parameter BURST_LEN = 1;

parameter p11 =65791;
parameter p21= 98625;
parameter p22 =197506;
parameter p23 =255;
parameter p31 =33003;
parameter p32= 66093;
parameter p33 =65450;

assign trans_y_temp = -p31+p21*x_cnt+p11*y_cnt;
assign trans_x_temp = -p32+p22*x_cnt;
assign trans_z_temp = p33+p23*x_cnt;
reg[2:0] state;
reg[7:0] wr_cnt;
reg[MEM_DATA_BITS - 1:0] wr_burst_data_reg;
//reg	[15:0]	 wr_burst_data_reg_add;
assign wr_burst_data = wr_burst_data_reg;
reg[7:0] rd_cnt;
reg[31:0] write_read_len;
//reg	[10:0]	time_cnt;
wire signed [31:0] trans_x_temp,trans_y_temp,trans_z_temp;
wire [31:0] trans_x , trans_y;

//always@(posedge mem_clk or posedge rst)
//begin
//	if(rst)
//		time_cnt	<=	'b0;
//	else if( state == IDLE )
//		time_cnt	<=	time_cnt	+	1'b1;
//	else
//		time_cnt	<=	'b0;
//end

parameter	[31:0]	IMAGE_SIZE	=	32'hc0000;

//always@(posedge mem_clk or posedge rst)
//begin
//	if(rst)
//		wr_burst_data_reg_add	<=	16'h1111;
//    else if( wr_burst_data_reg_add	>=	16'hefff)
//        wr_burst_data_reg_add	<=	16'h1111;
//	else if(   (write_read_len == IMAGE_SIZE ))
//		wr_burst_data_reg_add	<=	wr_burst_data_reg_add	+	16'h1111;
//end


wire    signed [12:0]  x_cnt    =    write_read_len[9:0]; 
wire    signed [12:0]  y_cnt    =    write_read_len[31:10];

parameter	MAX_X	=	256*4;
parameter	MAX_Y	=	768;

wire signed [31:0] temp_1,temp_2,temp_3,temp_4;

//assign temp_1 =(y_cnt-256)*510;
//assign temp_2 =(x_cnt-512)*254;
//assign temp_3 =(y_cnt-726)*510;
//assign temp_4 =(512-x_cnt)*256;


always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		wr_burst_data_reg <= 64'b0;
				
//         else if( ((temp_1 < temp_2) | (temp_3 > temp_4))&(x_cnt<512))
//	     wr_burst_data_reg <= 64'hdddd;
	   else if(state == MEM_READ && rd_burst_data_valid )
		wr_burst_data_reg <= rd_burst_data;
end


reg					i_en;
wire				o_en;



div div_m0(.a(trans_x_temp),
           .b(trans_z_temp),
           .yshang(trans_x));

div div_m1(.a(trans_y_temp),
           .b(trans_z_temp),
           .yshang(trans_y));

always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		display_model	<=	0;
	else if( display_model == 8 )
		display_model	<=	'b0;
    else if( key_out[0] )
		display_model	<=	display_model	+	5'd1;	
end



always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		rd_burst_addr 		<='h000000;
	else if( write_read_len == IMAGE_SIZE )
		rd_burst_addr 		<='h000000;
	else	   if(x_cnt<=500)
		      rd_burst_addr 	<= 	rd_burst_addr_start	+	trans_x	+	1024*trans_y;
               
                else 
               rd_burst_addr <= rd_burst_addr_start + write_read_len;               ;	
	
end
		

reg	[31:0]	wr_burst_addr_start;
reg	[31:0]	rd_burst_addr_start;


always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		wr_burst_addr_start	<=32'd6220800 ;
	else if( image_addr_flag )					//image_addr_flag==1
		wr_burst_addr_start	<=32'd4147200 ;
	else	
		wr_burst_addr_start	<=32'd6220800;		//image_addr_flag==0
end

always@(posedge mem_clk or posedge rst)
begin
	if(rst)
		rd_burst_addr_start	<=32'd2073600;
	else if( image_addr_flag )					//image_addr_flag==1
		rd_burst_addr_start	<=32'd0  ;
	else	
		rd_burst_addr_start	<=32'd2073600;		//image_addr_flag==0
end


always@(posedge mem_clk or posedge rst)
begin
	if(rst)
	begin
  //      angle                <=    'b0;
        state 				<= IDLE;
		i_en				<=	1'b1;
		image_addr_flag		<=	1'b0;
		
		wr_burst_req 		<= 1'b0;
		rd_burst_req 		<= 1'b0;
		
		rd_burst_len 		<= BURST_LEN;
		wr_burst_len 		<= BURST_LEN;
		
		wr_burst_addr 		<='h000000;
		
		write_read_len 		<= 32'd0;
	end

    else if( write_read_len == IMAGE_SIZE )
        begin
	//		angle	<=		angle_temp;

			i_en			<=	1'b0;
			state			<=	IDLE;
            write_read_len	<= 	32'd0;
			image_addr_flag	<=	~image_addr_flag;	
			
			wr_burst_req 	<=	1'b0;
			rd_burst_req 	<=	1'b0;		
		
			wr_burst_addr 	<=	32'd2073600;
			
        end


	else
	begin
		case(state)
			IDLE:			
			begin
				i_en			<=	1'b0;
				state 			<= 	MEM_READ;
				rd_burst_req 	<= 	1'b1;														
			end
			
			MEM_READ:
			begin
				if(rd_burst_finish)
				begin
					state 			<= 	MEM_WRITE;					
					rd_burst_req 	<= 	1'b0;				
					wr_burst_req 	<=	1'b1;				
					wr_burst_addr 	<= 	wr_burst_addr_start  +	x_cnt	+	1024*y_cnt;
				end
			end
			
			MEM_WRITE:
			begin
				if(wr_burst_finish)
				begin
					state 			<=	IDLE;
					wr_burst_req 	<=	1'b0;
					write_read_len 	<= write_read_len +	1'b1;
					i_en			<=	1'b1;
				end
			end

			default:
				state <= IDLE;
		endcase
	end
end


endmodule