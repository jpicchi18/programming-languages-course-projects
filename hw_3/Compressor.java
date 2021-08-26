import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.lang.Thread;
import java.util.concurrent.TimeUnit;

/** CREDIT to MessAdmin for the following ideas...
 *  - having a separate compressor class with a thread pool to perform compression
 *  - the use of ThreadPoolExecutor as a thread pool
 *  - some of the functions in this class have functionalities that are similar to those
 *      of functions in MessAdmin's "Compressor" class
 */
// contains a queue of blocks and a collection of threads. all of the threads continually
// try to draw from the queue and compress the block that it draws.
class Compressor {
    // MEMBER VARS
    private ThreadPoolExecutor thread_pool;
    private int n_threads;

    public Compressor(int n_processors) {
        // create a thread pool
        n_threads = n_processors;
        thread_pool = new ThreadPoolExecutor(n_threads, n_threads, 20L, TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>());
    }

    // add a task to the thread_pool so the threads can process it
    public void add_block(Block prev_block, Block cur_block) {
        thread_pool.execute(new CompressTask(prev_block, cur_block));
    }

    public void shutdown() {
        thread_pool.shutdown();        
    }
}