--Marco Tejedor Gonzalez
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;

package body Handlers is

   package ASU renames Ada.Strings.Unbounded;
	package CM renames Chat_Messages;
	package TIO renames Ada.Text_IO;
	use type CM.Message_Type;

   procedure Client_Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type) is
   Mensaje: CM.Message;
	Cagada_Monumental: exception;
   begin
      -- saca del Buffer P_Buffer.all un Unbounded_String
		Mensaje.Tipo := CM.Message_Type'Input(P_Buffer);
		if Mensaje.Tipo /= CM.Server then
			raise Cagada_Monumental;
		end if;
      Mensaje.Nick := ASU.Unbounded_String'Input(P_Buffer);
      Mensaje.Comment := ASU.Unbounded_String'Input(P_Buffer);
      TIO.New_Line;
      TIO.Put(ASU.To_String(Mensaje.Nick) & ": ");
      TIO.Put_Line(ASU.To_String(Mensaje.Comment));

	exception
		when Cagada_Monumental =>
			TIO.Put_Line("Cagada Monumental!!!");
			TIO.Put_Line("Algo va muy mal");
			LLU.Finalize;

   end Client_Handler;
	
end Handlers;

