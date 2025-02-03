























module counter(datain,dataout,rst,clk,load,mode);

	input [3:0]datain;
	input rst,clk,load,mode;
	output reg [3:0]dataout'
always @(posedge clk)
begin
	if(rst)
		dataout <= 0 ;
	else if(load)
		dataout <= dtain;
	else if(mode)
	begin
		if(dataout == 4'd11)
			dataout <= 4'd0;
		else
		   dataout <= dataout  + 4'b1;
	end
	else
	begin
		if(dataout == 4'd0)
			dataout <= 4'd11;
		else 
			dataout <= dataout - 1'b1;


	end

end

endmodule


