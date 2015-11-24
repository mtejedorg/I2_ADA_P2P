--Marco Tejedor González
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with ADA.Calendar;
with Chat_Handler;
with Ada.Unchecked_Deallocation;

package Chat_Messages is

	package LLU renames Lower_Layer_UDP;
	use type LLU.End_Point_Type;
	package ASU renames Ada.Strings.Unbounded;
	package AC renames ADA.Calendar;
	package CH renames Chat_Handler;

	type Message_Type is (Init, Reject, Confirm, Writer, Logout, Ack, SN);

	Message_Type_Error: exception;

	type Message_R is record
		Tipo: Message_Type;
		Ep_H_Creat: LLU.End_Point_Type;
		Seq_N: CH.U.Seq_N_T;
		EP_H_Rsnd: LLU.End_Point_Type;
		EP_H_ACKer: LLU.End_Point_Type;
		EP_H_Neigh: LLU.End_Point_Type;
		Ep_R_Creat: LLU.End_Point_Type;
		Nick: ASU.Unbounded_String;
		EP_H: LLU.End_Point_Type;
		Text: ASU.Unbounded_String;
		Confirm_Sent: Boolean;
	end record;

	P_Buffer_Main: CH.U.Buffer_A_T;
	P_Buffer_Handler: CH.U.Buffer_A_T;
	P_Buffer_SN_Main: CH.U.Buffer_A_T;
	P_Buffer_SN_Handler: CH.U.Buffer_A_T;

	procedure Buff_To_Msg_R (P_Buffer_H: access LLU.Buffer_Type; M: out Message_R);

	procedure Free is new Ada.Unchecked_Deallocation (LLU.Buffer_Type, CH.U.Buffer_A_T);

	procedure Retry (Time: in AC.Time);

	procedure Send_SN
			(Destination: LLU.End_Point_Type; 
			 EP_H: LLU.End_Point_Type;
			 Seq_N: CH.U.Seq_N_T);

	procedure Send_ACK 
			(Destination: LLU.End_Point_Type; 
			 EP_H_ACKer: LLU.End_Point_Type;
			 EP_H_Creat: LLU.End_Point_Type;
			 Seq_N: CH.U.Seq_N_T);

	procedure Send_Reject 
			(Destination: LLU.End_Point_Type; 
			 EP_H: LLU.End_Point_Type;
			 Nick: ASU.Unbounded_String);

	procedure Send_Flood_MR
			(P_Buffer: in out CH.U.Buffer_A_T;
			 Who: in out CH.User_Type; 
			 M: in out Message_R);

	procedure Main_Send_Flood 
			(Myself: in out CH.User_Type; 
			Tipo: Message_Type;
			Comentario: ASU.Unbounded_String 
				:= ASU.To_Unbounded_String("sin texto"));

end Chat_Messages;
