# ASSIGNMENT: multithreaded gzip compression filter
- Full specification in [hw3_spec.pdf](https://github.com/jpicchi18/programming-languages-course-projects/blob/main/hw_3/hw3_spec.pdf).
- All code located in [hw3.jar](https://github.com/jpicchi18/programming-languages-course-projects/blob/main/hw_3/hw3.jar) or, alternatively, all code files with
the extension ".java".
- Description of implementation and testing procedure in [README.txt](https://github.com/jpicchi18/programming-languages-course-projects/blob/main/hw_3/README.txt).

## Lanuage
Java

## Description
- Wrote a multithreaded Java implemenation of the C program *pigz*.
  - reads programs from standard input and writes to standard output.
  - divides the input into fixed-size blocks (with block size equal to 128 KiB), and has P threads that are each busily compressing a block.
    - That is, it starts by reading P blocks and starting a compression thread on each block.
    - It then waits for the first thread to finish, outputs its result, and then can reuse that thread to compress the (P+1)st block.
  - Instead of compressing each block independently, it uses the last 32 KiB of the previous block to prime the compression dictionary for the next block.
    That way, each block other than the first is compressed better, in the typical case.
