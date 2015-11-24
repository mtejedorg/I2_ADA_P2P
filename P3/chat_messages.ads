--Marco Tejedor Gonzalez
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
package Chat_Messages is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package TIO renames Ada.Text_IO;
	
	type Message_Type is (Init, Welcome, Writer, Server, Logout);

	type Message is record
		Tipo: Message_Type;
		Client_EP_Receive: LLU.End_Point_Type;
		Client_EP_Handler: LLU.End_Point_Type;
		Nick: ASU.Unbounded_String;
		Acogido: Boolean := False;
		Comment: ASU.Unbounded_String;
	end record;		

end Chat_Messages;
