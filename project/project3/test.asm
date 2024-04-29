.data 
comparisonNumber: .word 10      # An integer for comparison
helloWorldStringArray: .word 72 101 108 108 111 32 87 111 114 108 100 33 0  # Static memory character array
functions: .word sumMultCompare

.text 
.globl main

main:   
    # Test some operations
    addi $s0, $0, -5    # $s0 = -5
    addi $s1, $0, 1     # $s1 = 1
    addi $s2, $s1, 0    # $s2 = 1

    add $s3, $s1, $s2   # $s3 = -4
    sub $s4, $0, $s3    # $s4 = 4

    mult $s4, $s0
    mflo $s5            # $s5 = -20

    div $s5, $s4
    mflo $s6            # $s6 = -5
    mfhi $t9            # Check t9 is 0 to ensure remainder

    # We know shift right operations can be lossy
    srl $t8, $s0, 3

    # Rhetorical question: sll works to multiply by 4, but what of negative numbers?
    sll $t7, $s0, 2     
    sll $a0, $t7, 0     # Should be -20 if sll not lossy on small negative numbers
    sub $a1, $0, $s5    # a1 = 20

    # Using global pointer and its negative as zeros, saving gp to stack
    sll $a2, $gp, 0
    sub $t6, $0, $gp
    srl $a3, $t6, 0

    sw $s0, -4($sp)
    addi $sp, $sp, -4
    la $t5, functions       # Call the function to sum and compare and save results
    lw $t4, 0($t5)
    jalr $t4
    addi $sp, $sp, 4

    addi $s7, $v0, 0
    addi $s8, $v1, 0

    bne $s7, $0 skipExtra
    jal printCharArray      # Test printCharArray (print only once if sll and srl are lossy)

    skipExtra:
    jal printCharArray

    j end


sumMultCompare:
    add $k1, $a0, $a1
    lw $k0, 0($sp)
    add $k1, $k1, $a2
    add $k1, $k1, $a3       # Sum the four numbers
    mult $k0, $k1
    mflo $v0
    la $t0, comparisonNumber
    lw $t1, 0($t0)
    slt $v1, $v0, $t1       # $v1 = 1 if $v0 < $t1 (sum < comparisonNumber)
    jr $ra


printCharArray:
    la $t2, helloWorldStringArray
    lw $t3, 0($t2)

    printCharArrayLoop:
        beq $t3, $0, donePrintCharArray
        addi $a0, $t3, 0
        addi $v0, $0, 11
        syscall
        addi $t2, $t2, 4
        lw $t3, 0($t2)
        j printCharArrayLoop

    donePrintCharArray:
        jr $ra

end:
    addi $at, $0, 0         # Reset at to 0
    addi $v0, $0, 10
    syscall