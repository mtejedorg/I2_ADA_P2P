--Marco Tejedor González
with Ada.Text_IO;
with Lower_Layer_UDP;
with Chat_Handler;
with Ada.Strings.Unbounded;
with Pantalla;
package body Ctrl_C_Handler is
	package ASU renames Ada.Strings.Unbounded;
	procedure Handler is
		US: ASU.Unbounded_String;
	begin
		Pantalla.Poner_Color(Pantalla.Rojo);
		Ada.Text_IO.New_Line(1);
		Ada.Text_IO.Put_Line("Ha pulsado Control+C, ¿seguro que desea finalizar el chat?   (y/n)");
		US := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
		Pantalla.Poner_Color(Pantalla.Blanco);
		if ASU.To_String(US) = "y" then
			Chat_Handler.Prot_Salida;
		elsif ASU.To_String(US) /= "n" then
			Handler;
		end if;
	end Handler;
end Ctrl_C_Handler;
		
