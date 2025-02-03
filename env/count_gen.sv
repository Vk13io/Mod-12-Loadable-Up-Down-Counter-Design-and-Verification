


















class count_gen;
count_trans trans_h;
count_trans data2send;

mailbox #(count_trans) gen2drv;
function new(mailbox #(count_trans) gen2drv);

this.gen2drv = gen2drv;
trans_h = new();


endfunction:new
virtual task start();
	fork
		begin
			for(int i = 0;i<no_of_transactions;i++)
			begin
				assert(trans_h.randomize());
				data2send = new trans_h;
				gen2drv.put(data2send);				

			end			



		end

	join_none


endclass:count_gen






