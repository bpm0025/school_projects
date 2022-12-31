/*
 * catsem.c
 *
 * 30-1-2003 : GWA : Stub functions created for CS161 Asst1.
 *
 * NB: Please use SEMAPHORES to solve the cat syncronization problem in 
 * this file.
 */


/*
 * 
 * Includes
 *
 */

#include <types.h>
#include <lib.h>
#include <test.h>
#include <thread.h>
#include <synch.h>


/*
 * 
 * Constants
 *
 */

/*
 * Number of food bowls.
 */

#define NFOODBOWLS 2

/*
 * Number of cats.
 */

#define NCATS 6

/*
 * Number of mice.
 */

#define NMICE 2


// Max eating time
#define MAXTIME 3


//******************************* GLOBAL VARIABLES ******************************************

// For regulating turns and who goes in kitchen

struct lock *kitchen_lock;

struct semaphore *catsemaphore; 
struct semaphore *mousesemaphore;

struct semaphore *bothcats;
struct semaphore *bothmice;

// enumerated for which animal 0 (first animal) got in first
int first_in_kitchen;
int neither;
int cats;
int mice;



// For dishes and their protection

struct lock *dish_lock;
int dish1 = 1;
int dish2 = 2;
//bools
int dish1_taken = 0;
int dish2_taken = 0;


// For changing turns

struct lock *animals_in_kitchen_lock;
int cats_in_kitchen = 0;
int mice_in_kitchen = 0;
int cats_still_hungry = 6;
int mice_still_hungry = 2;




// Controls for end of cats and mice simulation (time to clean up threads)


struct semaphore *all_done_sem;







//*****************************************************************************************



/*
 * 
 * Function Definitions
 * 
 */


/*
 * catsem()
 *
 * Arguments:
 *      void * unusedpointer: currently unused.
 *      unsigned long catnumber: holds the cat identifier from 0 to NCATS - 1.
 *
 * Returns:
 *      nothing.
 *
 * Notes:
 *      Write and comment this function using semaphores.
 *
 */

static
void
catsem(void * unusedpointer, 
       unsigned long catnumber)
{
  
  //-------- THREAD FIELDS---------------------------------------------
  
   (void) unusedpointer;
   (void) catnumber;
   
   int my_dish = -1;
   
  //------------------------------------------------------------------
   
   
   
   
   // Who gets kitchen first? Whoever gets this lock first.
   
   //**************************************************************
   lock_acquire(kitchen_lock);
   lock_acquire(animals_in_kitchen_lock);
   
   if ((catnumber == 0) && (first_in_kitchen == neither)) {
         // We are first cat. Set us to first to block mice.
      first_in_kitchen = cats;
      V(catsemaphore);
      V(catsemaphore);
      
      
      // Also initialize this in here because its being janky
      cats_still_hungry = 6;
      mice_still_hungry = 2;
      
      
   }
   
   
   lock_release(kitchen_lock);
   lock_release(animals_in_kitchen_lock);
   //****************************************************************
   
   
   
   
   
   
   
   // Wait to actually be admitted to the kitchen
   P(catsemaphore);
   
   
   //********************************************************************
   //                      In the kitchen
   
   
   
   
   // Keep track of cats in kitchen
   //---------------------------------------------------------------------
   lock_acquire(animals_in_kitchen_lock);
   
   cats_in_kitchen++;
   
   lock_release(animals_in_kitchen_lock);
   //----------------------------------------------------------------------
   
   
   
   
   
   
   
   // Wait for both cats to get into kitchen
   //--------------------------------------------------------------------
   lock_acquire(animals_in_kitchen_lock);
   
   // If both cats are in, we will signal them to go. 
   if (cats_in_kitchen == 2) {
      V(bothcats);
      V(bothcats);
   }
   
   lock_release(animals_in_kitchen_lock);
   
   // Otherwise, wait here.
   
   P(bothcats);
   
   ///-------------------------------------------------------------------
   
   
   
   
   
   
   
   
   
   //Pick a dish to eat.
   // --------------------------------------------------------------------
   lock_acquire(dish_lock);
   
   // If dish 1 is available 
   if (dish1_taken == 0) {
      // Make it our dish
      my_dish = dish1;
      // Let other threads know this dish is taken
      dish1_taken = 1;
      
   } 
   else {
      // Otherwise, take dish 2
      my_dish = dish2;
      // Let other threads know dish is taken
      dish2_taken = 1;
   }
   
   lock_release(dish_lock);
   //--------------------------------------------------------------------

   
   
   
   
   
   // Eat out your dish, represented by waiting
   kprintf("cat %d starts eating at dish %d\n", catnumber, my_dish);
   clocksleep(random() % MAXTIME);
   
   
   
   
   
   // Done eating, release the dish.
   //---------------------------------------------------------------------
   lock_acquire(dish_lock);
   
   if (my_dish == dish1) {
      dish1_taken = 0;
   } 
   else {
      dish2_taken = 0;
   }
   
   lock_release(dish_lock);
   //---------------------------------------------------------------------
   
   
   
   
   // Check if we need to change turns, and to who
   //--------------------------------------------------------------------
   lock_acquire(animals_in_kitchen_lock);
   
   // We are done eating and we're also leaving kitchen. Update that info.
   cats_still_hungry--;
   cats_in_kitchen--;
   
   kprintf("cat %d leaves kitchen\n", catnumber);
   
   // If the mice are hungry, they get top priority
   if (cats_in_kitchen == 0 && mice_still_hungry > 0) {
      V(mousesemaphore);
      V(mousesemaphore);
      kprintf("giving mice a turn\n");
   } 
   else if (cats_in_kitchen == 0) {
      // Otherwise, we feed ourselves
      V(catsemaphore);
      V(catsemaphore);
      kprintf("giving cats another turn\n");
   }
   
   
   
   lock_release(animals_in_kitchen_lock);
   //-------------------------------------------------------------------
   
   
   
   
   
   //                      EXITING KITCHEN
   //*******************************************************************
   
   
   
   
   
   
   // Signal that this process is done
   V(all_done_sem);
   
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
        

/*
 * mousesem()
 *
 * Arguments:
 *      void * unusedpointer: currently unused.
 *      unsigned long mousenumber: holds the mouse identifier from 0 to 
 *              NMICE - 1.
 *
 * Returns:
 *      nothing.
 *
 * Notes:
 *      Write and comment this function using semaphores.
 *
 */

static
void
mousesem(void * unusedpointer, 
         unsigned long mousenumber)
{

    
  //-------- THREAD FIELDS---------------------------------------------
  
   (void) unusedpointer;
   (void) mousenumber;
   
   int my_dish = -1;
   
  //------------------------------------------------------------------





   // Who gets kitchen first? Whoever gets this lock first.
   
   //**************************************************************
   lock_acquire(kitchen_lock);
   lock_acquire(animals_in_kitchen_lock);
   
   if (mousenumber == 0 && first_in_kitchen == neither) {
         // We are first mouse. Set us to first to block cats.
      first_in_kitchen = mice;
      V(mousesemaphore);
      V(mousesemaphore);
      kprintf("first_in_kitchen: %d\n", first_in_kitchen);
      
      // Also initialize this in here because its being janky
      cats_still_hungry = 6;
      mice_still_hungry = 2;
      
      
   }
   
   
   lock_release(kitchen_lock);
   lock_release(animals_in_kitchen_lock);
   //****************************************************************



   // Wait to actually be admitted to the kitchen
   P(mousesemaphore);
   
   //********************************************************************
   //                      In the kitchen
   


   // Keep track of mice in kitchen
   //---------------------------------------------------------------------
   lock_acquire(animals_in_kitchen_lock);
   
   mice_in_kitchen++;
   
   lock_release(animals_in_kitchen_lock);
   //----------------------------------------------------------------------







   // Wait for both mice to get into kitchen
   //--------------------------------------------------------------------
   lock_acquire(animals_in_kitchen_lock);
   
   // If both cats are in, we will signal them to go. 
   if (mice_in_kitchen == 2) {
      V(bothmice);
      V(bothmice);
   }
   
   lock_release(animals_in_kitchen_lock);
   
   // Otherwise, wait here.
   
   P(bothmice);
   
   ///-------------------------------------------------------------------




      
   //Pick a dish to eat.
   // --------------------------------------------------------------------
   lock_acquire(dish_lock);
   
   // If dish 1 is available 
   if (dish1_taken == 0) {
      // Make it our dish
      my_dish = dish1;
      // Let other threads know this dish is taken
      dish1_taken = 1;
      
   } 
   else {
      // Otherwise, take dish 2
      my_dish = dish2;
      // Let other threads know dish is taken
      dish2_taken = 1;
   }
   
   lock_release(dish_lock);
   //---------------------------------------------------------------------





   // Eat out your dish, represented by waiting
   kprintf("mouse %d starts eating at dish %d\n", mousenumber, my_dish);
   clocksleep(random() % MAXTIME);





   // Done eating, release the dish.
   //---------------------------------------------------------------------
   lock_acquire(dish_lock);
   
   if (my_dish == dish1) {
      dish1_taken = 0;
   } 
   else {
      dish2_taken = 0;
   }
   
   lock_release(dish_lock);
   //---------------------------------------------------------------------
   





   // Check if we need to change turns, and to who
   //--------------------------------------------------------------------
   lock_acquire(animals_in_kitchen_lock);
   
   // We are done eating and we're also leaving kitchen. Update that info.
   mice_still_hungry--;
   mice_in_kitchen--;
   
   
   kprintf("mouse %d leaves kitchen\n", mousenumber);
   
   // If the cats are hungry, they get top priority
   if ( (mice_in_kitchen == 0) && (cats_still_hungry > 0) ) {
      V(catsemaphore);
      V(catsemaphore);
      kprintf("giving cats a turn\n");
   } 
   else if (mice_in_kitchen == 0) {
      // Otherwise, we feed ourselves
      V(mousesemaphore);
      V(mousesemaphore);
      kprintf("giving mice another turn\n");
   }
   
  
   
   lock_release(animals_in_kitchen_lock);
   //-------------------------------------------------------------------
   
   
   
   
   
   //                      EXITING KITCHEN
   //******************************************************************
   
   
   
   
   // Signal that this process is done
   V(all_done_sem);


}






































/*
 * catmousesem()
 *
 * Arguments:
 *      int nargs: unused.
 *      char ** args: unused.
 *
 * Returns:
 *      0 on success.
 *
 * Notes:
 *      Driver code to start up catsem() and mousesem() threads.  Change this 
 *      code as necessary for your solution.
 */

int
catmousesem(int nargs,
            char ** args)
{
   int index, error;

   /*
    * Avoid unused variable warnings.
    */

   (void) nargs;
   (void) args;
   
   
   // ------------------------ INITIALIZE GLOBAL VARS -------------------------------------
   
   
   
   const char str = 'a';
   const char *str_ptr = &str;
   
   kitchen_lock = lock_create(str_ptr);
   
   
   catsemaphore = sem_create(str_ptr, 0); 
   mousesemaphore = sem_create(str_ptr, 0);
   
   dish_lock = lock_create(str_ptr);

   animals_in_kitchen_lock = lock_create(str_ptr);

   all_done_sem = sem_create(str_ptr, 8);

   first_in_kitchen = 0;
   neither = 0;
   cats = 1;
   mice = 2;


   bothcats = sem_create(str_ptr, 0);
   bothmice = sem_create(str_ptr, 0);


   int cats_still_hungry = 6;
   int mice_still_hungry = 2;

   //-------------------------------------------------------------------------------------



   /*
    * Start NCATS catsem() threads.
    */

   for (index = 0; index < NCATS; index++) {
      P(all_done_sem); 
      error = thread_fork("catsem Thread", 
                     NULL, 
                     index, 
                     catsem, 
                     NULL
                     );
                     
                  
      
      /*
       * panic() on error.
       */
   
      if (error) {
      
         panic("catsem: thread_fork failed: %s\n", 
            strerror(error)
            );
      }
   }
   
   
   
   
   
   
   /*
    * Start NMICE mousesem() threads.
    */

   for (index = 0; index < NMICE; index++) {
      P(all_done_sem); 
      error = thread_fork("mousesem Thread", 
                     NULL, 
                     index, 
                     mousesem, 
                     NULL
                     );
      
      /*
       * panic() on error.
       */
   
      if (error) {
      
         panic("mousesem: thread_fork failed: %s\n", 
            strerror(error)
            );
      }
   }



   // Wait for all processes to finish before proceeding to cleanup

   int i;
   for (i = 0; i < (NCATS + NMICE); i++) {
      P(all_done_sem);
   }
   
   kprintf("cats and mice simulation done.\n\n\n\n");


   return 0;
}


/*
 * End of catsem.c
 */
