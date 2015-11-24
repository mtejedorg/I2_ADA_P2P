--Marco Tejedor González
with Debug;
with Pantalla;
package body Messages is
	package D renames Debug;

	function H_Buff_To_Msg_R (P_Buffer: access LLU.Buffer_Type) return Message_R is
	M: Message_R;
	begin
		M.Tipo := Message_Type'Input (P_Buffer);
		M.EP_H_Creat := LLU.End_Point_Type'Input(P_Buffer);
		M.Seq_N := CH.Seq_N_T'Input (P_Buffer);
		M.EP_H_Rsnd := LLU.End_Point_Type'Input (P_Buffer);
		if M.Tipo = Init then
			M.EP_R_Creat := LLU.End_Point_Type'Input (P_Buffer);
		end if;
		M.Nick := ASU.Unbounded_String'Input (P_Buffer);
		if M.Tipo = Writer then
			M.Text := ASU.Unbounded_String'Input (P_Buffer);
		elsif M.Tipo = Logout then
			M.Confirm_Sent := Boolean'Input (P_Buffer);
		end if;
				D.Put ("Rcv " & Message_Type'Image(M.Tipo) & "   " , Pantalla.Amarillo);
				D.Put (CH.Writable_EP(M.EP_H_Creat) & 
				CH.Seq_N_T'Image(M.Seq_N) & "     " & CH.Writable_EP(M.EP_H_Rsnd) & "...  " & ASU.To_String(M.Nick));
				if M.Tipo = Writer then
				D.Put (ASU.To_String(M.Text));
				end if;
				D.New_Line(1);
		return M;
	end H_Buff_To_Msg_R;

	function Users_To_Msg_R (Whose: CH.User_Type; Who_Not: LLU.End_Point_Type; Tipo: Message_Type; Conf: Boolean; Text: ASU.Unbounded_String) return Message_R is
	M: Message_R;
	begin
		M.Tipo := Tipo;
		M.EP_H_Creat := Whose.EP_H; 
		M.Seq_N := Whose.Seq_N;
		M.EP_H_Rsnd := Who_Not;
		M.EP_R_Creat := Whose.EP_R;
		M.Nick := Whose.Nick;
		M.Text := Text;
		M.Confirm_Sent := Conf;
		return M;
	end Users_To_Msg_R;


	procedure Send_Reject 
			(Destination: LLU.End_Point_Type; 
			 EP_H: LLU.End_Point_Type;
			 Nick: ASU.Unbounded_String) is
		Buffer: aliased LLU.Buffer_Type(1024);
	begin 
			Message_Type'Output(Buffer'Access, Reject);
			LLU.End_Point_Type'Output(Buffer'Access, EP_H);
			ASU.Unbounded_String'Output(Buffer'Access, Nick);
			LLU.Send (Destination, Buffer'Access);
	end Send_Reject;

	procedure Send_Flood_MR
			(Who: in out CH.User_Type; 
			 M: in out Message_R) is 
		Buffer: aliased LLU.Buffer_Type(1024);
		Neigh_Array: CH.Neighbors.Keys_Array_Type := CH.Neighbors.Get_Keys(Who.Neigh);
		Who_Not: LLU.End_Point_Type := M.EP_H_Rsnd;
		Success: Boolean;
	begin
				D.Put_Line("Añadimos a latest_messages " & CH.Writable_EP(M.EP_H_Creat) & CH.Seq_N_T'Image
				(M.Seq_N));
		CH.Latest_Msgs.Put(Who.L_Msgs, M.EP_H_Creat, M.Seq_N, Success);
				D.Put ("FLOOD " & Message_Type'Image(M.Tipo) & "   " , Pantalla.Amarillo);
				D.Put (CH.Writable_EP(M.EP_H_Creat) & 
				CH.Seq_N_T'Image(M.Seq_N) & "     " & CH.Writable_EP(Who.EP_H) & " ==> " & ASU.To_String(M.Nick));
				if M.Tipo = Writer then
				D.Put (" " & ASU.To_String(M.Text));
				end if;
				D.New_Line(2);
		M.EP_H_Rsnd := Who.EP_H;
		Message_Type'Output(Buffer'Access, M.Tipo);
		LLU.End_Point_Type'Output(Buffer'Access, M.EP_H_Creat);
		CH.Seq_N_T'Output(Buffer'Access, M.Seq_N);
		LLU.End_Point_Type'Output(Buffer'Access, Who.EP_H);
		if M.Tipo = Init then
			LLU.End_Point_Type'Output(Buffer'Access, M.EP_R_Creat);
			ASU.Unbounded_String'Output(Buffer'Access, M.Nick);
		elsif M.Tipo = Confirm or
				M.Tipo = Writer or
				M.Tipo = Logout then
			ASU.Unbounded_String'Output(Buffer'Access, M.Nick);
			if M.Tipo = Writer then
				ASU.Unbounded_String'Output(Buffer'Access, M.Text);
			elsif M.Tipo = Logout then
				Boolean'Output(Buffer'Access, M.Confirm_Sent);
			end if;
		else
			raise Message_Type_Error;
		end if;
		for K in 1..CH.Neighbors.Map_Length(Who.Neigh) loop
			if Neigh_Array(K) /= Who_Not then
				LLU.Send (Neigh_Array(K), Buffer'Access);
			end if;
		end loop;
	end Send_Flood_MR;

--Si es un logout y envió un confirm hay que decirlo explícitamente
	procedure Send_Flood 
			(Whose: CH.User_Type; 
			 Who: in out CH.User_Type; 
			 Who_Not: LLU.End_Point_Type;
			 M_Type: Message_Type;  
			 Conf: Boolean := False;
			 Text: ASU.Unbounded_String := ASU.To_Unbounded_String("sin texto")) is 
		M: Message_R;
	begin
		M := Users_To_Msg_R (Whose, Who_Not, M_Type, Conf, Text);
		Send_Flood_MR(Who, M);
	end Send_Flood;

	procedure Resend_Flood (Who: in out CH.User_Type; M: in out Message_R) is
		Seq_N: CH.Seq_N_T;
		use type CH.Seq_N_T;
		Success: Boolean := False;
	begin
		CH.Latest_Msgs.Get(Who.L_Msgs, M.EP_H_Creat, Seq_N, Success);
		if not Success then
			if M.Tipo /= Logout then
				CH.Latest_Msgs.Put(Who.L_Msgs, M.EP_H_Creat, M.Seq_N, Success);
				Send_Flood_MR(Who, M);
			end if;
		elsif M.Seq_N > Seq_N then
			CH.Latest_Msgs.Put(Who.L_Msgs, M.EP_H_Creat, M.Seq_N, Success);
			Send_Flood_MR(Who, M);
		end if;
	end Resend_Flood;

--	procedure Mess_Debug 
--			(Whose: LLU.End_Point_Type; 
--			 Who: LLU.End_Point_Type;
--			 Seq_N: CH.Seq_N_T) is
--		Buffer: aliased LLU.Buffer_Type(1024);
--	begin 
--			
--	end Mess_Debug;

end Messages;
