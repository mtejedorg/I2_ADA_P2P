--Marco Tejedor Gonzalez
with ADA.Text_IO;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with ADA.Command_Line;
with ADA.Exceptions;
with Chat_Messages;
with Types;
	
procedure Chat_Client is

	package TIO renames ADA.Text_IO;
	package LLU renames Lower_Layer_UDP;
	package ASU renames ADA.Strings.Unbounded;
	package ACL renames ADA.Command_Line;
	package EXC renames ADA.Exceptions;
	package CM renames Chat_Messages;
	use type CM.Message_Type;

	procedure Iniciar (Client: in out Types.Client_Type; 
					Server: in out Types.Server_Type;
					Buffer: in out LLU.Buffer_Type) is
	begin
		Server.IP := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Server.Host_Name)));
		Server.EP := LLU.Build (ASU.To_String(Server.IP),Server.Port);
		LLU.Bind_Any(Client.EP);
		
		LLU.Reset(Buffer);
		CM.Message_Type'Output(Buffer'Access, CM.Init);
		LLU.End_Point_Type'Output(Buffer'Access, Client.EP);
		ASU.Unbounded_String'Output(Buffer'Access, Client.Nick);
		LLU.Send (Server.Ep, Buffer'Access);
		LLU.Reset(Buffer);
	end Iniciar;

	procedure Escritor (Client: Types.Client_Type; 
					Server_EP: LLU.End_Point_Type;
					Buffer: in out LLU.Buffer_Type) is
		Mensaje: CM.Message;
		Comentario: ASU.Unbounded_String;
	begin
		loop
			Ada.Text_IO.Put("Mensaje: ");
			Comentario := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);

			if ASU.To_String(Comentario) /= ".salir" then
				Mensaje.Tipo := CM.Writer;
				Mensaje.Client_EP := Client.EP;
				Mensaje.Comment:= Comentario;

				LLU.Reset(Buffer);
				CM.Message_Type'Output(Buffer'Access, Mensaje.Tipo);
				LLU.End_Point_Type'Output(Buffer'Access, Mensaje.Client_EP);
				ASU.Unbounded_String'Output(Buffer'Access, Mensaje.Comment);
				LLU.Send (Server_Ep, Buffer'Access);
				LLU.Reset(Buffer);
			end if;

			exit when ASU.To_String(Comentario) = ".salir";
		end loop;
		LLU.Finalize;
	end Escritor;

	procedure Lector (Client: Types.Client_Type; 
					Buffer: in out LLU.Buffer_Type) is
		Mensaje: CM.Message;
		Expired: Boolean;
	begin
		loop
			LLU.Receive(Client.EP, Buffer'Access, 1000.0, Expired);
			if Expired then
				Ada.Text_IO.Put_Line ("Plazo expirado");
			else
				Mensaje.Tipo := CM.Message_Type'Input(Buffer'Access);
				Mensaje.Nick := ASU.Unbounded_String'Input(Buffer'Access);
				Mensaje.Comment := ASU.Unbounded_String'Input(Buffer'Access);
				
				Ada.Text_IO.Put(ASU.To_String(Mensaje.Nick) & ": ");
				Ada.Text_IO.Put_Line(ASU.To_String(Mensaje.Comment));
			end if;
			LLU.Reset(Buffer);
		end loop;
	end Lector;

	Buffer: aliased LLU.Buffer_Type(1024);
	Mensaje: ASU.Unbounded_String;
	Reply: ASU.Unbounded_String;

	Usage_Error: exception;
	Client: Types.Client_Type;
	Server: Types.Server_Type;

begin

	if ACL.Argument_Count /= 3 then
		raise Usage_Error;
	else
		
		Server.Host_Name := ASU.To_Unbounded_String(ACL.Argument(1));
		Server.Port := Integer'Value(ACL.Argument(2));
		Client.Nick := ASU.To_Unbounded_String(ACL.Argument(3));

		if ASU.To_String(Client.Nick) = "lector" then
			Iniciar (Client, Server, Buffer);
			Lector (Client, Buffer);
		else
			Iniciar (Client, Server, Buffer);
			Escritor (Client, Server.EP, Buffer);
		end if;
	end if;

	exception
	when Usage_Error =>
		TIO.Put_Line("Error de uso!!");
		TIO.Put_Line("Uso: ./chat_client <Server_Host_Name> <Server_Port> <Nick>");
		LLU.Finalize;
end Chat_Client;
