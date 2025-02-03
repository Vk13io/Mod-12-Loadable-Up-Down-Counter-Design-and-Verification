




















class count_trans;

rand bit [3:0]datain;
rand bit load;
rand bit mode;

logic [3:0]dataout;
 
virtual function void display(input string s);

begin
$display("-------------------------%s-----------------------",s);
$display("Mode == %d",mode);
$display("Load == %d",load);
$display("Datain == %d",datain);
$display("Dataout == %d",dataout);
$display("Resetn == %d",rst);
$display("------------------------------------------------");
end

endfunction:display



endclass:count_trans







