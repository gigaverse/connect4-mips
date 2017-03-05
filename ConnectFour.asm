.data
#grid: .space 42
grid: .byte 32:42 # creates an array of 42 chars and sets each one as a blank space since 32 is the decimal value for spacebar
#grid: .byte 32, 32, 32, 32, 32 ,32 ,32 ,32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32
borderL: .asciiz "|" # used for the border on the left side
borderR: .asciiz " |" # used for the border on the right side and all the spaces in the middle
bottom: .asciiz "______________________" # the bottom line of the board, I have yet to find out if its the right length yet
newline: .asciiz "\n" # makes a new line


.text

main:

DisplayBoard: # displays the board
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


# problems with the code right now
# before displaying the char it dipslays a borderR and a bottom line forsome reason and then after every borderR a bottom line is displayed and I can't figure out the reason behind this
# bottom should only be called in after the while loop exits but it is displayed many times before that for some reason
# the byte/char is loaded and displayed the correct number of times though, but it is also cuasing other values to be displayed for some reason
# nothing I search for online has any referance or solution to this.
