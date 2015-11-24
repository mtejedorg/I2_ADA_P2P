--Marco Tejedor González
with Lower_Layer_UDP;
with Maps_G;
with Maps_Protector_G;
with Ada.Calendar;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ordered_Maps_G;
with Ordered_Maps_Protector_G;
with Utiles;
with Timed_Handlers;

package Chat_Handler is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
	package AC renames Ada.Calendar;
	package TIO renames Ada.Text_IO;
	package U renames Utiles;
	package TH renames Timed_Handlers;
	use type AC.Time;
	use U;

	Prompt: Boolean := False;
	Plazo_Retransmision: Duration;
	End_Error: exception;

	package NP_Neighbors is new Maps_G
		(Key_Type 	=> LLU.End_Point_Type,
       Value_Type => AC.Time,
		 Null_Key 	=> null,
		 Null_Value => AC.Clock,
		 Max_Length => Max_Neigh_Length,
	    "="        => LLU."=",
	    Key_To_String  	=> Writable_EP,
	    Value_To_String  => Time_To_String);
	package NP_Latest_Msgs is new Maps_G
		(Key_Type 	=> LLU.End_Point_Type,
       Value_Type => Seq_N_T,
		 Null_Key 	=> null,
		 Null_Value => 0,
		 Max_Length => Max_LM_Length,
       "="        => LLU."=",
		 Key_To_String  	=> Writable_EP,
       Value_To_String  => Seq_N_T'Image);

	package Neighbors is new Maps_Protector_G (NP_Neighbors) ;
	package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);

	package NP_Sender_Dests is new Ordered_Maps_G
		(Key_Type		=> Mess_Id_T,
		 Value_Type		=> Destinations_T,
		 "="				=> SD_Igual,
		 "<"				=> SD_Menor,
		 ">"				=> SD_Mayor,
		 Key_To_String	=> MIT_To_String,
		 Value_To_String=>DT_To_String);

	package NP_Sender_Buffering is new Ordered_Maps_G
		(Key_Type		=> AC.Time,
		 Value_Type		=> Value_T,
		 "="				=> AC."=",
		 "<"				=> AC."<",
		 ">"				=> AC.">",
		 Key_To_String	=> Time_To_String,
		 Value_To_String=>VT_To_String);

	package Sender_Dests is new Ordered_Maps_Protector_G (NP_Sender_Dests) ;
	package Sender_Buffering is new Ordered_Maps_Protector_G (NP_Sender_Buffering);

	type User_Type is record
		Nick: ASU.Unbounded_String;
		Neigh: Neighbors.Prot_Map;
		Max_Neigh: Natural := Max_Neigh_Length;
		L_Msgs: Latest_Msgs.Prot_Map;
		Max_LM: Natural := Max_LM_Length;
		Port: Natural;
		Conf_Sent: Boolean := False;
		Min_Delay: Natural;	--milisegundos
		Max_Delay: Natural;	--milisegundos
		Fault_Pct: Natural;	--limitado de 0 a 100
		Seq_N: Seq_N_T := 0;
		EP_H: LLU.End_Point_Type;
		EP_R: LLU.End_Point_Type;
		S_Dests: Sender_Dests.Prot_Map;
		S_Buff: Sender_Buffering.Prot_Map;
	end record;

	Myself: User_Type;

   -- This procedure must NOT be called. It's called from LLU
	
   procedure Peer_Handler (From     : in     LLU.End_Point_Type;
                           To       : in     LLU.End_Point_Type;
                           P_Buffer : access LLU.Buffer_Type);

	procedure Prot_Salida;

	procedure Delete_Neighbors_Map (N_M: in out Neighbors.Prot_Map);
	procedure Delete_LM_Map (LM_M: in out Latest_Msgs.Prot_Map);


end Chat_Handler;
