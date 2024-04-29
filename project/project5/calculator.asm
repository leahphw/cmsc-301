.data
newline: .asciiz "\n"
prev_result: .word 0    # Storage for the previous result

.text
.globl main


main:
    la $t0, prev_result     # Load the address of prev_result
    lw $s0, ($t0)           # Load the previous result into $s0


loop:
    # Read the first term
    li $v0, 5
    syscall
    move $t0, $v0  # Store the first term in $t0

    # Check if the first term is the special character '_'
    beq $t0, $s0, read_operator  # If it is then skip reading the first term

    move $s0, $t0               # Store the first term in $s0


read_operator:
    # Read the operator
    li $v0, 12
    syscall
    move $t1, $v0       # Store the operator in $t1

    # Read the second term
    li $v0, 5
    syscall
    move $t2, $v0       # Store the second term in $t2

    # Call the calculator function
    move $a0, $s0
    move $a1, $t2
    move $a2, $t1
    jal calculator

    # Store the result for the next calculation
    la $t0, prev_result
    sw $v0, ($t0)

    # Print the result
    move $a0, $v0
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    j loop      # Loop back for the next expression


calculator:
    addi $sp, $sp, -20      # Stack allocation
    sw $ra, 0($sp)
    sw $s0, 4($sp)          # First num
    sw $s1, 8($sp)          # Second num
    sw $s2, 12($sp)         # Sign
    sw $a0, 16($sp)         # Old num

    move $s0, $a0   # First num parameter
    move $s1, $a1   # Second num parameter
    move $s2, $a2   # Sign

    jal arithmetics

    lw $ra, 0($sp)
    lw $s0, 4($sp)      # First num
    lw $s1, 8($sp)      # Second num
    lw $s2, 12($sp)
    lw $a0, 16($sp)     # Old num
    addi $sp, $sp, 20   # Stack deallocation
    jr $ra


arithmetics:
    li $t0, 43
    beq $s2, $t0, adder
    li $t0, 45
    beq $s2, $t0, subtract
    li $t0, 42
    beq $s2, $t0, multiply
    li $t0, 47
    beq $s2, $t0, divide

adder:
    add $v0, $s0, $s1
    jr $ra

subtract:
    sub $v0, $s0, $s1
    jr $ra

multiply:
    mult $s0, $s1
    mflo $v0
    jr $ra

divide:
    div $s0, $s1
    mflo $v0
    jr $ra