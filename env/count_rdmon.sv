












class count_rdmon;
	
virtual count_if.RD_MON rdmon_if;

count_trans data2sb,rd_data;

mailbox #(count_trans)mon2sb;

function new(virtual count_if.RD_MON rdmon_if,mailbox #(count_trans)mon2sb);
	begin
		this.rdmon_if = rdmon_if;
		this.mon2sb   = mon2sb;
		rd_data       = new();
	
	end


endfunction:new

virtual task monitor();
begin
@(rdmon_if.rd_cb);
begin
	rd_data.count = rdmon_if.rd_cb.count();
	rd_data.display("From Read Monitor");
end
end

endtask:monitor


virtual task start();
fork
forever
begin

monitor();
data2sb = new rd_data;
mon2sb.put(data2sb);
end
join_none
endtask


endclass:count_rdmon








