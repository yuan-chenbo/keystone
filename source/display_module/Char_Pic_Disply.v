module Char_Pic_Disply
( 	
	input                   rst_n,   
	input                   clk,
	input		[11:0]		x,        // video position X
	input		[11:0]		y,         // video position y
		
	input                   i_hs,    
	input                   i_vs,    
	input                   i_de,    
	input		[23:0]		i_data,


	output                  o_hs,    
	output                  o_vs,    
	output                  o_de,    
	output		[23:0]		o_data

);

reg       [40:0]    time_cnt;

reg 			de_d0;
reg 			de_d1;
reg 			vs_d0;
reg 			vs_d1;
reg 			hs_d0;
reg 			hs_d1;
reg		[23:0]	vout_data;	

wire	[11:0] 	x_cnt	=	x;
wire	[11:0]	y_cnt	=	y;


parameter	LSB			=	2;
parameter	LSB2		=	2;

assign o_de 	= 	de_d0;
assign o_vs 	= 	vs_d0;
assign o_hs 	= 	hs_d0;
assign o_data 	= 	vout_data;

always@(posedge clk)
begin
	de_d0 		<= 	i_de	;
	vs_d0 		<= 	i_vs	;	
	hs_d0 		<= 	i_hs	;
end

always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
        time_cnt    <=    'b0;
    else 
        time_cnt    <=    time_cnt    +    5;
end



parameter OSD_WIDTH   =  12'd248;
parameter OSD_HEGIHT  =  12'd26;//OK

reg        [15:0]  osd_ram_addr;
wire        [7:0]  q;
reg[11:0]  osd_x;
reg[11:0]  osd_y;
reg        region_active;
reg        region_active_d0;
reg        region_active_d1;
reg        region_active_d2;

always@(posedge clk)
begin
	if(y_cnt >= 12'd9 && y_cnt <= 12'd9 + OSD_HEGIHT - 12'd1 && x_cnt >= 12'd9 && x_cnt  <= 12'd9 + OSD_WIDTH - 12'd1)
		region_active <= 1'b1;
	else
		region_active <= 1'b0;
end

always@(posedge clk)
begin
	region_active_d0 <= region_active;
	region_active_d1 <= region_active_d0;
	region_active_d2 <= region_active_d1;
end

//delay 2 clock
//region_active_d0
always@(posedge clk)
begin
	if(region_active_d0 == 1'b1)
		osd_x <= osd_x + 12'd1;
	else
		osd_x <= 12'd0;
end

always@(posedge clk)
begin
	if( vs_d0 == 1'b1 && i_vs == 1'b0)
		osd_ram_addr <= 16'd0;
	else if(region_active == 1'b1)
		osd_ram_addr <= osd_ram_addr + 16'd1;
end

osd_rom osd_rom_m0 
(
    .addr       (osd_ram_addr[15:3]),
    .clk        (clk),
    .rst        (1'b0),
    .rd_data    (q)
);


always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		vout_data	<=	24'b0;
    else if(region_active_d0 == 1'b1 && q[osd_x[2:0]] == 1'b1)		
        vout_data <= 24'hff0000;  
    else if(region_active_d0 == 1'b1 )      
        vout_data <= 24'hffffff;
	
	else
		vout_data	<=	i_data;
end


endmodule 