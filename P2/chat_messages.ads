--Marco Tejedor Gonzalez
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
package Chat_Messages is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package TIO renames Ada.Text_IO;
	
	type Message_Type is (Init, Writer, Server);

	type Message is record
		Tipo: Message_Type;
		Client_EP: LLU.End_Point_Type;
		Nick: ASU.Unbounded_String;
		Comment: ASU.Unbounded_String;
	end record;		

end Chat_Messages;
