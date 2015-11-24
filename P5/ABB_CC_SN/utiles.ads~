--Marco Tejedor González
with Lower_Layer_UDP;
with Ada.Calendar;
with Ada.Text_IO;
with Ada.Strings.Unbounded;

package Utiles is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
	package AC renames Ada.Calendar;
	package TIO renames Ada.Text_IO;
	use type AC.Time;

	Max_Neigh_Length : constant Natural := 10;
	Max_LM_Length : constant Natural := 50;
	Max_Retries: constant Natural := 10;

	type Seq_N_T is mod Integer'Last;

	function Time_To_String (T: Ada.Calendar.Time) return String;

	function Writable_EP (EP: LLU.End_Point_Type) return String;

	type Mess_Id_T is record
		EP: LLU.End_Point_Type;
		Seq: Seq_N_T;
	end record;

	type Destination_T is record
		EP: LLU.End_Point_Type := null;
		Retries: Natural := 0;
	end record;

	type Destinations_T is array (1..Max_Neigh_Length) of Destination_T;

	function SD_Igual (A, B: Mess_Id_T) return Boolean;

	function SD_Menor (A, B: Mess_Id_T) return Boolean;

	function SD_Mayor (A, B: Mess_Id_T) return Boolean;

	function MIT_To_String (A: Mess_Id_T) return String;

	function DT_To_String (A: Destinations_T) return String;

	type Buffer_A_T is access LLU.Buffer_Type;

	type Value_T is record
		EP_H_Creat: LLU.End_Point_Type;
		Seq_N: Seq_N_T;
		P_Buffer: Buffer_A_T;
	end record;

--	function SB_Igual (A, B: AC.Time) return boolean;

--	function SB_Menor (A, B: AC.Time) return boolean;

--	function SB_Mayor (A, B: AC.Time) return boolean;

	function VT_To_String (A: Value_T) return String;

end Utiles;
