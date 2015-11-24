--Marco Tejedor Gonzalez
package body Utilidades is


	function Num_Palabras (Frase: ASU.Unbounded_String) return Natural is
		N: Natural := 1;
		Num_Pal: Natural := 0;
		F: ASU.Unbounded_String;
	begin
		F := ASU.To_Unbounded_String (ASU.To_String(Frase) & " ");
		loop
			N := ASU.Index (F, " ");
			if N > 1 then
				Num_Pal := Num_Pal + 1;
			end if;
			F := ASU.Tail (F, ASU.Length(F)-N);
			exit when N = 0;
		end loop;
		return Num_Pal;
	end Num_Palabras;

	function Num_Espacios (Frase: ASU.Unbounded_String) return Natural is
		N: Natural := 1;
		Num_Esp: Natural := 0;
		F: ASU.Unbounded_String;
	begin
		F := Frase;
		loop
			N := ASU.Index (F, " ");
			if N /= 0 then
				Num_Esp := Num_Esp + 1;
			end if;
			F := ASU.Tail (F, ASU.Length(F)-N);
			exit when N = 0;
		end loop;
		return Num_Esp;
	end Num_Espacios;

	function Num_Caract (Frase: ASU.Unbounded_String) return Natural is
		N: Natural := 1;
		Num_Car: Natural := 0;
		F: ASU.Unbounded_String;
	begin
		F := ASU.To_Unbounded_String (ASU.To_String(Frase) & " ");
		loop
			N := ASU.Index (F, " ");
			if N > 1 then
				Num_Car := Num_Car + N - 1;
			end if;
			F := ASU.Tail (F, ASU.Length(F)-N);
			exit when N = 0;
		end loop;
		return Num_car;
	end Num_Caract;


	procedure Escr_Num_Palabras (Frase: ASU.Unbounded_String) is
		Num_Pal: Natural;
	begin
		Num_Pal := Num_Palabras (Frase);
		TIO.Put (Integer'Image(Num_Pal) & " palabras");
	end Escr_Num_Palabras;

	procedure Escr_Num_Espacios (Frase: ASU.Unbounded_String) is
		Num_Esp: Natural;
	begin
		Num_Esp := Num_Espacios (Frase);
		TIO.Put(Integer'Image(Num_Esp) & " espacios");
	end Escr_Num_Espacios;

	procedure Escr_Num_Caract (Frase: ASU.Unbounded_String) is
		Num_Car: Natural;
	begin
		Num_Car := Num_Caract (Frase);
		TIO.Put (Integer'Image(Num_Car) & " caracteres");
	end Escr_Num_Caract;
	
	function Es_May (C: Character) return Boolean is
	Si: boolean := False;
	begin
		if Character'Pos(C) >= Character'Pos('A')
			and Character'Pos(C) <= Character'Pos('Z') 
				then Si := True;
		end if;
		return Si;
	end Es_May;

	function May_A_Min (C: Character) return Character is
	Min: Character;
	begin
		Min := Character'Val(Character'Pos('a')+(Character'Pos(C)-Character'Pos('A')));
	return Min;
	end May_A_Min;

	procedure US_A_Min (Pal:in out ASU.Unbounded_String) is
	begin
		for N in 1..ASU.Length(Pal) loop
			if Es_May(ASU.To_String(Pal)(N)) then
				ASU.Replace_Element(Pal, N, May_A_Min(ASU.To_String(Pal)(N)));
			end if;
		end loop;
	end US_A_Min;

	procedure Escr_Lin_Pal_Car 
			(Lin, Pal, Car: Natural) is
	begin
		TIO.Put (Integer'Image(Lin) & " lineas, ");
		TIO.Put (Integer'Image(Pal) & " palabras, ");
		TIO.Put_Line (Integer'Image(Car) & " caracteres");
	end Escr_Lin_Pal_Car;
		

end Utilidades;


