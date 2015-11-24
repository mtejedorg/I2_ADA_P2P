--Marco Tejedor Gonzalez
with ADA.Text_IO;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with ADA.Command_Line;
with ADA.Exceptions;
with Chat_Messages;
with Types;
with Handlers;
	
procedure Chat_Client_2 is

	package TIO renames ADA.Text_IO;
	package LLU renames Lower_Layer_UDP;
	package ASU renames ADA.Strings.Unbounded;
	package ACL renames ADA.Command_Line;
	package EXC renames ADA.Exceptions;
	package CM renames Chat_Messages;
	use type CM.Message_Type;

	Denegado: exception;
	Server_Error: exception;

	procedure Send_Init (Client: Types.Client_Type; 
					Server_EP: LLU.End_Point_Type;
					Buffer: in out LLU.Buffer_Type) is
	begin
		LLU.Reset(Buffer);
		CM.Message_Type'Output(Buffer'Access, CM.Init);
		LLU.End_Point_Type'Output(Buffer'Access, Client.EP_Receive);
		LLU.End_Point_Type'Output(Buffer'Access, Client.EP_Handler);
		ASU.Unbounded_String'Output(Buffer'Access, Client.Nick);
		LLU.Send (Server_Ep, Buffer'Access);
		LLU.Reset(Buffer);
	end Send_Init;

	procedure Send_Logout (Client: Types.Client_Type; 
					Server_EP: LLU.End_Point_Type;
					Buffer: in out LLU.Buffer_Type) is
	begin
		LLU.Reset(Buffer);
		CM.Message_Type'Output(Buffer'Access, CM.Logout);
		LLU.End_Point_Type'Output(Buffer'Access, Client.EP_Handler);
		LLU.Send (Server_Ep, Buffer'Access);
		LLU.Reset(Buffer);
	end Send_Logout;

	procedure Rec_Welcome (Client: Types.Client_Type; 
					Server: Types.Server_Type;
					Buffer: in out LLU.Buffer_Type) is
		Expired: Boolean;
		Mensaje: CM.Message;
	begin
		LLU.Receive(Client.EP_Receive, Buffer'Access, 10.0, Expired);
		if Expired then
			raise Server_Error;
		end if;
		Mensaje.Tipo := CM.Message_Type'Input(Buffer'Access);
		Mensaje.Acogido := Boolean'Input(Buffer'Access);
		if Mensaje.Acogido then
			TIO.Put_Line("Mini-Chat v2.0: Bienvenido " & ASU.To_String(Client.Nick));
		else
			raise Denegado;
		end if;
	end Rec_Welcome;
	
	procedure Iniciar (Client: in out Types.Client_Type; 
					Server: in out Types.Server_Type;
					Buffer: in out LLU.Buffer_Type) is
	begin
		Server.IP := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Server.Host_Name)));
		Server.EP := LLU.Build (ASU.To_String(Server.IP),Server.Port);
		LLU.Bind_Any(Client.EP_Receive);

		Send_Init (Client, Server.EP, Buffer);
		Rec_Welcome (Client, Server, Buffer);
	end Iniciar;

	procedure Escritor (Client: Types.Client_Type; 
					Server_EP: LLU.End_Point_Type;
					Buffer: in out LLU.Buffer_Type) is
		Mensaje: CM.Message;
		Comentario: ASU.Unbounded_String;
	begin
		loop
			Ada.Text_IO.Put(">> ");
			Comentario := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
			if ASU.To_String(Comentario) /= ".salir" then
				Mensaje.Tipo := CM.Writer;
				Mensaje.Client_EP_Handler := Client.EP_Handler;
				Mensaje.Comment:= Comentario;

				LLU.Reset(Buffer);
				CM.Message_Type'Output(Buffer'Access, Mensaje.Tipo);
				LLU.End_Point_Type'Output(Buffer'Access, Mensaje.Client_EP_Handler);
				ASU.Unbounded_String'Output(Buffer'Access, Mensaje.Comment);
				LLU.Send (Server_Ep, Buffer'Access);
				LLU.Reset(Buffer);
			else
				Send_Logout(Client, Server_EP, Buffer);
			end if;
			exit when ASU.To_String(Comentario) = ".salir";
		end loop;
		LLU.Finalize;
	end Escritor;

	Buffer: aliased LLU.Buffer_Type(1024);
	Mensaje: ASU.Unbounded_String;
	Reply: ASU.Unbounded_String;

	Usage_Error: exception;
	Nick_Error: exception;
	Client: Types.Client_Type;
	Server: Types.Server_Type;

begin

	if ACL.Argument_Count /= 3 then
		raise Usage_Error;
	else
		
		Server.Host_Name := ASU.To_Unbounded_String(ACL.Argument(1));
		Server.Port := Integer'Value(ACL.Argument(2));
		Client.Nick := ASU.To_Unbounded_String(ACL.Argument(3));

		if ASU.To_String(Client.Nick) = "servidor" then
			raise Nick_Error;
		else
			LLU.Bind_Any(Client.EP_Handler, Handlers.Client_Handler'Access);
			Iniciar (Client, Server, Buffer);
			Escritor (Client, Server.EP, Buffer);
		end if;
	end if;

	exception
	when Usage_Error =>
		TIO.Put_Line("Error de uso!!");
		TIO.Put_Line("Uso: ./chat_client_2 <Server_Host_Name> <Server_Port> <Nick>");
		LLU.Finalize;
	when Nick_Error =>
		TIO.Put_Line("Error de uso!!");
		TIO.Put_Line("Nickname denegado. El apodo <servidor> está reservado");
		LLU.Finalize;
	when Denegado =>
		TIO.Put("Cliente rechazado porque el nickname ");
		TIO.Put(ASU.To_String(Client.Nick));
		TIO.Put_Line (" ya existe en este servidor");
		LLU.Finalize;
	when Server_Error =>
		TIO.Put_Line("No es posible comunicarse con el servidor");
				LLU.Finalize;
end Chat_Client_2;
