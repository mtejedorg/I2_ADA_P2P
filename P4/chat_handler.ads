--Marco Tejedor González
with Lower_Layer_UDP;
with Maps_G;
with Maps_Protector_G;
with Ada.Calendar;
with Ada.Text_IO;
with Ada.Strings.Unbounded;

package Chat_Handler is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
	package AC renames Ada.Calendar;
	package TIO renames Ada.Text_IO;
	use type AC.Time;
	type Seq_N_T is mod Integer'Last;

	Prompt: Boolean := False;

	function Image_3 (T: Ada.Calendar.Time) return String;

	Max_Neigh_Length : constant Natural := 10;
	Max_LM_Length : constant Natural := 50;

	function Writable_EP (EP: LLU.End_Point_Type) return String;

	package NP_Neighbors is new Maps_G
		(Key_Type 	=> LLU.End_Point_Type,
       Value_Type => AC.Time,
		 Null_Key 	=> null,
		 Null_Value => AC.Clock,
		 Max_Length => Max_Neigh_Length,
	    "="        => LLU."=",
	    Key_To_String  	=> Writable_EP,
--	    Key_To_String  	=> LLU.Image,
	    Value_To_String  => Image_3);
	package NP_Latest_Msgs is new Maps_G
		(Key_Type 	=> LLU.End_Point_Type,
       Value_Type => Seq_N_T,
		 Null_Key 	=> null,
		 Null_Value => 0,
		 Max_Length => Max_LM_Length,
       "="        => LLU."=",
		 Key_To_String  	=> Writable_EP,
--		 Key_To_String  	=> LLU.Image,
       Value_To_String  => Seq_N_T'Image);

	package Neighbors is new Maps_Protector_G (NP_Neighbors) ;
	package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);

	type User_Type is record
		Nick: ASU.Unbounded_String;
		Neigh: Neighbors.Prot_Map;
		Max_Neigh: Natural := Max_Neigh_Length;
		L_Msgs: Latest_Msgs.Prot_Map;
		Max_LM: Natural := Max_LM_Length;
		Port: Natural;
		Seq_N: Seq_N_T := 0;
		EP_H: LLU.End_Point_Type;
		EP_R: LLU.End_Point_Type;
	end record;

	Myself: User_Type;

   -- This procedure must NOT be called. It's called from LLU
	
   procedure Peer_Handler (From     : in     LLU.End_Point_Type;
                           To       : in     LLU.End_Point_Type;
                           P_Buffer : access LLU.Buffer_Type);

	procedure Delete_Neighbors_Map (N_M: in out Neighbors.Prot_Map);
	procedure Delete_LM_Map (LM_M: in out Latest_Msgs.Prot_Map);


end Chat_Handler;
