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
# - Milestone 1, 2, 3, 4, 5
#
# Which approved features have been implemented?
# (E1) Gravity
# (E2) Speed of gravity
# (E4) Sounds for movement, rotation, dropped, and line
# (E11) Pieces have different colour
# (H2) Full set of blocks
# (H4) Line completion animations
# (H5) Tetris music
#
# How to play:
# W- Rotate
# A- Move left
# S- Drop piece
# D- Move right
# Q- Quit
# 
# Link to video demonstration for final submission:
# https://drive.google.com/file/d/1KLz47e2hMeOKPPOOLY3Ld0W40azwyI6J/view?usp=sharing
#
# Are you OK with us sharing the video with people outside course staff?
# Yes
#
# Any additional information that the TA needs to know:
# Not applicable
######################################################################


.data
ADDR_DSPL: .word 0x10008000  # Base address for display
ADDR_KBRD: .word 0xffff0000  # Base address for keyboard
COLOR_GRAY: .word 0x00808080  # Wall color
COLOR_TETROMINO: .word 0x00FF00FF  # Tetromino color
COLOR_BLACK: .word 0x00000000  # Black color for clearing
COLOR_DARK: .word 0x00202020  # Dark grey for checkerboard
current_x: .word 8  # Centered X position (32/2 - 2) = 14 
current_y: .word 1  # Y position
is_vertical: .word 1  # Orientation
playing_field: .space 4096  # Playing field
full_row_message: .asciiz "Row is Full\n"
gravity_counter: .word 0
gravity_threshold: .word 100  # initial fall speed (adjust as needed)
rows_cleared: .word 0
speed_increase_threshold: .word 1  # Increase speed every 10 rows [Make 10 for final]
speed_increase_msg: .asciiz "Speed increased! "
current_threshold_msg: .asciiz "Current gravity threshold: "
newline: .asciiz "\n"
rows_cleared_msg: .asciiz "Total rows cleared: "
music_playing: .word 1
music_threshold: .word 50  #fOR TESTING (higher = slower)
music_counter: .word 0
current_note_index: .word 0
debug_msg: .asciiz "Playing note index: "
debug_pitch: .asciiz ", Pitch: "
debug_duration: .asciiz ", Duration: "
reset_msg: .asciiz "Resetting music to beginning\n"

COLOR_I: .word 0x00000FF  
COLOR_O: .word 0x000FF00 
COLOR_L: .word 0x000FFFF  
COLOR_J: .word 0x0FFFF00 
COLOR_S: .word 0x0FF00FF  
COLOR_Z: .word 0x0FF0000 
COLOR_T: .word 0x0CC00FF 

next_numbers: .word 1 1 1 1


# Music data
notes:
	.byte 66, 0, 61, 62, 64, 0, 62, 61, 59, 0, 59, 62, 66, 0, 64, 62, 61, 0, 61, 62, 64,0, 66, 0, 62, 0, 59,0, 59, 0, 0,
	.byte 64, 0, 67, 71, 0, 69, 67, 66, 0, 0, 62, 66, 0, 64, 62, 61, 0, 61, 62, 64, 0, 66, 0, 62, 0, 59, 0, 59, 0, 0
	.byte 66, 0, 61, 62, 64, 0, 62, 61, 59, 0, 59, 62, 66, 0, 64, 62, 61, 0, 61, 62, 64, 0, 66, 0, 62, 0, 59,0, 59, 0, 0,
	.byte 64, 0, 67, 71, 0, 69, 67, 66, 0, 0, 62, 66, 0, 64, 62, 61, 0, 61, 62, 64, 0, 66, 0, 62, 0, 59, 0, 59, 0, 0
	.byte 66, 0, 0, 62, 0, 0, 64, 0, 0, 61, 0, 0, 62, 0, 0, 59, 0, 0, 58, 0, 0, 61, 0, 0, 66, 0, 0, 62, 0, 0, 64, 0, 0, 61, 0, 0, 62, 0, 66, 0, 71, 0, 0, 70, 0, 0


durations:
	.byte 48, 16, 16, 16, 48, 16, 16, 16, 48, 16, 16, 16, 48, 16, 16, 16, 48, 16, 16, 16, 48, 16, 48, 16, 48, 16, 48, 16, 48, 16, 16, 
	.byte 48, 0, 16, 48, 0, 16, 16, 48, 0, 0, 16, 48, 0, 16, 16, 48, 0, 16, 16, 48, 0, 48, 0, 48, 0, 48, 0, 48, 0, 0
	.byte 48, 16, 16, 16, 48, 16, 16, 16, 48, 16, 16, 16, 48, 16, 16, 16, 48, 16, 16, 16, 48, 16, 48, 16, 48, 16, 48, 16, 48, 16, 16, 
	.byte 48, 0, 16, 48, 0, 16, 16, 48, 0, 0, 16, 48, 0, 16, 16, 48, 0, 16, 16, 48, 0, 48, 0, 48, 0, 48, 0, 48, 0, 0
	.byte 48, 0, 0, 48, 0, 0, 48, 0, 0, 48, 0, 0, 48, 0, 0, 48, 0, 0, 48, 0, 0, 48, 0, 0, 48, 0, 0, 48, 0, 0, 48, 0, 0, 48, 0, 0, 32, 0, 32, 0, 48, 0, 0, 48, 0, 0
 # End marker

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
S_SHAPE: .word 1, -1,		0 ,-1,		0 , 0,		-1 , 0

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
	beq $t2, 16, bottom_done 
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
	li $t0, 0x10008040  		# Start at last column (right border) [Base address + (31 * 4 bytes)]
right_border:
	beq $t2, 32, right_done 
	sw $t3, 0($t0)
	addi $t0, $t0, 128  		# Move to the next row
	addi $t2, $t2, 1
	j right_border
right_done:				#Finished border

jal init_music
li $t0 0
li $t1 12
load_loop:
	bgt $t0 $t1 load_loop_end
	li $v0 42
	li $a1 7
	syscall
	sw $a0 next_numbers($t0)
	addi $t0 $t0 4
	j load_loop
load_loop_end:

jal switch_shape
jal redraw_playing_field
jal draw_shape  			# Draw initial shape
#-------------
#--GAME LOOP--
#-------------
game_loop:
    li $t1, 0xffff0000
    lw $t2, 0($t1)
    bnez $t2, key_pressed  # Check for key press

    # Gravity check
    lw $t0, gravity_counter
    addi $t0, $t0, 1
    sw $t0, gravity_counter
    
    lw $t1, gravity_threshold
    blt $t0, $t1, skip_gravity
    
    # Reset counter and move piece down
    sw $zero, gravity_counter
    jal clear_shape
    jal move_down
    j skip_key_handling

key_pressed:
    lw $t3, 4($t1)
    beq $t3, 0x61, move_left    # 'a' key
    beq $t3, 0x64, move_right   # 'd' key
    beq $t3, 0x73, move_down    # 's' key
    beq $t3, 0x77, rotate       # 'w' key
    beq $t3, 0x71, quit         # 'q' key

skip_key_handling:
skip_gravity:
    jal draw_shape

    jal play_music

    # Sleep for a short time
    li $v0, 32
    li $a0, 4  # Sleep for 4ms (adjust if u want ngl)
    syscall

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
	li $v0, 31
    	li $a0 40 # pitch
  	li $a1 80 # duration (20 ms per duration unit)
  	li $a2, 80  # instrument
  	li $a3, 60  # volume
    	syscall 
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
	li $v0, 31
    	li $a0 30  # pitch
  	li $a1 120 # duration (20 ms per duration unit)
  	li $a2, 80  # instrument
  	li $a3, 80  # volume
  	syscall 
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
	li $v0, 31
    	li $a0 30 # pitch
  	li $a1 60 # duration (20 ms per duration unit)
  	li $a2, 100  # instrument
  	li $a3, 80  # volume
  	syscall
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
	li $v0, 31
    	li $a0 70 # pitch
  	li $a1 100 # duration (20 ms per duration unit)
  	li $a2, 40  # instrument
  	li $a3, 60  # volume
    	syscall 
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
	li $t0, 8  # Reset X position to center
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
		
		li $t8 60
		
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
	
#Draws the current shape onto the board as a falling block
#Also draw an outline
draw_shape: 
	#load display
	la $t8 COLOR_TETROMINO
	lw $t8 0($t8)
	li $t6 32
	
	li $t0 0
	
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
		#check game over
		lw $t9 playing_field($t1)
		bgtz $t9 game_over
		#display pixel
		la $t9 ADDR_DSPL
		lw $t9 0($t9)
		add $t1 $t1 $t9
		sw $t8 0($t1)		
		addi $t0 $t0 8			#i ++
	j draw_loop_start
	draw_loop_end: jr $ra		#return

#Clear screen when game over
game_over:
	jal clear_screen
	li $v0, 31
    	li $a0 50 # pitch
  	li $a1 500 # duration (20 ms per duration unit)
  	li $a2, 80  # instrument
  	li $a3, 60  # volume
    	syscall 
    	li $v0, 32
    	li $a0, 450  # Sleep for 4ms (adjust if u want ngl)
   	syscall
   	li $v0, 31
    	li $a0 40 # pitch
  	li $a1 500 # duration (20 ms per duration unit)
  	li $a2, 80  # instrument
  	li $a3, 60  # volume
    	syscall 
	game_over_loop:
	j game_over_loop

#Clears the current falling block
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
	jal switch_shape
	jal draw_shape
	jal check_full_rows
	
	# Print rows cleared message
	li $v0, 4
	la $a0, rows_cleared_msg
	syscall
	
	# Print number of rows cleared
	li $v0, 1
	lw $a0, rows_cleared
	syscall
	
	# Print newline
	li $v0, 4
	la $a0, newline
	syscall
	
	li $v0, 31
    	li $a0 60 # pitch
  	li $a1 60 # duration (20 ms per duration unit)
  	li $a2, 200  # instrument
  	li $a3, 106  # volume
  	syscall
	jal check_speed_increase 
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



#redraw the field
redraw_playing_field:
	la $t0, playing_field
	la $t1, ADDR_DSPL
	lw $t1, 0($t1)
	li $t2, 0 #counter
	li $t9  4096
	li $t8 128
	
	la $s6 COLOR_DARK
	lw $s6 0($s6)
	redraw_loop:
	
		
		bgt $t2 $t9 redraw_loop_end
		div $t2 $t8
		mflo $t4 #y
		mfhi $t3 #x
		
		beqz $t3 redraw_loop_continue
		li $t7 64
		beq $t3 $t7 redraw_loop_continue
		li $t7 31
		beq $t4 $t7 redraw_loop_continue
		
		lw $t7 playing_field($t2)
		add $t6 $t2 $t1
		beqz $t7 redraw_background
		sw $t7 0($t6)
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
	
check_full_rows:
li $s7 0#rows cleared so far
    li $t0, 30  # Start is the second to last row
    li $t1, 0   # Counter telling the  removed rows
check_line_loop:
    li $t2, 1
    li $t3, 15
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
    
    # Increment rows_cleared counter
    lw $t8, rows_cleared
    addi $t8, $t8, 1
    sw $t8, rows_cleared
    
    jal remove_row
    addi $s7 $s7 -1
    #jal redraw_playing_field
    
    addi $t1, $t1, 1
    j check_line_loop  # Check the same row again
row_not_full:
    addi $t0, $t0, -1
    bgez $t0, check_line_loop
    
    # redraw the field if removed 
    beqz $t1, end_check
    jal redraw_playing_field
end_check:
    j check_speed_increase

remove_row:
    move $t6, $t0  # Current row to remove
    add $s2 $t6 $s7
    li $t2 1
	la $t9, ADDR_DSPL
	lw $t9, 0($t9)
	
    li $v0, 31
    li $a0 64  # pitch
    li $a1 300 # duration (20 ms per duration unit)
    li $a2, 80  # instrument
    li $a3, 80  # volume 
    syscall
    remove_animation_loop:
	
        mul $t4, $s2, 32
        add $t4, $t4, $t2
        sll $t4, $t4, 2
        lw $t7, COLOR_GRAY($zero)
        add $t4 $t4 $t9
        sw $t7, 0($t4)
        
	addi $t2 $t2 1
 	   # Sleep for a short time
 	li $v0, 32
    	li $a0, 6  # Sleep for 4ms (adjust if u want ngl)
   	syscall
	ble $t2 $t3 remove_animation_loop

    li $t2 1
    remove_animation_loop2:
	
        mul $t4, $s2, 32
        add $t4, $t4, $t2
        sll $t4, $t4, 2
        add $t4 $t4 $t9
        sw $zero, 0($t4)
        
	addi $t2 $t2 1
	
	
 	   # Sleep for a short time
 	li $v0, 32
    	li $a0, 6  # Sleep for 4ms (adjust if u want ngl)
   	syscall
	ble $t2 $t3 remove_animation_loop2
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

check_speed_increase:
    lw $t0, rows_cleared
    lw $t1, speed_increase_threshold
    blt $t0, $t1, speed_check_end  # If rows cleared < threshold, don't change speed

    # Increase speed
    lw $t0, gravity_threshold
    mul $t0, $t0, 90   # Decrease threshold by 10%
    div $t0, $t0, 100

    # Ensure we don't go below the minimum threshold
    li $t3, 10  # Minimum threshold
    blt $t0, $t3, set_min_threshold
    j store_threshold

set_min_threshold:
    li $t0, 10

store_threshold:
    sw $t0, gravity_threshold

    # Reset rows_cleared by subtracting the threshold
    lw $t2, rows_cleared
    sub $t2, $t2, $t1
    sw $t2, rows_cleared

    li $v0, 1
    move $a0, $t0
    syscall

    # Print newline
    li $v0, 4
    la $a0, newline
    syscall

speed_check_end:
    j game_loop

#####################################################################

# Add these new functions
init_music:
    sw $zero, current_note_index  # Start from the first note
    sw $zero, music_counter  # Initialize music counter
    jr $ra
    
play_music:
    lw $t9, music_playing
    beqz $t9, music_done  # If music_playing is 0, skip playing music

    # add music counter
    lw $t9, music_counter
    addi $t9, $t9, 1
    sw $t9, music_counter

    # Check if we should play a note
    lw $t8, music_threshold
    blt $t9, $t8, music_done

    # Reset music counter
    sw $zero, music_counter

    lw $t0, current_note_index

    # Check if we've reached the end of the song
    li $t4, 168   # Total number of notes
    bge $t0, $t4, reset_music

    # Load note
    la $t1, notes
    add $t1, $t1, $t0
    lb $t2, ($t1)  # Load note

    # Check for end marker
    li $t4, 255
    beq $t2, $t4, reset_music

    # Load duration
    la $t1, durations
    add $t1, $t1, $t0
    lb $t3, ($t1)  # Load duration

    # Play the note
    li $v0, 31
    move $a0, $t2  # pitch
    li $t5, 20
    mul $a1, $t3, $t5  # duration (20 ms per duration unit)
    li $a2, 96  # instrument (piano)
    li $a3, 64  # volume 
    syscall

    # Move to next note
    addi $t0, $t0, 1
    sw $t0, current_note_index

    j music_done

reset_music:
    sw $zero, current_note_index
    # Print reset message
    li $v0, 4
    la $a0, reset_msg
    syscall

music_done:
    jr $ra

#####################################################################

#-----------------------
#--Switch shape--
#-Switch shape to a new shape
switch_shape:
	
	
	#li $v0 40
	#li $a0 50
	#li $a1 15
	#syscall
	
	li $v0 42
	li $a1 7
	syscall
	li $t0 0
	li $t5 8
	lw $t1 next_numbers($zero)
	move_front_loop:
		bgt $t0 $t5 move_front_loop_end
		addi $t2 $t0 4
		lw $t3 next_numbers($t2)
		sw $t3 next_numbers($t0)
		addi $t0 $t0 4
		j move_front_loop
	move_front_loop_end:
	sw $a0 next_numbers($t0)
	
	li $t0 0
	li $t2 32
	switch_loop:
	bge $t0 $t2 switch_loop_end
	#Jump to correct number
	li $t3 0
	beq $t3 $t1 switch_I
	li $t3 1
	beq $t3 $t1 switch_O
	li $t3 2
	beq $t3 $t1 switch_J
	li $t3 3
	beq $t3 $t1 switch_L
	li $t3 4
	beq $t3 $t1 switch_Z
	li $t3 5
	beq $t3 $t1 switch_S
	li $t3 6
	beq $t3 $t1 switch_T
	#Switch jump
	switch_I: 
		lw $t4 I_SHAPE($t0)
		sw $t4 current_shape($t0)
		lw $t4 COLOR_I($zero)
		sw $t4 COLOR_TETROMINO($zero)
		j switch_loop_continue
	switch_O:
		lw $t4 O_SHAPE($t0)
		sw $t4 current_shape($t0)
		lw $t4 COLOR_O($zero)
		sw $t4 COLOR_TETROMINO($zero)
		j switch_loop_continue
	switch_J:
		lw $t4 J_SHAPE($t0)
		sw $t4 current_shape($t0)
		lw $t4 COLOR_J($zero)
		sw $t4 COLOR_TETROMINO($zero)
		j switch_loop_continue
	switch_L:
		lw $t4 L_SHAPE($t0)
		sw $t4 current_shape($t0)
		
		lw $t4 COLOR_L($zero)
		sw $t4 COLOR_TETROMINO($zero)
		j switch_loop_continue
	switch_Z:
		lw $t4 Z_SHAPE($t0)
		sw $t4 current_shape($t0)
		lw $t4 COLOR_Z($zero)
		sw $t4 COLOR_TETROMINO($zero)
		j switch_loop_continue
	switch_S:
		lw $t4 S_SHAPE($t0)
		sw $t4 current_shape($t0)
		lw $t4 COLOR_S($zero)
		sw $t4 COLOR_TETROMINO($zero)
		j switch_loop_continue
	switch_T:
		lw $t4 T_SHAPE($t0)
		sw $t4 current_shape($t0)
		lw $t4 COLOR_T($zero)
		sw $t4 COLOR_TETROMINO($zero)
		j switch_loop_continue
	switch_loop_continue:
	addi $t0 $t0 4
	j switch_loop
	switch_loop_end:
	jr $ra

quit: 
    # Stop the music
    sw $zero, music_playing

    # Stop all sound
    li $v0, 31
    li $a0, 0   # pitch (0 to stop all sound)
    li $a1, 0   # duration
    li $a2, 0   # instrument
    li $a3, 0   # volume
    syscall

    # Exit the program
    li $v0, 10
    syscall
