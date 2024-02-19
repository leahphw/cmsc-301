          .data #This is boilerplate stuff to get QTSPIM to read this file the right way
          .text
          .align 2
          .globl main 

main:
    # Initialize dummy head
    addi $v0, $0, 9
    addi $a0, $0, 12
    syscall
    addi $s2, $v0, 0

    # Initialize dummy tail
    addi $v0, $0, 9
    addi $a0, $0, 12
    syscall
    addi $s3, $v0, 0

    # Set dummy nodes data to 0 for later stopping conditions
    sw $0, 0($s2)
    sw $0, 0($s3)

    addi $t7, $s2, 0 # curr = dummyHead

insert_loop:
    # Read input
    addi $v0, $0, 5
    syscall
    addi $t0, $v0, 0 # Store input in t0

    # If t0 = 0 then stop
    beq $t0, $0, post_input_loop
    addi $s1, $0, 0 # initialize s1 = 0 to handle if no value is entered

    # Create memory for new node
    addi $v0, $0, 9
    addi $a0, $0, 12
    syscall
    addi $s1, $v0, 0 # s1 now store the new node's address

    # Set data
    sw $t0, 0($s1)

    # Set pointers
    sw $s1, 4($t7) # curr->next = newNode
    sw $t7, 8($s1) # newNode->prev = curr
    addi $t7, $s1, 0 # curr = newNode

    j insert_loop

post_input_loop:
    beq $s1, $0, end # if s1 is still 0 after the loop, end because no value was entered
    sw $s1, 8($s3) # dummyTail->prev = newNode
    sw $s3, 4($s1) # newNode->next = dummyTail

sort_loop:
    addi $t6, $0, 1 # variable to see if swaps were made - swapped = true

    outer_loop:
        beq $t6, $0, pre_print_loop
        addi $t6, $0, 0 # swapped = false
        lw $t7, 4($s2) # curr = dummyHead->next

        inner_loop:
            lw $t0, 0($t7) # t0 = curr->data
            lw $t1, 4($t7) # t1 = curr->next
            lw $t2, 0($t1) # t2 = curr->next->data
            beq $t2, $0, outer_loop # if curr->next->data == 0 then branch out of inner loop

            # If curr->data > curr->next->data then swap their values
            slt $t3, $t2, $t0
            beq $t3, $0, update
            sw $t2, 0($t7) # curr->data = curr->next->data
            sw $t0, 0($t1) # curr->next->data = curr->data
            addi $t6, $0, 1 # swapped = true
            
            update:
                lw $t7, 4($t7) # curr = curr->next
                j inner_loop

pre_print_loop: 
    lw $t7, 4($s2) # curr = dummyHead->next

print_loop:
    lw $t2, 0($t7)
    beq $t2, $0, end

    # Print data
    addi $v0, $0, 1
    addi $a0, $t2, 0
    syscall

    # Print new line - by character
    addi $v0, $0, 11
    addi $a0, $0, 10
    syscall

    # Move to next node
    lw $t7, 4($t7) # curr = curr->next

    j print_loop

end:
    addi $v0, $0, 10
    syscall