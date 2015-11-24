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
with Chat_Handler;
with Timed_Handlers;

package SN_Handler is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
	package AC renames Ada.Calendar;
	package TIO renames Ada.Text_IO;
	package U renames Utiles;
	package TH renames Timed_Handlers;
	package CH renames Chat_Handler;
	use type AC.Time;
	use U;

	Prompt: Boolean := False;
	Plazo_Retransmision: Duration;
	End_Error: exception;

	Myself: CH.User_Type;

   -- This procedure must NOT be called. It's called from LLU
	
   procedure Peer_Handler (From     : in     LLU.End_Point_Type;
                           To       : in     LLU.End_Point_Type;
                           P_Buffer : access LLU.Buffer_Type);

	procedure Prot_Salida;

	procedure Delete_Neighbors_Map (N_M: in out CH.Neighbors.Prot_Map);
	procedure Delete_LM_Map (LM_M: in out CH.Latest_Msgs.Prot_Map);


end SN_Handler;
