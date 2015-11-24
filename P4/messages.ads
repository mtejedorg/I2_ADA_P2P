--Marco Tejedor González
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with ADA.Calendar;
with Chat_Handler;

package Messages is

	package LLU renames Lower_Layer_UDP;
	use LLU;
	package ASU renames Ada.Strings.Unbounded;
	package AC renames ADA.Calendar;
	package CH renames Chat_Handler;
	package Neigh renames Chat_Handler.Neighbors;
	package L_Msgs renames Chat_Handler.Latest_Msgs;

	type Message_Type is (Init, Reject, Confirm, Writer, Logout);

	Message_Type_Error: exception;

	type Message_R is record
		Tipo: Message_Type;
		Ep_H_Creat: LLU.End_Point_Type;
		Seq_N: Chat_Handler.Seq_N_T;
		EP_H_Rsnd: LLU.End_Point_Type;
		Ep_R_Creat: LLU.End_Point_Type;
		Nick: ASU.Unbounded_String;
		EP_H: LLU.End_Point_Type;
		Text: ASU.Unbounded_String;
		Confirm_Sent: Boolean;
	end record;

	function H_Buff_To_Msg_R (P_Buffer: access LLU.Buffer_Type) return Message_R;

	function Users_To_Msg_R (Whose: CH.User_Type; Who_Not: LLU.End_Point_Type; Tipo: Message_Type; Conf: Boolean; Text: ASU.Unbounded_String) return Message_R;

	procedure Send_Reject 
			(Destination: LLU.End_Point_Type; 
			 EP_H: LLU.End_Point_Type;
			 Nick: ASU.Unbounded_String);

	procedure Send_Flood_MR
			(Who: in out CH.User_Type; 
			 M: in out Message_R);

--Si es un logout y envió un confirm hay que decirlo explícitamente
	procedure Send_Flood 
			(Whose: CH.User_Type; 
			 Who: in out CH.User_Type; 
			 Who_Not: LLU.End_Point_Type;
			 M_Type: Message_Type;  
			 Conf: Boolean := False;
			 Text: ASU.Unbounded_String := ASU.To_Unbounded_String("sin texto"));

	procedure Resend_Flood (Who: in out CH.User_Type; M: in out Message_R);

end Messages;
