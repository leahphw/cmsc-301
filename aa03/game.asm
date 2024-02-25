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

playerTakeDamage:                           # Arg: a0 = playerAddress, a1 = damage
    lw $t0, 8($a0)                          # t0 = currentHp
    sub $t0, $t0, $a1                       # currentHp -= damage

    bge $t0, $0, donePlayerTakeDamage       # if currentHp < 0
    addi $t0, $0, 0

    donePlayerTakeDamage:                   
        sw $t0, 8($a0)
        jr $ra                              # return

playerSellItem:                             # Args: a0 = playerAddress, a1 = *item
    beq $a1, $0, donePlayerSellItem         # if item != nullptr
    la $t0, PlayerInventorySize             # t0 = PlayerInventorySize
    lw $t0, 0($t0)
    addi $t1, $0, 0                         # i = 0
    lw $t2, 24($a0)                         # t2 = *inventory

    playerSellItemLoop:
        lw $t3, 0($t2)                      # t3 = inventory[i]
        bge $t1, $t0, donePlayerSellItem    # while i < PlayerInventorySize
        beq $t3, $a1, playerSellItemMatch   # if item != inventory[i]
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

    playerPickUpItemLoop:
        lw $t3, 0($t2)                      # t2 = inventory[i]
        beq $t3, $0, playerPickUpItemSlot   # if t2 != nullptr
        addi $t1, $t1, 1
        addi $t2, $t2, 4
        j playerPickUpItemLoop
    
    playerPickUpItemSlot:
        sw $a1, 0($t2)                      # inventory[i] -> newItem
        jr $ra

testPlayer:                                 # Arg: a0 = playerAddress
    # Implement your testPlayer function here.
    addi $sp, $sp, -12
    sw $a0, 0($sp)                          # Store a0 on stack
    sw $ra, 4($sp)                          # Store ra on stack

    addi $a0, $0, 16                        
    addi $v0, $0, 9
    syscall                                 # Request Item space
    addi $a0, $v0, 0
    addi $a1, $0, 100
    addi $a2, $0, 5
    addi $a3, $0, 6
    jal itemConstructor                     # Create item1

    addi $a1, $v0, 0                        # a1 = item1
    lw $a0, 0($sp)                          # a0 = playerAddress
    sw $a0, 0($sp)                          # Store a0 on stack
    jal playerPickUpItem                    # player->pickUpItem(item1)

    addi $a0, $0, 16                        
    addi $v0, $0, 9
    syscall                                 # Request Item space
    addi $a0, $v0, 0
    addi $a1, $0, 120
    addi $a2, $0, 4
    addi $a3, $0, 8
    jal itemConstructor                     # Create item2

    addi $a1, $v0, 0                        # a1 = item2
    sw $v0, 8($sp)                          # Store item2 on stack
    lw $a0, 0($sp)                          # a0 = playerAddress
    sw $a0, 0($sp)                          # Store a0 on stack
    jal playerPickUpItem                    # player->pickUpItem(item2)

    lw $a0, 0($sp)                          # Load player
    lw $t0, 24($a0)                         # t0 = player->inventory
    lw $t0, 0($t0)                          # t0 = player->inventory[0]
    sw $t0, 20($a0)                         # player->equipped_item = inventory[0]

    jal playerAttack                        # Call playerAttack()
    addi $a0, $v0, 0                        # a0 = int damage
    addi $v0, $0 , 1
    syscall                                 # cout damage

    addi $a0, $0, 10                        # print new line
    addi $v0, $0, 11
    syscall

    lw $a0, 0($sp)                          # Load player
    addi $a1, $0, 10                        # damage = 10
    jal playerTakeDamage                    # player->playerTakeDamage(10)
    lw $a0, 0($sp)                          
    lw $a0, 8($a0)                          # a0 = player->currentHp
    addi $v0, $0, 1
    syscall                                 # cout player->currentHp

    addi $a0, $0, 10                        # print new line
    addi $v0, $0, 11
    syscall

    lw $a0, 0($sp)                          # Load player
    lw $a1, 8($sp)                          # Load item2
    jal playerSellItem                      # player->sellItem(item2)
    lw $a0, 0($sp)                          # Load player
    lw $a0, 12($a0)
    addi $v0, $0, 1
    syscall                                 # cout player->gold

    lw $ra, 4($sp)
    addi $sp, $sp, 12
    jr $ra

    addi $a0, $0, 10                        # print new line
    addi $v0, $0, 11
    syscall
    
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

    # Call the testPlayer function with each pointer.
    addi $a0, $v0, 0                        # a0 = player
    jal testPlayer                          
    
    addi $v0, $0, 0                         # return 0;
end:
    addi $v0, $0, 10
    syscall