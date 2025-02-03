





//Interface signals
interface count_if(input bit clock);
	logic [3:0]datain;
	logic [3:0] dataout;
	logic mode;
	logic rst;

//Driver clocking block
clocking drv_cb@(posedge clk);
	default input #1 output #1;
	output datain;
	output load;
	output mode;
endclocking

//Write monitor clocking block
clocking wr_cb@(posedge clk);
	default input #1 output #1;
	input datain;	
	input load;
	input mode;
endclocking

//Read Monitor blocking block
clocking rd_cb@(posedge clk);
	default input #1 output #1;
	input dataout;
endclocking

//Driver
modport DRV(clocking dr_cb);

//Write Monitor
modport WR_MON(clocking wr_cb);

//Read Monitor
modport RD_MON(clocking rd_cb);

endinterface