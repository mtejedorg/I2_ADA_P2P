--Marco Tejedor Gonzalez

package body Users is

	procedure Delete_User(L:in out Clients; Num: Natural; Num_Clients: Natural) is
		N: Natural := Num + 1;
		M: Natural;
		Cliente: Client;
	begin
		for K in N..Num_Clients loop
			M:= K-1;
			L(M) := L(K);
		end loop;
		L(Num_Clients) := Cliente;
	end Delete_User;

	procedure Delete_List(L:in out Clients) is
		Cliente: Client;
	begin
		for K in 1..Clients'Length loop
			L(K) := Cliente;
		end loop;
	end Delete_List;

	procedure Replace_User (L:in out Clients; Cliente: Client; Num: Natural; Num_Clients: Natural) is
		
	begin
		if Num <= Num_Clients then
			L(Num) := Cliente;
		else
			raise Limit_Error;
		end if;
	end Replace_User;

	function Get_User (L: Clients; Num: Natural; Num_Clients: Natural) return Client is
		Cliente: Client;
	begin
		if Num <= Num_Clients then
			Cliente := L(Num);
		else
			raise Limit_Error;
		end if;
		return Cliente;
	end Get_User;

	procedure Add_User (L: in out Clients; Cliente: Client; Num_Clients: Natural) is
			N: Natural := Num_Clients + 1;
		begin
			L(N) := Cliente;
		end Add_User;

end Users;
