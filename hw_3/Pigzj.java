import java.lang.Runtime;
import java.io.IOException;

public class Pigzj {
    private static int num_processors;

    private static void exit_with_error (String s) {
        System.err.println(s);
        System.exit(1);
    }

    public static void main (String[] args) throws 
    IOException, NumberFormatException, InterruptedException {
        try {
            // set the number of processors from the command line arg, defaulting to the 
            // number of available processors in the system
            if (args.length == 2) {
                // make sure the flag is correct
                if (!args[0].equals("-p")) {
                    exit_with_error("Pigzj error: if specified, first argument must be '-p'");
                }

                // extract the number of processors from second arg and check for error
                num_processors = Integer.parseInt(args[1]);
                if (num_processors <= 0) {
                    exit_with_error("Pigzj error: number of processors must be greater than 0");
                } else if (num_processors > Runtime.getRuntime().availableProcessors()) {
                    exit_with_error("error: number of processors requested is > than availableProcessors()");
                }
            }
            else if (args.length != 0) {
                exit_with_error("Pigzj error: only allowed option is '-p processes'");
            }
            else{
                num_processors = Runtime.getRuntime().availableProcessors();
            }


            // do the actual compression stuff
            MultiThreadedCompressor cmp = new MultiThreadedCompressor(num_processors);
            cmp.compress();
            return;


        } catch (NumberFormatException e) {
            exit_with_error("found NumberFormatException in top level");
        } catch (IOException e) {
            exit_with_error("found IOException in top level");
        } catch (InterruptedException e) {
            exit_with_error("found InterruptedException in top level");
        }
    }
}