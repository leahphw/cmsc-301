          .data 
          PlayerVMT: .word playerAttack playerTakeDamage playerSellItem playerPickUpItem
          MerchantVMT: .word playerAttack playerTakeDamage merchantSellItem merchantPickUpItem
          WarriorVMT: .word warriorAttack playerTakeDamage playerSellItem playerPickUpItem
          KnightVMT: .word warriorAttack knightTakeDamage playerSellItem playerPickUpItem

          .text
          .align 2 #This is boilerplate stuff to get QTSPIM to read this file the right way
          .globl main 
# Implement your classes here.
itemConstructor:                            # Takes 4 args: address, gv, ab, armb
    lw $a1, 4($a0)                          # goldValue = gv
    lw $a2, 8($a0)                          # attackBonus = ab
    lw $a3, 12($a0)                         # armorBonus = armb
    jr $ra                                  # return

playerConstructor:                          # Takes 4 args: address, mh, g, s
    lw $a1, 4($a0)                          # max_hp = mh
    lw $a2, 8($a0)                          # currect_hp = mh
    lw $a3, 12($a0)                         # 

playerAttack: 

playerTakeDamage: 

playerSellItem:

playerPickUpItem:

testPlayer:
    # Implement your testPlayer function here.
    
main:
    # Allocate heap space for a Player, Warrior, Knight, and Merchant
    # Call the constructors.
    # Call the testPlayer function with each pointer.
   
    addi $v0, $0, $0 # return 0;
end:
    addi $v0, $0, 10
    syscall