--Marco Tejedor González
with ADA.Text_IO;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with ADA.Command_Line;
with ADA.Exceptions;
with ADA.Calendar;
with Debug;
with Pantalla;
with Messages;
with Chat_Handler;
with Ada.Unchecked_Deallocation;
with Input_Manager;
	
procedure Chat_Peer is

	package TIO renames ADA.Text_IO;
	package LLU renames Lower_Layer_UDP;
	package ASU renames ADA.Strings.Unbounded;
	package ACL renames ADA.Command_Line;
	package EXC renames ADA.Exceptions;
	package AC renames ADA.Calendar;
	package D renames Debug;
	package CH renames Chat_Handler;
	use CH;
	use Messages;

	Usage_Error: exception;
-------------------------------------------------
procedure Leer_Argumentos (N: Natural; Myself: in out CH.User_Type) is
		IP: ASU.Unbounded_String;
		Port: Natural;
		EP_H: LLU.End_Point_Type;
		Success: Boolean;
	begin
		if N = 2 or N = 4 or N = 6 then
			Myself.Nick := ASU.To_Unbounded_String(ACL.Argument(2));
			Port := Integer'Value(ACL.Argument(1));
			IP := ASU.To_Unbounded_String(LLU.To_IP(LLU.Get_Host_Name));
			Myself.EP_H := LLU.Build (ASU.To_String(IP), Port);
			if N = 2 then
				D.Put_Line ("No hacemos protocolo de admision porque no tenemos contactos iniciales");
			end if;

			if N = 4 or N = 6 then
				IP := ASU.To_Unbounded_String(LLU.To_IP(ACL.Argument(3)));
				Port := Integer'Value(ACL.Argument(4));
				EP_H := LLU.Build (ASU.To_String(IP), Port);
						D.Put_Line ("Añadimos a neighbors " & Writable_EP(EP_H)); 
						D.New_Line (1);
				CH.Neighbors.Put(Myself.Neigh, EP_H, AC.Clock, Success);
			end if;
			if N = 6 then
				IP := ASU.To_Unbounded_String(LLU.To_IP(ACL.Argument(5)));
				Port := Integer'Value(ACL.Argument(6));
						D.Put_Line ("Añadimos a neighbors " & ASU.To_String
						(IP) & ":" & Integer'Image(Port)); 
				EP_H := LLU.Build (ASU.To_String(IP), Port);
				CH.Neighbors.Put(Myself.Neigh, EP_H, AC.Clock, Success);
			end if;
		else
			raise Usage_Error;
		end if;
	end Leer_Argumentos;

	procedure Prot_Admision (Myself: in out CH.User_Type) is
		Tipo: Messages.Message_Type;
		Expired: Boolean;
		Buffer: aliased LLU.Buffer_Type(1024);
	begin
				D.Put_Line ("Iniciando Protocolo de Admisión...");
		Myself.Seq_N := Myself.Seq_N + 1;
				D.Put_Line("Sumo 1 a mi Seq_N", Pantalla.Azul);
		Messages.Send_Flood(Myself, Myself, Myself.EP_H, Messages.Init);
		LLU.Receive(Myself.EP_R, Buffer'Access, 2.0, Expired);
		if Expired then
			Myself.Seq_N := Myself.Seq_N + 1;
					D.Put_Line("Sumo 1 a mi Seq_N", Pantalla.Azul);
			Messages.Send_Flood(Myself, Myself, Myself.EP_H, Messages.Confirm);
					D.Put_Line ("En el protocolo de admision el tiempo de espera para recibir mensajes de tipo Reject ha Expirado, envío Confirm", Pantalla.Azul);
		else
			Tipo := Messages.Message_Type'Input(Buffer'Access);
			if Tipo = Messages.Reject then
				Messages.Send_Flood(Myself, Myself, Myself.EP_H, Messages.Logout, True);
					D.Put_Line ("Me han mandado un Reject así que me voy, envío Logout", Pantalla.Azul);
				LLU.Finalize; 
			else
				Myself.Seq_N := Myself.Seq_N + 1;
					D.Put_Line("Sumo 1 a mi Seq_N", Pantalla.Azul);
				Messages.Send_Flood(Myself, Myself, Myself.EP_H, Messages.Confirm);
					D.Put_Line ("Esto es por si crean conflictos mensajes que lleguen antes del Reject, en cuyo caso mi programa se quedaría y manda un Confirm", Pantalla.Azul);
			end if;
		end if;
	end Prot_Admision;

	procedure Iniciar (Myself: in out CH.User_Type) is
	begin
		LLU.Bind_Any(Myself.EP_R);
				D.Put_Line ("EP_R atado en " & Writable_EP
				(Myself.EP_R), Pantalla.Azul); 
		LLU.Bind(Myself.EP_H, CH.Peer_Handler'Access);
				D.Put_Line ("Handler EP_H atado en " & Writable_EP(Myself.EP_H), Pantalla.Azul); 
				D.New_Line(1);
		if ACL.Argument_Count /= 2 then
			Prot_Admision (Myself);
		end if;
		TIO.Put_Line("Peer-Chat v1.0");
		TIO.Put_Line("==============");
		TIO.Put_Line("");
		TIO.Put_Line("Entramos en el chat con Nick: " & ASU.To_String(Myself.Nick));
		TIO.Put_Line(".h para help");
	end Iniciar;

	Comentario: ASU.Unbounded_String;
	Final: Boolean := False;
	use type ASU.Unbounded_String;

begin
	Leer_Argumentos (ACL.Argument_Count, CH.Myself);
	Iniciar (CH.Myself);
	while not Final loop
		if Prompt then
			TIO.Put(ASU.To_String(Myself.Nick) & " >> ");
		end if;
		Comentario := ASU.To_Unbounded_String(TIO.Get_Line);
		Input_Manager.Manage_Input (Comentario, Myself, Final, Prompt);
	end loop;
	LLU.Finalize;

	exception
	when Usage_Error =>
		TIO.Put_Line("Error de uso!!");
		TIO.Put_Line("Uso: ./chat_peer <Port> <Nick> [[<Neighbor_Host> <Neighbor_Port>] [<Neighbor_Host> <Neighbor_Port>]]");
		LLU.Finalize;
	when Messages.Message_Type_Error =>
		TIO.Put_Line("Error de tipos de mensaje!!");
		TIO.Put_Line("Tipo de mensaje desconocido o al procesado");
		LLU.Finalize;

end Chat_Peer;
