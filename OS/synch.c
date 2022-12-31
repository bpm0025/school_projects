/*
 * Synchronization primitives.
 * See synch.h for specifications of the functions.
 */

#include <types.h>
#include <lib.h>
#include <synch.h>
#include <thread.h>
#include <curthread.h>
#include <machine/spl.h>

////////////////////////////////////////////////////////////
//
// Semaphore.

struct semaphore *
sem_create(const char *namearg, int initial_count)
{
	struct semaphore *sem;

	sem = kmalloc(sizeof(struct semaphore));
	if (sem == NULL) {
		return NULL;
	}

	sem->name = kstrdup(namearg);
	if (sem->name == NULL) {
		kfree(sem);
		return NULL;
	}

	sem->count = initial_count;
	return sem;
}

void
sem_destroy(struct semaphore *sem)
{
	int spl;
	assert(sem != NULL);

	spl = splhigh();
	assert(thread_hassleepers(sem)==0);
	splx(spl);

	/*
	 * Note: while someone could theoretically start sleeping on
	 * the semaphore after the above test but before we free it,
	 * if they're going to do that, they can just as easily wait
	 * a bit and start sleeping on the semaphore after it's been
	 * freed. Consequently, there's not a whole lot of point in 
	 * including the kfrees in the splhigh block, so we don't.
	 */

	kfree(sem->name);
	kfree(sem);
}

void 
P(struct semaphore *sem)
{
	int spl;
	assert(sem != NULL);

	/*
	 * May not block in an interrupt handler.
	 *
	 * For robustness, always check, even if we can actually
	 * complete the P without blocking.
	 */
	assert(in_interrupt==0);

	spl = splhigh();
	while (sem->count==0) {
		thread_sleep(sem);
	}
	assert(sem->count>0);
	sem->count--;
	splx(spl);
}

void
V(struct semaphore *sem)
{
	int spl;
	assert(sem != NULL);
	spl = splhigh();
	sem->count++;
	assert(sem->count>0);
	thread_wakeup(sem);
	splx(spl);
}

/////////////////////////////////////////////////////////////////////
// 								   //
// Lock.    (Please refer to synch.h for lock's actual structure)  //
//								   //
/////////////////////////////////////////////////////////////////////




/* Create lock, check if everything is good, and give its fields default values*/
	
struct lock *
lock_create(const char *name)
{
	struct lock *lock;

	lock = kmalloc(sizeof(struct lock));
	if (lock == NULL) {
		return NULL;
	}

	lock->name = kstrdup(name);
	if (lock->name == NULL) {
		kfree(lock);
		return NULL;
	}
	
	// add stuff here as needed
	

	lock->holder = NULL;
	


	return lock;
}








/* Destroy the lock, free all the memory it is taking up*/

void
lock_destroy(struct lock *lock)
{
	assert(lock != NULL);

	// add stuff here as needed
	kfree(lock->holder);
	kfree(lock->name);
	kfree(lock);
	
}











/* Process calls this to try and aqcuire the lock */


void
lock_acquire(struct lock *lock)
{
	// Write this
	
	// Disable interrupts
	int spl = splhigh();
	

	// ***************** ATOMIC ***************************
	
	// If we want to acquire the lock, we shouldn't have it already.
	// Otherwise, there is a problem, so panic.
	
	if( lock_do_i_hold(lock) == 1 ) {
		thread_panic();
	}
	
	// Otherwise, wait (passive) while someone else is holding lock.
	// Put waiting thread in sleeping queue.
	// thread_sleep will make the thread point to this lock.
	// 	Threads have a field that points to things that
	// 	they are waiting on, basically saying
	// 	"this is what I am waiting on."

	while(lock->holder != NULL) {	
		thread_sleep(lock);
	}


	// When lock is finally free, grab it.
	// Not every thread will run this command 
	// 	when the lock is released. Only
	// 	one lucky program will get it.
	lock->holder = curthread;

	// Restore interrupts
	splx(spl);
	
	// ************ END of ATOMIC operation ****************
	


	/* Was here when I got here, don't know if I need it
		(void)lock; 
	*/
}












/* Process releases the lock. It is done doing what it needs to do,
 * 	and lets it go so somebody else can use it.
 *
*/

void
lock_release(struct lock *lock)
{
	// Write this
	

	// *************** ATOMIC OPERATION *******************
	int spl = splhigh(); 



	// Release the lock
	lock->holder = NULL;
	
	// Wake up threads waiting on the lock
	thread_wakeup(lock);




	splx(spl);
	// ************ End of ATOMIC OPERATION ***************


	// Comes withs (when I got here):
	//(void)lock;  // suppress warning until code gets written
}














/* Returns whether the current process is holding the lock.
 * Useful for setting off a panic if a process that already
 * 	has the lock tries to acquire it again (because it
 * 	shouldn't be doing that.
*/ 	



int
lock_do_i_hold(struct lock *lock)
{
	// Write this


	// *************** ATOMIC OPERATION *********************
	int spl = splhigh();
	
	// Holds answer to whether or not we hold the lock
	int same = -1;

	// Check if current process holds the lock
	if (lock -> holder == curthread) {
		int same = 1;				 // yes
	} else {
		int same = 0;				 // no
	}

	splx(spl);
	// ******************** END ****************************

	return same;

	//(void)lock;  // suppress warning until code gets written
	//return 1;    // dummy until code gets written
}








////////////////////////////////////////////////////////////
//						          //
// CV						          //
//							  //
////////////////////////////////////////////////////////////




struct cv *
cv_create(const char *name)
{
	struct cv *cv;

	cv = kmalloc(sizeof(struct cv));
	if (cv == NULL) {
		return NULL;
	}

	cv->name = kstrdup(name);
	if (cv->name==NULL) {
		kfree(cv);
		return NULL;
	}
	
	// add stuff here as needed
	
	return cv;
}





void
cv_destroy(struct cv *cv)
{
	assert(cv != NULL);

	// add stuff here as needed
	
	kfree(cv->name);
	kfree(cv);
}











// Process waits for a condition to be true
//
// *cv   : The specific condition variable we are waiting on.
//  lock : The lock our process must also aqcuire 

void
cv_wait(struct cv *cv, struct lock *lock)
{
	// Write this
	
	// Make sure our lock and cv are properly initialized.
	assert(cv != NULL)
	assert(lock != NULL)


	/*************** ATOMIC OPERATION ****************************/
	int spl = splhigh();	
	
	// Release the lock so another process, can hopefully
	// 	change our condition variable.

	lock_release(lock);

	// Put thread to sleep on cv. We must sleep on cv 
	// 	instead of lock because WE ARE NOT ONLY 
	// 	WAITING ON A CRITICAL SECTION/LOCK. WE ARE
	// 	ALSO WAITING ON SOME CONDITION.
	
	thread_sleep(cv);

	// We are just waiting in sleep until suddenly, 
	// 	we are awoken and switch back to this process.
	// 	Since we are awake, it means condition may be met.
	// 	we can try and acquire the lock for critical
	// 	section or etc.
	
	lock_acquire(lock);


	splx(spl);
	/************ END of ATOMIC OPERATION ***************************/



	// If we aqcuire the lock, but condition changes to
	// 	false again, we will likely repeat this process,
	// 	depending on how the process uses this function.

}













void
cv_signal(struct cv *cv, struct lock *lock)
{
	//Make sure cv and lock are properly initialized
	assert(cv != NULL);
	assert(lock != NULL);
	
	/*********************** ATOMIC OPERATION **************************/
	int spl = splhigh();
	
	
	// Assumption is that if we can change the "CV,"
	// 	we are already somewhere that requires 
	// 	the lock. So we must have the lock.
	// 	Otherwise, we there is something wrong
	// 	if a process without the lock is signaling
	// 	it has changed the CV. 

	if( lock_do_i_hold(lock) == 0 ) {
		thread_panic();
	}	
	
	// At this point, we know we have the lock. We've changed something
	// 	so now whatever condition we want has been met. Time to 
	// 	"send a signal" that the condition has been met, and things
	// 	waiting on it can now run. We wake up a thread waiting on cv.
	thread_wakeup(cv);



	splx(spl);
	/******************** END OF ATOMIC OPERATION **********************/

}










/* This is almost the exact same function as 
 * 	cv_signal() above, but now we are
 * 	waking ALL threads waiting on this cv.
 *
*/

void
cv_broadcast(struct cv *cv, struct lock *lock)
{	
	
	// Write this
	
	// Checking to make sure cv and lock properly initialized
	assert(cv != NULL);
	assert(lock != NULL);

	/******************** ATOMIC OPERATION ********************/
	int spl = splhigh();


	// Make sure we actually hold the lock (see cv_signal)
	if ( lock_do_i_hold(lock) == 0 ) {
		thread_panic();
	}

	
	// Wake up all threads waiting on cv.
	thread_wakeall(cv);

	
	splx(spl);
	/************** END  OF ATOMIC OPERATION ******************/

}



