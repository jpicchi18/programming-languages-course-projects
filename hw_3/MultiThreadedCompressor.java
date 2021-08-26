import java.io.IOException;
import java.lang.Thread;


/** CREDIT to MessAdmin for the following ideas...
 *  - the overall object composition/hierarchy that is contained in the
 *      top-level multithreaded compression program
 *  - creating separating threads for the checksum and write tasks
 *  - creating a separate compressor object that contains a thread pool
 *  - the cycle in which blocks are read, passed to the write task queue, passed
 *      to the compressor queue, and passed to the checksum queue
 *  - some of the functions in this class have functionality that is very similar
 *      to the functions in the top-level multithreaded compressor program in 
 *      MessAdmin
 */
class MultiThreadedCompressor {
    private int n_processors;
    private WriteTask write_task;
    private Thread write_thread;
    private boolean saw_last_block = false;
    private ChecksumTask checksum_task;
    private Thread checksum_thread;
    private Compressor compressor;

    // constructor
    public MultiThreadedCompressor(int processor_count) {
        checksum_task = new ChecksumTask();
        checksum_thread = new Thread(checksum_task);
        compressor = new Compressor(processor_count);
        write_task = new WriteTask();
        write_thread = new Thread(write_task);
        n_processors = processor_count;
    }

     // perform compression and output results
     public void compress() throws IOException, InterruptedException {
        write_task.add_header();

        // start up checksum and writing
        checksum_thread.start();
        write_thread.start();

        // read our first block
        Block previous_block = null;
        Block current_block = read_a_block();


        // Repeatdely... compress, checksum, write until the end of the block stream
        while (current_block != null) {
            compressor.add_block(previous_block, current_block);
            checksum_task.add_block(current_block);
            write_task.add_block(current_block);
            
            previous_block = current_block;
            current_block = read_a_block();
        }

        // finish write procedure and write results to stdout
        compressor.shutdown();
        write_thread.join();
        checksum_thread.join();

        // add trailer and write all output to stdout
        write_task.add_trailer(checksum_task.get_crc());

        return;
    }

    // returns null when no more block are available
    public Block read_a_block() {
        try {
            // if we already saw the last block, then no more input available --> return null
            if (saw_last_block) {
                return null;
            }

            // else, read a block and return it
            Block new_block = new Block();
            saw_last_block = new_block.is_last_block();

            return new_block;
        } catch (IOException e) {
            System.err.println("IOException in 'read_a_block()");
            System.exit(1);
            return null;
        }
    }
}