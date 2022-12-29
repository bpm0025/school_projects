package Assgn is
   subtype HALF_INT is INTEGER range 0..16384;
   subtype BINARY_NUMBER is INTEGER range 0..1;
   type BINARY_ARRAY is array(1..16) of BINARY_NUMBER;

   --initialize first array (My_Array) with random binary values
   procedure Init_Array (Arr: in out BINARY_ARRAY);

   --reverse binary array
   procedure Reverse_Bin_Arr (Arr : in out BINARY_ARRAY);
   
   --print an array
   procedure Print_Bin_Arr (Arr : in BINARY_ARRAY);

   --Convert Integer to Binary Array
   function Int_To_Bin(Num : in INTEGER) return BINARY_ARRAY;

   --convert binary number to integer
   function Bin_To_Int (Arr : in BINARY_ARRAY) return INTEGER;

   --overloaded + operator to add two BINARY_ARRAY types together
   function "+" (Left, Right : in BINARY_ARRAY) return BINARY_ARRAY;

   --overloaded + operator to add an INTEGER type and a BINARY_ARRAY type together
   function "+" (Left : in INTEGER;
                 Right : in BINARY_ARRAY) return BINARY_ARRAY;

   --overloaded - operator to subtract one BINARY_ARRAY type from another			 
   function "-" (Left, Right : in BINARY_ARRAY) return BINARY_ARRAY;

   --overloaded - operator to subtract a BINARY_ARRAY type from an INTEGER type
   function "-" (Left : in Integer;
                 Right : in BINARY_ARRAY) return BINARY_ARRAY;
end Assgn;
