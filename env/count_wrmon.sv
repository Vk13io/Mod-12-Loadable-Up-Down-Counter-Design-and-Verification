











class count_wrmon;
	virtual count_if.WR_MON wrmon_if;
	
	count_trans data2rm,wr_data;
	mailbox #(count_trans)mon2rm;

	function new(virtual count_if.WR_MON wrmon_if,mailbox #(count_trans) mon2rm);
		begin 
			this.wrmon_if = wrmon_if;
			this.mon2rm   = mon2rm;
			wr_data       = new();
		end		
	endfunction:new
	
	virtual task monitor();
		begin
		@(wrmon_if.wr_cb)
		begin
			wr_data.mode = wrmon_if.wr_cb.mode;
			wr_data.load = wrmon_if.wr_cb.load;
			wr_data.datain = wrmon_if.wr_cb.datain;
			wr_data.display("From Write Monitor");
		

		end
		end
	
	endtask:monitor
	
	virtual task start();
		fork
			forever
				begin
					monitor();
					data2rm = new wr_data;
					mon2rm.put(data2rm);
					
				end
		join_none
	endtask:start
	 



endclass:count_wrmon


