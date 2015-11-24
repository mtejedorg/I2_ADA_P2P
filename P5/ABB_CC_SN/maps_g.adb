--Marco Tejedor González
with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package body Maps_G is

   procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);


   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
      P_Aux : Cell_A;
   begin
      P_Aux := M.P_First;
      Success := False;
      while not Success and P_Aux /= null Loop
         if P_Aux.Key = Key then
            Value := P_Aux.Value;
            Success := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;
   end Get;


   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type;
						Success: out Boolean) is
      P_Aux : Cell_A;
      Found : Boolean;
   begin
      -- Si ya existe Key, cambiamos su Value
      P_Aux := M.P_First;
      Found := False;
		--En principio suponemos que todo irá bien;
		Success := True;
      while not Found and P_Aux /= null loop
         if P_Aux.Key = Key then
            P_Aux.Value := Value;
            Found := True;
         end if;
         P_Aux := P_Aux.Next;
      end loop;

      -- Si no hemos encontrado Key añadimos al principio
      if not Found and M.Length < Max_Length then
			if M.Length /= 0 then
				P_Aux := M.P_First;
		      M.P_First := new Cell'(Key, Value, M.P_First, null);
				P_Aux.Prev := M.P_First;
		      M.Length := M.Length + 1;
			else
		      M.P_First := new Cell'(Key, Value, null, null);
		      M.Length := M.Length + 1;
			end if;	
		elsif not Found then
			Success := False;
      end if;
   end Put;



   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean) is
      P_Current  : Cell_A;
   begin
      Success := False;
      P_Current  := M.P_First;
      while not Success and P_Current /= null  loop
         if P_Current.Key = Key then
            Success := True;
            M.Length := M.Length - 1;
            if P_Current.Prev /= null then
               	P_Current.Prev.Next := P_Current.Next;
				end if;
				if P_Current.Next /= null then
						P_Current.Next.Prev := P_Current.Prev;
            end if;
            if M.P_First = P_Current then
					if M.P_First.Next /= null then
		            M.P_First := M.P_First.Next;
					else 
						M.P_First := null;
					end if;
            end if;
            Free (P_Current);
         else
            P_Current := P_Current.Next;
         end if;
      end loop;

   end Delete;

	function Get_Keys (M : Map) return Keys_Array_Type is
		P_Aux : Cell_A := M.P_First;
		N : Natural := 1;
		K_Array : Keys_Array_Type;
	begin
		while P_Aux /= null loop
			K_Array(N) := P_Aux.Key;
			N := N + 1;
			P_Aux := P_Aux.Next;
		end loop;
		for K in N .. Max_Length loop
			K_Array(K) := Null_Key;
		end loop;
		return K_Array;
	end Get_Keys;


	function Get_Values (M : Map) return Values_Array_Type is
		P_Aux : Cell_A := M.P_First;
		N : Natural := 1;
		V_Array : Values_Array_Type;
	begin
		while P_Aux /= null loop
			V_Array(N) := P_Aux.Value;
			N := N + 1;
			P_Aux := P_Aux.Next;
		end loop;
		for K in N .. Max_Length loop
			V_Array(K) := Null_Value;
		end loop;
		return V_Array;
	end Get_Values;

   function Map_Length (M : Map) return Natural is
   begin
      return M.Length;
   end Map_Length;

   procedure Print_Map (M : Map) is
      P_Aux : Cell_A;
   begin
      P_Aux := M.P_First;

      Ada.Text_IO.Put_Line ("Map");
      Ada.Text_IO.Put_Line ("===");

      while P_Aux /= null loop
         Ada.Text_IO.Put_Line (Key_To_String(P_Aux.Key) & " " &
                                 VAlue_To_String(P_Aux.Value));
         P_Aux := P_Aux.Next;
      end loop;
      Ada.Text_IO.Put_Line ("_________________________");
   end Print_Map;

end Maps_G;
