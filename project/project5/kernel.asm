_start_of_syscall:
    beq $v0, $0, _syscall0 #jump to syscall 0
    addi $k1, $0, 1
    beq $v0, $k1, _syscall1 #jump to syscall 1
    addi $k1, $0, 4
    beq $v0, $k1, _syscall4 #jump to syscall 4
    addi $k1, $0, 5
    beq $v0, $k1, _syscall5 #jump to syscall 5
    addi $k1, $0, 8
    beq $v0, $k1, _syscall8 #jump to syscall 8
    addi $k1, $0, 9
    beq $v0, $k1, _syscall9 #jump to syscall 9
    addi $k1, $0, 10
    beq $v0, $k1, _syscall10 #jump to syscall 10
    addi $k1, $0, 11
    beq $v0, $k1, _syscall11 #jump to syscall 11
    addi $k1, $0, 12
    beq $v0, $k1, _syscall12 #jump to syscall 12
    addi $k1, $0, 60
    beq $v0, $k1, _syscall60 #jump to syscall 60
    addi $k1, $0, 61
    beq $v0, $k1, _syscall61 #jump to syscall 61
    #Error state - this should never happen - treat it like an end program
    j _syscall10

#Initialization
_syscall0:
    addi $sp, $0, -4096 #Initialize stack pointer
    la $k1, _END_OF_STATIC_MEMORY_  # put the address of the end of static memory into k1
    sw $k1, 1073741564($0)  #set heap point to 0x3FFFFEFC
    j _syscallEnd_

#Print Integer
_syscall1:
    addi $sp, $sp, -12
    addi $k1, $sp, 0    #Mark start point for print

    #Save registers on stack
    sw $k0, 8($sp)
    sw $t2, 4($sp)
    sw $t3, 0($sp)

    addi $t2, $0, 10
    addi $k0, $a0, 0    #k0 contains integer stored in a0

    readInt:
        div $k0, $t2    #Divide 10 each time to get each digit
        mflo $k0    #k0 contains result of division
        mfhi $t3    #t3 contains remainder of division
        addi $sp, $sp, -4
        sw $t3, 0($sp)
        bne $k0, $0, readInt    #finish/continue reading

    printIntLoop:
        lw $k0, 0($sp)
        addi $k0, $k0, 48   #add 48 to give ascii for 0-9
        sw $k0, -256($0)    #save to 0x3FFFF00 (Terminal)
        addi $sp, $sp, 4
        bne $sp, $k1, printIntLoop

    #Restore registers
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $k0, 0($sp)
    addi $sp, $sp, 4
    jr $k0

#Read Integer
#ASCII 48-57
_syscall5:
    addi $sp, $sp, -12 #allocate three space
    sw $t2, 0($sp)
    sw $t3, 4($sp)
    sw $k0, 8($sp)
    addi $t2, $0, 10 #used to move the number to left
    addi $k1, $0, 0 #accumulation starts at 0
    readLoop:
        addi $t3, $0, 48
        lw $k0, -240($0) #0xFFFFFF10 = keyboard ready
        beq $k0, $0, _syscall5 #if no keypress, jump to end
        lw $k0, -236($0) #0xFFFFFF14 = read keyboard character
        sw $0, -240($0) #set keyboard ready to 0 to get next character
        beq $k0, $t3, ascii0
        addi $t3, $t3, 1 #for next number
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
        mult $k1, $t2 #when it is zero, do nothing, just move to left
        mflo $k1
        j end_syscall5:
    ascii1:
        mult $k1, $t2 #if not, we move to left and add the corresponding number
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
        add $v0, $k1, $0 #store k1
        lw $t2, 0($sp) #deallocation
        addi $sp $sp, 4
        lw $t3, 0($sp)
        addi $sp $sp, 4
        lw $k0, 0($sp)
        addi $sp, $sp, 4
        jr $k0

#Heap allocation
_syscall9:
    addi $k1, $a0, 0    #request number of bytes in $a0
    lw $v0, 1073741564($0)
    add $k1, $k1, $v0   #return a pointer in v0
    sw $k1, 1073741564($0)
    jr $k0

#"End" the program
_syscall10:
    j _syscall10


#print character
_syscall12:
    sw $a0, -256($0)    #Print char in a0 to 0x3FFFF00 (terminal)
    jr $k0

#read character
_syscall11:
    lw $k1, -240($0) #lw from 0x3FFFF10 (keyboard)
    beq $k1, $0, _syscall11 #Check keypress
    lw $k1, -236($0) #read char from 0x3FFFF14
    sw $0, -240($0) #increment to the next keypress
    addi $v0, $k1, 0 #save character value in $v0
    jr $k0


    #print string
_syscall4:
  addi $sp, $sp, -4
  sw $k0, 0($sp)
  addi $k0, $a0, 0
  printStringLoop:
    lw $k1, 0($k0)
    beq $k1, $0, strEnd
    sw $k1, -256($0)
    addi $k0, $k0, 4
    j printStringLoop
    strEnd:
      lw $k0, 0($sp)
      addi $sp, $sp, 4
      jr $k0


 #read string
_syscall8:
    addi $sp, $sp, -4 #allocate space
    sw $t2, 0($sp)
    addi $t2, $0, 0 #t2 keep track of how much space we use on sp
    
    readStringLoop:
        lw $k0, -240($0) #0xFFFFFF10 = keyboard ready
        beq $k0, $0, _syscall8 #if no keypress, keep trying 
        lw $k0, -236($0) #0xFFFFFF14 = read keyboard character
        sw $0, -240($0) #set keyboard ready to 0 to get next character
        addi $k1, $0, 10
        beq $k0, $k1, endreadStringLoop
        addi $sp, $sp, -4
        addi $t2, $t2, 4
        sw $k0, 0($sp)
        j readStringLoop
    endreadStringLoop:
        addi $sp, $sp, -4
        addi $t2, $t2, 4
        sw $0, 0($sp)  #add '0' to string
        add $sp, $sp, $t2
        sw $sp, 1073741564($0) #save to heap
        lw $t2, 0($sp)      #deallocation
        addi $sp, $sp, 4
        jr $k0



_syscallEnd_:
    j main
