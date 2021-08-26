
import java.util.concurrent.LinkedBlockingQueue;
import java.io.IOException;
import java.util.zip.Deflater;
import java.io.PrintStream;



/** CREDIT to MessAdmin for the following ideas...
 *  - creating a separate write task that contains a queue of blocks that are to be
 *      processed
 *  - using CountDownLatch as a synchronization to coordinate the writing and compression
 *      task order
 *  - some of the functions in this class are very similar in functionality to functions that appear
 *      in the WriteTask class of MessAdmin
 */
// has a queue of blocks, and it keeps trying to take a block and write it
class WriteTask implements Runnable {

    // MEMEBER VARS
    private final static int TRAILER_SIZE = 8;
    private final static int GZIP_MAGIC = 0x8b1f;

    private LinkedBlockingQueue<Block> block_queue;
    private volatile boolean done = false;
    private PrintStream outStream;
    private long total_bytes_in_stdin;
    

    public WriteTask() {
        block_queue = new LinkedBlockingQueue<Block>();
        outStream = new PrintStream(System.out, true);
        total_bytes_in_stdin = 0;
    }

    // add the header to local output stream
    public void add_header() throws IOException {
        byte[] header_array = new byte[] {
            (byte) GZIP_MAGIC,        // Magic number (short)
            (byte)(GZIP_MAGIC >> 8),  // Magic number (short)
            Deflater.DEFLATED,        // Compression method (CM)
            0,                        // Flags (FLG)
            0,                        // Modification time MTIME (int)
            0,                        // Modification time MTIME (int)
            0,                        // Modification time MTIME (int)
            0,                        // Modification time MTIME (int)Sfil
            0,                        // Extra flags (XFLG)
            0                         // Operating system (OS)
        };
        
        // write to stdout and check for error
        outStream.write(header_array, 0, header_array.length);
        check_for_error();
    }

    // add block to queue for processing
    public void add_block(Block block) throws InterruptedException {
        block_queue.put(block);
    }

    // writes the compressed bytes of the blocks. must add header before and trailer afterwards
    public void run() {
        try {
            while ( ! done) {
                // retrieve block from queue
                Block block = block_queue.take();
                if (block.is_last_block()) {
                    done = true;
                }

                // FIX LATER: write the block and check for error
                outStream.write(block.return_compressed_buf(), 0, block.return_compressed_bytes());
                check_for_error();

                // count up the uncompressed bytes in this block
                total_bytes_in_stdin += block.return_uncompressed_bytes();
            }
        } catch (InterruptedException ignore) {}

        // make sure you add the trailer later!
    }

    // // write entire local output stream to stdout
    // public void write_to_stdout() throws IOException {
    //     outStream.writeTo(System.out);
    // }

    // add trailer to local output stream
    public void add_trailer(long crc_value) throws IOException {
        byte[] trailerBuf = new byte[TRAILER_SIZE];
        writeTrailer(trailerBuf, 0, crc_value);

        // write to stdout and check for error
        outStream.write(trailerBuf, 0, trailerBuf.length);
        check_for_error();
    }


    /* HELPER
     * Writes GZIP member trailer to a byte array, starting at a given
     * offset.
     */
    private void writeTrailer(byte[] buf, int offset, long crc_value) throws IOException {
        writeInt((int)crc_value, buf, offset); // CRC-32 of uncompr. data
        writeInt((int)total_bytes_in_stdin, buf, offset + 4); // Number of uncompr. bytes
    }

    /* HELPER
     * Writes integer in Intel byte order to a byte array, starting at a
     * given offset.
     */
    private void writeInt(int i, byte[] buf, int offset) throws IOException {
        writeShort(i & 0xffff, buf, offset);
        writeShort((i >> 16) & 0xffff, buf, offset + 2);
    }

    /* HELPER
     * Writes short integer in Intel byte order to a byte array, starting
     * at a given offset
     */
    private void writeShort(int s, byte[] buf, int offset) throws IOException {
        buf[offset] = (byte)(s & 0xff);
        buf[offset + 1] = (byte)((s >> 8) & 0xff);
    }

    private void check_for_error() {
        if (outStream.checkError()) {
            System.err.println("Write error from printStream.checkError()");
            System.exit(1);
        }
    }
}