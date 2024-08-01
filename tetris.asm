######################################################################
# CSCB58 Summer 2024 Assembly Final Project - UTSC
# Student1: Jack Liu (Jia Qing Liu), 1009937730, liuji563, jql.liu@mail.utoronto.ca
# Student2: Aviraj Waraich, 1006152057, waraic11, a.waraich@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# - Milestone 3
#
# Which approved features have been implemented?
# None
#
# How to play:
# W- Rotate
# A- Move left
# S- Move down (temporary)
# D- Move right
# Q- quit
# 
# Link to video demonstration for final submission:
# Not applicable
#
# Are you OK with us sharing the video with people outside course staff?
# Yes
#
# Any additional information that the TA needs to know:
#
######################################################################


.data
ADDR_DSPL: .word 0x10008000  # Base address for display
ADDR_KBRD: .word 0xffff0000  # Base address for keyboard
COLOR_GRAY: .word 0x00808080  # Wall color
COLOR_TETROMINO: .word 0x00FF00FF  # Tetromino color
COLOR_BLACK: .word 0x00000000  # Black color for clearing
COLOR_DARK: .word 0x00101010  # Dark grey for checkerboard
I_TETROMINO: .word 0x0000000F, 0x00000000, 0x00000000, 0x00000000  # Tetromino shape
current_tetromino: .word 0x0000000F, 0x00000000, 0x00000000, 0x00000000  # Current tetromino
current_x: .word 14  # Centered X position (32/2 - 2) = 14 
current_y: .word 1  # Y position
is_vertical: .word 1  # Orientation
playing_field: .space 4096  # Playing field
full_row_message: .asciiz "Row is Full\n"

#I_SHAPE: .word -32, 0, 32, 64
#O_SHAPE: .word 0, 1, 32, 33
#L_SHAPE: .word -32, 0, 32, 33
#J_SHAPE: .word -32, 0, 31, 32
#T_SHAPE: .word -32, -1, 0, 1
#Z_SHAPE: .word -33, -32, 0, 1
#S_SHAPE: .word -32, -31, -1, 0


I_SHAPE: .word 0 , -1,		0 , 0,		0 , 1,		0 , 2
O_SHAPE: .word 0 , 0 ,		0 , 1,		1 , 0,		1 , 1
L_SHAPE: .word 0 , -1,		0 , 0,		0 , 1,		1 , 1
J_SHAPE: .word 0 , -1,		0 , 0,		-1, 1,		0 , 1
T_SHAPE: .word 0 , -1, 		-1, 0,		0 , 0,		0 , 1
Z_SHAPE: .word -1, -1, 		0 ,-1,		0 , 0,		1 , 0
S_SHAPE: .word -1, -1,		0 ,-1,		0 , 0,		1 , 0

current_shape: .word 0 , -1,		0 , 0,		0 , 1,		0 , 2
rotation: .word 0

.text
.globl main
	
main:
#initial setup
	la $t0, ADDR_DSPL
	lw $t0, 0($t0)
	la $t3, COLOR_GRAY
	lw $t3, 0($t3)
	jal clear_screen
	
#-----------------
#---DRAW BORDER---
#-----------------

	# Draw the top border
	li $t2, 0
top_border:
	beq $t2, 32, top_done 
	sw $t3, 0($t0)
	addi $t0, $t0, 4  # Move to the next unit in the row
	addi $t2, $t2, 1
	j top_border
top_done:
	# Draw the bottom border
	li $t2, 0
	li $t0, 0x10008F80  # Start address at last row (bottom border) [Base address + (31 rows * 32 units per row * 4 bytes per unit)]
bottom_border:
	beq $t2, 32, bottom_done 
	sw $t3, 0($t0)
	addi $t0, $t0, 4  # Move to the next unit in the row
	addi $t2, $t2, 1
	j bottom_border
bottom_done:
	# Draw the left border
	li $t2, 0
	li $t0, 0x10008000  # Start at first column (left border) [Base address]
left_border:
	beq $t2, 32, left_done
	sw $t3, 0($t0)
	addi $t0, $t0, 128  # Move to the next row (32 units per row * 4 bytes per unit)
	addi $t2, $t2, 1
	j left_border
left_done:
	# Draw the right border
	li $t2, 0
	li $t0, 0x1000807C  		# Start at last column (right border) [Base address + (31 * 4 bytes)]
right_border:
	beq $t2, 32, right_done 
	sw $t3, 0($t0)
	addi $t0, $t0, 128  		# Move to the next row
	addi $t2, $t2, 1
	j right_border
right_done:				#Finished border

jal redraw_playing_field
jal draw_shape  			# Draw initial shape
#-------------
#--GAME LOOP--
#-------------
game_loop:
	li $t1, 0xffff0000
	lw $t2, 0($t1)
	beq $t2, $zero, game_loop  	# Check for key press

	lw $t3, 4($t1)
	beq $t3, 0x61, move_left	# 'a' key
	beq $t3, 0x64, move_right	# 'd' key
	beq $t3, 0x73, move_down	# 's' key
	beq $t3, 0x77, rotate		# 'w' key
	beq $t3, 0x71, quit		# 'q' key
	j game_loop



#------------
#--END MOVE--
#-Redraw shape after moving
#------------
end_move:
	jal draw_shape
	j game_loop

move_left:  # Move tetromino left
	#clear shape
	jal clear_shape		
	#call check new position
	li $a0 -1
	li $a1 0
	li $a2 0
	jal check_new_position
	#end move if false
	beq $v0, $zero, end_move
	#perform move if true
	lw $t0, current_x
	addi $t0, $t0, -1
	sw $t0, current_x
	#end move
	j end_move

move_right: # Move tetromino left
	#clear shape
	jal clear_shape		
	#call check new position
	li $a0 1
	li $a1 0
	li $a2 0
	jal check_new_position
	#end move if false
	beq $v0, $zero, end_move
	#perform move if true
	lw $t0, current_x
	addi $t0, $t0, 1
	sw $t0, current_x
	#end move
	j end_move

move_down:
	# Move tetromino left
	#clear shape
	jal clear_shape		
	#call check new position
	li $a0 0
	li $a1 1
	li $a2 0
	jal check_new_position
	#block landed if false
	beq $v0, $zero, block_landed
	#perform move if true
	lw $t0, current_y
	addi $t0, $t0, 1
	sw $t0, current_y
	#end move
	j end_move

rotate:  # Move tetromino left
	#clear shape
	jal clear_shape		
	#call check new position
	li $a0 0
	li $a1 0
	li $a2 1
	jal check_new_position
	#end move if false
	beq $v0, $zero, end_move
	#perform move if true
	lw $t0, rotation
	addi $t0, $t0, 1
	sw $t0, rotation
	#end move
	j end_move

#----------------
#--CLEAR SCREEN--
#----------------
clear_screen:
	la $t0, ADDR_DSPL
	lw $t0, 0($t0)
	li $t1, 0x00000000  # Black color
	li $t2, 1024  # 32x32 display
	clear_loop:
		sw $t1, 0($t0)
		addi $t0, $t0, 4
		addi $t2, $t2, -1
		bnez $t2, clear_loop
	jr $ra
#----------------------
#--GENERATE NEW BLOCK--
#----------------------
generate_new_block:
	li $t0, 14  # Reset X position to center
	sw $t0, current_x
	li $t0, 1   # Reset Y position to top
	sw $t0, current_y
	li $t0, 1   # Reset rotation
	sw $zero, rotation
	jr $ra


#--------------------
#--COMPUTE POSITION--
#-Returns an integer that is the position with respect to the start of the grid
compute_position:
	move $t1 $a0
	move $t2 $a1
	move $t5 $a2
		#for each rotation, rotate it once
		rotate_loop_start:
			beqz $t5 rotate_loop_end
		rotate_loop: 
			sub $t3 $zero $t2
			add $t4 $zero $t1
			addi $t5 $t5 -1
			move $t1 $t3
			move $t2 $t4
			j rotate_loop_start
		rotate_loop_end:
		#By this point, our segment is rotated in place, now we will draw
	lw $t3 current_x
	lw $t4 current_y
	#multiply by 4 and 128 respectively, to match addresses
	sll $t1 $t1 2
	sll $t2 $t2 7
	#do same for cx and cy
	sll $t3 $t3 2
	sll $t4 $t4 7
	#sum it together
	add $t1 $t1 $t2
	add $t3 $t3 $t4
	add $t1 $t1 $t3
	
	move $v0 $t1
	jr $ra


#----------------------
#--CHECK NEW POSITION--
#-Checks a position given arguments that tells new x, y, and rot
#----------------------
check_new_position:
	
	li $t0 0
	move $s0 $a0
	li $s1 4
	mul $s0 $s0 $s1
	move $s1 $a1
	li $s2 128
	mul $s1 $s1 $s2
	move $s2 $a2
	
	li $t6 32
	check_loop_start: bge $t0 $t6 check_loop_end
		#load x y rot into arguments
		lw $a0 current_shape($t0)
		addi $t5 $t0 4
		lw $a1 current_shape($t5)
		lw $a2 rotation($zero)
		add $a2 $a2 $s2 #increase rotation
		#Call compute position
		move $s3 $ra
		jal compute_position
		#restore return 
		move $ra $s3
		#obtain result
		move $t3 $v0
		li $t8 128
		#Check borders
		#add x and y to result
		li $t9 30
		li $t8 128
		li $t7 4
		add $t3 $t3 $s0
		add $t3 $t3 $s1
		div $t3 $t8 #divide by 128. y stored in lo (result), x stored in hi (remainder)
		
		li $t8 120
		
		mflo $t2  #y
		mfhi $t1  #x
		
		
		bgt $t1 $t8 check_failure	#x > 120
		blt $t1 $t7 check_failure	#x < 4
		bgt $t2 $t9 check_failure	#y > 31
		lw $t4 playing_field($t3)
		bnez $t4 check_failure		#block occupied space
		addi $t0 $t0 8			#i ++
		j check_loop_start
	check_failure:
	li $v0 0 #0 = collide
	jr $ra
	check_loop_end: 
	li $v0 1 #1 = no collide
	jr $ra		#return
	

#NEW DRAW FUNCTION: This will draw the current shape regardless of type
draw_shape: 
	li $t0 0
	#load display
	la $t8 COLOR_TETROMINO
	lw $t8 0($t8)
	li $t6 32
	draw_loop_start: bge $t0 $t6 draw_loop_end
	draw_loop: 
		#load x and y values into arguments
		lw $a0 current_shape($t0)
		addi $t5 $t0 4
		lw $a1 current_shape($t5)
		lw $a2 rotation($zero)
		#Call compute position
		move $s0 $ra
		jal compute_position
		#restore return 
		move $ra $s0
		#obtain result
		move $t1 $v0
		#display pixel
		la $t9 ADDR_DSPL
		lw $t9 0($t9)
		add $t1 $t1 $t9
		sw $t8 0($t1)		
		addi $t0 $t0 8			#i ++
	j draw_loop_start
	draw_loop_end: jr $ra		#return

clear_shape: 
	la $s6 COLOR_DARK
	lw $s6 0($s6)
	li $t0 0
	#load display
	li $t6 32
	clear_shape_loop:
	bge $t0 $t6 clear_shape_loop_end
	#load x y rot values into arguments
		lw $a0 current_shape($t0)
		addi $t5 $t0 4
		lw $a1 current_shape($t5)
		lw $a2 rotation($zero)
		#Call compute position
		move $s0 $ra
		jal compute_position
		#restore return 
		move $ra $s0
		#obtain result
		move $t1 $v0
		#display pixel
		la $t9 ADDR_DSPL
		lw $t9 0($t9)
		add $t1 $t1 $t9
		
		andi $t2 $t1 128
		srl $t2 $t2 5
		add $t2 $t1 $t2
		andi $t2 $t2 4
		
		beqz $t2 clear_grey
		sw $zero 0($t1)
		j clear_done
		clear_grey:
		sw $s6 0($t1)
		clear_done:
		addi $t0 $t0 8		# i ++
	j clear_shape_loop
	clear_shape_loop_end: jr $ra		#return



#----------------
#--BLOCK LANDED--
#--Called when block lands on ground
#----------------
block_landed:
    jal add_to_playing_field
    jal redraw_playing_field
    jal generate_new_block
    jal draw_shape
    jal check_full_rows
    j game_loop
#---------------------
#--ADD TO FIELD
#--Adds current block to field
add_to_playing_field:
	li $t0 0
	la $t8 COLOR_TETROMINO
	lw $t8 0($t8)
	li $t6 32
	add_loop_start:
	bge $t0 $t6 add_loop_end
	add_loop: 
		#load x and y values into arguments
		lw $a0 current_shape($t0)
		addi $t5 $t0 4
		lw $a1 current_shape($t5)
		#Call compute position
		move $s0 $ra
		jal compute_position
		#restore return 
		move $ra $s0
		#obtain result
		move $t1 $v0
		#add to playing field
		sw $t8 playing_field($t1)
		#increase counter
		addi $t0 $t0 8
	j add_loop_start
	add_loop_end:
	#retrun
	#TODO: replace with stack lol
	jr $ra



redraw_playing_field:
	la $t0, playing_field
	la $t1, ADDR_DSPL
	lw $t1, 0($t1)
	li $t2, 0 #counter
	li $t9  4096
	li $t8 128
	
	la $s7 COLOR_TETROMINO
	lw $s7 0($s7)
	la $s6 COLOR_DARK
	lw $s6 0($s6)
	
	redraw_loop:
	
		
		bgt $t2 $t9 redraw_loop_end
		div $t2 $t8
		mflo $t4 #y
		mfhi $t3 #x
		
		beqz $t3 redraw_loop_continue
		li $t7 124
		beq $t3 $t7 redraw_loop_continue
		li $t7 31
		beq $t4 $t7 redraw_loop_continue
		
		lw $t7 playing_field($t2)
		add $t6 $t2 $t1
		beqz $t7 redraw_background
		sw $s7 0($t6)
		j redraw_loop_continue
		redraw_background:	
		
			
			andi $t5 $t2 128
			srl $t5 $t5 5
			add $t5 $t5 $t2
			andi $t5 $t5 4
			beqz $t5 redraw_grey
				sw $zero 0($t6)
				j redraw_loop_continue
			redraw_grey:
				sw $s6 0($t6)
		
	redraw_loop_continue:
		addi $t2 $t2 4
		j redraw_loop
	redraw_loop_end:
	jr $ra
	

#redraw the field
redraw_playing_field_old:
	la $t0, playing_field
	la $t1, ADDR_DSPL
	lw $t1, 0($t1)
	li $t2, 0  # row counter
redraw_field_loop_row:
	li $t3, 0  # column counter
redraw_field_loop_col:
	lw $t4, 0($t0)
	beqz $t4, skip_redraw_block
	
	sw $t4, 0($t1)
	
	
	
skip_redraw_block:
	addi $t0, $t0, 4
	addi $t1, $t1, 4
	
	add $t5 $t4 $t3
	andi $t5 $t5 1
	
	
	addi $t3, $t3, 1
	blt $t3, 32, redraw_field_loop_col
	addi $t2, $t2, 1
	blt $t2, 32, redraw_field_loop_row
	jr $ra

#####################################################################

check_full_rows:
    li $t0, 30  # Start is the second to last row
    li $t1, 0   # Counter telling the  removed rows
check_line_loop:
    li $t2, 1
    li $t3, 30
    li $t5, 1   # if row is full
check_block_loop:
        mul $t4, $t0, 32
        add $t4, $t4, $t2
        sll $t4, $t4, 2
        lw $t6, playing_field($t4)
        beqz $t6, row_not_full
        addi $t2, $t2, 1
        ble $t2, $t3, check_block_loop
    # If u here, the row is full
    jal remove_row
    addi $t1, $t1, 1
    j check_line_loop  # Check the same row again
row_not_full:
    addi $t0, $t0, -1
    bgez $t0, check_line_loop
    
    # redraw the field if removed 
    beqz $t1, end_check
    jal redraw_playing_field
end_check:
    j game_loop

remove_row:
    move $t6, $t0  # Current row to remove
remove_loop:
    beqz $t6, fill_top_row
    li $t2, 1
copy_row_loop:
        mul $t4, $t6, 32
        add $t4, $t4, $t2
        sll $t4, $t4, 2
        addi $t5, $t4, -128  #  block in the row above
        lw $t7, playing_field($t5)
        sw $t7, playing_field($t4)
        addi $t2, $t2, 1
        ble $t2, $t3, copy_row_loop
    addi $t6, $t6, -1
    j remove_loop

fill_top_row:
    li $t2, 1
clear_top_loop:
        mul $t4, $t6, 32
        add $t4, $t4, $t2
        sll $t4, $t4, 2
        sw $zero, playing_field($t4)
        addi $t2, $t2, 1
        ble $t2, $t3, clear_top_loop
    jr $ra
    
#####################################################################
quit: 
	li $v0 10
	syscall
