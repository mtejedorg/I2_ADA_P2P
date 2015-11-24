--Marco Tejedor González
with Gnat.Calendar.Time_IO;
with Ada.Calendar;
with Chat_Peer;
with Messages;
with Debug;
with Pantalla;
package body Chat_Handler is
   package C_IO renames Gnat.Calendar.Time_IO;
	package D renames Debug;

   Handler_Call_Counter : Natural := 0;

	function Image_3 (T: Ada.Calendar.Time) return String is
   begin
      return C_IO.Image(T, "%T.%i");
   end Image_3;

	function Writable_EP (EP: LLU.End_Point_Type) return String is
		IP: ASU.Unbounded_String;
		Port: ASU.Unbounded_String;
		F: ASU.Unbounded_String;
		N:Natural;
	begin
		F := ASU.To_Unbounded_String (LLU.Image(EP));
		N := ASU.Index (F, "IP: ");
		F := ASU.Tail (F, ASU.Length(F)-(N+3));
		N := ASU.Index (F, ", ");
		IP:= ASU.Head (F, N-1);
		N := ASU.Index (F, "Port: ");
		Port := ASU.Tail (F, ASU.Length(F)-(N+6));
		F:=ASU.To_Unbounded_String((ASU.To_String(IP) & ":" & ASU.To_String(Port)));
		return ASU.To_String(F);
	end Writable_EP;

   procedure Peer_Handler (From: in LLU.End_Point_Type;
                 To: in     LLU.End_Point_Type;
                 P_Buffer: access LLU.Buffer_Type) is
      M: Messages.Message_R;
		use type Messages.Message_Type;
		use type ASU.Unbounded_String;
		use type LLU.End_Point_Type;
		Success: Boolean;
   begin
		M := Messages.H_Buff_To_Msg_R(P_Buffer);
		if M.Tipo = Messages.Init then
			if M.Nick = Myself.Nick then
				Messages.Send_Reject(M.EP_R_Creat, Myself.EP_H, M.Nick);
			elsif M.EP_H_Creat = M.EP_H_Rsnd then
						D.Put_Line ("Añadimos a neighbors " & Writable_EP
						(M.EP_H_Creat));
				Neighbors.Put(Myself.Neigh, M.EP_H_Creat, AC.Clock, Success);
			end if;
		elsif M.Tipo = Messages.Confirm then
			TIO.Put_Line(ASU.To_String(M.Nick) & " ha entrado en el chat");
		elsif M.Tipo = Messages.Logout then
			if M.EP_H_Creat = M.EP_H_Rsnd then
						D.Put_Line ("Borramos de neighbors " & Writable_EP
						(M.EP_H_Creat));
				Neighbors.Delete (Myself.Neigh, M.EP_H_Creat, Success);
			end if;
						D.Put_Line ("Borramos de latest msgs la entrada de " & 
						Writable_EP(M.EP_H_Creat));
				Latest_Msgs.Delete (Myself.L_Msgs, M.EP_H_Creat, Success);
		elsif M.Tipo = Messages.Writer then
			TIO.Put_Line (ASU.To_String(M.Text));
		end if;
		Messages.Resend_Flood(Myself, M);
   end Peer_Handler;

	procedure Delete_Neighbors_Map (N_M: in out Neighbors.Prot_Map) is
		Success: Boolean;
		Neigh_Array: Neighbors.Keys_Array_Type := Neighbors.Get_Keys(N_M);
	begin
		for K in 1..Neighbors.Map_Length(N_M) loop
			Neighbors.Delete (N_M, Neigh_Array(K), Success);
			if not Success then
				D.Put_Line ("No pude borrar la lista en Delete_Neighbors_Map en Chat_Handler", Pantalla.Azul);
			end if;
		end loop;
	end Delete_Neighbors_Map;

	procedure Delete_LM_Map (LM_M: in out Latest_Msgs.Prot_Map) is
		Success: Boolean;
		LM_Array: Latest_Msgs.Keys_Array_Type := Latest_Msgs.Get_Keys(LM_M);
	begin
		for K in 1..Latest_Msgs.Map_Length(LM_M) loop
			Latest_Msgs.Delete (LM_M, LM_Array(K), Success);
			if not Success then
				D.Put_Line ("No pude borrar la lista en Delete_LM_Map en Chat_Handler", Pantalla.Azul);
			end if;
		end loop;
	end Delete_LM_Map;

end Chat_Handler;
