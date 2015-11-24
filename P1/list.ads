--Marco Tejedor Gonzalez
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Unchecked_Deallocation;


package List is

	package ASU renames Ada.Strings.Unbounded;
	package TIO renames Ada.Text_IO;
	
	type Cell;
	type Cell_A is access Cell;

	type Cell is record
		Name: ASU.Unbounded_String;
		Count: Natural := 0;
		Next: Cell_A;
		Prev: Cell_A;
	end record;

	type Lista is record
		First: Cell_A;
		Last: Cell_A;
		Comenzada: Boolean := False;
	end record;

	procedure Free is new 
			Ada.Unchecked_Deallocation 
			(Cell, Cell_A);

	--Crea una lista con una celda
	procedure Begin_US_List
		(L:in out Lista; US:ASU.Unbounded_String);

	procedure Insert_Next_US_List
		(L:in out Lista; US:ASU.Unbounded_String);

	procedure Delete_First_Cell_List(L:in out Lista);

	procedure Delete_Last_Cell_List(L:in out Lista);

	procedure Delete_List(L:in out Lista);

	function First_Cell_List_Name(L: Lista) return String;

	function Last_Cell_List_Name(L: Lista) return String;

	procedure Extract_First_Cell_List(L:in out Lista);

	procedure Extract_Last_Cell_List(L:in out Lista);

	procedure Extract_List(L:in out Lista);

	procedure Extract_List_Reverse(L:in out Lista);

	procedure Insertar_Palabra (Pal:ASU.Unbounded_String; L: in out Lista);

	procedure Insertar_Palabras (Frase: ASU.Unbounded_String; L: in out Lista);

end List;
