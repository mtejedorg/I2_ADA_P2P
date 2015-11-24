-- Marco Tejedor Gonzalez
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Utilidades;

procedure Trocea is

	package ASU renames Ada.Strings.Unbounded;
	package TIO renames Ada.Text_IO;
	package U renames Utilidades;

	procedure Trocear (Frase:ASU.Unbounded_String) is
		N: Natural := 1;
		P: Natural := 0;
		Pal: ASU.Unbounded_String;
		F: ASU.Unbounded_String;
	begin
		F := ASU.To_Unbounded_String (ASU.To_String(Frase) & " ");
		loop
			N := ASU.Index (F, " ");
			if N > 1 then
				P := P + 1;
				Pal := ASU.Head (F, N-1);
				TIO.Put_Line("Palabra " & Integer'Image(P) &
							": |" & ASU.To_String(Pal) & "|");
			end if;
			F := ASU.Tail (F, ASU.Length(F)-N);
			exit when N = 0;
		end loop;
	end Trocear;

	Frase: ASU.Unbounded_String;

begin
	TIO.Put ("Introduce una cadena: ");
	Frase := ASU.To_Unbounded_String (TIO.Get_Line);
	Trocear(Frase);

	TIO.Put ("Total: ");
	U.Escr_Num_Palabras (Frase);
	TIO.Put (" y");
	U.Escr_Num_Espacios (Frase);
end Trocea;

