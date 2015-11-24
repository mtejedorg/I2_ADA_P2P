--Marco Tejedor Gonzalez
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
package Types is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package TIO renames Ada.Text_IO;
	
	type Server_Type is record
		Host_Name: ASU.Unbounded_String;
		IP: ASU.Unbounded_String;
		Port: Natural;
		EP: LLU.End_Point_Type;
	end record;
		
	type Client_Type is record
		Nick: ASU.Unbounded_String;
		Ep: LLU.End_Point_Type;
	end record;
	
	type Clients is array (1..50) of Client_Type;

end Types;
