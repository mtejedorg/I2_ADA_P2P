--Marco Tejedor Gonzalez
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with ADA.Command_Line;
with ADA.Text_IO;
with ADA.Exceptions;
with Chat_Messages;
with Types;
	
procedure Chat_Server is

	package TIO renames ADA.Text_IO;
	package LLU renames Lower_Layer_UDP;
	package ASU renames ADA.Strings.Unbounded;
	package ACL renames ADA.Command_Line;
	package EXC renames ADA.Exceptions;
	package CM renames Chat_Messages;
	use type LLU.End_Point_Type;
	use type CM.Message_Type;

	function Get_Nick (EP: LLU.End_Point_Type; 
	Clientes: Types.Clients; N: Natural) return ASU.Unbounded_String is
		Nick: ASU.Unbounded_String;
	begin
		Nick := ASU.To_Unbounded_String("desconocido");
		for K in 1 .. N loop
			if Clientes(K).EP = EP then
				Nick := Clientes(K).Nick;
			end if;
		end loop;
		return Nick;
	end Get_Nick;

	procedure Send_Lectores (Clientes: Types.Clients; 
	Buffer: in out LLU.Buffer_Type; N: Natural) is
	begin
		for K in 1 .. N loop
			if ASU.To_String(Clientes(K).Nick) = "lector" then
				LLU.Send (Clientes(K).EP, Buffer'Access);
			end if;
		end loop;
	end Send_Lectores;

	procedure Add_Client (Clientes: in out Types.Clients; 
	Buffer: in out LLU.Buffer_Type; N: in out Natural) is
	begin
		N := N + 1;
		Clientes(N).EP := LLU.End_Point_Type'Input(Buffer'Access);
		Clientes(N).Nick := ASU.Unbounded_String'Input(Buffer'Access);
		LLU.Reset(Buffer);
		TIO.Put("recibido mensaje inicial de ");
		TIO.Put_Line(ASU.To_String(Clientes(N).Nick));
	end Add_Client;

	procedure Reenviar (Clientes: Types.Clients; 
	Buffer: in out LLU.Buffer_Type; N: Natural) is
		Mensaje: CM.Message;
	begin
		--Recibir
		Mensaje.Client_EP := LLU.End_Point_Type'Input(Buffer'Access);
		Mensaje.Comment := ASU.Unbounded_String'Input(Buffer'Access);
		Mensaje.Nick := Get_Nick(Mensaje.Client_EP, Clientes, N);
		TIO.Put("recibido mensaje de ");
		TIO.Put(ASU.To_String(Mensaje.Nick) & ": ");
		TIO.Put_Line(ASU.To_String(Mensaje.Comment));
		--Reenviar
		LLU.Reset(Buffer);
		Mensaje.Tipo:= CM.Server;
		CM.Message_Type'Output(Buffer'Access, Mensaje.Tipo);
		ASU.Unbounded_String'Output(Buffer'Access, Mensaje.Nick);
		ASU.Unbounded_String'Output(Buffer'Access, Mensaje.Comment);

		Send_Lectores (Clientes, Buffer, N);
		LLU.Reset(Buffer);
		
	end Reenviar;

	Clientes: Types.Clients;

	Server: Types.Server_Type;
	Buffer: aliased LLU.Buffer_Type(1024);
	Mensaje: CM.Message;
	N: Natural := 0;
	Expired: Boolean:= False;

	Usage_Error: exception;
	Fatal_Error: exception;

begin

	if ACL.Argument_Count /= 1 then
		raise Usage_Error;
	else
		Server.Host_Name := ASU.To_Unbounded_String (LLU.Get_Host_Name);
		Server.Port := Integer'Value(ACL.Argument(1));
		Server.IP := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Server.Host_Name)));
		Server.EP := LLU.Build (ASU.To_String(Server.IP),Server.Port);
   	LLU.Bind (Server.EP);
	
		loop
			LLU.Reset(Buffer);
			LLU.Receive (Server.EP, Buffer'Access, 1000.0, Expired);
			if Expired then
				Ada.Text_IO.Put_Line ("Plazo expirado, vuelvo a intentarlo");
			else
				Mensaje.Tipo := CM.Message_Type'Input(Buffer'Access);
				if Mensaje.Tipo = CM.Init then
					Add_Client(Clientes, Buffer, N);
				elsif Mensaje.Tipo = CM.Writer then
					Reenviar(Clientes, Buffer, N);
				else
					raise Fatal_Error;
				end if;
			end if;
		end loop;
	end if;
	exception
	when Usage_Error =>
		TIO.Put_Line("Error de uso!!");
		TIO.Put_Line("Uso: ./chat_server <Port>");
		LLU.Finalize;
	when Fatal_Error =>
		TIO.Put_Line("Error Fatal!!");
		TIO.Put_Line("Imposible identificar el mensaje");
		LLU.Finalize;
end Chat_Server;
