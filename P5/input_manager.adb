--Marco Tejedor González
with Pantalla;
with Chat_Handler;
with ADA.Calendar;
with Chat_Messages;
package body Input_Manager is
	package CM renames Chat_Messages;

	procedure Manage_Input(Comentario: ASU.Unbounded_String; Myself: in out CH.User_Type; Final: in out Boolean; Prompt: in out Boolean; Text: out Boolean) is
	begin
		Text := False;
		if ASU.To_String(Comentario) = ".salir" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			Final := True;
			Pantalla.Poner_Color(Pantalla.Blanco);
      elsif ASU.To_String(Comentario) = ".nb" or ASU.To_String(Comentario) = ".neighbors" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			CH.Neighbors.Print_Map(Myself.Neigh);
			Pantalla.Poner_Color(Pantalla.Blanco);
      elsif ASU.To_String(Comentario) = ".lm" or ASU.To_String(Comentario) = ".latest_msgs" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			CH.Latest_Msgs.Print_Map(Myself.L_Msgs);
			Pantalla.Poner_Color(Pantalla.Blanco);
      elsif ASU.To_String(Comentario) = ".sb" or ASU.To_String(Comentario) = ".sender_buffering" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			CH.Sender_Buffering.Print_Map(Myself.S_Buff);
			Pantalla.Poner_Color(Pantalla.Blanco);
		elsif ASU.To_String(Comentario) = ".sd" or ASU.To_String(Comentario) = ".sender_dests" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			CH.Sender_Dests.Print_Map(Myself.S_Dests);
			Pantalla.Poner_Color(Pantalla.Blanco);
      elsif ASU.To_String(Comentario) = ".debug" then
			Pantalla.Poner_Color(Pantalla.Rojo);
				if D.Get_Status then
					D.Set_Status(False);
					TIO.Put_Line("Desactivada información de debug");
				elsif not D.Get_Status then
					D.Set_Status(True);
					TIO.Put_Line("Activada información de debug");
				end if;
			Pantalla.Poner_Color(Pantalla.Blanco);
      elsif ASU.To_String(Comentario) = ".wai" or ASU.To_String(Comentario) = ".whoami" then
			Pantalla.Poner_Color(Pantalla.Rojo);
			TIO.Put_Line("Nick: " & ASU.To_String(Myself.Nick) & " | EP_H: " & CH.U.Writable_EP(Myself.EP_H) & " | EP_R: " & CH.U.Writable_EP(Myself.EP_R));
			Pantalla.Poner_Color(Pantalla.Blanco);
      elsif ASU.To_String(Comentario) =  ".prompt" then
			Pantalla.Poner_Color(Pantalla.Rojo);
            if not Prompt then
					Prompt := True;
					TIO.Put_Line("Activado el prompt");
				elsif Prompt then
					Prompt := False;
					TIO.Put_Line("Desactivado el prompt");
				end if;
			Pantalla.Poner_Color(Pantalla.Blanco);
      elsif ASU.To_String(Comentario) =  ".h" or ASU.To_String(Comentario) = ".help" then
			Pantalla.Poner_Color(Pantalla.Rojo);
            TIO.Put_Line("      Comandos              Efectos");
            TIO.Put_Line("      ==============        =======");
            TIO.Put_Line("      .nb .neighbors        lista de vecinos");
            TIO.Put_Line("      .lm .latest_msgs      lista de últimos mensajes recibidos");
            TIO.Put_Line("      .sb .sender_buffering lista de últimos mensajes enviados no asentidos");
            TIO.Put_Line("      .debug                toggle para info de debug");
            TIO.Put_Line("      .wai .whoami          muestra en pantalla: Nick | EP_H | EP_R");
            TIO.Put_Line("      .prompt               toggle para mostrar prompt");
            TIO.Put_Line("      .h .help              muestra esta información de ayuda");
            TIO.Put_Line("      .salir                termina el programa");
			Pantalla.Poner_Color(Pantalla.Blanco);
		else
			Text := True;
		end if;
	end Manage_Input;

end Input_Manager;
