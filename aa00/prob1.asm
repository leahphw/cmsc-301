          .data #This is boilerplate stuff to get QTSPIM to read this file the right way
          .text
          .align 2
          .globl main 
# Code goes here

init:
    # Initialize n here
    addi $s0, $0, 6
    # addi $s0, $0, 5
    # addi $s0, $0, 4
    # addi $s0, $0, 3
    # addi $s0, $0, 1
    # addi $s0, $0, -2


main:

    # Initialize $s1 = -1
    addi $s1, $0, -1

    # If n < 0 then branch to end and return -1
    slt $t1, $s0, $0
    bne $t1, $0, end

    # Initialize i = 1
    addi $t0, $0, 1
    # Reinitialize $s1 = 1
    addi $s1, $0, 1

    while:
    # If i >= n then branch to end
    slt $t1, $s0, $t0
    bne $t1, $0, end
    # Multiply i into $s1
    mult $s1, $t0
    mflo $s1
    # Increment i
    addi $t0, $t0, 1
    j while

end:
# This is how to end your program gracefully. We will learn what this is doing later.
    addi $v0, $0, 10
    syscall