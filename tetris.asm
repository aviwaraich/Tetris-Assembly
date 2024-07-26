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

.text
.globl main

main:
    la $t0, ADDR_DSPL
    lw $t0, 0($t0)
    la $t3, COLOR_GRAY
    lw $t3, 0($t3)

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

    jal draw_tetromino  # Draw initial tetromino

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
    jal clear_tetromino
    jal can_move_left
    beq $v0, $zero, end_move_left
    lw $t0, current_x
    addi $t0, $t0, -1
    sw $t0, current_x
end_move_left:
    jal draw_tetromino
    j game_loop

move_right:  # Move tetromino right
    jal clear_tetromino
    jal can_move_right
    beq $v0, $zero, end_move_right
    lw $t0, current_x
    addi $t0, $t0, 1
    sw $t0, current_x
end_move_right:
    jal draw_tetromino
    j game_loop

move_down:  # Move tetromino down
    jal clear_tetromino
    jal can_move_down
    beq $v0, $zero, end_move_down
    lw $t0, current_y
    addi $t0, $t0, 1
    sw $t0, current_y
end_move_down:
    jal draw_tetromino
    j game_loop

rotate:  # Rotate tetromino
    jal clear_tetromino
    jal can_rotate
    beq $v0, $zero, end_rotate  # Do not rotate if can_rotate returns zero
    jal perform_rotation
end_rotate:
    jal draw_tetromino
    j game_loop

draw_tetromino:  # Draw tetromino on screen
    la $t0, ADDR_DSPL
    lw $t0, 0($t0)
    la $t1, COLOR_TETROMINO
    lw $t1, 0($t1)
    lw $t3, current_x
    lw $t4, current_y
    lw $t5, is_vertical
    li $t6, 0x0000000F

    beq $t5, $zero, draw_horizontal
draw_vertical:
    andi $t7, $t6, 0x1
    beqz $t7, skip_block1
    mul $t8, $t4, 128
    mul $t9, $t3, 4
    add $t8, $t0, $t8
    add $t8, $t8, $t9
    sw $t1, 0($t8)
skip_block1:
    addi $t4, $t4, 1
    srl $t6, $t6, 1
    bnez $t6, draw_vertical
    jr $ra

draw_horizontal:
    li $t6, 0x0000000F
draw_horizontal_loop:
    andi $t7, $t6, 0x1
    beqz $t7, skip_block2
    mul $t8, $t4, 128
    mul $t9, $t3, 4
    add $t8, $t0, $t8
    add $t8, $t8, $t9
    sw $t1, 0($t8)
skip_block2:
    addi $t3, $t3, 1
    srl $t6, $t6, 1
    bnez $t6, draw_horizontal_loop
    jr $ra

clear_tetromino:  # Clear tetromino from screen
    la $t0, ADDR_DSPL
    lw $t0, 0($t0)
    la $t1, COLOR_BLACK
    lw $t1, 0($t1)
    lw $t3, current_x
    lw $t4, current_y
    lw $t5, is_vertical
    li $t6, 0x0000000F

    beq $t5, $zero, clear_horizontal
clear_vertical:
    andi $t7, $t6, 0x1
    beqz $t7, skip_clear_block1
    mul $t8, $t4, 128
    mul $t9, $t3, 4
    add $t8, $t0, $t8
    add $t8, $t8, $t9
    sw $t1, 0($t8)
skip_clear_block1:
    addi $t4, $t4, 1
    srl $t6, $t6, 1
    bnez $t6, clear_vertical
    jr $ra

clear_horizontal:
    li $t6, 0x0000000F
clear_horizontal_loop:
    andi $t7, $t6, 0x1
    beqz $t7, skip_clear_block2
    mul $t8, $t4, 128
    mul $t9, $t3, 4
    add $t8, $t0, $t8
    add $t8, $t8, $t9
    sw $t1, 0($t8)
skip_clear_block2:
    addi $t3, $t3, 1
    srl $t6, $t6, 1
    bnez $t6, clear_horizontal_loop
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


quit: 
    li $v0 10
    syscall
