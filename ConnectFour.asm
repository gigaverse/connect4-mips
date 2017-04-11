.data
#grid: .space 42
grid: .byte 32:42 # creates an array of 42 chars and sets each one as a blank space since 32 is the decimal value for spacebar
#grid: .byte 32, 32, 32, 32, 32 ,32 ,32 ,32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32
borderL: .asciiz "|" # used for the border on the left side
borderR: .asciiz " |" # used for the border on the right side and all the spaces in the middle
bottom: .asciiz "______________________" # the bottom line of the board, I have yet to find out if its the right length yet
newline: .asciiz "\n" # makes a new line
prompt:	.asciiz "Enter a number between 1 and 7 to drop a chip into that column: "
p1:	.asciiz "X"
p2:	.asciiz "O"
space:	.asciiz " "
fullC:	.asciiz "The column you are trying to add to is full. Please enter a different number between 1 and 7: "
oOfR:	.asciiz "Please enter a number betweeen 1 and 7: "
comp:	.asciiz "After the computer's turn, the board looks like this:\n"
start:	.asciiz "The board has been reset. A new game will be started."
p1Win: .asciiz "\nPlayer 1 Wins! Good job Player 1!\n"

.text

main: #manages the game
      jal DisplayBoard
      la $a0, newline
      li $v0, 4
      syscall
 
	la $a0, prompt
	li $v0, 4
	syscall #prompt user for column number
	li $v0, 5
	syscall #retrieve column number
	
	#move the column number
Loop:	add $s0, $v0, $zero
	
	#check that the number's actually between 1 and 7
	li $t0, 0
	li $t1, 8
	slt $t2, $s0, $t1
	#branch if it ain't
	beq $t2, $zero, outOfRange
	slt $t2, $t0, $s0
	beq $t2, $zero, outOfRange
	
	addi $s0, $s0, -1
	addi $s0, $s0, 35 #start checking at bottom row
	lb $t0, space
loop:	lb $t1, grid($s0)
	beq $t0, $t1, addp1 #check if soemthing's there (add a piece if something isn't)
	addi $s0, $s0, -7 #move up a row
	li $t2, 0
	#breaks the loop by branching if the column is full
	slt $t2, $t2, $s0
	beq $t2, $zero, colFull
	j loop
	
	#generates random column number
cTurn:	li $a1, 7
	li $v0, 42
	syscall
	
	#move the column number
	add $s0, $a0, $zero
	addi $s0, $s0, 35
	lb $t0, space
cLoop:	lb $t1, grid($s0)
	beq $t0, $t1, addp2
	addi $s0, $s0, -7
	li $t2, 0
	#breaks the loop by branching if the column is full
	slt $t2, $t2, $s0
	beq $t2, $zero, cTurn
	j cLoop
	
	#add a piece for player 1 (X's)
addp1:	lb $t0, p1
	sb $t0, grid($s0)
	
	jal DisplayBoard #display updated board
	
	add $s1, $s0, $zero
	jal HorizontalP1Check #checks if they won
	
	add $s1, $s0, $zero
	
	la $a0, newline
	li $v0, 4
	syscall
	
	#play the computer's turn
	j cTurn
	
	#add a piece for player 2 (O's)
addp2:	lb $t0, p2
	sb $t0, grid($s0)
	
	#display updated board and tell the user what on earth is going on
	la $a0, comp
	li $v0, 4
	syscall
	
	jal DisplayBoard
	
	la $a0, newline
	li $v0, 4
	syscall
	
	j main
	
	#tells the user they're stupid and they need to try again
colFull:
	la $a0, fullC
	li $v0, 4
	syscall #prompt user again
	li $v0, 5
	syscall #get the new entry
	j Loop #jump back to recheck and hopefully continue

	#also tells the user they're stupid
outOfRange:
	la $a0, oOfR
	li $v0, 4
	syscall #prompt user again
	li $v0, 5
	syscall #get the new entry
	j Loop #jump back to recheck and hopefully continue

	#resets the game board
resetBoard:
	lb $s0, space
	add $t0, $zero, $zero
rLoop:	beq $t0, 42, rExit
	sb $s0, grid($t0)
	addi $t0, $t0, 1
	j rLoop

	#give the user a message that the board was cleared and the game is restarting
rExit:	la $a0, start
	li $v0, 4
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	
	j main #jump back to beginning

DisplayBoard: # displays the board
   subu $sp, $sp, 4 # adds enough room on the stack for the return address
   sw $ra, ($sp)
   
   add $t0, $zero, $zero # makes sure $t0 is set to 0
   
   while: beq $t0, 42, exit # loops until every item in the array has been displayed, loops a total of 6 times, one for each row

            # displays the left border 
            la $a0, borderL 
            li $v0, 4
            syscall
            
            # makes sure $t1 is set to zero on each iteration
            add $t1, $zero, $zero
            
       row: beq $t1, 7, rowComplet # displays a row of the board with 7 columns, loops until that row's 7 coulumns have been displayed
       
            # should display an item in the char array; which is a blank space the first time display board is called
            lb $a0, grid($t0) # loads the byte into $a0 to be displayed; characters are only one byte
            li $v0, 11 # syscall value for displaying a character
            syscall
            
            # displays a right border mark 
            la $a0, borderR
            li $v0, 4
            syscall
            
            #increments the values of $t0 and $t1 by one
            addi $t0, $t0, 1
            addi $t1, $t1, 1
            
            j row # jumps back to row   
                
       rowComplet: # is called once the row is displayed
       # displayes the right border at the end of that row
       #la $a0, borderR
       #li $v0, 4
       #syscall
       
       # makes a new line for the next row
       la $a0, newline
       li $v0, 4
       syscall
       j while



exit:

#displays the bottom of the board
la $a0, bottom 
li $v0, 4
syscall

   lw $ra, ($sp)
   addu $sp, $sp, 4
   jr $ra
   
HorizontalP1Check:
    subu $sp, $sp, 4
    sw $ra, ($sp)
    
    add $t0, $zero, $zero
    lb $t1, space
    lb $t2, p2
    jal HorizontalP1Right
    add $t0, $zero, $zero
    jal HorizontalP1Left
    
    lw $ra, ($sp)
    addu $sp, $sp, 4
    jr $ra
    
HorizontalP1Right:
subu $sp, $sp, 4
sw $ra, ($sp)

addi $t5, $zero, 7
slt $t4, $s1, $t5
beq $t4, 1, HorizLoop1R

addi $t5, $zero, 14
slt $t4, $s1, $t5
beq $t4, 1, HorizLoop2R

addi $t5, $zero, 21
slt $t4, $s1, $t5
beq $t4, 1, HorizLoop3R

addi $t5, $zero, 28
slt $t4, $s1, $t5
beq $t4, 1, HorizLoop4R

addi $t5, $zero, 35
slt $t4, $s1, $t5
beq $t4, 1, HorizLoop5R

addi $t5, $zero, 42
slt $t4, $s1, $t5
beq $t4, 1, HorizLoop6R
     
    HorizLoop6R: beq $t0,3,Rexit
     lb $t3, grid($s1)
     beq $t3, $t2, noHRwin # if the space is player 2's peice then p1 didn't win
     beq $t3, $t1, noHRwin # if the space is a blank space then p1 didn't win
     addi $s1, $s1, 1
     beq, $s1, 42, noHRwin
     addi $t0, $t0, 1
     j HorizLoop6R
     
      HorizLoop5R: beq $t0,3,Rexit
     lb $t3, grid($s1)
     beq $t3, $t2, noHRwin # if the space is player 2's peice then p1 didn't win
     beq $t3, $t1, noHRwin # if the space is a blank space then p1 didn't win
     addi $s1, $s1, 1
     beq, $s1, 35, noHRwin
     addi $t0, $t0, 1
     j HorizLoop5R
     
      HorizLoop4R: beq $t0,3,Rexit
     lb $t3, grid($s1)
     beq $t3, $t2, noHRwin # if the space is player 2's peice then p1 didn't win
     beq $t3, $t1, noHRwin # if the space is a blank space then p1 didn't win
     addi $s1, $s1, 1
     beq, $s1, 28, noHRwin
     addi $t0, $t0, 1
     j HorizLoop4R
     
      HorizLoop3R: beq $t0,3,Rexit
     lb $t3, grid($s1)
     beq $t3, $t2, noHRwin # if the space is player 2's peice then p1 didn't win
     beq $t3, $t1, noHRwin # if the space is a blank space then p1 didn't win
     addi $s1, $s1, 1
     beq, $s1, 21, noHRwin
     addi $t0, $t0, 1
     j HorizLoop3R
     
      HorizLoop2R: beq $t0,3,Rexit
     lb $t3, grid($s1)
     beq $t3, $t2, noHRwin # if the space is player 2's peice then p1 didn't win
     beq $t3, $t1, noHRwin # if the space is a blank space then p1 didn't win
     addi $s1, $s1, 1
     beq, $s1, 14, noHRwin
     addi $t0, $t0, 1
     j HorizLoop2R
     
      HorizLoop1R: beq $t0,3,Rexit
     lb $t3, grid($s1)
     beq $t3, $t2, noHRwin # if the space is player 2's peice then p1 didn't win
     beq $t3, $t1, noHRwin # if the space is a blank space then p1 didn't win
     addi $s1, $s1, 1
     beq, $s1, 7, noHRwin
     addi $t0, $t0, 1
     j HorizLoop1R
    
     
    noHRwin:
        lw $ra, ($sp)
        addu $sp, $sp, 4 
         jr $ra 
         
    Rexit:
        la $a0, p1Win
        li $v0, 4
        syscall
        
        li $v0, 10
        syscall

HorizontalP1Left:
subu $sp, $sp, 4
sw $ra, ($sp)

addi $t5, $zero, 7
slt $t4, $s1, $t5
beq $t4, 1, HorizLoop1L

addi $t5, $zero, 14
slt $t4, $s1, $t5
beq $t4, 1, HorizLoop2L

addi $t5, $zero, 21
slt $t4, $s1, $t5
beq $t4, 1, HorizLoop3L

addi $t5, $zero, 28
slt $t4, $s1, $t5
beq $t4, 1, HorizLoop4L

addi $t5, $zero, 35
slt $t4, $s1, $t5
beq $t4, 1, HorizLoop5L

addi $t5, $zero, 42
slt $t4, $s1, $t5
beq $t4, 1, HorizLoop6L
     
    HorizLoop6L: beq $t0,3,Lexit # if it looped 4 times without a space that isn't their peice then p1 wins
     lb $t3, grid($s1)
     beq $t3, $t2, noHLwin # if the space is player 2's peice then p1 didn't win
     beq $t3, $t1, noHLwin # if the space is a blank space then p1 didn't win
     addi $s1, $s1, -1
     beq, $s1, 34, noHLwin # if there is no more space in that row to count then p1 didn't win
     addi $t0, $t0, 1
     j HorizLoop6L
     
      HorizLoop5L: beq $t0,3,Lexit
     lb $t3, grid($s1)
     beq $t3, $t2, noHLwin # if the space is player 2's peice then p1 didn't win
     beq $t3, $t1, noHLwin # if the space is a blank space then p1 didn't win
     addi $s1, $s1, -1
     beq, $s1, 27, noHLwin
     addi $t0, $t0, 1
     j HorizLoop5L
     
      HorizLoop4L: beq $t0,3,Lexit
     lb $t3, grid($s1)
     beq $t3, $t2, noHLwin # if the space is player 2's peice then p1 didn't win
     beq $t3, $t1, noHLwin # if the space is a blank space then p1 didn't win
     addi $s1, $s1, -1
     beq, $s1, 20, noHLwin
     addi $t0, $t0, 1
     j HorizLoop4L
     
      HorizLoop3L: beq $t0,3,Lexit
     lb $t3, grid($s1)
     beq $t3, $t2, noHLwin # if the space is player 2's peice then p1 didn't win
     beq $t3, $t1, noHLwin # if the space is a blank space then p1 didn't win
     addi $s1, $s1, -1
     beq, $s1, 13, noHLwin
     addi $t0, $t0, 1
     j HorizLoop3L
     
      HorizLoop2L: beq $t0,3,Lexit
     lb $t3, grid($s1)
     beq $t3, $t2, noHLwin # if the space is player 2's peice then p1 didn't win
     beq $t3, $t1, noHLwin # if the space is a blank space then p1 didn't win
     addi $s1, $s1, -1
     beq, $s1, 6, noHLwin
     addi $t0, $t0, 1
     j HorizLoop2L
     
      HorizLoop1L: beq $t0,3,Lexit
     lb $t3, grid($s1)
     beq $t3, $t2, noHLwin # if the space is player 2's peice then p1 didn't win
     beq $t3, $t1, noHLwin # if the space is a blank space then p1 didn't win
     addi $s1, $s1, -1
     beq, $s1, -1, noHLwin
     addi $t0, $t0, 1
     j HorizLoop1L
    
     
    noHLwin:
        lw $ra, ($sp)
        addu $sp, $sp, 4 
        jr $ra
          
     Lexit:
        la $a0, p1Win
        li $v0, 4
        syscall
        
        li $v0, 10
        syscall

