.data
ADDR_DSPL: .word 0x10008000  # Base address for display
ADDR_KBRD: .word 0xffff0000  # Base address for keyboard
COLOR_GRAY: .word 0x00808080  # Wall color
COLOR_TETROMINO: .word 0x00FF00FF  # Tetromino color
COLOR_BLACK: .word 0x00000000  # Black color for clearing
I_TETROMINO: .word 0x0000000F, 0x00000000, 0x00000000, 0x00000000  # Tetromino shape
current_tetromino: .word 0x0000000F, 0x00000000, 0x00000000, 0x00000000  # Current tetromino
current_x: .word 14  # Centered X position (32/2 - 2) = 14 
current_y: .word 1  # Y position
is_vertical: .word 1  # Orientation
playing_field: .space 4096  # Playing field

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
    la $t0, ADDR_DSPL
    lw $t0, 0($t0)
    la $t3, COLOR_GRAY
    lw $t3, 0($t3)
    jal clear_screen
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
    li $t0, 0x1000807C  # Start at last column (right border) [Base address + (31 * 4 bytes)]
right_border:
    beq $t2, 32, right_done 
    sw $t3, 0($t0)
    addi $t0, $t0, 128  # Move to the next row
    addi $t2, $t2, 1
    j right_border
right_done:

    jal draw_shape  # Draw initial tetromino

game_loop:
    li $t1, 0xffff0000
    lw $t2, 0($t1)
    beq $t2, $zero, game_loop  # Check for key press

    lw $t3, 4($t1)
    beq $t3, 0x61, move_left     # 'a' key
    beq $t3, 0x64, move_right    # 'd' key
    beq $t3, 0x73, move_down     # 's' key
    beq $t3, 0x77, rotate        # 'w' key
    beq $t3, 0x71, quit        # 'q' key
	
    j game_loop

move_left:  # Move tetromino left
    jal clear_shape
    jal can_move_left
    beq $v0, $zero, end_move
    lw $t0, current_x
    addi $t0, $t0, -1
    sw $t0, current_x
    j end_move

move_right:  # Move tetromino right
    jal clear_shape
    jal can_move_right
    beq $v0, $zero, end_move
    lw $t0, current_x
    addi $t0, $t0, 1
    sw $t0, current_x
    j end_move

move_down:
    jal clear_shape
    jal can_move_down
    beq $v0, $zero, tetromino_landed
    lw $t0, current_y
    addi $t0, $t0, 1
    sw $t0, current_y
    j end_move

#clear the screen
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


generate_new_tetromino:
    li $t0, 14  # Reset X position to center
    sw $t0, current_x
    li $t0, 1   # Reset Y position to top
    sw $t0, current_y
    li $t0, 1   # Reset rotation
    sw $zero, rotation
    jr $ra

tetromino_landed:
    jal add_to_playing_field
    jal redraw_playing_field
    jal generate_new_tetromino

end_move:
    jal draw_shape
    j game_loop

add_to_playing_field:
    	li $t0 0
	la $t8 COLOR_TETROMINO
	lw $t8 0($t8)
	li $t6 32
	add_loop_start:
	bge $t0 $t6 add_loop_end
	add_loop: 
	#LOAD x and y values
	lw $t1 current_shape($t0)
	addi $t5 $t0 4
	lw $t2 current_shape($t5)
	lw $t5 rotation($zero)
		#for each rotation, rotate it once
		add_rotate_loop_start:
			beqz $t5 add_rotate_loop_end
		add_rotate_loop: 
			sub $t3 $zero $t2
			add $t4 $zero $t1
			addi $t5 $t5 -1
			move $t1 $t3
			move $t2 $t4
			j add_rotate_loop_start
		add_rotate_loop_end:
		#By this point, our segment is rotated in place, now we will draw
	lw $t3 current_x
	lw $t4 current_y
	#multiply by 4 and 7 respectively, to match addresses
	sll $t1 $t1 2
	sll $t2 $t2 7
	#do same for cx and cy
	sll $t3 $t3 2
	sll $t4 $t4 7
	#sum it together
	add $t1 $t1 $t2
	add $t3 $t3 $t4
	add $t1 $t1 $t3
	#add to playing field
	sw $t8 playing_field($t1)
	#increase counter
	addi $t0 $t0 8
	j add_loop_start
	add_loop_end:
	#retrun
	#TODO: replace with stack lol
	jr $ra

rotate:  # Rotate tetromino
    jal clear_shape
    jal can_rotate
    beq $v0, $zero, end_move  # Do not rotate if can_rotate returns zero
    lw $t0, rotation
    addi $t0, $t0, 1
    li $t1 3
    ble $t0 $t1 pass_rotation
    #If rotation too large, subtract
    subi $t0 $t0 4
    pass_rotation: 
    sw $t0, rotation
    j end_move


#NEW DRAW FUNCTION: This will draw the current shape regardless of type
draw_shape: 
	li $t0 0
	#load display
	la $t8 COLOR_TETROMINO
	lw $t8 0($t8)
	li $t6 32
	draw_loop_start:
	bge $t0 $t6 draw_loop_end
	draw_loop: 
	#LOAD x and y values
	lw $t1 current_shape($t0)
	addi $t5 $t0 4
	lw $t2 current_shape($t5)
	lw $t5 rotation($zero)
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
	#multiply by 4 and 7 respectively, to match addresses
	sll $t1 $t1 2
	sll $t2 $t2 7
	#do same for cx and cy
	sll $t3 $t3 2
	sll $t4 $t4 7
	#sum it together
	add $t1 $t1 $t2
	add $t3 $t3 $t4
	add $t1 $t1 $t3
	#display pixel
	la $t9 ADDR_DSPL
	lw $t9 0($t9)
	add $t1 $t1 $t9
	sw $t8 0($t1)
	#increase counter
	addi $t0 $t0 8
	j draw_loop_start
	draw_loop_end:
	#retrun
	#TODO: replace with stack lol
	jr $ra

clear_shape: 
	li $t0 0
	#load display
	li $t6 32
	draw_loop_start2:
	bge $t0 $t6 draw_loop_end2
	draw_loop2: 
	#LOAD x and y values
	lw $t1 current_shape($t0)
	addi $t5 $t0 4
	lw $t2 current_shape($t5)
	lw $t5 rotation($zero)
		#for each rotation, rotate it once
		rotate_loop_start2:
			beqz $t5 rotate_loop_end2
		rotate_loop2: 
			sub $t3 $zero $t2
			add $t4 $zero $t1
			addi $t5 $t5 -1
			move $t1 $t3
			move $t2 $t4
			j rotate_loop_start2
		rotate_loop_end2:
		#By this point, our segment is rotated in place, now we will draw
	lw $t3 current_x
	lw $t4 current_y
	#multiply by 4 and 7 respectively, to match addresses
	sll $t1 $t1 2
	sll $t2 $t2 7
	#do same for cx and cy
	sll $t3 $t3 2
	sll $t4 $t4 7
	#sum it together
	add $t1 $t1 $t2
	add $t3 $t3 $t4
	add $t1 $t1 $t3
	#display pixel
	la $t9 ADDR_DSPL
	lw $t9 0($t9)
	add $t1 $t1 $t9
	sw $zero 0($t1)
	#increase counter
	addi $t0 $t0 8
	j draw_loop_start2
	draw_loop_end2:
	#retrun
	#TODO: replace with stack lol
	jr $ra

can_move_left:  # Check if tetromino can move left
    la $t0, current_tetromino
    lw $t1, current_x
    lw $t2, current_y
    lw $t3, is_vertical
    li $t4, 0x0000000F
    beq $t3, $zero, check_horizontal_left
check_vertical_left:
    andi $t5, $t4, 0x1
    beqz $t5, skip_check_left1
    sub $t6, $t1, 1
    blt $t6, 1, cannot_move_left   # Left wall limit
    mul $t7, $t2, 128
    mul $t8, $t6, 4
    add $t7, $t7, $t8
    la $t9, playing_field
    add $t7, $t7, $t9
    lw $t8, 0($t7)
    bne $t8, $zero, cannot_move_left
skip_check_left1:
    addi $t2, $t2, 1
    srl $t4, $t4, 1
    bnez $t4, check_vertical_left
    li $v0, 1
    jr $ra

check_horizontal_left:
    li $t4, 0x0000000F
check_horizontal_left_loop:
    andi $t5, $t4, 0x1
    beqz $t5, skip_check_left2
    sub $t6, $t1, 1
    blt $t6, 1, cannot_move_left   # Left wall limit
    mul $t7, $t2, 128
    mul $t8, $t6, 4
    add $t7, $t7, $t8
    la $t9, playing_field
    add $t7, $t7, $t9
    lw $t8, 0($t7)
    bne $t8, $zero, cannot_move_left
skip_check_left2:
    addi $t1, $t1, 1
    srl $t4, $t4, 1
    bnez $t4, check_horizontal_left_loop
    li $v0, 1
    jr $ra

cannot_move_left:
    li $v0, 0
    jr $ra

can_move_right:  # Check if tetromino can move right
    la $t0, current_tetromino
    lw $t1, current_x
    lw $t2, current_y
    lw $t3, is_vertical
    li $t4, 0x0000000F
    beq $t3, $zero, check_horizontal_right
check_vertical_right:
    andi $t5, $t4, 0x1
    beqz $t5, skip_check_right1
    add $t6, $t1, 1
    bge $t6, 32, cannot_move_right  # Right wall limit
    mul $t7, $t2, 128
    mul $t8, $t6, 4
    add $t7, $t7, $t8
    la $t9, playing_field
    add $t7, $t7, $t9
    lw $t8, 0($t7)
    bne $t8, $zero, cannot_move_right
skip_check_right1:
    addi $t2, $t2, 1
    srl $t4, $t4, 1
    bnez $t4, check_vertical_right
    li $v0, 1
    jr $ra

check_horizontal_right:
    li $t4, 0x0000000F
check_horizontal_right_loop:
    andi $t5, $t4, 0x1
    beqz $t5, skip_check_right2
    add $t6, $t1, 1
    bge $t6, 31, cannot_move_right  # Right wall limit
    mul $t7, $t2, 128
    mul $t8, $t6, 4
    add $t7, $t7, $t8
    la $t9, playing_field
    add $t7, $t7, $t9
    lw $t8, 0($t7)
    bne $t8, $zero, cannot_move_right
skip_check_right2:
    addi $t1, $t1, 1
    srl $t4, $t4, 1
    bnez $t4, check_horizontal_right_loop
    li $v0, 1
    jr $ra

cannot_move_right:
    li $v0, 0
    jr $ra

can_move_down:  # Check if tetromino can move down
    la $t0, current_tetromino
    lw $t1, current_x
    lw $t2, current_y
    lw $t3, is_vertical
    li $t4, 0x0000000F
    beq $t3, $zero, check_horizontal_down
check_vertical_down:
    andi $t5, $t4, 0x1
    beqz $t5, skip_check_down1
    add $t6, $t2, 1
    bge $t6, 31, cannot_move_down  # Bottom limit
    mul $t7, $t6, 128
    mul $t8, $t1, 4
    add $t7, $t7, $t8
    la $t9, playing_field
    add $t7, $t7, $t9
    lw $t8, 0($t7)
    bne $t8, $zero, cannot_move_down
skip_check_down1:
    addi $t2, $t2, 1
    srl $t4, $t4, 1
    bnez $t4, check_vertical_down
    li $v0, 1
    jr $ra

check_horizontal_down:
    li $t4, 0x0000000F
check_horizontal_down_loop:
    andi $t5, $t4, 0x1
    beqz $t5, skip_check_down2
    add $t6, $t2, 1
    bge $t6, 31, cannot_move_down  # Bottom limit
    mul $t7, $t6, 128
    mul $t8, $t1, 4
    add $t7, $t7, $t8
    la $t9, playing_field
    add $t7, $t7, $t9
    lw $t8, 0($t7)
    bne $t8, $zero, cannot_move_down
skip_check_down2:
    addi $t1, $t1, 1
    srl $t4, $t4, 1
    bnez $t4, check_horizontal_down_loop
    li $v0, 1
    jr $ra

cannot_move_down:
    li $v0, 0
    jr $ra

can_rotate:  # Check if tetromino can rotate without collision
    la $t0, ADDR_DSPL
    lw $t0, 0($t0)
    la $t1, COLOR_GRAY
    lw $t1, 0($t1)
    lw $t3, current_x
    lw $t4, current_y
    lw $t5, is_vertical
    xori $t5, $t5, 1  # Toggle (o or 1) to check the rotated state
    li $t6, 0x0000000F

    beq $t5, $zero, check_horizontal_rotate
check_vertical_rotate:
    andi $t7, $t6, 0x1
    beqz $t7, skip_check_rotate1
    mul $t8, $t4, 128
    mul $t9, $t3, 4
    add $t8, $t0, $t8
    add $t8, $t8, $t9
    lw $t2, 0($t8)
    beq $t2, $t1, cannot_rotate  # Collision with gray (wall)
skip_check_rotate1:
    addi $t4, $t4, 1
    srl $t6, $t6, 1
    bnez $t6, check_vertical_rotate
    li $v0, 1
    jr $ra

check_horizontal_rotate:
    li $t6, 0x0000000F
check_horizontal_rotate_loop:
    andi $t7, $t6, 0x1
    beqz $t7, skip_check_rotate2
    mul $t8, $t4, 128
    mul $t9, $t3, 4
    add $t8, $t0, $t8
    add $t8, $t8, $t9
    lw $t2, 0($t8)
    beq $t2, $t1, cannot_rotate  # Collision with gray (wall)
skip_check_rotate2:
    addi $t3, $t3, 1
    srl $t6, $t6, 1
    bnez $t6, check_horizontal_rotate_loop
    li $v0, 1
    jr $ra

cannot_rotate:
    li $v0, 0
    jr $ra

perform_rotation:  # Do 180-degree rotation
    lw $t0, current_x
    lw $t1, current_y
    lw $t2, is_vertical
    xori $t2, $t2, 1
    sw $t2, is_vertical
    beq $t2, $zero, rotate_horizontal_to_vertical
rotate_vertical_to_horizontal:
    addi $t0, $t0, 1
    addi $t1, $t1, -2
    j end_perform_rotation
rotate_horizontal_to_vertical:
    addi $t0, $t0, -1
    addi $t1, $t1, 2
end_perform_rotation:
    sw $t0, current_x
    sw $t1, current_y
    jr $ra

#redraw the field
redraw_playing_field:
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
    addi $t3, $t3, 1
    blt $t3, 32, redraw_field_loop_col
    addi $t2, $t2, 1
    blt $t2, 32, redraw_field_loop_row
    jr $ra


quit: 
    li $v0 10
    syscall
