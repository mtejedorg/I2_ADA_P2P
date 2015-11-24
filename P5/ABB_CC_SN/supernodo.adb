--Marco Tejedor González
with ADA.Text_IO;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with ADA.Command_Line;
with ADA.Exceptions;
with ADA.Calendar;
with Debug;
with Pantalla;
with Chat_Messages;
with SN_Handler;
with Ada.Unchecked_Deallocation;
with Input_Manager;
with Timed_Handlers;
with Gnat.Ctrl_C;
with Ctrl_C_SN;
procedure Supernodo is

	package TIO renames ADA.Text_IO;
	package LLU renames Lower_Layer_UDP;
	package ASU renames ADA.Strings.Unbounded;
	package ACL renames ADA.Command_Line;
	package EXC renames ADA.Exceptions;
	package AC renames ADA.Calendar;
	package D renames Debug;
	package SH renames SN_Handler;
	package CM renames Chat_Messages;
	package TH renames Timed_Handlers;
	use type AC.Time;

	Usage_Error: exception;
	Delay_Error: exception;
	End_Error: exception;
	PCT_Error: exception;
-------------------------------------------------
procedure Leer_Argumentos (N: Natural; Myself: in out SH.CH.User_Type) is
		IP: ASU.Unbounded_String;
		Port: Natural;
		EP_H: LLU.End_Point_Type;
		Success: Boolean;
	begin
		if N = 4 or N = 6 or N = 8 then
			Myself.Nick := ASU.To_Unbounded_String(ACL.Argument(2));
			Myself.Port := Integer'Value(ACL.Argument(1));
			if Natural'Value(ACL.Argument(4)) < Natural'Value(ACL.Argument(3)) then
				raise Delay_Error;
			else
				Myself.Min_Delay := Natural'Value(ACL.Argument(3));
				Myself.Max_Delay := Natural'Value(ACL.Argument(4));
			end if;

			IP := ASU.To_Unbounded_String(LLU.To_IP(LLU.Get_Host_Name));
			Myself.EP_H := LLU.Build (ASU.To_String(IP), Myself.Port);
			if N = 4 then
				D.Put_Line ("No hacemos protocolo de admision porque no tenemos contactos iniciales");
			end if;

			if N = 6 or N = 8 then
				IP := ASU.To_Unbounded_String(LLU.To_IP(ACL.Argument(5)));
				Port := Integer'Value(ACL.Argument(6));
				EP_H := LLU.Build (ASU.To_String(IP), Port);
						D.Put_Line ("Añadimos a neighbors " & SH.U.Writable_EP(EP_H)); 
						D.New_Line (1);
				SH.CH.Neighbors.Put(Myself.Neigh, EP_H, AC.Clock, Success);
			end if;
			if N = 8 then
				IP := ASU.To_Unbounded_String(LLU.To_IP(ACL.Argument(7)));
				Port := Integer'Value(ACL.Argument(8));
						D.Put_Line ("Añadimos a neighbors " & ASU.To_String
						(IP) & ":" & Integer'Image(Port)); 
				EP_H := LLU.Build (ASU.To_String(IP), Port);
				SH.CH.Neighbors.Put(Myself.Neigh, EP_H, AC.Clock, Success);
			end if;
		else
			raise Usage_Error;
		end if;
	end Leer_Argumentos;

	procedure Prot_Admision (Myself: in out SH.CH.User_Type) is
		Tipo: CM.Message_Type;
		use type CM.Message_Type;
		Expired: Boolean;
		Buffer: aliased LLU.Buffer_Type(1024);
	begin
				D.Put_Line ("Iniciando Protocolo de Admisión...");
		CM.Main_Send_Flood(Myself, CM.Init);
		LLU.Receive(Myself.EP_R, Buffer'Access, 2.0, Expired);
		if Expired then
			CM.Main_Send_Flood(Myself, CM.Confirm);
			Myself.Conf_Sent := True;
					D.Put_Line ("En el protocolo de admision el tiempo de espera para recibir mensajes de tipo Reject ha Expirado, envío Confirm", Pantalla.Azul);
		else
			Tipo := CM.Message_Type'Input(Buffer'Access);
			if Tipo = CM.Reject then
				SH.Prot_Salida;
			else
				CM.Main_Send_Flood(Myself, CM.Confirm);
					D.Put_Line ("Esto es por si crean conflictos mensajes que lleguen antes del Reject, en cuyo caso mi programa se quedaría y manda un Confirm", Pantalla.Azul);
			end if;
		end if;
	end Prot_Admision;

	procedure Iniciar (Myself: in out SH.CH.User_Type) is
	begin
		LLU.Bind_Any(Myself.EP_R);
				D.Put_Line ("EP_R atado en " & SH.U.Writable_EP
				(Myself.EP_R), Pantalla.Azul); 
		LLU.Bind(Myself.EP_H, SH.Peer_Handler'Access);
				D.Put_Line ("Handler EP_H atado en " & SH.U.Writable_EP(Myself.EP_H), Pantalla.Azul); 
				D.New_Line(1);
		if ACL.Argument_Count /= 4 then
			Prot_Admision (Myself);
		end if;
		TIO.Put_Line("Peer-Chat v2.0");
		TIO.Put_Line("==============");
		TIO.Put_Line("");
		TIO.Put_Line("Entramos en el chat con Nick: " & ASU.To_String(Myself.Nick));
		TIO.Put_Line(".h para help");
	end Iniciar;

	Comentario: ASU.Unbounded_String;
	Final: Boolean := False;
	Text: Boolean;
	use type ASU.Unbounded_String;
begin
	Gnat.Ctrl_C.Install_Handler (Ctrl_C_SN.Handler'Access);
	Leer_Argumentos (ACL.Argument_Count, SH.Myself);
	LLU.Set_Random_Propagation_Delay(SH.Myself.Min_Delay, SH.Myself.Max_Delay);
		D.Put_Line ("Establecido retardo de entre " & Natural'Image(SH.Myself.Min_Delay) & " y " & Natural'Image(SH.Myself.Max_Delay) & " milisegundos", Pantalla.Azul); 
		D.New_Line (1);
	SH.Plazo_Retransmision := 2*Duration(SH.Myself.Max_Delay)/1000;
		D.Put_Line ("Establecido un plazo de retransmisión de" & Duration'Image(SH.Plazo_Retransmision) & " segundos", Pantalla.Azul); 
		D.New_Line (1);
	Iniciar (SH.Myself);
	while not Final loop
		if SH.Prompt then
			TIO.Put(ASU.To_String(SH.Myself.Nick) & " >> ");
		end if;
		Comentario := ASU.To_Unbounded_String(TIO.Get_Line);
		Input_Manager.Manage_Input (Comentario, SH.Myself, Final, SH.Prompt, Text);
		if Text then
			CM.Main_Send_Flood (SH.Myself, CM.Writer, Comentario);
		end if;
	end loop;
	SH.Prot_Salida;

	exception
	when SH.End_Error =>
		TH.Finalize;
		LLU.Finalize;
		TIO.Put_Line("Hasta luego!!");
	when Usage_Error =>
		TIO.Put_Line("Error de uso!!");
		TIO.Put_Line("Uso: ./supernodo <Port> <Nick> <Min_Delay> <Max_Delay> [[<Neighbor_Host> <Neighbor_Port>] [<Neighbor_Host> <Neighbor_Port>]]");
		TH.Finalize;
		LLU.Finalize;
	when CM.Message_Type_Error =>
		TIO.Put_Line("Error de tipos de mensaje!!");
		TIO.Put_Line("Tipo de mensaje desconocido o al procesado");
		TH.Finalize;
		LLU.Finalize;
	when Delay_Error =>
		TIO.Put_Line("Error de uso!!");
		TIO.Put_Line("<Min_Delay> debe ser menor o igual a <Max_Delay>");
		TH.Finalize;
		LLU.Finalize;
	when PCT_Error =>
		TIO.Put_Line("Error de uso!!");
		TIO.Put_Line("<Fault_Pct> debe estar entre 0 y 100");
		TH.Finalize;
		LLU.Finalize;
	when Others =>
		TIO.Put_Line("Error inesperado");
		TIO.Put_Line("Sugerencia: Comprueba si el puerto utilizado está ya en uso");
		TH.Finalize;
		LLU.Finalize;

end Supernodo;
