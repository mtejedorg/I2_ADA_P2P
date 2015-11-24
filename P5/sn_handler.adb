--Marco Tejedor González
with Gnat.Calendar.Time_IO;
with Chat_Messages;
with Debug;
with Pantalla;

package body SN_Handler is
   package C_IO renames Gnat.Calendar.Time_IO;
	package D renames Debug;
	package CM renames Chat_Messages;

   Handler_Call_Counter : Natural := 0;

	procedure Resend_Flood (M: in out CM.Message_R) is
		use type U.Seq_N_T;
		use type LLU.End_Point_Type;
		V: U.Value_T;
		Time: AC.Time;
		Neigh_Array: CH.Neighbors.Keys_Array_Type := CH.Neighbors.Get_Keys(Myself.Neigh);
		Destinations: U.Destinations_T;
		Mess_ID: U.Mess_Id_T;
	begin
		CM.P_Buffer_SN_Handler := new LLU.Buffer_Type(1024);
		for K in 1..CH.Neighbors.Map_Length(Myself.Neigh) loop
			if Neigh_Array(K) /= M.EP_H_Rsnd then
				Destinations(K).EP := Neigh_Array(K);
				Destinations(K).Retries := 0;
			end if;
		end loop;
		Mess_ID := (M.EP_H_Creat, M.Seq_N);
		CH.Sender_Dests.Put(Myself.S_Dests, Mess_ID, Destinations);
			D.Put_Line("Añadimos a Sender_Dests el mensaje caracterizado por: ");
			D.Put_Line(U.MIT_To_String (Mess_ID), Pantalla.Azul);
			D.Put_Line("Se espera la confirmación de los vecinos: ");
			D.Put_Line(U.DT_To_String(Destinations), Pantalla.Azul);	
		V := (M.EP_H_Creat, M.Seq_N, CM.P_Buffer_SN_Handler);
		Time := AC.Clock + Plazo_Retransmision;
		CH.Sender_Buffering.Put(Myself.S_Buff, Time, V);
			D.Put_Line("Añadimos a Sender_Buffering el mensaje caracterizado por: ");
			D.Put_Line(U.VT_To_String(V), Pantalla.Azul);
			D.Put_Line("Hora de retransmisión:");
			D.Put_Line(U.Time_To_String(Time), Pantalla.Azul);
		CM.Send_Flood_MR(CM.P_Buffer_SN_Handler, Myself, M);
		TH.Set_Timed_Handler (Time, CM.Retry'access);
	end Resend_Flood;

	procedure Procesar_ACK (M: CM.Message_R) is
		MID: Mess_Id_T;
		Quedan_EP: Boolean := False;
		Success: Boolean;
		Dests: Destinations_T;
		use type LLU.End_Point_Type;
	begin
		MID := (M.Ep_H_Creat, M.Seq_N);
			D.Put_Line("Recibido mensaje de ACK con ID " & MIT_To_String(MID), Pantalla.Azul_Claro);
		CH.Sender_Dests.Get(Myself.S_Dests, MID, Dests, Success);
		if Success then
			for K in 1..Dests'length loop
				if Dests(K).EP = M.EP_H_ACKer then
					Dests(K).EP := null;
						D.Put_Line("Destinatario borrado", Pantalla.Azul_Claro);
				elsif Dests(K).EP /= null and Dests(K).Retries < Max_Retries then
					Quedan_EP := True;
				end if;
			end loop;
			if Quedan_EP then
					D.Put_Line("Aún quedan destinatarios por confirmar", Pantalla.Azul_Claro);
				CH.Sender_Dests.Put(Myself.S_Dests, MID, Dests);
			else
				D.Put_Line("No quedan destinatarios por confirmar", Pantalla.Azul_Claro);
				CH.Sender_Dests.Delete(Myself.S_Dests, MID, Success);
			end if;
		else
			D.Put_Line("Mensaje de ACK repetido o inesperado, mensaje ignorado", Pantalla.Magenta);
		end if;
	end Procesar_ACK;

	procedure Supernodo (Destination: LLU.End_Point_Type) is
		Seq_N: Seq_N_T;
		Neigh_Array: CH.Neighbors.Keys_Array_Type := CH.Neighbors.Get_Keys(Myself.Neigh);
		Success:Boolean;
	begin
		for K in 1..CH.Neighbors.Map_Length(Myself.Neigh) loop
			CH.Latest_Msgs.Get(Myself.L_Msgs, Neigh_Array(K), Seq_N, Success);
--			if Success then 
				D.Put("SEND SN    ", Pantalla.Amarillo);
				D.Put_Line( "Neigh: " & U.Writable_EP(Neigh_Array(K)) & "Seq_N" & " ==> " & U.Writable_EP(Destination));
				CM.Send_SN(Destination, Neigh_Array(K), Seq_N);
--			end if;
		end loop;
	end Supernodo;

	procedure Procesar_Flood(M: CM.Message_R) is
		use type CM.Message_Type;
		use type ASU.Unbounded_String;
		use type LLU.End_Point_Type;
		Success: Boolean;
	begin
		CH.Latest_Msgs.Put(Myself.L_Msgs, M.EP_H_Creat, M.Seq_N, Success);
		if M.Tipo = CM.Init then
			if M.Nick = Myself.Nick then
				CM.Send_Reject(M.EP_R_Creat, Myself.EP_H, M.Nick);
			elsif M.EP_H_Creat = M.EP_H_Rsnd then
				Supernodo(M.EP_H_Creat);
						D.Put_Line ("Añadimos a neighbors " & Writable_EP(M.EP_H_Creat));
				CH.Neighbors.Put(Myself.Neigh, M.EP_H_Creat, AC.Clock, Success);
			end if;
		elsif M.Tipo = CM.Confirm then
			TIO.Put_Line(ASU.To_String(M.Nick) & " ha entrado en el chat");
		elsif M.Tipo = CM.Logout then
			if M.EP_H_Creat = M.EP_H_Rsnd then
						D.Put_Line ("Borramos de neighbors " & Writable_EP(M.EP_H_Creat));
				CH.Neighbors.Delete (Myself.Neigh, M.EP_H_Creat, Success);
			end if;
						D.Put_Line ("Borramos de latest msgs la entrada de " & Writable_EP(M.EP_H_Creat));
				CH.Latest_Msgs.Delete (Myself.L_Msgs, M.EP_H_Creat, Success);
		elsif M.Tipo = CM.Writer then
			TIO.New_Line(1);
			TIO.Put_Line (ASU.To_String(M.Nick) & ": " & ASU.To_String(M.Text));
			if Prompt then
				TIO.Put(ASU.To_String(Myself.Nick) & " >> ");
			end if;
		end if;
	end Procesar_Flood;

   procedure Peer_Handler (From: in LLU.End_Point_Type;
                 To: in     LLU.End_Point_Type;
                 P_Buffer: access LLU.Buffer_Type) is
      M: CM.Message_R;
		Seq_N: Seq_N_T;
		use type CM.Message_Type;
		use type ASU.Unbounded_String;
		use type LLU.End_Point_Type;
		Time: AC.Time;
		Success: Boolean;
   begin
		CM.Buff_To_Msg_R(P_Buffer, M);
		if M.Tipo = CM.ACK then
			Procesar_ACK(M);
		else 
				D.Put ("Rcv " & CM.Message_Type'Image(M.Tipo) & "   " , Pantalla.Amarillo);
				D.Put (U.Writable_EP(M.EP_H_Creat) & 
				U.Seq_N_T'Image(M.Seq_N) & "     " & U.Writable_EP(M.EP_H_Rsnd) & "...  " & ASU.To_String(M.Nick));
				if M.Tipo = CM.Writer then
				D.Put (": " & ASU.To_String(M.Text));
				end if;
				D.New_Line(1);

			CH.Latest_Msgs.Get(Myself.L_Msgs, M.EP_H_Creat, Seq_N, Success);
			if not Success then
					D.Put_Line("El mensaje es nuevo, lo asiento y lo proceso...", Pantalla.Magenta);
				CM.Send_Ack(M.EP_H_Rsnd, Myself.EP_H, M.EP_H_Creat, M.Seq_N);
				Procesar_Flood(M);
				if M.Tipo /= CM.Logout then
						D.Put_Line("...y lo reenvío ya que no es un mensaje de Logout", Pantalla.Magenta);
					Resend_Flood(M);
				else
					D.Put_Line("...pero no lo reenvío por ser un mensaje de Logout", Pantalla.Magenta);
				end if;
			elsif M.Seq_N = Seq_N + 1 then
				CM.Send_Ack(M.EP_H_Rsnd, Myself.EP_H, M.EP_H_Creat, M.Seq_N);
				Procesar_Flood(M);
				Resend_Flood(M);
					D.Put_Line("El mensaje es el siguiente al último recibido: lo asiento, lo proceso y lo reenvío", Pantalla.Magenta);
			elsif M.Seq_N <= Seq_N then
					D.Put("El mensaje es anterior al último recibido", Pantalla.Magenta);
--Esto es una modificación que hago para que los init
--que llegan después que el confirm sean procesados.
				if M.Tipo = CM.Init and 
				M.EP_H_Creat = M.EP_H_Rsnd then
					CH.Neighbors.Get(Myself.Neigh, M.EP_H_Creat, Time, Success);	
						D.Put(", pero es de tipo Init de un vecino al que", Pantalla.Magenta);
					if not Success then
					D.Put_Line(" debemos agregar: lo asiento y lo proceso, pero no lo reenvío", Pantalla.Magenta);
						CM.Send_Ack(M.EP_H_Rsnd, Myself.EP_H, M.EP_H_Creat, M.Seq_N);
						Procesar_Flood(M);
					else
					D.Put_Line(" no debemos agregar: lo asiento, pero ni lo proceso ni lo reenvío", Pantalla.Magenta);
						CM.Send_Ack(M.EP_H_Rsnd, Myself.EP_H, M.EP_H_Creat, M.Seq_N);
					end if;
				else
				D.Put_Line(", y por tanto es repetido: lo asiento, pero ni lo proceso ni lo reenvío", Pantalla.Magenta);
					CM.Send_Ack(M.EP_H_Rsnd, Myself.EP_H, M.EP_H_Creat, M.Seq_N);
				end if;
			elsif M.Seq_N > Seq_N + 1 then
					D.Put_Line("El mensaje demasiado actual: no lo asiento ni lo proceso, pero sí lo reenvío", Pantalla.Magenta);
				Resend_Flood(M);
			end if;
		end if;
   end Peer_Handler;

	procedure Delete_Neighbors_Map (N_M: in out CH.Neighbors.Prot_Map) is
		Success: Boolean;
		Neigh_Array: CH.Neighbors.Keys_Array_Type := CH.Neighbors.Get_Keys(N_M);
	begin
		for K in 1..CH.Neighbors.Map_Length(N_M) loop
			CH.Neighbors.Delete (N_M, Neigh_Array(K), Success);
			if not Success then
				D.Put_Line ("No pude borrar la lista en Delete_Neighbors_Map en Chat_Handler", Pantalla.Azul);
			end if;
		end loop;
	end Delete_Neighbors_Map;

	procedure Delete_LM_Map (LM_M: in out CH.Latest_Msgs.Prot_Map) is
		Success: Boolean;
		LM_Array: CH.Latest_Msgs.Keys_Array_Type := CH.Latest_Msgs.Get_Keys(LM_M);
	begin
		for K in 1..CH.Latest_Msgs.Map_Length(LM_M) loop
			CH.Latest_Msgs.Delete (LM_M, LM_Array(K), Success);
			if not Success then
				D.Put_Line ("No pude borrar la lista en Delete_LM_Map en Chat_Handler", Pantalla.Azul);
			end if;
		end loop;
	end Delete_LM_Map;

	procedure Prot_Salida is
		Delay_Time: Duration;
	begin
	if CH.Neighbors.Map_Length(Myself.Neigh) > 0 then
		Pantalla.Poner_Color(Pantalla.Rojo);
		TIO.Put_Line("Informando de la salida");
		Pantalla.Poner_Color(Pantalla.Blanco);
		CM.Main_Send_Flood(Myself, CM.Logout);
		Delay_Time := Max_Retries * Plazo_Retransmision;
		Pantalla.Poner_Color(Pantalla.Rojo);
		TIO.Put_Line("Por favor espera " & Duration'Image(Delay_Time) & " segundos para asegurarse de que todos los usuarios son informados");
		Pantalla.Poner_Color(Pantalla.Blanco);
		delay Delay_Time;
	else 
		D.Put_Line("Al no haber vecinos, no envío Logout", Pantalla.Azul);
	end if;
	Delete_Neighbors_Map (Myself.Neigh);
	Delete_LM_Map (Myself.L_Msgs);
	raise End_Error;
	end Prot_Salida;

end SN_Handler;
