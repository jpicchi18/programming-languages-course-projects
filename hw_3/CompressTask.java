import java.util.zip.Deflater;

/** CREDIT to MessAdmin for the following ideas...
 *  - having a runnable task that performs compression on a single block
 *  - using these tasks as inputs to the compressor's thread pool
 */
class CompressTask implements Runnable {
    // MEMBER VARS
    public final static int BLOCK_SIZE = 131072; // 128 KiB

    private Deflater compressor;
    private Block prev_block;
    private Block cur_block;


    // create a compressor
    public CompressTask(Block prev_block_input, Block cur_block_input) {
        compressor = new Deflater(Deflater.DEFAULT_COMPRESSION, true);

        prev_block = prev_block_input;
        cur_block = cur_block_input;
    }

    // compress the block and store the deflated bytes inside of the block
    public void run() {
        compressor.reset();

        // set dictionary if this is not the first block
        if (prev_block != null) {
            compressor.setDictionary(prev_block.return_dict_buf());
        }

        compressor.setInput(cur_block.return_uncompressed_buf(), 0, cur_block.return_uncompressed_bytes());

        byte[] cmpBlockBuf = new byte[BLOCK_SIZE * 2];

        // deflate the current block and add the bytes to the block's compressed bytes buffer
        if (cur_block.is_last_block()) {
            if (!compressor.finished()) {
                compressor.finish();
                while (!compressor.finished()) {
                    int deflatedBytes = compressor.deflate(cmpBlockBuf, 0, cmpBlockBuf.length, Deflater.NO_FLUSH);
                    if (deflatedBytes > 0) {
                        cur_block.add_deflated_bytes(cmpBlockBuf, deflatedBytes);
                    }
                }
            }
        }
        else {
            int deflatedBytes = compressor.deflate(cmpBlockBuf, 0, cmpBlockBuf.length, Deflater.SYNC_FLUSH);
            if (deflatedBytes > 0) {
                cur_block.add_deflated_bytes(cmpBlockBuf, deflatedBytes);
            }
        }

        // tell the block that we finished compressing
        cur_block.done_compressing();
    }
}