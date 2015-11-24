--Marco Tejedor Gonzalez
with Ada.Strings.Unbounded;
with Ada.Text_IO;
package Utilidades is

	package ASU renames Ada.Strings.Unbounded;
	package TIO renames Ada.Text_IO;
	
	function Num_Palabras (Frase: ASU.Unbounded_String) return Natural;
	--Devuelve el numero de palabras de un Unbounded string
	
	function Num_Espacios (Frase: ASU.Unbounded_String) return Natural;
	--Devuelve el numero de espacios de un Unbounded string

	function Num_Caract (Frase: ASU.Unbounded_String) return Natural;

	procedure Escr_Num_Palabras (Frase: ASU.Unbounded_String);
	--Escribe el numero de palabras de un Unbounded String

	procedure Escr_Num_Espacios (Frase: ASU.Unbounded_String);
	--Escribe el numero de espacios de un Unbounded String

	procedure Escr_Num_Caract (Frase: ASU.Unbounded_String);
	--Escribe el numero de caracteres de un Unbounded String

	function Es_May (C: Character) return Boolean;
	--Devuelve True si es mayuscula y False si no

	function May_A_Min (C: Character) return Character;
	--Devuelve un caracter a si equivalente en minuscula

	procedure US_A_Min (Pal:in out ASU.Unbounded_String);
	--Cambia cualquier Unbounded String a minusculas

	procedure Escr_Lin_Pal_Car 
			(Lin, Pal, Car: Natural);
		

end Utilidades;


