--Marco Tejedor Gonzalez
package body List is

	--Crea una lista con una celda
	procedure Begin_US_List
		(L:in out Lista; US:ASU.Unbounded_String) is
	begin
		L.First := new Cell'(US, 1, null, null);
		L.Last := L.First;
		L.Comenzada := True;
	end Begin_US_List;

	procedure Insert_Next_US_List
		(L:in out Lista; US:ASU.Unbounded_String) is
			P_Aux: Cell_A;
	begin
		P_Aux := new Cell' (US, 1, null, L.Last);
		L.Last.Next := P_Aux;
		L.Last := P_Aux;
		P_Aux := null;
	end Insert_Next_US_List;

	procedure Delete_First_Cell_List(L:in out Lista) is
			P_Aux: Cell_A;
	begin
		P_Aux := L.First.Next;
		L.First.Next.Prev := null;
		Free (L.First);
		L.First := P_Aux;	
		P_Aux := null;
	end Delete_First_Cell_List;

	procedure Delete_Last_Cell_List(L:in out Lista) is
			P_Aux: Cell_A;
	begin
		P_Aux := L.Last.Prev;
		L.Last.Prev.Next := null;
		Free (L.Last);
		L.Last := P_Aux;	
		P_Aux := null;
	end Delete_Last_Cell_List;

	procedure Delete_List(L:in out Lista) is

	begin
		while L.First /= L.Last loop
			Delete_First_Cell_List(L);
		end loop;
			L.First := null;
			Free (L.Last);
	end Delete_List;

	function First_Cell_List_Name(L: Lista) return String is
	begin
		return ASU.To_String(L.First.Name);
	end First_Cell_List_Name;

	function Last_Cell_List_Name(L: Lista) return String is
	begin
		return ASU.To_String(L.Last.Name);
	end Last_Cell_List_Name;

	procedure Extract_First_Cell_List(L:in out Lista) is
	begin
		TIO.Put_Line (First_Cell_List_Name(L) & ": " & Integer'Image(L.First.Count));
		Delete_First_Cell_List(L);
	end Extract_First_Cell_List;

	procedure Extract_Last_Cell_List(L:in out Lista) is
	begin
		TIO.Put_Line (Last_Cell_List_Name(L) & ": " & Integer'Image(L.Last.Count));
		Delete_Last_Cell_List(L);
	end Extract_Last_Cell_List;

	procedure Extract_List(L:in out Lista) is
	begin
		while L.First /= L.Last loop
			Extract_First_Cell_List(L);
		end loop;
			TIO.Put_Line (Last_Cell_List_Name(L) & ": " & Integer'Image(L.Last.Count));
			Delete_List(L);
	end Extract_List;

	procedure Extract_List_Reverse(L:in out Lista) is
	begin
		while L.First /= L.Last loop
			Extract_Last_Cell_List(L);
		end loop;
			TIO.Put_Line (First_Cell_List_Name(L) & ": " & Integer'Image(L.Last.Count));
			Delete_List(L);
	end Extract_List_Reverse;

	procedure Insertar_Palabra (Pal:ASU.Unbounded_String; L: in out Lista) is
	P_Aux : Cell_A;
	Found: Boolean;
	Stop: Boolean;
	begin
		P_Aux := L.First;	
		Found := False;
		Stop := False;	
		loop
			if ASU.To_String(Pal) = ASU.To_String(P_Aux.Name) then
				P_Aux.Count := P_Aux.Count+1;
				Found := True;
			elsif P_Aux /= L.Last then
				P_Aux := P_Aux.Next;
			else
				Stop := True;
				List.Insert_Next_US_List (L, Pal);
			end if;

			exit when Stop or Found;
		end loop;
		P_Aux := null;
	end Insertar_Palabra;


	procedure Insertar_Palabras (Frase: ASU.Unbounded_String; L: in out Lista) is
		N: Natural := 1;
		F: ASU.Unbounded_String;
		Pal: ASU.Unbounded_String;
	begin
		F := ASU.To_Unbounded_String (ASU.To_String(Frase) & " ");
		loop
			N := ASU.Index (F, " ");
			if N > 1 then
				Pal := ASU.Head (F, N-1);
				if not L.Comenzada then
					Begin_Us_List (L, Pal);
				else
					Insertar_Palabra (Pal, L);
				end if;
			end if;
			F := ASU.Tail (F, ASU.Length(F)-N);
			exit when N = 0;
		end loop;
	end Insertar_Palabras;

end List;
