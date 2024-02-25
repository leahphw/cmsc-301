          .data 
          PlayerVMT: .word playerAttack playerTakeDamage playerSellItem playerPickUpItem
          MerchantVMT: .word playerAttack playerTakeDamage merchantSellItem merchantPickUpItem
          WarriorVMT: .word warriorAttack playerTakeDamage playerSellItem playerPickUpItem
          KnightVMT: .word warriorAttack knightTakeDamage playerSellItem playerPickUpItem
          PlayerInventorySize: .word 5
          .text
          .align 2 #This is boilerplate stuff to get QTSPIM to read this file the right way
          .globl main 

j main

# Implement your classes here.
itemConstructor:                            # Takes 4 args: address, gv, ab, armb
    sw $a1, 4($a0)                          # goldValue = gv
    sw $a2, 8($a0)                          # attackBonus = ab
    sw $a3, 12($a0)                         # armorBonus = armb
    addi $v0, $a0, 0                        # return Item address
    jr $ra                                  # return

playerConstructor:                          # Takes 4 args: address, mh, g, s
    sw $a1, 4($a0)                          # max_hp = mh
    sw $a1, 8($a0)                          # currect_hp = mh
    sw $a2, 12($a0)                         # gold = g
    sw $a3, 16($a0)                         # strength = s

    sw $0, 20($a0)                          # initialize equipped_item to point to a 0 value

    la $t0, PlayerInventorySize             # load PlayerInventorySize
    lw $t0, 0($t0)                          # t0 = PlayerInventorySize
    addi $t1, $0, 4                         # t1 = 4
    mult $t1, $t0                           # number of bytes to request
    addi $sp, $sp, -4
    sw $a0, 0($sp)                          # store a0 on stack
    mflo $a0
    addi $v0, $0, 9
    syscall                                 # request heap memory

    lw $a0, 0($sp)                          # load a0 from stack
    addi $sp, $sp, 4                        # deallocate stack
    sw $v0, 24($a0)                         # 24($a0) is a pointer to an array size 5

    addi $t1, $0, 0                         # i = 0
    lw $t2, 24($a0)                         # t2 = *inventory
    populateInventory:
        bge $t1, $t0, donePopulateInventory # while i < 5
        sw $0, 0($t2)                       # &t2 = 0 (nullptr)
        addi $t2, $t2, 4                    # t2 += 4
        addi $t1, $t1, 1                    # t1 += 1

    donePopulateInventory:
        addi $v0, $a0, 0
        jr $ra                              # return


playerAttack: 

playerTakeDamage: 

playerSellItem:

playerPickUpItem:

testPlayer:
    # Implement your testPlayer function here.
    
main:
    # Allocate heap space for a Player, Warrior, Knight, and Merchant
    addi $a0, $0, 28                        # Allocate space for Player
    addi $v0, $0, 9
    syscall
    # Call the constructors.
    addi $a0, $v0, 0
    addi $a1, $0, 100                       # Player(100, 0, 5)
    addi $a2, $0, 0                         # Player(100, 0, 5)
    addi $a3, $0, 5                         # Player(100, 0, 5)
    jal playerConstructor

    lw $a0, 24($v0)                          # print test
    addi $v0, $0, 1
    syscall                                 # expect 0

    # Call the testPlayer function with each pointer.
   
    addi $v0, $0, 0                         # return 0;
end:
    addi $v0, $0, 10
    syscall