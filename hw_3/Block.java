import java.util.concurrent.CountDownLatch;
import java.io.IOException;
import java.io.InputStream;

/** CREDIT to MessAdmin for the following ideas...
 *  - making each data block its own class
 *  - having each block track its own data buffers and dictionary
 *  - some of the functions contained in this class have functionalities
 *      that are highly similar to Block class functions in MessAdmin
 */
class Block {
    public final static int BLOCK_SIZE = 131072; // 128 KiB
    public final static int DICT_SIZE = 32768; // 32 KiB = 32*2^10 B
    
    private volatile byte[] uncompressed_buf;
    private volatile int uncompressed_bytes;
    private volatile byte[] compressed_buf;
    private volatile int compressed_bytes;
    private volatile byte[] dictionary_buf;

    private volatile boolean is_last_block;
    private volatile CountDownLatch write_trigger;

    // initializes the fields for the block, reads a block from stdin, and creates a dictionary
    public Block() throws IOException {
        // allocate the buffers
        uncompressed_buf = new byte[BLOCK_SIZE];
        dictionary_buf = new byte[DICT_SIZE];
        compressed_buf = new byte[BLOCK_SIZE * 2];
        
        // set the size vars
        uncompressed_bytes = 0;
        compressed_bytes = 0;

        // create the latch to make sure we write at the correct time
        write_trigger = new CountDownLatch(1);

        // initialize it to not be the last block
        is_last_block = false;

        // fill its uncompressed data buffer
        read_stdin();

        // fill its dictionary buffer
        make_dict();
    }

    // read from stdin and 
    public void read_stdin() throws IOException {

        // try to read from stdin
        int n_bytes_read = System.in.read(uncompressed_buf);
        uncompressed_bytes += (n_bytes_read > 0) ? n_bytes_read : 0;

        while (uncompressed_bytes < uncompressed_buf.length && n_bytes_read != -1) {
            // read more
            n_bytes_read = System.in.read(uncompressed_buf, uncompressed_bytes, uncompressed_buf.length - uncompressed_bytes);
            if (n_bytes_read > 0) {
                uncompressed_bytes += n_bytes_read;
            }
        }

        // check if this was the last block, and record if it was
        if (n_bytes_read == -1) {
            is_last_block = true;
        }
    }

    // return true or false: whether this is the last block of the input stream
    public boolean is_last_block() {
        return is_last_block;
    }

    // sets the dict buffer for this block. return false if it failed
    public boolean make_dict() {
        if (uncompressed_bytes < DICT_SIZE) {
            return false;
        }
        else {
            System.arraycopy(uncompressed_buf, uncompressed_bytes - DICT_SIZE, dictionary_buf, 0, DICT_SIZE);
            return true;
        }
    }

    public byte[] return_uncompressed_buf() {
        return uncompressed_buf;
    }

    public int return_uncompressed_bytes() {
        return uncompressed_bytes;
    }

    public byte[] return_dict_buf() {
        return dictionary_buf;
    }

    // add compressed bytes to our compressed_buf
    public void add_deflated_bytes(byte[] buffer, int n_bytes) {
        System.arraycopy(buffer, 0, compressed_buf, compressed_bytes, n_bytes);
        compressed_bytes += n_bytes;
    }

    public void done_compressing() {
        write_trigger.countDown();
    }

    public byte[] return_compressed_buf() throws InterruptedException {
        write_trigger.await();
        return compressed_buf;
    }

    public int return_compressed_bytes() throws InterruptedException {
        write_trigger.await();
        return compressed_bytes;
    }
}