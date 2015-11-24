--Marco Tejedor González
with Pantalla;
with Chat_Handler;
with ADA.Calendar;
package body Input_Manager is

	procedure Manage_Input(Comentario: ASU.Unbounded_String; Myself: in out CH.User_Type; Final: in out Boolean; Prompt: in out Boolean) is
	use type CH.Seq_N_T;
	begin
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
			TIO.Put_Line("Nick: " & ASU.To_String(Myself.Nick) & " | EP_H: " & CH.Writable_EP(Myself.EP_H) & " | EP_R: " & CH.Writable_EP(Myself.EP_R));
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
            TIO.Put_Line("      Comandos          Efectos");
            TIO.Put_Line("      ==============    =======");
            TIO.Put_Line("      .nb .neighbors    lista de vecinos");
            TIO.Put_Line("      .lm .latest_msgs  lista de últimos mensajes recibidos");
            TIO.Put_Line("      .debug            toggle para info de debug");
            TIO.Put_Line("      .wai .whoami      muestra en pantalla: Nick | EP_H | EP_R");
            TIO.Put_Line("      .prompt           toggle para mostrar prompt");
            TIO.Put_Line("      .h .help          muestra esta información de ayuda");
            TIO.Put_Line("      .salir            termina el programa");
			Pantalla.Poner_Color(Pantalla.Blanco);
		else
			Myself.Seq_N := Myself.Seq_N + 1;
					D.Put_Line("Sumo 1 a mi Seq_N", Pantalla.Azul);
			Messages.Send_Flood (Myself, Myself, Myself.EP_H, Messages.Writer, False, Comentario);
		end if;
	end Manage_Input;

end Input_Manager;
