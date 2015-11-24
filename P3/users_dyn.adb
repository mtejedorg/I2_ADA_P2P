--Marco Tejedor Gonzalez
with Ada.Unchecked_Deallocation;
package body Users is

	procedure Free is new 
	Ada.Unchecked_Deallocation (User, User_A);

--Los siguientes cuatro procedimientos no estan declarados en el ads
--y sirven para otros procedimientos que sí que lo están

	--Crea una lista con una celda
	procedure Begin_User_List
		(L:in out Clients; Cliente: Client) is
	begin
		L.First := new User'(Cliente, null, null);
		L.Last := L.First;
		L.Comenzada := True;
	end Begin_User_List;

	procedure Insert_Next_User_List
		(L:in out Clients; Cliente: Client) is
			P_Aux: User_A;
	begin
		P_Aux := new User'(Cliente, null, L.Last);
		L.Last.Next := P_Aux;
		L.Last := P_Aux;
		P_Aux := null;
	end Insert_Next_User_List;

	procedure Delete_First_User_List(L:in out Clients) is
			P_Aux: User_A;
	begin
		P_Aux := L.First.Next;
		L.First.Next.Prev := null;
		Free (L.First);
		L.First := P_Aux;	
		P_Aux := null;
	end Delete_First_User_List;

	procedure Delete_Last_User_List(L:in out Clients) is
			P_Aux: User_A;
	begin
		P_Aux := L.Last.Prev;
		L.Last.Prev.Next := null;
		Free (L.Last);
		L.Last := P_Aux;	
		P_Aux := null;
	end Delete_Last_User_List;

-------------

	procedure Delete_User (L:in out Clients; Num: Natural; Num_Clients: Natural) is
			P_Aux: User_A;
	begin
		if Num_Clients = 1 then
			Delete_List(L);
		else
			if Num = 1 then
				Delete_First_User_List(L);
			elsif Num = Num_Clients then
				Delete_Last_User_List(L);
			elsif Num <= Num_Clients then
				P_Aux := L.First;
				for N in 2..Num loop
					P_Aux := P_Aux.Next;
				end loop;
					P_Aux.Prev.Next := P_Aux.Next;
					P_Aux.Next.Prev := P_Aux.Prev;
					Free (P_Aux);
			else
				raise Limit_Error;
			end if;
		end if;
	end Delete_User;

	procedure Delete_List(L:in out Clients) is

	begin
		while L.First /= L.Last loop
			Delete_First_User_List(L);
		end loop;
			L.Comenzada := False;
			L.First := null;
			Free (L.Last);
	end Delete_List;


	procedure Replace_User (L:in out Clients; Cliente: Client; Num: Natural; Num_Clients: Natural) is
			P_Aux: User_A;
	begin
		if Num = 1 then
			L.First.Cliente := Cliente;
		elsif Num = Num_Clients then
			L.Last.Cliente := Cliente;
		elsif Num <= Num_Clients then
			P_Aux := L.First;
			for N in 2..Num loop
				P_Aux := P_Aux.Next;
			end loop;
			P_Aux.Cliente := Cliente;
		else
			raise Limit_Error;
		end if;
	end Replace_User;

	function Get_User (L:Clients; Num: Natural; Num_Clients: Natural) return Client is
			P_Aux: User_A;
			Cliente: Client;
	begin
		if Num = 1 then
			Cliente := L.First.Cliente;
		elsif Num = Num_Clients then
			Cliente := L.Last.Cliente;
		elsif Num <= Num_Clients then
			P_Aux := L.First;
			for N in 2..Num loop
				P_Aux := P_Aux.Next;
			end loop;
			Cliente := P_Aux.Cliente;
		else
			raise Limit_Error;
		end if;
		return Cliente;
	end Get_User;


	procedure Add_User (L: in out Clients; Cliente: Client; Num_Clients: Natural) is
	P_Aux : User_A;
	Stop: Boolean := False;
	begin
		P_Aux := L.First;	
		if not L.Comenzada then
			Begin_User_List (L, Cliente);
		else
			Insert_Next_User_List (L, Cliente);
		end if;
	end Add_User;

end Users;
