--Marco Tejedor González
with Gnat.Calendar.Time_IO;
with Chat_Messages;
package body Utiles is
   package C_IO renames Gnat.Calendar.Time_IO;
	package CM renames Chat_Messages;
	use type AC.Time;

	function Time_To_String (T: Ada.Calendar.Time) return String is
		S: ASU.Unbounded_String;
   begin
		S := ASU.To_Unbounded_String("Time: " & C_IO.Image(T, "%T.%i"));
      return ASU.To_String(S);
   end Time_To_String;

	function Writable_EP (EP: LLU.End_Point_Type) return String is
		IP: ASU.Unbounded_String;
		Port: ASU.Unbounded_String;
		F: ASU.Unbounded_String;
		N:Natural;
		use type LLU.End_Point_Type;
	begin
		if EP /= null then
			F := ASU.To_Unbounded_String (LLU.Image(EP));
			N := ASU.Index (F, "IP: ");
			F := ASU.Tail (F, ASU.Length(F)-(N+3));
			N := ASU.Index (F, ", ");
			IP:= ASU.Head (F, N-1);
			N := ASU.Index (F, "Port: ");
			Port := ASU.Tail (F, ASU.Length(F)-(N+6));
			F:=ASU.To_Unbounded_String(ASU.To_String(IP) & ":" & ASU.To_String(Port));
		else
			F := ASU.To_Unbounded_String ("null");
		end if;
		return ASU.To_String(F);
	end Writable_EP;

	function SD_Igual (A, B: Mess_Id_T) return boolean is
	begin
		return LLU.Image(A.EP) = LLU.Image(B.EP) and A.Seq = B.Seq;
	end SD_Igual;

	function SD_Menor (A, B: Mess_Id_T) return boolean is
	begin
		return LLU.Image(A.EP) = LLU.Image(B.EP) and A.Seq < B.Seq;
	end SD_Menor;

	function SD_Mayor (A, B: Mess_Id_T) return boolean is
	begin
		return LLU.Image(A.EP) = LLU.Image(B.EP) and A.Seq > B.Seq;
	end SD_Mayor;

	function MIT_To_String (A: Mess_Id_T) return String is
		F: ASU.Unbounded_String;
	begin
		F := ASU.To_Unbounded_String("EP_H_Creat => " & Writable_EP(A.EP) & " Número de secuencia: " & Seq_N_T'Image(A.Seq));
		return ASU.To_String (F);
	end MIT_To_String;

	function DT_To_String (A: Destinations_T) return String is
		F: ASU.Unbounded_String;
		T: ASU.Unbounded_String := ASU.To_Unbounded_String("vacío");
		use type LLU.End_Point_Type;
		Comenzado: Boolean := False;
	begin
		for K in 1..A'Length loop
			if A(K).EP /= null then
				T := ASU.To_Unbounded_String(Writable_EP(A(K).EP) & " " & Natural'Image(A(K).Retries) & " Retries");
				if not Comenzado then
					F := T;
					Comenzado := True;
				else
					F := ASU.To_Unbounded_String(ASU.To_String(F) & "; " & ASU.To_String(T));
				end if;
			end if;
		end loop;
		if not Comenzado then
			return "sin vecinos";
		else
			return ASU.To_String (F);
		end if;
	end DT_To_String;

-----------------------------------------------------------------

--	function SB_Igual (A, B: AC.Time) return boolean is
--		D: Duration;
--	begin
--		D := B-A;
--		return D = 0.0;
--	end SB_Igual;

--	function SB_Menor (A, B: AC.Time) return boolean is
--		D: Duration;	
--	begin
--		D := B-A;
--		return D > 0.0;
--	end SB_Menor;

--	function SB_Mayor (A, B: AC.Time) return boolean is
--		D: Duration;
--	begin
--		D := B-A;
--		return D < 0.0;
--	end SB_Mayor;

	function VT_To_String (A: Value_T) return String is
		S: ASU.Unbounded_String;
		E: ASU.Unbounded_String;
		N: ASU.Unbounded_String;
		B: ASU.Unbounded_String;
	begin
		--EP
		E := ASU.To_Unbounded_String("EP_H_Creat =>" & Writable_EP(A.EP_H_Creat));
		--Seq_N
		N := ASU.To_Unbounded_String(" Número de secuencia: " & Seq_N_T'Image(A.Seq_N) & " ==> ");
		--Buffer
		B := ASU.To_Unbounded_String(LLU.Image(A.P_Buffer.All));
		S := ASU.To_Unbounded_String(ASU.To_String(E) & ASU.To_String(N) & ASU.To_String(B));
		return ASU.To_String(S);
	end VT_To_String;

end Utiles;
