
















class count_wrdrv;
	virtual count_if.DRV dr_if;
	
	count_trans data2duv;
	
	mailbox #(count_trans)gen2dr;
	
	function new(virtual count_if.DRV dr_if,mailbox #(count_trans)gen2dr)
	begin
		this.dr_if = dr_if;
		this.gen2dr = gen2dr;

	endfunction:new
	
	virtual task drive();
		begin
			@(dr_if.drv_cb);
			dr_if.drv_cb.load    <= data2duv.load;
			dr_if.drv_cb.datain  <= data2duv.dataout;
			dr_if.drv_cb.mode    <= daata2duv.mode;

		end
	endtask:drive
		
	





endclass:count_wrdrv














