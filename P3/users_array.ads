--Marco Tejedor Gonzalez
with Lower_Layer_UDP;
with ADA.Calendar;
with Types;
package Users is

	package LLU renames Lower_Layer_UDP;
	package AC renames ADA.Calendar;

	subtype Client is Types.Client_Type;
	type Clients is private;

	Limit_Error: exception;

	procedure Delete_User(L:in out Clients; Num: Natural; Num_Clients: Natural);

	procedure Delete_List(L:in out Clients);

	procedure Replace_User (L:in out Clients; Cliente: Client; Num: Natural; Num_Clients: Natural);

	function Get_User (L: Clients; Num: Natural; Num_Clients: Natural) return Client;

	procedure Add_User (L: in out Clients; Cliente: Client; Num_Clients: Natural);

	private
		type Clients is array (1..50) of Client;

end Users;
