===============================================
IMPLEMENTTION FUNCTIONALITY VERIFICATION TESTS
===============================================

Testing the behavior of the program to verify compliance with the homework
specs...

   -> supporting the "-p processes" option of Pigz...

	 Pigzj supports the "-p processes" option of Pigz. A space must be
	 specified between "-p" and "number_of_processes". Any other option
	 syntax (either for this option, or for an attempt to specify any other
	 unsupported option) causes the program to throw an error.

	 The following bash test script ensures that invalid option syntax
	 results in the Pigzj program throwing an error:

		   run="java -cp class_files"

		   # create sample file
		   echo "hello there" >hi.txt

		   # look for invalid argument syntax errors...

		   # invalid number of processors
		   $run Pigzj -p -1 <hi.txt 2>/dev/null
		   res1=$?

		   # invalid nubmer of processors
		   $run Pigzj -p 0 <hi.txt 2>/dev/null
		   res2=$?

		   # invalid number of processors
		   $run Pigzj -p 1000 <hi.txt 2>/dev/null
		   res3=$?

		   # must specify -p before the number of processors
		   $run Pigzj 1000 <hi.txt 2>/dev/null
		   res4=$?

		   # must specify a number of processors after -p
		   $run Pigzj -p <hi.txt 2>/dev/null
		   res5=$?

		   # must specify a valid option if you specify an option
		   $run Pigzj -d <hi.txt 2>/dev/null
		   res6=$?

		   # file input must be through stdin
		   $run Pigzj -p 2 hi.txt 2>/dev/null
		   res7=$?

		   if [ ! res1 ] || [ ! res2 ] || [ ! res3 ] || [ ! res4 ] || [ ! res5 ]
				 || [ ! res6 ] || [ ! res7 ]
		   then
		       echo "test failed"
		   fi


	    The test script above succeeds (i.e. produces no output) on my Pigzj
	    program.

   -> "Pigzj always reads from standard input and writes to standard output. It
       can report an error if you specify a file name."...

   	  The test script above already tests for this input standard, and my
   	  script succeeds when tested on the following test case from the above
   	  script:

		 # file input must be through stdin
		 $run Pigzj -p 2 hi.txt 2>/dev/null
		 res7=$?

			# my Pigz correctly reports an error here ^^

		# this should run and exit without an error code:
		$run Pigzj -p 2 <hi.txt 2>/dev/null
		res8=$?

			# my Pigz runs successfully here without an error, since
                        # the input method is properly is properly specified.


   -> "Pigzj's behavior is not specified if the input or the output is a
       terminal. For example, it can unconditionally read standard input and write
       to standard output without checking whether these streams are connected to a
       terminal."...

            My Pigzj program does not check whether the input or output is
            connected to a terminal. It simply continually reads from stdin,
            prints to stdout when it writes the header, writes to stdout when
            it finishes reading and compressing a complete block of data, and
            prints to stdout when it writes the trailer.

	    It does not matter whether the input/output is connected to a
	    terminal or not. My Pigzj program will always have this behavior.

    -> "When an error occurs, Pigzj need not issue exactly the same diagnostic
       message as pigz, so long as it detects and reports the error to standard
       error, and exits with nonzero status."

       	      My Pigzj program does not issue the exact same diagnostic messages
       	      as Pigz when the same error occurs in both programs. Instead, my
       	      Pigzj program writes its own custom error messages to stderr and
       	      exits with an error code of 1.

	      My Pigzj program catches all exceptions that are declared to be
	      thrown in member classes, and it issues customized error messages
	      for each type of exception.

	      Any rare exceptions that are not typical of program behavior
	      (e.g. ran out of memory) are thrown, but not caught by my
	      program. Such errors still cause a message to be written to
	      stderr, and they still cause the program to exit with nonzero
	      status, as desired.


Verifying that Pigzj behaves like Pigz, as required in the spec...

   -> If you decompress the output with gzip or with pigz, you get a copy of the
      input.

	   the following bash test script tests to make sure that the above
	   condition is true for the test input file provided in the project spec.

	       ./compile.sh
	       run="java -cp class_files"

	       # If you decompress the output with gzip or with pigz, you get a copy of the input.

	       # --> create input
	       input=/usr/local/cs/jdk-16.0.1/lib/modules

	       # --> compress image file
	       $run Pigzj <$input >output

	       # --> decompress with Pigz and Gzip and make sure output is the
	       # same as original file
	       gzip -d <output >gzip_output pigz -d <output >pigz_output

	       if ! cmp gzip_output $input || ! cmp pigz_output $input
	       then
		   echo "failed"
	       fi

	       # --> cleanup
	       rm output gzip_output pigz_output

         My Pigzj program succeeds on the abve script (i.e. prints no output to
         stdout)


   -> The output is compressed, about as well as pigz would compress it.

      	     I used the below sample code from the spec to verify the that the
      	     output of Pigzj is compressed about as well as it is compressed by
      	     Pigz...

		     ./compile.sh
		     run="java -cp class_files"

		     input=/usr/local/cs/jdk-16.0.1/lib/modules
		     time gzip <$input >gzip.gz
		     time pigz <$input >pigz.gz
		     time $run Pigzj <$input >Pigzj.gz
		     ls -l gzip.gz pigz.gz Pigzj.gz

		     # This checks Pigzj's output.
		     pigz -d <Pigzj.gz | cmp - $input

		     rm *.gz

             the "ls -l" command above allows us to compare the file sizes
             between the output of Pigzj and the output of Pigz...

		    -rw-r--r-- 1 picchi beugrad 43136276 May 10 22:33 Pigzj.gz
		    -rw-r--r-- 1 picchi beugrad 43261332 May 10 22:33 gzip.gz
		    -rw-r--r-- 1 picchi beugrad 43134815 May 10 22:33 pigz.gz

             As can be seen above, the output of Pigzj is 43136276 bytes
             compared to Pigz's 43134815 bytes.

	     This is decently close in size, since the output of Pigzj has a
	     byte quantity that is much closer in value to the output of Pigz
	     compared to Gzip.


   -> The output follows the GZIP file format standard, Internet RFC 1952.

       	     The output follows this format to the same degree that the sample
       	     code provided by the TA's follows this format.

	     Also, the output of my Pigzj program decompresses correctly when it
	     is decompressed by Pigz or Gzip (as verified by the test cases
	     above). This is further verification that the output follows the
	     GZIP file format standard.

   -> The output contains just a single member, that is, it does not contain the
      concatenation of two or more members. For a definition of "member" please
      see RFC 1952 §2.3. If you have trouble implementing this, then for partial
      credit you can generate output with multiple members.

      	     My Pigzj program produces just a single member with a single header
      	     and a single trailer, as desired.

   -> Ideally the output is byte-for-byte identical with the output of pigz. If
      this is not possible, the reason for any discrepancies must be documented.

      	     The output of my Pigzj program is not byte-for-byte identical with
      	     the output of pigz. We can verify that this is the case using the
      	     following test...

 	      	       ./compile.sh
		       run="java -cp class_files"

		       input=/usr/local/cs/jdk-16.0.1/lib/modules
		       $run Pigzj <$input >pigzj_output.txt
		       pigz <$input >pigz_output.txt

		       cmp pigzj_output.txt pigz_output.txt

		       rm pigzj_output.txt pigz_output.txt

            The above tests produce the following output...

	    	      pigzj_output.txt pigz_output.txt differ: char 5, line 1

            As we can see from the output above, the output of Pigzj is not
            byte-for-byte identical to the output of pigz, since they differ in
            char 5 of line 1.

	    Char 5 of line 1 is contained in the header. This correspeonds to
	    the MTIME byte, which is different from the pigz program because my
	    program does not report the MTIME for any files.

	    This makes sense from Pigzj's perspective because it is taking a
	    stdin input stream, which has no formal MTIME unless it is coming
	    from a file. But regardless, our program desires to read from
	    streams on-demand, not from files, so it shouldn't have to worry
	    about the modification time of any files.

	    Therefore, this difference in output between the programs is
	    reasonable.

	    We also know that the outputs between the two programs are different
	    because the output of Pigzj has a slightly larger file size compared
	    to the output of Pigz. Therefore, Pigzj contains one or more bytes
	    that are not contained in Pigz, and thus their outputs are not
	    byte-for-byte identical.

	    This makes sense because our Pigzj program's compression method is
	    not quite as optimal as Pigz. Pigz performs some bit manipulation
	    techniques that are not discussed in our spec or in the specified
	    implementation of Pigzj, so Pigz uses more advanced methods that
	    make its output even smaller than that of Pigzj.

	    This provides further justification as to why the outputs are not
	    byte-for-byte identical.


   -> Pigzj runs faster than gzip, when the number of processors is greater than
      1. It is competitive in speed with pigz.

      	    We can verify this using the same test script as before (the one
      	    provided in the project specs...

		   input=/usr/local/cs/jdk-16.0.1/lib/modules
		   time gzip <$input >gzip.gz
		   time pigz <$input >pigz.gz
		   time $run Pigzj <$input >Pigzj.gz
		   ls -l gzip.gz pigz.gz Pigzj.gz

		   # This checks Pigzj's output.
		   pigz -d <Pigzj.gz | cmp - $input

		   rm *.gz

	    For which the output is...

	    	   real    0m7.446s
		   user    0m7.314s
		   sys     0m0.089s

		   real    0m2.126s
		   user    0m7.023s
		   sys     0m0.116s

		   real    0m2.354s
		   user    0m7.342s
		   sys     0m0.658s

            As we can see from the results, the wall clock runtime (i.e. "real"
            time) of Pigzj (i.e. the last block of results) is much faster than
            the real time of the Gzip program (i.e. the first block of results).

	    The difference in real time between Pigzj and Pigz is negligable,
	    differing by only a couple tenths of a second. Thus, it is
	    reasonable to say that Pigzj is "competitive" in speed with Pigz.


   -> The default value for processes is the number of available processors; see
      the Java standard library's availableProcessors method.

            This feature is implemented in my code (check out the "main"
            method in the "Pigzj.java" file).


   -> Read errors and write errors are detected. For example, the command "pigz
      </dev/zero >/dev/full" reports a write error and exits with nonzero exit
      status, and the same should be true for "java Pigzj </dev/zero
      >/dev/full".

	    My Pigzj program detects this write error. I tested it with the
	    following commands...

	    	      bash-4.4$ java -cp class_files Pigzj </dev/zero >/dev/full
		      Write error from printStream.checkError()
		      bash-4.4$ echo $?
		      1

            As seen in the above terminal session, my Pigzj program catches the
            write error and reports a message to stderr. It also returns with
            nonzero exit status.

	    The same behavior (i.e. error message and exit code) occurs for all
	    IOExceptions (i.e. read and write errors).


   -> Out-of-range requests are detected. For example, on the Seasnet Linux
      servers "pigz -p 10000000 </dev/zero >/dev/null" By default reports an
      error and exits with nonzero status due to lack of virtual memory, and
      Pigzj should do likewise.

      	    My Pigzj program handles this case correctly.
	    I can verify that with the following terminal session...

	      	  bash-4.4$ java -cp class_files Pigzj -p 10000 </dev/zero >/dev/null
		  error: number of processors requested is > than availableProcessors()
		  bash-4.4$ echo $?
		  1

           As can be seen in the above terminal session, my Pigzj program
           effectively reports the error and exits with nonzero exit status.

	   It reports this error any time the specified number of processors is
	   greater than the number of processors available to the JVM, which is
	   a behavior that was specified by a TA on piazza.


   -> The input and output need not be a regular file; they may be pipes. For
      example, the command "cat /etc/passwd | java Pigzj | cat" should output
      the same thing as the command "java Pigzj </etc/passwd".

      	   I verify the above behavior using the following testing script...

	         ./compile.sh
		 run="java -cp class_files"

		 cat /etc/passwd | $run Pigzj | cat >output1
		 $run Pigzj </etc/passwd >output2

		 if [ ! res1 ] || ! cmp output1 output2
		 then
		     echo "test failed"
		 fi

		 rm output*

           My Pigzj program succeeds on the above test (i.e. produces no
           output when the script is run). Thus, the desired behavior is
           correctly implemented.


============================
PERFORMANCE MEASUREMENTS...
============================

    "Measure the performance of three programs: your Pigzj, /usr/local/cs/bin/pigz,
    and /usr/local/cs/bin/gzip. For your measurement platform, use a Seasnet Linux
    server, and specify its configuration well enough so that others outside the
    class could reproduce your results."



Seasnet Linux configuration...

       	   I am running my tests on lnxsrv13.

	   Using the command "lscpu", I can see that the number of CPU's
	   available on the machine is 4. Thus, this is the default number of
	   CPU's used for my Pigzj program.

	   My $PATH variable is specified as follows...
	      	    /usr/local/cs/bin:/usr/share/Modules/bin:/usr/local/bin:/usr/bin:/
		    usr/local/sbin:/usr/sbin:/usr/X11R6/bin:/usr/local/cs/bin:/u/be/
		    ugrad/picchi/bin

           Using the "top" command to analyze the current load on the machine
           yields the following outputs...

	      	  top - 23:13:46 up 38 days,  1:12,  3 users,  load average: 0.39, 0.38, 0.37
		  Tasks: 263 total,   1 running, 246 sleeping,  16 stopped,   0 zombie
		  %Cpu(s):  1.4 us,  2.9 sy,  0.0 ni, 95.7 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
		  MiB Mem :  64099.5 total,  29343.7 free,   6891.0 used,  27864.8 buff/cache
		  MiB Swap:   8192.0 total,   8192.0 free,      0.0 used.  56489.7 avail Mem 

	   running "java --version" to analyze the version of java that I am
	   using yields the following results...

	   	 openjdk 16.0.1 2021-04-20
		 OpenJDK Runtime Environment (build 16.0.1+9-24)
		 OpenJDK 64-Bit Server VM (build 16.0.1+9-24, mixed mode, sharing)

	   Running "pigz --version" yields the following result...

	   	 pigz 2.6

           And running "gzip --version" yeilds the following result...

	          gzip 1.10

           All of the "--version" commands above produce output that is
           consistent with the output specified by the spec.


Testing Performance vs Number of Processors...

       I used the test code provided in the project spec to perform the
       performance tests and compare the outputs across the various
       programs. This testing code is roughly the following...

	   	     input=/usr/local/cs/jdk-16.0.1/lib/modules
		     
		     time gzip <$input >gzip.gz
		     time pigz <$input >pigz.gz
		     time java Pigzj <$input >Pigzj.gz
		     ls -l gzip.gz pigz.gz Pigzj.gz

		     # This checks Pigzj's output.
		     pigz -d <Pigzj.gz | cmp - $input
		     

        For all of the below trials, I ran the script above with minor
        modifications (e.g. changing the number of processors used, changing
        the file input) and calculated the average of 3 trials for each program.
	I also calculated the compression ratio for each program by hand.

	-> using only 1 processor and the input file
           "/usr/local/cs/jdk-16.0.1/lib/modules"...

		  gzip...
		  real    0m7.464s
		  user    0m7.310s
		  sys     0m0.101s

		  pigz...
		  real    0m7.255s
		  user    0m6.973s
		  sys     0m0.071s

		  pigzj...
		  real    0m7.336s
		  user    0m7.269s
		  sys     0m0.564s

		  -rw-r--r-- 1 picchi beugrad 43136276 May 10 23:26 Pigzj.gz
		  -rw-r--r-- 1 picchi beugrad 43261332 May 10 23:26 gzip.gz
		  -rw-r--r-- 1 picchi beugrad 43134815 May 10 23:26 pigz.gz

	     Using the command "ls -l /usr/local/cs/jdk-16.0.1/lib/modules" to
	     find the file size of "/usr/local/cs/jdk-16.0.1/lib/modules", we get
	     the following output...

	         -rw-r--r-- 1 eggert csfac 125942959 Mar 26 11:20
                  /usr/local/cs/jdk-...

	     Therefore, the compression ratio (i.e. uncompressed file size divided
	     by compressed file size) for each of the programs above is...
		  
		  Pigzj... 2.920
		  Gzip...  2.911
		  pigz...  2.920

	     Observations...

		  From the results above, we see that gzip, pigz, and pigzj all
		  run at approximately the same "real time" speed when pigz and
		  pigzj use 1 thread. This makes sense, becasue all compression
		  is occuring sequentially in all 3 programs, so any minimal
		  difference in time is just related to minute differences in
		  program implementation.

		  The user time for gzip and pigzj were both greater than the
		  user time for pigzj.

		  System time used for pigzj is significantly higher than the
		  system time used for either gzip or pigz, which is probably
		  due to the fact that Pigzj does not buffer read and write
		  calls as much as pigz and gzip because it must read from an
		  input stream and write to an output stream "on the fly".

		  The compression ratios for pigz and pigzj are approximately
		  equivalent (though the ratio for pigz is slightly higher than
		  that for pigzj when more decimal places are taken into
		  account). Either way, both of these ratios are greater than
		  that for gzip. This makes sense because pigz and pigzj both
		  use the same "compression trick" of priming the dictionary for
		  each block using the last 32 KiB from the prior block. Gzip
		  does not use this trick, and thus it experiences a lower
		  compression ratio.


      --> using 2 processors and the input file
	  "/usr/local/cs/jdk-16.0.1/lib/modules"...

	     the new test code is the same as the last, but with "-p 2"
	     specified for both pigz and pigzj.

	     results...

		gzip...
		real    0m7.410s
		user    0m7.290s
		sys     0m0.080s

		pigz...
		real    0m3.604s
		user    0m6.970s
		sys     0m0.189s

		pigzj...
		real    0m3.785s
		user    0m7.365s
		sys     0m0.470s
		
		-rw-r--r-- 1 picchi beugrad 43136276 May 10 23:34 Pigzj.gz
		-rw-r--r-- 1 picchi beugrad 43261332 May 10 23:34 gzip.gz
		-rw-r--r-- 1 picchi beugrad 43134815 May 10 23:34 pigz.gz

             The compression ratio is the same as the last trial.

	     Observations:

		   Notice here that the real time for execution is approximately
		   halved for pigz and pigzj compared to the last trial. This
		   makes sense because 2 threads work in parallel to accomplish
		   almost 2 times as much work as a single thread in the same
		   period of time.

		   That said, the user and system time for all 3 programs is
		   essentially unchanged. The only major change is that the user
		   time for pigz increased considerably. This is probably due to
		   the OS overhead associated with creating, managing, and
		   scheduling additional threads.

		   The compression ratios are the same as before because the
		   input file is the same and each of the programs performs
		   compression and writes output in a deterministic order
		   (though each step of that task may be performed
		   nondeterministically by the threads).


      --> using 3 processors and the input file
	   "/usr/local/cs/jdk-16.0.1/lib/modules"...

	     the new test code is the same as the last, but with "-p 3"
	     specified for both pigz and pigzj.

		gzip...
		real    0m7.442s
		user    0m7.303s
		sys     0m0.100s

		pigz...
		real    0m2.605s
		user    0m7.035s
		sys     0m0.104s

		pigzj...
		real    0m2.628s
		user    0m7.262s
		sys     0m0.624s

		-rw-r--r-- 1 picchi beugrad 43136276 May 10 23:37 Pigzj.gz
		-rw-r--r-- 1 picchi beugrad 43261332 May 10 23:37 gzip.gz
		-rw-r--r-- 1 picchi beugrad 43134815 May 10 23:37 pigz.gz

		the compression ratios are the same as the last trial.

		Observations:

			Again, the real time for gzip is approximately constant,
			but the real time for pigz and pigzj has dropped. This
			time around the decrease in real time for pigz and pigzj
			was less between this trial and the last compared to the
			decrease between the last trial and the one before
			it. This makes sense because although we have an
			additional thread performing computations, the decrease
			when switching from purely linear executation to
			2-thread multithreaded execution is more drastic than
			simply adding another thread to an execution scheme that
			was already multithreaded.
			
			The user time for all 3 processes is approximately
			eqiovalent to the last trial.

			The system time for Pigzj increased slightly, which
			could be explained by the fact that the CPU's have to
			spend more time handling and scheduling threads in the
			OS.

			As before, the compression ratios are still the same
			because the input file is the same as that in the last
			trial.
			

     --> using 4 processors and the input file
	   "/usr/local/cs/jdk-16.0.1/lib/modules"...

	     the new test code is the same as the last trial, but with "-p 4"
	     specified for both pigz and pigzj.

	        gzip...
		real    0m7.561s
		user    0m7.250s
		sys     0m0.182s

		pigz...
		real    0m2.189s
		user    0m7.062s
		sys     0m0.167s

		pigzj...
		real    0m2.345s
		user    0m7.330s
		sys     0m0.546s

		-rw-r--r-- 1 picchi beugrad 43136276 May 10 23:39 Pigzj.gz
		-rw-r--r-- 1 picchi beugrad 43261332 May 10 23:39 gzip.gz
		-rw-r--r-- 1 picchi beugrad 43134815 May 10 23:39 pigz.gz

	     The compression ratios are the same as the last trial.

	     observations...

		  Again, the real time for execution has decreased for pigz and
		  pigzj, and it has remained approximately constant for
		  gzip. This makes sense because we are adding an additional
		  thread for for pigz and pigzj, but we are not doing so for
		  gzip.

		  We can further see the "law of diminishing returns" in action
		  here as the decrease in real time between this trial and the
		  last is less than the decrease between the trial before this
		  and the one before that. i.e. the gains that we get from
		  adding more threads decreases for each additional thread that
		  we have added so far in our trials.

		  As before, the compression ratios are still the same because
		  the input file is the same.

       --> (NOTE: 4 processors is the maximum amount of processors that I can
           specify on lnxsrv13, since the TA's on piazza said that specifying
           more processors in the command line argument than are available on
           the machine should report an error and exit with nonzero status).


      Analysis for performance vs number of threads...

	   As we can see in the above outputs, the "real time" for program execution
	   monotonically decreases as the number of threads increases for Pigzj and
	   Pigz. This makes sense because using more threads allows the programs
	   to parallelize the operations to a greater degree, resulting in real time
	   speedup.

	   The "real time" runtime for gzip remains approximately constant across all
	   of the above trials because the number of threads (i.e. 1) remains the
	   same. This was expected due to the logic in the aforemented paragraph.

	   The amount of "speedup gainz" that we achieve by increasing the number of
	   threads decreases as the number of threads increases. In other words, the
	   speedup of going from 1 to 2 threads is higher than the speedup of going
	   from 2 to 3 threads, which is higher than the speedup of going from 3 to 4,
	   etc. This trend makes sense because although more threads allows us to
	   perform more computations in parallel, there must be enough tasks to perform
	   in parallel if we are to make full use of every thread at all times in
	   program execution (i.e. use each thread to its full work capacity). Since my
	   program generates tasks at a bounded speed, more threads probably means that
	   there is more idle time per thread, which leads to lesser speedup gains when
	   we add more and more threads.

	   If the number of threads becomes too large (e.g. greater than the
	   number of processors available), the amount of time
	   managing/scheduling threads might lead to a performance detriment,
	   thus causing the program speed to decrease relative to other trials
	   that use a moderate or small amount of threads.

	   Across all of the trials, the real time remains approximately constant for
	   all of the programs. This makes sense because, although the threads are
	   performing their tasks in parallel, user time refers to the cumulative
	   amount of CPU processing time used on the program outside of the kernel
	   across all threads. Thus, adding more threads still leads to the same amount
	   of processing time when we add together the processing time spent on the
	   different CPU's. The only difference is that each of those instances of
	   processing time is added together across multiple CPU's at once (since each
	   thread that is running in parallel is running on its own CPU).

	   The system time is also approximately constant across all of the trials for
	   pigzj and gzip, though it increases slightly when going from 1 thread to 2
	   threads for pigz. I hypothesize that this result for pigz is due to the fact
	   that running pigz with 1 processor probably causes the program to not create
	   threads all together (i.e. the program acts like a sequential program, so it
	   has no thread creation overhead). However, when you run pigz with 2 or more
	   threads, then it probably starts to create threads that run in parallel,
	   which leads to more OS overhead to manage and scheule the threads. This
	   increase in OS overhead when switching from a sequential implementation to a
	   parallel implementation is likely what causes the initial increase in system
	   time between -p 1 and -p 2 for pigz. In contrast, my pigzj program always
	   creates at least one thread, and the gzip program never creates any threads,
	   so both of the their system time measurements remain approximately constant
	   across trials.

	   The compression ratios for the different programs are constant across each
	   of the above trials, since each of the trials use the same input file and
	   each of the programs produces deterministic output. The compression ratios
	   for pigz and pigzj are approximately equivalent, since they both use the
	   "compression trick" mentioned in the spec of using the last 32 KiB of the
	   prior block to prime the dictionary for the current block. In contrast the
	   compression ratio for gzip is lower because it does not use this trick.


Measuring performance vs file size...

    To make the following measurements, I performed all trials with 4 processors
    for pigz and Pigzj, and with 1 processor for gzip. The results shown are
    average values across 3 trials for each file size inputed into the tests. I
    generated files of different sizes using the following command...

    	 cat /dev/random | tr -dc "[:print:]" | head -c $num_bytes > test.txt

    This ensures that the "test.txt" file contains "$num_bytes" bytes and that
    it consists of randomly generated printable characters, thus simulating a
    typical file that we might expect our compressors to operate on.

       --> using 4 processors and an empty file...

       	      results...

		    gzip...
		    real    0m0.023s
		    user    0m0.000s
		    sys     0m0.002s
		    
		    pigz...
		    real    0m0.038s
		    user    0m0.001s
		    sys     0m0.001s
		    
		    pigzj...
		    real    0m0.062s
		    user    0m0.028s
		    sys     0m0.032s
		    
		    -rw-r--r-- 1 picchi beugrad 30 May 11 15:16 Pigzj.gz
		    -rw-r--r-- 1 picchi beugrad 30 May 11 15:16 gzip.gz
		    -rw-r--r-- 1 picchi beugrad 30 May 11 15:16 pigz.gz

	            compression ratios..

		    	pigzj... 0
			gzip ... 0
			pigz ... 0

               Observations...

	            Due to the fact that we needed to add a header and trailer
	            to our compressed files, the file size of the compressed
	            file is larger than the file size of the empty file, which
	            leads to a compression ratio of 0. there are also a few
	            other added characters in the compressed file in between the
	            header and trailer, which is probably due to the fact that
	            finalizing the compressor adds some extra bytes to the last
	            compressed block.

		    Pigz and Pigzj both perform more poorly than gzip (i.e. have
		    higher real time for execution). This is probably because
		    the input is not parallelizable, so the overhead/complexity
		    of creating and managing threads leads to higher execution
		    time than simiply running a sequential program.
		    

      --> 4 processors and a file size of 131072 bytes (i.e. 128 KiB = 1 block)

              results...

		     gzip...
		     real    0m0.014s
		     user    0m0.004s
		     sys     0m0.004s
		     
		     pigz...
		     real    0m0.442s
		     user    0m0.006s
		     sys     0m0.001s

		     pigzj...
		     real    0m0.085s
		     user    0m0.036s
		     sys     0m0.030s

		     -rw-r--r-- 1 picchi beugrad 109069 May 11 15:36 Pigzj.gz
		     -rw-r--r-- 1 picchi beugrad 109033 May 11 15:36 gzip.gz
		     -rw-r--r-- 1 picchi beugrad 109063 May 11 15:36 pigz.gz
		     -rw-r--r-- 1 picchi beugrad 131072 May 11 15:38 test.txt

	      	     compression ratio:

		         pigzj... 1.202
			 gzip ... 1.202
			 pigz ... 1.202


	       observations...

	            pigz ran the slowest, followed by pigzj and then gzip. This
	            still makes sense becuase gzip is probably optimized for
	            sequential processing. When we have just 1 block, the
	            program is essentially sequential (since only 1 thread has
	            work to do), so the overhead of creating more threads causes
	            gzip to have an advantage and thus have smaller total
	            runtime.

		    The compression ratios of all of the programs were
		    approximately equivalent, though minor differences could be
		    seen if you extend the numbers to a larger amount of decimal
		    places.

		    Pigzj had the largest system and user times compared to the
		    negligably small corollaries of pigz and gzip. This makes
		    sense because my program is implemented to always create the
		    same number of threads and perform the same preliminary
		    processing steps regardless of the input size, whereas gzip
		    is optimized for sequential compression and pigz probably
		    has greater optimization for detecting small files.

	          
      --> 4 processors and a file size of 1310720 bytes (i.e. 10*128 KiB = 10
          blocks)

		results...

			gzip...
			real    0m0.073s
			user    0m0.063s
			sys     0m0.004s

			pigz...
			real    0m0.042s
			user    0m0.059s
			sys     0m0.005s

			pigzj...
			real    0m0.099s
			user    0m0.093s
			sys     0m0.032s

			-rw-r--r-- 1 picchi beugrad 1090677 May 11 15:45 Pigzj.gz
			-rw-r--r-- 1 picchi beugrad 1090285 May 11 15:45 gzip.gz
			-rw-r--r-- 1 picchi beugrad 1090656 May 11 15:45 pigz.gz
			-rw-r--r-- 1 picchi beugrad 1310720 May 11 15:45 test.txt

			compression ratios...
				 pigzj... 1.201
				 gzip ... 1.202
				 pigz ... 1.201


	       Observations...

		     Pigzj ran slower than both gzip and pigz, though the
		     difference is relatively small. The compression ratios are
		     approximately equivalent.

		     The system and user time for Pigzj are still greater than
		     both gzip and pigz.

       --> 4 processors and a file size of 125,942,959 bytes = 120 MB

               results...

		     gzip...
		     real	0m8.097s
		     user	0m6.941s
		     sys	0m0.521s
		     
		     pigz...
		     real	0m2.307s
		     user	0m7.026s
		     sys	0m0.183s

		     pigzj...
		     real	0m2.572s
		     user	0m7.354s
		     sys	0m0.541s
		     
		     -rw-r--r-- 1 picchi beugrad 43136276 May 11 17:10 Pigzj.gz
		     -rw-r--r-- 1 picchi beugrad 43261332 May 11 17:10 gzip.gz
		     -rw-r--r-- 1 picchi beugrad 43134815 May 11 17:10 pigz.gz
		     -rw-r--r-- 1 picchi beugrad 125942959 May 11 17:10 test.txt

	             compression ratios...
		          Pigzj... 2.920
			  Gzip...  2.911
			  pigz...  2.920


		Observations...

		      As seen above, pigzj is about 2 tenths of a second slower
		      than pigz, an it is multiple seconds faster than
		      gzip. Both pigzj and pigz are much faster than gzip, which
		      makes sense because they are each using 4 processors while
		      gzip uses only 1.

		      The user times are approximately equivalent across all of
		      the different programs.

		      The system time of pigzj and gzip are very similar, and
		      they are both notably higher than pigz.

		      The compression ratio is very similar between pigzj and
		      pigz, both of which have much higher ratios than
		      gzip. This indicates that pigzj is likely performing the
		      "compression dictionary trick" well.


     General observations for performance vs file size...

     	     for very small file sizes (e.g. 10 blocks or less) gzip compresses
     	     more quickly (as measured in real time) compared to pigzj, though
     	     each one only takes a real time of less than 1 second.

	     As the file size increases, the speed of pigzj closely mirrors pigz
	     (with a few added tenths of second), thus vastly outperforming gzip
	     by a growing margin.

	     As the file size increases, the system time of pigzj seems to grow
	     faster than that of pigz, though it is very close in value to the
	     system time of gzip.

	     As the file size increases, the compression ratio of pigzj and pigz
	     greatly outperform that of gzip by a growing margin (i.e. the
	     bigger the file size, the more gzip is outperformed). this is
	     probably because more word-for-reference substitutions can be made
	     as the number of characters/bytes increases.


=============
USING STRACE
=============

    To create traces of the system calls, I used the following test script...

             ./compile.sh
	     run="java -cp class_files"

	     # generate a file of a specified size
	     input=/usr/local/cs/jdk-16.0.1/lib/modules
	     cat $input >test.txt
	     # touch test.txt


	     echo "gzip..."
	     strace -c gzip <test.txt >gzip.gz
	     echo "pigz..."
	     strace -c pigz -p 4 <test.txt >pigz.gz
	     echo "pigzj..."
	     strace -c $run Pigzj -p 4 <test.txt >Pigzj.gz
	     ls -l gzip.gz pigz.gz Pigzj.gz

     running the script above produces the following output...

             gzip...
	     % time     seconds  usecs/call     calls    errors syscall
	     ------ ----------- ----------- --------- --------- ----------------
	      80.12    0.016044           4      3846           read
	      19.88    0.003981           1      2641           write
	       0.00    0.000000           0         4           close
	       0.00    0.000000           0         3           fstat
	       0.00    0.000000           0         1           lseek
	       0.00    0.000000           0         5           mmap
	       0.00    0.000000           0         4           mprotect
	       0.00    0.000000           0         1           munmap
	       0.00    0.000000           0         1           brk
	       0.00    0.000000           0        12           rt_sigaction
	       0.00    0.000000           0         1         1 ioctl
	       0.00    0.000000           0         1         1 access
	       0.00    0.000000           0         1           execve
	       0.00    0.000000           0         2         1 arch_prctl
	       0.00    0.000000           0         2           openat
	     ------ ----------- ----------- --------- --------- ----------------
	     100.00    0.020025                  6525         3 total


	     pigz...
	     % time     seconds  usecs/call     calls    errors syscall
	     ------ ----------- ----------- --------- --------- ----------------
	      80.32    0.146686         217       673           futex
	      19.18    0.035019          36       971           read
	       0.24    0.000446          20        22           munmap
	       0.08    0.000139           4        28           mmap
	       0.05    0.000096           6        15           mprotect
	       0.03    0.000048           8         6           openat
	       0.02    0.000041           8         5           clone
	       0.02    0.000029           4         6           fstat
	       0.02    0.000028           4         6           close
	       0.01    0.000019           2         8           brk
	       0.01    0.000014           4         3           rt_sigaction
	       0.01    0.000012           4         3           lseek
	       0.00    0.000008           4         2         1 arch_prctl
	       0.00    0.000007           7         1           execve
	       0.00    0.000006           6         1         1 access
	       0.00    0.000005           5         1         1 ioctl
	       0.00    0.000004           4         1           rt_sigprocmask
	       0.00    0.000004           4         1           set_tid_address
	       0.00    0.000004           4         1           set_robust_list
	       0.00    0.000004           4         1           prlimit64
	     ------ ----------- ----------- --------- --------- ----------------
	     100.00    0.182619                  1755         3 total


	     pigzj...
	     % time     seconds  usecs/call     calls    errors syscall
	     ------ ----------- ----------- --------- --------- ----------------
	      99.74    0.484892      242446         2           futex
	       0.09    0.000414           8        49        39 openat
	       0.04    0.000189           5        33        30 stat
	       0.03    0.000167           7        23           mmap
	       0.03    0.000131           8        15           mprotect
	       0.02    0.000090           7        12           read
	       0.01    0.000049           4        10           fstat
	       0.01    0.000048           4        11           close
	       0.01    0.000045          15         3           munmap
	       0.01    0.000032          16         2           readlink
	       0.00    0.000024          24         1           clone
	       0.00    0.000017           4         4           brk
	       0.00    0.000017           8         2         1 access
	       0.00    0.000012           4         3           lseek
	       0.00    0.000009           4         2           rt_sigaction
	       0.00    0.000008           4         2         1 arch_prctl
	       0.00    0.000006           6         1           getpid
	       0.00    0.000005           5         1           execve
	       0.00    0.000005           5         1           set_robust_list
	       0.00    0.000004           4         1           rt_sigprocmask
	       0.00    0.000004           4         1           set_tid_address
	       0.00    0.000004           4         1           prlimit64
	     ------ ----------- ----------- --------- --------- ----------------
	     100.00    0.486172                   180        71 total


      observations...

             From the system call traces above, we can see that...

	     read/write system calls form the bulk of gzip calls.

	     futex and read system calls form the bulk of pigz calls.

	     futex calls form the bulk of pigzj calls (even more so than they do
	     for pigz).


	     futex calls are used for synchronizaton/blocking (i.e. waiting for
	     a condition to become true), so it makes sense that they are the
	     top system call for pigz and pigzj, both of which require on futex
	     to synchronize thread activities and produce deterministic
	     output.

	     Since gzip does not use synchronization, it makes sense that there
	     are no futex calls, and instead read/writing to stdin/stdout makes
	     up the bulk of its system calls.

	     This also explains why the performance of pigz and pigzj is poor
	     for small file sizes: since there is little data to compress, there
	     is not very much oppoertunity for parallelization (since data is
	     parallelized in block granularity, at least for pigzj). Therefore,
	     the overhead of futex calls to coordinate threads dominates the
	     performance metrics for low file sizes and drives the runtime above
	     that of gzip.

	     In contrast, for large file sizes, the time taken to service futex
	     calls are relatively minimal compared to the amount of time spent
	     compressing data. Therefore, the futex calls do not dominate the
	     performance metrics: instead, the time spent compressing dominates
	     the performance metrics. Since the compression task can be
	     performed in parallel, pigz and pigzj can complete it much faster
	     than gzip, and the OS overhead of servicing synchronization methods
	     (i.e. futex calls) is well worth it to achieve the gains from
	     parallelization.


===================================================
which method you expect to work better in general?
===================================================

Overall, the superior performance if gzip for small files is relatively
unimportant because pigz and pigzj also compress those files very quickly
(i.e. under 1 second), so the benefits of gzip are relatively unnoticable.

As the file size increases, Pigzj and Pigz perform relatively similar, though
Pigz creates files that are slightly smaller, and it does so at a slightly
quicker pace.

Knowing this, it is important to optimize for large files, so Pigz is the method
that would work better in general. In the same sense, a multithreaded approach
works better in general (i.e. I would pick Pigzj over gzip if pigz were not an
option).



===================================================
Credit to MessAdmin
===================================================

All credit to MessAdmin appears in code comments in all of my ".java" files.

Namely, my implementation uses the class partition of MessAdmin (i.e a block
class, write task, compression task, and checksum task, all within one
overarching multithreaded_compression task. Each of these class has similar
functionality to their equivalents in MessAdmin, though they have been
implemented independently from the MessAdmin code.

I also used some of the synchronization constructs from MessAdmin in my own code
(CountDownLatch, LinkedBlockingQueue, and ThreadPoolExecutor).
