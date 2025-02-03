
//////////////////////////////////\\\\Package////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
package counter_trans;

int no_of_transactions = 100;
endpackage
import counter_trans::*;
//////////////////////////////////\\\\\\RTL//////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

module counter(data_in,data_out,rst,clk,load,mode);

	input [3:0]data_in;
	input rst,clk,load,mode;
	output reg [3:0]data_out;
always @(posedge clk)
begin
	if(rst)
		data_out <= 0 ;
	else if(load)
		data_out <= data_in;
	else if(mode)
	begin
		if(data_out == 4'd11)
			data_out <= 4'd0;
		else
		   data_out <= data_out  + 1'b1;
	end
	else
	begin
		if(data_out == 4'd0)
			data_out <= 4'd11;
		else 
			data_out <= data_out - 1'b1;


	end

end

endmodule

/////////////////////////////////INTERFACE\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


interface count_if(input bit clk);

	logic  [3:0]data_in;
	logic  [3:0]data_out;
	logic  load,rst,mode;
	

	//////////////CLOCKING BLOCKS - 3 //////////////////

	/* clocking write driver */
	clocking wr_drv @(posedge clk);
		default input #1 output #1;
		output rst;
		output mode;
		output load;
		output data_in;
	endclocking: wr_drv

	
	/* clocking write monitor */
	clocking wr_mon @(posedge clk);
		default input #1 output #1;
		input rst;
		input mode;
		input load;
		input data_in;
	endclocking: wr_mon
	


	/* clocking read monitor */
	clocking rd_mon @(posedge clk);
		default input #1 output #1;
		input data_out;
	endclocking:rd_mon

	/*Modports declarations */

	modport WR_DRV_MP(clocking wr_drv);
	modport WR_MON_MP(clocking wr_mon);
	modport RD_MON_MP(clocking rd_mon);

endinterface: count_if

//Class Transaction

class count_trans;
	rand bit load,mode,rst;
	rand bit [3:0]data_in;
	
	logic [3:0]data_out;

	constraint c1{rst dist{0:=10, 1:=1};}
	constraint c2{load dist{0:=4, 1:=1};}
	constraint c3{mode dist{0:=10, 1:=10};}
	constraint c4{data_in <12;}	
	static int tr_id;
	
	//int no_of_transactions = 10;
	
	function void display(input string s);
	$display("\n /////////////////////////////////////////////");
	$display("\n Input String Message %s ",s);
	$display("\n %0t ---- tr_id - %d, rst - %d load - %d mode - %d data_in - %d data_out - %d ",$time,tr_id, rst,load,mode,data_in,data_out);
	
	$display("\n /////////////////////////////////////////////");
	endfunction:display

	function void post_randomize();
	tr_id++;
	endfunction: post_randomize

endclass:count_trans


//generator
class count_gen;


	count_trans gen_trans;  //object creation
	count_trans data2send;  //shallow copy

	mailbox #(count_trans) gen2wr;
	
	function new(mailbox #(count_trans) gen2wr);
		this.gen2wr = gen2wr;
		gen_trans   = new();
	endfunction:new

	virtual task start;
	fork
	begin
		//for(int i=0;i<gen_trans.no_of_transactions;i++)
		for(int i=0;i<no_of_transactions;i++)
		begin
			assert(gen_trans.randomize());
			data2send = new gen_trans;
			gen2wr.put(data2send);
		end
	end
	join_none
	endtask
	
endclass:count_gen


///////////////write driver

class count_wrdrv;
	
	virtual count_if.WR_DRV_MP wr_drv_vif;
	
	count_trans data2duv;
	mailbox #(count_trans) gen2wr;
	
	function new(virtual count_if.WR_DRV_MP wr_drv_vif,mailbox #(count_trans) gen2wr);
	this.wr_drv_vif = wr_drv_vif;
	this.gen2wr = gen2wr;
	endfunction:new
	
	virtual task drive;
	@(wr_drv_vif.wr_drv);
	begin
		wr_drv_vif.wr_drv.rst <= data2duv.rst;
		wr_drv_vif.wr_drv.load <= data2duv.load;
		wr_drv_vif.wr_drv.mode <= data2duv.mode;
		wr_drv_vif.wr_drv.data_in <= data2duv.data_in;
	end
	endtask:drive
	
	virtual task start();
	fork
	forever
	begin
		gen2wr.get(data2duv);
		drive();
	end
	join_none
	endtask
	endclass


	////////////////////WRITE MONITOR///////////////

	class count_wr_mon;
	
	virtual count_if.WR_MON_MP wr_mon_vif;

	count_trans data2rm;
	
	
	mailbox #(count_trans) wr2rm;
	
	function new(virtual count_if.WR_MON_MP wr_mon_vif,mailbox #(count_trans) wr2rm);
	
	this.wr_mon_vif = wr_mon_vif;
	this.wr2rm     = wr2rm;
 	data2rm = new();
	endfunction:new

	task monitor;
	//repeat(2) //ith add akiyapad pottathet vannu monitor ilot
	@(wr_mon_vif.wr_mon);
	//@(wr_mon_vif.wr_mon); // ithum mele thente oppam akiyapolm monitor wrk avnila, ennit ee rand delay um ozhivaki sanm ready ann
	begin
		data2rm.rst = wr_mon_vif.wr_mon.rst;	
		data2rm.load = wr_mon_vif.wr_mon.load;
		data2rm.mode = wr_mon_vif.wr_mon.mode;
		data2rm.data_in = wr_mon_vif.wr_mon.data_in;
	end
	endtask:monitor

	task start;
	$display("WM Start");
	fork
	forever
		begin
			monitor();
			wr2rm.put(data2rm);
		end
	join_none
	endtask:start
	endclass



	////////////////////////Read Monitor/////////////////////////////////

	class count_rd_mon;
	
	virtual count_if.RD_MON_MP rd_mon_vif;
	
	count_trans data2rm; //object creation	
	count_trans data2sb; //Shallow copy ,to keep safe copy
	
	mailbox #(count_trans) mon2sb;

	function new(virtual count_if.RD_MON_MP rd_mon_vif,mailbox #(count_trans) mon2sb);
		this.rd_mon_vif = rd_mon_vif;
		this.mon2sb     = mon2sb;
		data2rm         = new();
	endfunction:new
	
	task monitor;
	//repeat(2) ith add akiyapad pottathet vannu monitor ilot
	@(rd_mon_vif.rd_mon);
	//@(rd_mon_vif.rd_mon); // ithum mele thente oppam akiyapolm monitor wrk avnila, ennit ee rand delay um ozhivaki sanm ready ann
	begin
		data2rm.data_out = rd_mon_vif.rd_mon.data_out;
		data2rm.display("\nData from Read Monitor");
	end
	endtask :monitor

	task start;
	$display("Read Start");
	fork 
	
	begin
	
	forever
	begin // here you didn't begin
		monitor();
		data2sb = new data2rm;
		mon2sb.put(data2sb);
	//begin- here you have typed begin, in the wrong place
	
	end
	end
	join_none


	endtask:start
	endclass

/////////////////////////////////////REFERNCE MODEL//////////////////////////////////
class count_ref_mod;
	
	count_trans mon_data,mon_data2;
	
	mailbox #(count_trans) wr2rm;
	mailbox #(count_trans) rm2sb;
	
	function new(mailbox #(count_trans) wr2rm,mailbox #(count_trans) rm2sb);
	
		this.wr2rm = wr2rm;
		this.rm2sb = rm2sb;
	
	endfunction:new

	task counter(count_trans mon_data);
	begin
	     if(mon_data.rst)
		mon_data.data_out <= 4'd0;
	     else if(mon_data.load)
		mon_data.data_out <= mon_data.data_in;
	     else if(mon_data.mode)
		begin
			if(mon_data.data_out == 4'd11)
			mon_data.data_out <= 4'd0;
			else
			mon_data.data_out <= mon_data.data_out + 1;
		end
	     else
		begin
			if(mon_data.data_out == 4'd0)
			mon_data.data_out <= 4'd11;
			else
			mon_data.data_out <= mon_data.data_out - 1;
		end	
	end
	endtask:counter

	task start;
	fork 
		begin
	//		fork			//ADDED FORK JOIN IN BEGIN END OF FORK JOIN_NONE
	//			begin		//added here 
					forever
						begin	
						wr2rm.get(mon_data);
						counter(mon_data);
						mon_data2=new mon_data;
						rm2sb.put(mon_data2);
						mon_data2.display("reference Model Data");
						end
	//			end
	//		join
		end
	join_none
	endtask:start

endclass

	/////////////////SCOREBOARD//////////////
class count_sb;
	
	event DONE;
	int data_verified;
	
	int data_mismatch;
	int data_match;

	count_trans rmdata,sbdata,cov_data;
	
	mailbox #(count_trans) rm2sb;  //reference model to score board
	mailbox #(count_trans) rd2sb; // read monitor to score board 
	
	covergroup coverage;
		RST : coverpoint cov_data.rst;
		MODE : coverpoint cov_data.mode;
		LOAD : coverpoint cov_data.load;   //Here total 7 bins here
		DATA_IN : coverpoint cov_data.data_in {bins a= {[1:10]};} //tracking the datas from 1 to 10 only
		CR : cross RST,MODE,LOAD,DATA_IN; //total 8 bins
	endgroup:coverage		//total bins === 15
				
	function new(mailbox #(count_trans) rm2sb,mailbox #(count_trans) rd2sb);
		
		this.rm2sb = rm2sb;
		this.rd2sb = rd2sb;
		coverage = new();

	endfunction: new

	//Coverage Code
	task start;
	fork 
		while(1)
		begin
			rm2sb.get(rmdata);
	
			rd2sb.get(sbdata);

		        check(sbdata);
		end
	join_none

	endtask:start

	virtual task check(count_trans rddata);
	if(rmdata.data_out == rddata.data_out)
	begin
		$display("Data Verified");
		data_match++;
	end

	else
	begin	
		$display("Data Mismatch");
		data_mismatch++;
	end
	
	
	cov_data = new rmdata;
	
	coverage.sample();
	
	data_verified++;
	
	//if(data_verified == rmdata.no_of_transactions)
	if(data_verified == no_of_transactions)
	begin
		->DONE;
	end
	endtask:check


	function void report;
	$display("\n //////////////////SCOREBOARD REPORT//////////////////////////");
	$display("\n Data Matched : %0d",data_match);
	
	$display("Data Mismatched : %0d",data_mismatch);
	$display("Data Verified: %0d",data_verified);
	$display("\n Coverage is : %0.3f",$get_coverage());
	$display("\n //////////////////SCOREBOARD REPORT//////////////////////////");
	endfunction:report

	
endclass:count_sb

/////////////////////////	environment     //////////////////////////////
class count_env;
	
	virtual count_if.WR_DRV_MP wr_drv_vif;	
	virtual count_if.WR_MON_MP wr_mon_vif;
	virtual count_if.RD_MON_MP rd_mon_vif;
	

	mailbox #(count_trans) gen2wr = new();
	mailbox #(count_trans) wr2rm  = new();
	mailbox #(count_trans) mon2sb = new();
	mailbox #(count_trans) rm2sb  = new(); 


	count_gen gen_h;
	count_wrdrv wr_drv_h;
	count_wr_mon wr_mon_h;
	count_rd_mon rd_mon_h;
	count_ref_mod ref_mod_h;
	count_sb sb_h;
	
	function new ( virtual count_if.WR_DRV_MP wr_drv_vif,virtual count_if.WR_MON_MP wr_mon_vif,virtual count_if.RD_MON_MP rd_mon_vif);
	
	this.wr_drv_vif = wr_drv_vif;
	this.wr_mon_vif = wr_mon_vif;
	this.rd_mon_vif = rd_mon_vif;
	
	endfunction:new

	virtual task build;
	
	gen_h = new(gen2wr);
	wr_drv_h = new(wr_drv_vif,gen2wr);
	wr_mon_h = new(wr_mon_vif,wr2rm);
	rd_mon_h = new(rd_mon_vif,mon2sb);
	ref_mod_h = new(wr2rm,rm2sb);
	sb_h = new(rm2sb,mon2sb);
	endtask:build

	virtual task start;
	gen_h.start();
	wr_drv_h.start();
	wr_mon_h.start();
	rd_mon_h.start();
	ref_mod_h.start();
	sb_h.start();
	endtask:start

	virtual task stop;
		wait(sb_h.DONE.triggered);
	endtask:stop
	
	virtual task run;
	
	start;	
	stop;	
	sb_h.report;
	
	endtask:run
	
endclass

///////////////////////////////TEST CLASS/////////////////////////
class testcase;

	virtual count_if.WR_DRV_MP wr_drv_vif;	
	virtual count_if.WR_MON_MP wr_mon_vif;
	virtual count_if.RD_MON_MP rd_mon_vif;

	count_env env_h;

	function new ( virtual count_if.WR_DRV_MP wr_drv_vif,virtual count_if.WR_MON_MP wr_mon_vif,virtual count_if.RD_MON_MP rd_mon_vif);
	
	this.wr_drv_vif = wr_drv_vif;
	this.wr_mon_vif = wr_mon_vif;
	this.rd_mon_vif = rd_mon_vif;
	
	env_h = new(wr_drv_vif,wr_mon_vif,rd_mon_vif);
	endfunction:new

	task build_and_run;
	
	env_h.build();
	env_h.run();
	//$finish;
	endtask:build_and_run
endclass:testcase

//////////////////////////////TOP//////////////////////////////////////////
module top;
	
	bit clk;

	always #5 clk=~clk;
	
	count_if DUV_IF(clk);
	testcase test_h;
	
	counter MOD12(.clk(clk),.rst(DUV_IF.rst),.mode(DUV_IF.mode),.load(DUV_IF.load),.data_in(DUV_IF.data_in),.data_out(DUV_IF.data_out));	
	
	initial 
		begin
			test_h = new(DUV_IF,DUV_IF,DUV_IF);
			//no_of_transactions=10;
			test_h.build_and_run();
			$finish;
		end

endmodule:top

