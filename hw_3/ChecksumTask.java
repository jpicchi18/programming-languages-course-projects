
import java.util.concurrent.LinkedBlockingQueue;
import java.util.zip.CRC32;


/** CREDIT to MessAdmin for the following ideas...
 *  - having a single thread that runs the checksum functionalities independently from
 *      the rest of the program
 *  - having the checksum task contain its own block queue to keep track of which blocks
 *      it needs to process in which order
 *  - the run function has a conceptually similar functionality to the equivalent
 *      function in MessAdmin
 */
class ChecksumTask implements Runnable {

    private LinkedBlockingQueue<Block> block_queue;
    private volatile boolean done = false;
    private CRC32 crc = new CRC32();



    public ChecksumTask() {
        block_queue = new LinkedBlockingQueue<Block>();
    }

    // returns the crc value, converted to an int
    public long get_crc() {
        return crc.getValue();
    }

    // add a block to the queue
    public void add_block(Block block) throws InterruptedException {
        block_queue.put(block);
    }

    public void run() {
        // reset the crc before we start anything
        crc.reset();

        try {
            while ( ! done) {
                // retrieve block from queue
                Block block = block_queue.take();
                if (block.is_last_block()) {
                    done = true;
                }

                // update the crc with the block
                crc.update(block.return_uncompressed_buf(), 0, block.return_uncompressed_bytes());
            }
        } catch (InterruptedException ignore) {}
    }
}