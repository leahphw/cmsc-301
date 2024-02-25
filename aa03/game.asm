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
itemConstructor:                            # Args: address, gv, ab, armb
    sw $a1, 4($a0)                          # goldValue = gv
    sw $a2, 8($a0)                          # attackBonus = ab
    sw $a3, 12($a0)                         # armorBonus = armb
    addi $v0, $a0, 0                        # return Item address
    jr $ra                                  # return

playerConstructor:                          # Args: address, mh, g, s
    la $t0, PlayerVMT
    sw $t0, 0($a0)                          # OH->PlayerVMT
    sw $a1, 4($a0)                          # maxHp = mh
    sw $a1, 8($a0)                          # currentHp = mh
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
        j populateInventory

    donePopulateInventory:
        addi $v0, $a0, 0
        jr $ra                              # return

playerAttack:                               # Arg: a0 = playerAddress
    lw $t0, 16($a0)                         # t0 = player->strength
    addi $v0, $t0, 0                        # v0 = t0
    jr $ra                                  # return

playerTakeDamage:                           # Arg: a0 = playerAddress, a1 =damage
    lw $t0, 12($a0)                         # t0 = currentHp
    sub $t0, $t0, $a1                       # currentHp -= damage

    bge $t0, $0, donePlayerTakeDamage       # if currentHp < 0
    addi $t0, $0, 0

    donePlayerTakeDamage:                   
        sw $t0, 12($a0)
        jr $ra                              # return

playerSellItem:                             # Args: a0 = playerAddress, a1 = *item
    beq $a1, $0, donePlayerSellItem         # if item != nullptr
    la $t0, PlayerInventorySize             # t0 = PlayerInventorySize
    lw $t0, 0($t0)
    addi $t1, $0, 0                         # i = 0
    lw $t2, 24($a0)                         # t2 = *inventory
    lw $t2, 0($t2)                          # t2 = inventory[0]

    playerSellItemLoop:
        bge $t1, $t0, donePlayerSellItem    # while i < PlayerInventorySize
        beq $t2, $a1, playerSellItemMatch   # if item != inventory[i]
        addi $t2, $t2, 4
        addi $t1, $t1, 1
        j playerSellItemLoop

    playerSellItemMatch:
        lw $t0, 4($a1)                      # t0 = item->goldValue
        lw $t1, 12($a0)                     # t1 = player->gold
        add $t1, $t1, $t0                  
        sw $t1, 12($a0)                     # player->gold += item->goldValue
        sw $0, 0($a1)                       # inventory[i] = nullptr

    donePlayerSellItem:
        jr $ra

playerPickUpItem:                           # Args: a0 = playerAddress, a1 = newItem
    la $t0, PlayerInventorySize
    lw $t0, 0($t0)                          # t0 = PlayerInventorySize
    addi $t1, $0, 0                         # i = 0
    lw $t2, 24($a0)                         # t2 = *inventory
    lw $t2, 0($t2)                          # t2 = inventory[0]

    playerPickUpItemLoop:
        beq $t2, $0, playerPickUpItemSlot   # if t2 != nullptr
        addi $t1, $t1, 1
        addi $t2, $t2, 4
        j playerPickUpItemLoop
    
    playerPickUpItemSlot:
        sw $a1, 0($t2)                      # inventory[i] -> newItem
        jr $ra

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

    lw $a0, 24($v0)                         # print test
    addi $v0, $0, 1
    syscall                                 # expect 0

    # Call the testPlayer function with each pointer.
   
    addi $v0, $0, 0                         # return 0;
end:
    addi $v0, $0, 10
    syscall