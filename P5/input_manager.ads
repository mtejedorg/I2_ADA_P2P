--Marco Tejedor González
with Pantalla;
with Chat_Handler;
with ADA.Calendar;
with ADA.Text_IO;
with ADA.Strings.Unbounded;
with Lower_Layer_UDP;
with Debug;
with Chat_Messages;

package Input_Manager is

	package LLU renames Lower_Layer_UDP;
	use LLU;
	package ASU renames Ada.Strings.Unbounded;
	package AC renames ADA.Calendar;
	package CH renames Chat_Handler;
	package TIO renames ADA.Text_IO;
	package D renames Debug;

	procedure Manage_Input(Comentario: ASU.Unbounded_String; Myself: in out CH.User_Type; Final: in out Boolean; Prompt: in out Boolean; Text: out Boolean);

end Input_Manager;
