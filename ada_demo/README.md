## ADA Language Demonstration

### Basil Moledina
### 12/28/2022



   The following files are for a project that demonstrates that I am capable of picking up a language in a very short span of time.
The programming language I learned for the assignment is ADA. Given a test driver and a basic interface that specifies what datatypes I will be using,
my job was to actually implement functions that perform operations on binary numbers. These functions are to be written in the ADA language. Operations
on binary numbers include addition, subtraction, initialization, reversal, and conversion to/from integers.




  Along the way, I learned about many different features of the ADA language, including the difference between functions and procedures, side-effects, parameter types (in, out, and in-out parameters), explicit type bindings, generic libraries, iterating over subtypes, and overloading special characters such as "+" and "-".  In the end, I learned that ADA is a very unique language packed with very useful features. Due to lack of resources available, it can be harder to learn. However, in my opinion, it is the best language I have ever used that enforces best programming practices. Where other languages' type safety is a hinderance, ADA's type-binding is a help.



P.S.  This assignment was graded with a series of test cases it had to pass. If you convert the unsigned binary numbers by hand to integers, you may get a different number than what the program outputs when it converts binary numbers to integers. If this results, it's because the binary numbers printed out by the program are backwards. This was done to satisfy the test cases that I was given (to the test cases, the binary numbers look correct). To get the actual binary number written correctly, simply write it in reverse (take number the computer outputs, then start writing from the left with the least-significant-bit to the right with the most significant-bit). Or, even more simply, you can: 

A) Remove line 52, which is "Reverse_Bin_Arr(Copy);" in the Print_Bin_Arr() function of assgn.adb 
B) Convert binary numbers to integers with the Bin_To_Int() function, and then convert the integer instead.



An update might come in the future to address this bug later when I am less busy.
