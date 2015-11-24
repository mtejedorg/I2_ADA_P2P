--
--  TAD genérico de una tabla de símbolos (map) implementada como un
--  array ordenado.
--

generic
   type Key_Type is private;
   type Value_Type is private;
   with function "=" (K1, K2: Key_Type) return Boolean;
   with function "<" (K1, K2: Key_Type) return Boolean;
   with function ">" (K1, K2: Key_Type) return Boolean;
   with function Key_To_String (K: Key_Type) return String;
   with function Value_To_String (K: Value_Type) return String;
package Ordered_Maps_G is

   type Map is limited private;

   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean);


   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type);

   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean);


   function Map_Length (M : Map) return Natural;

   procedure Print_Map (M : Map);


private

   type Element is record
		Key: Key_Type;
		Value: Value_Type;
	end record;

	type Array_T is array (1..1000) of Element;

   type Map is record
		Arr: Array_T;
		Length: Natural := 0;
	end record;



end Ordered_Maps_G;
