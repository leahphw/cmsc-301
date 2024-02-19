          .data 
# testcase1_arr: .word 301 150
# testcase1_len: .word 2
# testcase1_correct: .word 150 301

testcase2_arr: .word 3 2 1 0 -1 -2 -3
testcase2_len: .word 7
testcase2_correct: .word -3 -2 -1 0 1 2 3

          .text
          .align 2
          .globl main 
# Code goes here

init:


main:
    la $a0, testcase2_arr
    la $a1, testcase2_len
    lw $a1, 0($a1)
    jal bubble_sort

    la $a0, testcase2_arr
    la $a1, testcase2_len
    lw $a1, 0($a1)
    jal print_arr
    
    j end


print_arr:                                  # a0 = arr_address, a1 = arr_len
    addi $sp, $sp, -4
    sw $a1, 0($sp)
    addi $t0, $0, 0                         # i = 0
    addi $t2, $a0, 0                        # t2 = a0

    print_arr_while:
        lw $a1, 0($sp)
        beq $t0, $a1, print_arr_done        # if i = arr_len then end
        sll $t1, $t0, 2                     # t1 = 4 * i
        add $a1, $t2, $t1                   # a1 = arr_address + 4 * i
        lw $a0, 0($a1)                      # print element    
        addi $v0, $0, 1
        syscall
        add $v0, $0, 11
        addi $a0, $0, 32
        syscall
        addi $t0, $t0, 1                    # increment i
        j print_arr_while
    
    print_arr_done:
        addi $sp, $sp, 4                    # done printing, return control
        jr $ra


bubble_sort:
    addi $sp, $sp, -20                      
    sw $ra, 0($sp)                          # save $ra
    sw $a1, 4($sp)                          # save arr_len
    sw $0, 8($sp)                           # save i = 0
    sw $0, 12($sp)                          # save j = 0
    sw $a0, 16($sp)

    lw $t0, 8($sp)                          # i = 0

    sort_outer:                             # outer loop
        lw $t0, 8($sp)
        lw $a1, 4($sp)
        beq $t0, $a1, done_sort             # while i < arr_len
        sw $0, 12($sp)                      # j = 0

        sort_inner:                         # inner loop
            lw $a1, 4($sp)
            lw $t0, 8($sp)
            sub $a1, $a1, $t0               # a1 = a1 - i
            addi $a1, $a1, -1               # a1 = a1 - 1

            lw $t1, 12($sp)                 # load j
            beq $t1, $a1, done_inner        # while j < arr_len - i - 1
            sll $t2, $t1, 2                 # t2 = 4j
            add $t2, $a0, $t2
            lw $t3, 0($t2)                  # t3 = arr[j]
            lw $t4, 4($t2)                  # t4 = arr[j+1]
            bgt $t3, $t4, call_swap         # if arr[j] > arr[j+1]
            j after_compare

            call_swap:
                lw $a0, 16($sp)             # a0 = arr_address    
                lw $a1, 12($sp)             # a1 = j
                addi $a2, $a1, 1            # a2 = j + 1
                jal swap
                j after_compare

            after_compare:
                lw $t1, 12($sp)
                addi $t1, $t1, 1            # j += 1
                sw $t1, 12($sp)
                j sort_inner

            done_inner:
                lw $t0, 8($sp) 
                addi $t0, $t0, 1            # i += 1
                sw $t0, 8($sp) 
                j sort_outer

        done_sort:
            lw $ra, 0($sp)
            addi $sp, $sp, 20
            jr $ra


swap: # a0 = arr_address, a1 = i, a2 = j
    sll $a1, $a1, 2                         # a1 = 4i
    sll $a2, $a2, 2                         # a2 = 4j
    add $t0, $a0, $a1                       # t0 = a0 + 4i
    add $t1, $a0, $a2                       # t1 = a0 + 4j
    lw $t2, 0($t0)                          # a1 = arr[i]
    lw $t3, 0($t1)                          # t2 = arr[j]
    sw $t2, 0($t1)
    sw $t3, 0($t0)                          # swap values
    jr $ra


end:
    addi $v0, $0, 10
    syscall