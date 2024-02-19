          .data #This is boilerplate stuff to get QTSPIM to read this file the right way
          .text
          .align 2
          .globl main 
# Code goes here

init:
    # addi $s0, $0, 2000
    # addi $s0, $0, 2001
    # addi $s0, $0, 2004
    # addi $s0, $0, 2016
    # addi $s0, $0, 2100
    addi $s0, $0, 2400

main:
    # Initialize return value of 0
    addi $s1, $0, 0
    # Initialize $t0 = 4
    addi $t0, $0, 4
    # Initialize $t1 = 100
    addi $t1, $0, 100
    # Initialize $t2 = 400
    addi $t2, $0, 400

    # If remainder to 4 is not 0, end and return 0
    div $s0, $t0
    mfhi $t3
    bne $t3, $0, end

    # Reinitialize return value to 1
    # If year divisble by 400, end and return 1
    addi $s1, $0, 1
    div $s0, $t2
    mfhi $t3
    beq $t3, $0, end

    # Reinitialize return value to 0
    # If year divisible by 100, end and return 0
    addi $s1, $0, 0
    div $s0, $t1
    mfhi $t3
    beq $t3, $0, end

    # Reinitialize return value to 1
    # If all the situation not met, then year is leap
    addi $s1, $0, 1

end:
#This is how to end your program gracefully. We will learn what this is doing later.
    addi $v0, $0, 10
    syscall