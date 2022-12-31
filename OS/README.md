# Operating Systems Projects

This folder contains a sample of projects I have done for my operating systems class. So far, I have two programs included. Below is a brief description of each.<br/><br/>



## synch.c


Synch.c is a file that comes with OS/161, an educational operating system developed by Harvard University to teach fundamental OS concepts. However, it is also only a template. Using my knowledge of synchronization primitives and provided skeletone code, I had to write all functions associated with mutex locks and condition variables (CVs). This file is actually a part of the OS kernel and is what allows OS/161 to support concurrency. With synchronization primitives, OS/161 can now safely handle multiple processes running concurrently.<br/><br/>


## catsem.c 

The idea of this project is based on the readers and writers problem. My job is to write two concurrent programs, cats and mice. Cats and mice behave similarly to readers and writers, but this is a much more involved and advanced version of the reader-writer problem with even more constraints than normal. Briefly, here are the specifications:<br/>

* Mice and Cats are created and compete to get into "the kitchen" (area protected by mutex lock/semaphore)
* Mice cannot be in the kitchen at the same time as cats (and vice versa). Otherwise cats will eat mice.
* The program must exhibit round-robin queue behavior to ensure no starvation occurs for either cats or mice.
* Animals must eat from a dish (shared resource) when in the kitchen and cannot share a dish.
* When done eating, it must be signaled when the kitchen is empty and new animals may come in.


catsem.c is a file made up of 3 parts:

1. catsem() - This is the cat thread that can be ran concurrently.
2. mousesem() - This is the mouse thread that can be ran concurrently.
3. catmousesem() - This can be seen as a main driver program that creates several catsem and mousesem processes (using the thread_fork system call) that run concurrently. <br/>

synch.c and catsem.c are actually from two different projects, but catsem.c builds off of the work from synch.c and uses the synchronization primitive library. That means that catsem.c is intended to be run off of OS/161. This project empasizes the importance of synchronization and protection of shared variables so that processes can run without issues like race conditions and deadlock.


