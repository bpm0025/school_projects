-- Generic Packages
with Ada.Numerics.Discrete_Random;
-- Regular Packages
with Ada.Text_IO; use Ada.Text_IO;




package body Assgn is 

   --------------------- Some Support variables ----------------------------
   package Random_Bit is new Ada.Numerics.Discrete_Random (BINARY_NUMBER);
   use Random_Bit;
   
   G : Generator;
   
   subtype Index is INTEGER range 1..16;
   -------------------------------------------------------------------------

   
   
   
   
   procedure Init_Array     
     (Arr : in out BINARY_ARRAY) is
      
      B : BINARY_NUMBER;  
   begin
      
		for I in Index loop
         B := Random(G);
         Arr (I) := B;
      end loop;
      
   end Init_Array;



   
   
   

procedure Print_Bin_Arr
     (Arr : in BINARY_ARRAY) is
      Copy : BINARY_ARRAY;
      
 begin
      
      -- Make a copy of the array we want to print
      Copy := Arr;
      -- Reverse that array
      Reverse_Bin_Arr(Copy);

      for I in Index loop
         Put ( BINARY_NUMBER'Image (Copy(I)) );
      end loop;
      New_Line;
   
 end Print_Bin_Arr;





   
   
   
procedure Reverse_Bin_Arr
     (Arr : in out BINARY_ARRAY) is
     Rev : BINARY_ARRAY; 
      
   begin
      
      -- Build + store the reverse of the array in a temp variable
      -- I is 1..16
      for I in Index loop
         Rev (17 - I) := Arr(I);
      end loop;
      
      -- Update our array so it equals its reverse by setting equal to temp
      Arr := Rev;
      
    end Reverse_Bin_Arr;




   
   
   
   

   function Int_To_Bin 
     (Num : in INTEGER)
      return BINARY_ARRAY is
     Arr : BINARY_ARRAY;
     Remaining : INTEGER;
   Largest_Bit_Value : INTEGER;
   
      
   begin
     
      
      -- Set our copy equal to the integer we want to convert. 
      --      This copy will change to reflect what part of the
      --      integer we still need to represent in binary.
      Remaining := Num;
      
      
      
      -- To begin with, our largest bit's value is 32,768
      -- 1XXX XXXX XXXX XXXX
      -- Our goal is to decide whether that bit should be 1 or 0.
      Largest_Bit_Value := 32768;
      
      
      
     -- For every bit in our BIN_ARR, see if it needs a 1 or 0.
      for I in Index loop
         
         -- If the "remainder" of our decimal number is 
         --    greater than / = to the next largest bit 
         if Remaining >= Largest_Bit_Value  then
            -- Set that bit to 1.
            Arr(17 - I) := 1;


            
            -- We now have represented another part of the integer
            --    we are converting. Remove it from what we have 
            --    left to represent.
            Remaining := Remaining - Largest_Bit_Value;
            
         else
            -- Otherwise, set bit to 0. Remainder does not change.
            Arr(17 - I) := 0;
         end if;
         
         
         -- After each loop, we decide what the next smallest bit will be.
         --     Update the bit value to reflect the value of the next smallest
         --     bit.
         
         Largest_Bit_Value := Largest_Bit_Value / 2;   

      end loop;
      
      -- Array is stored backwards from what is desired,
      --     Simply fixed w/ Reverse_Bin_Arr()
      Reverse_Bin_Arr(Arr);

      return Arr;
      
   end Int_To_Bin;




   
   
   
   

   
   
   
   -- Works, may just need to use the reverse_bin_array function

   function Bin_To_Int
     (Arr : in BINARY_ARRAY)
      return INTEGER is
      Result : INTEGER;
      Smallest_Bit_Value : INTEGER;
      Arr_Copy : BINARY_ARRAY;

begin

   -- At the start, the value of the smallest bit is 1
   Smallest_Bit_Value := 1;
   -- Our Result also starts out as value 0.
   Result := 0;
   -- Reverse our binary array, make a copy
      Arr_Copy := Arr;
      Reverse_Bin_Arr(Arr_Copy);

   -- For every bit in our array
   for I in Index loop      
    
      -- If there is a 1 in the next smallest bit
         if Arr_Copy(I) = 1 then
         -- Add that bit's decimal value to the final result.
         Result := Result + Smallest_Bit_Value;
      end if;
      
      -- If not then add nothing to result.
      -- We check if there is a 1 in the next largest bit.
      --    Update the bit value to represent that next largest bit.
      Smallest_Bit_Value := Smallest_Bit_Value * 2;

   end loop;

   -- Return the integer/decimal equivalent.
   return Result;


    end Bin_To_Int;




   
   
   

   
  -- Overload + 1  
   function "+" 
     (Left, Right : in BINARY_ARRAY) 
      return BINARY_ARRAY is

      A, B, Carry, Sum : INTEGER;
      Result : BINARY_ARRAY;
      Left_Copy, Right_Copy : BINARY_ARRAY;

      
   begin
      -- Carry = 0 at the start
      Carry := 0;
      
      -- Because of the way I wrote this function, we need the reverse arrays
      Left_Copy := Left;
      Right_Copy := Right;
      Reverse_Bin_Arr(Left_Copy);
      Reverse_Bin_Arr(Right_Copy);

     
      -- For every bit of both binary numbers
      for I in Index loop
         
         -- The nth bit of both numbers A and B
         A := Left_Copy(I);
         B := Right_Copy(I);
         
         -- Add A + B + Carry
         Sum := A + B + Carry;
         
         
         -- If the sum = 0
         if sum = 0 then 
            Result(I) := 0;
            Carry := 0;
            

         -- If the sum = 1
         elsif sum = 1 then
            Result(I) := 1;
            Carry := 0;


         -- If the sum = 2
         elsif sum = 2 then
            Result(I) := 0;
            Carry := 1;


         -- else, the sum = 3
         else
            Result(I) := 1;
            Carry := 1;


         end if;

         

      end loop;
      
      -- Reverse again to get in the form that the test cases want
      Reverse_Bin_Arr(Result);
      return Result;

   end "+";

      



   
   
   
 -- Overload + 2  
 function "+" 
     (Left : in INTEGER;
      Right : in BINARY_ARRAY)
      return BINARY_ARRAY is 
      Left_Bin, Result : BINARY_ARRAY;

   
   begin
      -- Make a copy of Left, convert it to binary array.
      Left_Bin := Int_To_Bin(Left);
      
      -- Now, do binary addition of both binary arrays
      Result := Left_Bin + Right;
      
      -- Return the result
      return Result;

   end "+";


   
   
   
   
   -- Overload - 1
   -- Left - Right

   function "-"
     (Left, Right : in BINARY_ARRAY) 
      return BINARY_ARRAY is
      
      Right_Copy : BINARY_ARRAY;
      
   begin

      -- Easiest way to do Left - Right is to take the 2's complement 
      --     of Right, add it to left.
      
      -- Make a copy of Right param
      Right_Copy := Right;
      

      -- Invert each bit of Right_Copy (for each bit ...)
      for I in Index loop
         
         -- If bit = 0,
         if Right_Copy(I) = 0 then
            -- Make that bit = 1
            Right_Copy(I) := 1;

         else
            -- Bit = 1. Make it equal to 0.
            Right_Copy(I) := 0;

         end if;


      end loop;

      -- Add 1 to Right_Copy
      Right_Copy := 1 + Right_Copy;
      
      -- Return the sum of Right_Copy + Left.      
      return Right_Copy + Left;

   end "-";

   
   
   
   function "-" (Left : in Integer;
                 Right : in BINARY_ARRAY) 
                 return BINARY_ARRAY is
      
      Left_Bin : BINARY_ARRAY;
      
   begin
      
      -- Convert Left to a binary array, make a copy of it.
      Left_Bin := Int_To_Bin(Left);
      
      -- Perform binary subtraction w/ overloaded operator 1, return result.
      return Left_Bin - Right;   

   end "-";



end Assgn;
