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
CompWin: .asciiz "\n Computer wins. You lose!\n"

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
	li $t2, -1
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
	
	#add $s1, $s0, $zero
	lb $t0, p1
	jal WinCheck #checks if they won
	
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
	
	lb $t0, p2
	jal WinCheck
	
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
   
#------------------------#win checks for both players
  
WinCheck:
    subu $sp, $sp, 4
    sw $ra, ($sp)
    
    add $t2, $zero, $t0 #load current piece into t2
    add $t0, $zero, $zero
    #lb $t2, p1
    add $s1, $s0, $zero
    jal HorizontalRight
    addi $t0, $t0, -1
    add $s1, $s0, $zero
    jal HorizontalLeft
    
    add $s1, $s0, $zero
    add $t0, $zero, $zero
    
    add $s1, $s0, $zero
    jal VerticalDown
    
    add $t0, $zero, $zero
    add $s1, $s0, $zero
    jal DiagDownTop
    
    addi $t0, $t0, -1
    add $s1, $s0, $zero
    jal DiagDownBot
    
    add $t0, $zero, $zero
    add $s1, $s0, $zero
    jal DiagUpTop
    
    addi $t0, $t0, -1
    add $s1, $s0, $zero
    jal DiagUpBot
    
    lw $ra, ($sp)
    addu $sp, $sp, 4
    jr $ra
    
HorizontalRight:
subu $sp, $sp, 4
sw $ra, ($sp)

addi $t6, $zero, 1 #CHECKING HORIZONTALLY FROM THE LEFT (next piece)

addi $t5, $zero, 7
slt $t4, $s1, $t5
beq $t4, 1, CheckLoop

addi $t5, $zero, 14
slt $t4, $s1, $t5
beq $t4, 1, CheckLoop

addi $t5, $zero, 21
slt $t4, $s1, $t5
beq $t4, 1, CheckLoop

addi $t5, $zero, 28
slt $t4, $s1, $t5
beq $t4, 1, CheckLoop

addi $t5, $zero, 35
slt $t4, $s1, $t5
beq $t4, 1, CheckLoop

addi $t5, $zero, 42
slt $t4, $s1, $t5
beq $t4, 1, CheckLoop

HorizontalLeft:
subu $sp, $sp, 4
sw $ra, ($sp)

addi $t6, $zero, -1 #CHECKING HORIZONTALLY FROM THE LEFT (next piece)

addi $t5, $zero, 7
slt $t4, $s1, $t5
subi $t5, $zero, 8
beq $t4, 1, CheckLoop

addi $t5, $zero, 14
slt $t4, $s1, $t5
subi $t5, $zero, 8
beq $t4, 1, CheckLoop

addi $t5, $zero, 21
slt $t4, $s1, $t5
subi $t5, $zero, 8
beq $t4, 1, CheckLoop

addi $t5, $zero, 28
slt $t4, $s1, $t5
subi $t5, $zero, 8
beq $t4, 1, CheckLoop

addi $t5, $zero, 35
slt $t4, $s1, $t5
subi $t5, $zero, 8
beq $t4, 1, CheckLoop

addi $t5, $zero, 42
slt $t4, $s1, $t5
subi $t5, $zero, 8
beq $t4, 1, CheckLoop



VerticalDown:        
subu $sp, $sp, 4
sw $ra, ($sp)

li $t5, 42
addi $t6, $zero, 7
j CheckLoopVertD

DiagDownTop:        
subu $sp, $sp, 4
sw $ra, ($sp)

li $t5, 42
addi $t6, $zero, 8
j CheckLoopVertD

DiagDownBot:        
subu $sp, $sp, 4
sw $ra, ($sp)

li $t5, 0
addi $t6, $zero, -8
j CheckLoopVertU

DiagUpTop:        
subu $sp, $sp, 4
sw $ra, ($sp)

li $t5, 42
addi $t6, $zero, 6
j CheckLoopVertD

DiagUpBot:        
subu $sp, $sp, 4
sw $ra, ($sp)

li $t5, 0
addi $t6, $zero, -6
j CheckLoopVertU

    #Important ######### the check for out of bounds needs to happen at the bigginging of the loop before the lb.######### important
    CheckLoop: beq $t0,4,WinExit
    beq, $s1, $t5, noHLwin
    lb $t3, grid($s1)
    bne $t3, $t2, noHLwin # if the space is player 2's peice then p1 didn't win
    addi $t0, $t0, 1
    add $s1, $s1, $t6
    j CheckLoop
     
    
    CheckLoopVertD: beq $t0, 4, WinExit
    slt $t4, $s1, $t5
    beq $t4, $zero, noVwin
    lb $t3, grid($s1)
    bne $t3, $t2, noVwin
    addi $t0, $t0, 1
    add $s1, $s1, $t6
    j CheckLoopVertD
    
    CheckLoopVertU: beq $t0, 4, WinExit
    slt $t4, $t5, $s1
    beq $t4, $zero, noVwin
    lb $t3, grid($s1)
    bne $t3, $t2, noVwin
    addi $t0, $t0, 1
    add $s1, $s1, $t6
    j CheckLoopVertD
    
    noHLwin:
        lw $ra, ($sp)
        addu $sp, $sp, 4 
        jr $ra
        
        noVwin:
        lw $ra, ($sp)
        addu $sp, $sp, 4 
        jr $ra
          
     WinExit:
     	lb $t7, p2
     	beq $t7, $t2, CWinExit
        la $a0, p1Win
        li $v0, 4
        syscall
        
        li $v0, 10
        syscall
 
     CWinExit:
        la $a0, CompWin
        li $v0, 4
        syscall
        
        li $v0, 10
        syscall
