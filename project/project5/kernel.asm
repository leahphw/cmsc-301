# This is starter code, so that you know the basic format of this file.
# Use _ in your system labels to decrease the chance that labels in the "main"
# program will conflict

.data
.text
_syscallStart_:
    beq $v0, $0, _syscall0  # Jump to syscall 0
    addi $k1, $0, 1
    beq $v0, $k1, _syscall1  # Jump to syscall 1
    addi $k1, $0, 4
    beq $v0, $k1, _syscall4  # Jump to syscall 4
    addi $k1, $0, 5
    beq $v0, $k1, _syscall5  # Jump to syscall 5
    addi $k1, $0, 8
    beq $v0, $k1, _syscall8  # Jump to syscall 8
    addi $k1, $0, 9
    beq $v0, $k1, _syscall9  # Jump to syscall 9
    addi $k1, $0, 10
    beq $v0, $k1, _syscall10  # Jump to syscall 10
    addi $k1, $0, 11
    beq $v0, $k1, _syscall11  # Jump to syscall 11
    addi $k1, $0, 12
    beq $v0, $k1, _syscall61    #Jump to syscall 61
    # Error state - this should never happen - treat it like an end program
    j _syscall10


# Do init stuff
_syscall0:
    # Initialization goes here
    addi $sp, $sp, -4096        # Initialize stack pointer
    la $k1, _END_OF_STATIC_MEMORY_      # Load heap pointer
    sw $k1, -4096($0)      # Store heap pointer address
    j _syscallEnd_


# Print integer
_syscall1:
    addi $sp, $sp, -12
    addi $k1, $sp, 0        

    # Save registers 
    sw $k0, 8($sp)
    sw $t2, 4($sp)
    sw $t3, 0($sp)

    addi $t2, $0, 10        # Div factor
    addi $k0, $a0, 0    

    readInt:
        div $k0, $t2        # Divide 10 each time 
        mflo $k0            
        mfhi $t3            # Remainder
        addi $sp, $sp, -4
        sw $t3, 0($sp)
        bne $k0, $0, readInt   

    printIntLoop:
        lw $k0, 0($sp)
        addi $k0, $k0, 48   
        sw $k0, -256($0)        # Console output   
        addi $sp, $sp, 4
        bne $sp, $k1, printIntLoop

    # Deallocate memory
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $k0, 0($sp)
    addi $sp, $sp, 4
    jr $k0


# Read int (ascii)
_syscall5:
    addi $sp, $sp, -12 
    sw $t2, 0($sp)
    sw $t3, 4($sp)
    sw $k0, 8($sp)
    addi $t2, $0, 10 # decimal power
    addi $k1, $0, 0

    # loop to read each digit
    readDigitLoop:
        addi $t3, $0, 48
        lw $k0, -240($0) # keyboard ready at 0xFFFFFF10
        beq $k0, $0, _syscall5 # if no keypress then end
        lw $k0, -236($0) # read keyboard character at 0xFFFFFF14
        sw $0, -240($0) # reset
        beq $k0, $t3, ascii0
        addi $t3, $t3, 1 # next iter
        beq $k0, $t3, ascii1
        addi $t3, $t3, 1
        beq $k0, $t3, ascii2
        addi $t3, $t3, 1
        beq $k0, $t3, ascii3
        addi $t3, $t3, 1
        beq $k0, $t3, ascii4
        addi $t3, $t3, 1
        beq $k0, $t3, ascii5
        addi $t3, $t3, 1
        beq $k0, $t3, ascii6
        addi $t3, $t3, 1
        beq $k0, $t3, ascii7
        addi $t3, $t3, 1
        beq $k0, $t3, ascii8
        addi $t3, $t3, 1
        beq $k0, $t3, ascii9
        add $k1, $0, $k0
        j end_syscall5
    ascii0:
        mult $k1, $t2 
        mflo $k1
        j end_syscall5:
    ascii1:
        mult $k1, $t2 
        mflo $k1
        addi $k1, $k1, 1
        j end_syscall5
    ascii2:
        mult $k1, $t2
        mflo $k1
        addi $k1, $k1, 2
        j end_syscall5
    ascii3:
        mult $k1, $t2
        mflo $k1
        addi $k1, $k1, 3
        j end_syscall5
    ascii4:
        mult $k1, $t2
        mflo $k1
        addi $k1, $k1, 4
        j end_syscall5
    ascii5:
        mult $k1, $t2
        mflo $k1
        addi $k1, $k1, 5
        j end_syscall5
    ascii6:
        mult $k1, $t2
        mflo $k1
        addi $k1, $k1, 6
        j end_syscall5
    ascii7:
        mult $k1, $t2
        mflo $k1
        addi $k1, $k1, 7
        j end_syscall5
    ascii8:
        mult $k1, $t2
        mflo $k1
        addi $k1, $k1, 8
        j end_syscall5
    ascii9:
        mult $k1, $t2
        mflo $k1
        addi $k1, $k1, 9
        j end_syscall5


    end_syscall5:
        add $v0, $k1, $0
        lw $t2, 0($sp) # deallocation stack space
        addi $sp $sp, 4
        lw $t3, 0($sp)
        addi $sp $sp, 4
        lw $k0, 0($sp)
        addi $sp, $sp, 4
        jr $k0


# Heap allocation
_syscall9:
    addi $k1, $a0, 0    # get number of bytes in $a0
    lw $v0, -4096($0)
    add $k1, $k1, $v0   # return new pointer
    sw $k1, -4096($0)
    jr $k0


# "End" the program
_syscall10:
    j _syscall10


# Print character
_syscall11:
    # Print character code goes here
    sw $a0, -256($0)    # Console output
    jr $k0


# Read character
_syscall12:
    # Read character code goes here
    lw $k1, -240($0)    # Whether a key has been pressed on the console or terminal
    beq $k1, $0, _syscall12     # When key press not available
    lw $v0, -236($0)    # Character read from the console or terminal input
    sw $0, -240($0)      # Console output
    jr $k0  


# Extra challenge syscalls
# Print string
_syscall4:
    print_string_loop:
    lw $k1, 0($a0)      # Load the next character from the string
    beq $k1, $0, end    # If the character is null
    sw $k1, -256($0)    # Console output
    addi $a0, $a0, 4    # Increment the string pointer to the next character
    j print_string_loop

    end:
    jr $k0


# Read string
_syscall8:
    addi $sp, $sp, -4 
    sw $t2, 0($sp)
    addi $t2, $0, 0 # keep track of space usage
    
    readStringLoop:
        lw $k0, -240($0) 
        beq $k0, $0, _syscall8 # no keypress
        lw $k0, -236($0) # read next char
        sw $0, -240($0) # reset
        addi $k1, $0, 10
        beq $k0, $k1, endreadStringLoop
        addi $sp, $sp, -4
        addi $t2, $t2, 4
        sw $k0, 0($sp)
        j readStringLoop
    endreadStringLoop:
        addi $sp, $sp, -4
        addi $t2, $t2, 4
        sw $0, 0($sp) 
        add $sp, $sp, $t2
        sw $sp, -4096($0) # save to heap
        lw $t2, 0($sp)      # deallocation
        addi $sp, $sp, 4
        jr $k0

_syscallEnd_:

