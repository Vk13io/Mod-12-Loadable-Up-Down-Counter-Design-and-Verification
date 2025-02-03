











class count_refmodel;

count_trans w_data;
static logic[3:0]ref_count = 0 ;
	mailbox #(count_trans) wrmon2rm;
	mailbox #(count_trans) rm2sb;
function new(mailbox #(count_trans) wrmon2rm,mailbox #(count_trans)rm2sb);
	this.wrmon2rm = wrmon2rm;
	this.rm2sb    = rm2sb;

endfunction:new

virtual task count_mod(count_trans model_counter);
begin
if(model_counter.load)
	ref_count <= model_counter.w_data;
	wait(model_counter.load == 0)
	begin
		if(model_counter.mode == 0)
			begin 
			
				if()


				/*
				if(ref_count>12)
					ref_count  <= 4'd0;
				else
				   ref_count <= ref_count + 1'b1;
				*/
			end

		else
			


	end

end
endtask:count_mod



endclass:count_refmodel
