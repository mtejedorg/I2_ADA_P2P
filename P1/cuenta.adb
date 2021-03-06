-- Marco Tejedor Gonzalez
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with ADA.Command_Line;
with ADA.IO_Exceptions;
with Utilidades;
with List;
with Ada.Unchecked_Deallocation;

procedure Cuenta is

	package ASU renames Ada.Strings.Unbounded;
	package TIO renames Ada.Text_IO;
	package U renames Utilidades;
	package ACL renames ADA.Command_Line;
	package EXC renames ADA.IO_Exceptions;

	procedure Leer_Fich (L: in out List.Lista; Lin, Pal, Car: in out Natural; Arg: Integer) is
	Fich: TIO.File_Type;
	Final: Boolean:= False;
	Frase: ASU.Unbounded_String;
	begin
		TIO.Open(Fich, TIO.In_File, ACL.Argument(Arg));
		while not Final loop
			begin
				Frase := ASU.To_Unbounded_String(TIO.Get_Line(Fich));
				U.US_A_Min(Frase);
				Pal := Pal + U.Num_Palabras(Frase);
				Car := Car + U.Num_Caract(Frase);
				List.Insertar_Palabras (Frase, L);
				Lin := Lin + 1;
			exception
				when EXC.End_Error =>
					Final := True;
			end;
		end loop;
		TIO.Close(Fich);
	end Leer_Fich;

	procedure Hacer_Tabla (L: in out List.Lista) is
	begin
		TIO.New_Line(3);
		TIO.Put_Line ("Palabras");
		TIO.Put_Line ("--------");
		List.Extract_List(L);
	end Hacer_Tabla;

	L: List.Lista;
	Lineas: Natural := 0;
	Num_Pal: Natural := 0;
	Num_Car: Natural := 0;
	Usage_Error: exception;

begin
	if ACL.Argument_Count = 2 then
		if ACL.Argument(1) = "-f" then
			Leer_Fich(L, Lineas, Num_Pal, Num_Car, 2);
			U.Escr_Lin_Pal_Car (Lineas, Num_Pal, Num_Car);
			List.Delete_List(L);
		else
			raise Usage_Error;
		end if;
	elsif ACL.Argument_Count = 3 then
		if ACL.Argument(1) = "-t" and
			ACL.Argument(2) = "-f" then
			Leer_Fich(L, Lineas, Num_Pal, Num_Car, 3);
			U.Escr_Lin_Pal_Car (Lineas, Num_Pal, Num_Car);
			Hacer_Tabla(L);
		elsif ACL.Argument(3) = "-t" and
			ACL.Argument(1) = "-f" then
			Leer_Fich(L, Lineas, Num_Pal, Num_Car, 2);
			U.Escr_Lin_Pal_Car (Lineas, Num_Pal, Num_Car);
			Hacer_Tabla(L);
		end if;
	else
		raise Usage_Error;
	end if;

	exception
		when Usage_Error =>
			TIO.Put_Line("Error de uso!!");
			TIO.Put_Line("Comandos permitidos:");
			TIO.Put_Line("   ./cuenta -f <fichero>");
			TIO.Put_Line("   ./cuenta -t -f <fichero>");
			TIO.Put_Line("   ./cuenta -f <fichero> -t");

end Cuenta;

