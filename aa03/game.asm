          .data 

          .text
          .align 2 #This is boilerplate stuff to get QTSPIM to read this file the right way
          .globl main 
# Implement your classes here.

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