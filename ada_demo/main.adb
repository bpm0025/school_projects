with Ada.Text_IO, Ada.Float_Text_IO, Ada.Integer_Text_IO, Assgn;
use Ada.Text_IO, Ada.Float_Text_IO, Ada.Integer_Text_IO, Assgn;

procedure Main is

   My_Array, Another_Array, Array3, Array4 : BINARY_ARRAY;
   Test : HALF_INT := 55;
   Test2 : HALF_INT := 10;
   Test3 : HALF_INT := 16384;

begin --start main

   Init_Array(My_Array); --Test Init_Array

   Put("Printing Random Array My_Array");
   New_Line;
   Print_Bin_Arr(My_Array); --View Random Binary Array

   Put("Printing Integer value of My_Array");
   New_Line;
   Put(Bin_To_Int(My_Array),5);--Convert BINARY_ARRAY to INTEGER and print it
   New_Line(2);

   Another_Array := Int_To_Bin(Test); --Convert INTEGER to BINARY_ARRAY and save it.
   Put("Printing Array created from Int_To_Bin function: ");
   Put("Int_To_Bin("); Put(Test, 2); Put(");");
   New_Line;
   Print_Bin_Arr(Another_Array); --Printing Array created with Int_To_Bin function

   Array3 := My_Array + Another_Array; --Test one overloaded + operator
   Put("Printing value of My_Array + Another_Array, first + overload");
   New_Line;
   Put("Int value of My_Array: ");
   Put(Bin_To_Int(My_Array),5);
   New_Line;
   Put("Int value of Another_Array: ");
   Put(Bin_To_Int(Another_Array),5);
   New_Line;
   Put("Int value of Array3: ");
   Put(Bin_To_Int(Array3),5);
   New_Line;
   Put("Binary value of Array3: ");
   Print_Bin_Arr(Array3);

   Array3 := Int_To_Bin(Test2) + Array3; --Test other overloaded + operator
   Put("Printing value of Int_To_Bin(");
   Put(Test2,2);
   Put(") + Array3, second + overload");
   New_Line;
   Put("Int value of Array3 after addition: ");
   Put(Bin_To_Int(Array3),5);
   New_Line;
   Put("Current binary value of Array3: ");
   Print_Bin_Arr(Array3);

   Array4 := My_Array - Another_Array; --Test overloaded - operator
   Put("Printing value of My_Array - Another_Array, first - overload");
   New_Line;
   Put("Int value of My_Array: ");
   Put(Bin_To_Int(My_Array),5);
   New_Line;
   Put("Int value of Another_Array: ");
   Put(Bin_To_Int(Another_Array),5);
   New_Line;
   Put("Int value of Array 4 (Note, this value will be incorrect if first number is smaller than second): ");
   Put(Bin_To_Int(Array4),5);
   New_Line;
   Put("Binary value of Array 4");
   New_Line;
   Print_Bin_Arr(Array4);

   Array4 := Int_To_Bin(Test3) - My_Array; --Test other overloaded - operator
   Put("Printing value of Int_To_Bin(16384) - My_Array, second - overload");
   New_Line;
   Put("Int value of My_Array: ");
   Put(Bin_To_Int(My_Array),5);
   New_Line;
   Put("Int value of Array4 after modification: ");
   Put(Bin_To_Int(Array4),5);
   New_Line;
   Put("Binary value of Array4");
   New_Line;
   Print_Bin_Arr(Array4);

   Reverse_Bin_Arr(Array4); --Test Reverse_Bin_Arr
   Put("Reversing and printing Array4");
   New_Line;
   Print_Bin_Arr(Array4); --Print resulting reversed BINARY_ARRAY

end Main;
