.data
ADDR_DSPL: .word 0x10008000 # Base address for display
ADDR_KBRD: .word 0xffff0000 # Base address for keyboard
COLOR_GRAY: .word 0x00808080 # Wall color
COLOR_TETROMINO: .word 0x00FF00FF # Tetromino color
COLOR_BLACK: .word 0x00000000 # Black color for clearing
current_tetromino: .word 0x0000000F # Current tetromino (4 blocks)
current_x: .word 14 # Centered X position
current_y: .word 1 # Y position
is_vertical: .word 1 # Orientation
.align 2
playing_field: .space 4096 # Playing field (32 * 32 * 4 bytes)

.text
.globl main

main:
    jal clear_screen
    jal draw_borders
    jal generate_new_tetromino
    jal draw_tetromino

game_loop:
    li $t1, 0xffff0000
    lw $t2, 0($t1)
    beq $t2, $zero, game_loop # Check for key press

    lw $t3, 4($t1)
    beq $t3, 0x61, move_left  # 'a' key
    beq $t3, 0x64, move_right # 'd' key
    beq $t3, 0x73, move_down  # 's' key
    beq $t3, 0x77, rotate     # 'w' key
    beq $t3, 0x71, quit       # 'q' key

    j game_loop

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

draw_borders:
    la $t0, ADDR_DSPL
    lw $t0, 0($t0)
    la $t3, COLOR_GRAY
    lw $t3, 0($t3)

    # Draw top and bottom borders
    li $t1, 0
    move $t4, $t0
    addi $t5, $t0, 3968
top_bottom_border:
    sw $t3, 0($t4)
    sw $t3, 0($t5)
    addi $t4, $t4, 4
    addi $t5, $t5, 4
    addi $t1, $t1, 1
    blt $t1, 32, top_bottom_border

    # Draw left and right borders
    li $t1, 0
    move $t4, $t0
    addi $t5, $t0, 124
left_right_border:
    sw $t3, 0($t4)
    sw $t3, 0($t5)
    addi $t4, $t4, 128
    addi $t5, $t5, 128
    addi $t1, $t1, 1
    blt $t1, 32, left_right_border

    jr $ra

move_left:
    jal clear_tetromino
    jal can_move_left
    beq $v0, $zero, end_move
    lw $t0, current_x
    addi $t0, $t0, -1
    sw $t0, current_x
    j end_move

move_right:
    jal clear_tetromino
    jal can_move_right
    beq $v0, $zero, end_move
    lw $t0, current_x
    addi $t0, $t0, 1
    sw $t0, current_x
    j end_move

move_down:
    jal clear_tetromino
    jal can_move_down
    beq $v0, $zero, tetromino_landed
    lw $t0, current_y
    addi $t0, $t0, 1
    sw $t0, current_y
    j end_move

tetromino_landed:
    jal add_to_playing_field
    jal generate_new_tetromino

end_move:
    jal redraw_playing_field
    jal draw_tetromino
    j game_loop

rotate:
    jal clear_tetromino
    jal can_rotate
    beq $v0, $zero, end_move
    jal perform_rotation
    j end_move

draw_tetromino:
    la $t0, ADDR_DSPL
    lw $t0, 0($t0)
    la $t1, COLOR_TETROMINO
    lw $t1, 0($t1)
    lw $t3, current_x
    lw $t4, current_y
    lw $t5, is_vertical
    li $t6, 0x0000000F  # 4-block tetromino

    beq $t5, $zero, draw_horizontal
draw_vertical:
    li $t7, 0
draw_vertical_loop:
    andi $t8, $t6, 0x1
    beqz $t8, skip_block1
    mul $t8, $t4, 128
    add $t8, $t8, $t7
    mul $t9, $t3, 4
    add $t8, $t8, $t9
    add $t8, $t0, $t8
    sw $t1, 0($t8)
skip_block1:
    addi $t7, $t7, 128
    srl $t6, $t6, 1
    bnez $t6, draw_vertical_loop
    jr $ra

draw_horizontal:
    li $t7, 0
draw_horizontal_loop:
    andi $t8, $t6, 0x1
    beqz $t8, skip_block2
    mul $t8, $t4, 128
    mul $t9, $t3, 4
    add $t9, $t9, $t7
    add $t8, $t8, $t9
    add $t8, $t0, $t8
    sw $t1, 0($t8)
skip_block2:
    addi $t7, $t7, 4
    srl $t6, $t6, 1
    bnez $t6, draw_horizontal_loop
    jr $ra

clear_tetromino:
    la $t0, ADDR_DSPL
    lw $t0, 0($t0)
    la $t1, COLOR_BLACK
    lw $t1, 0($t1)
    lw $t3, current_x
    lw $t4, current_y
    lw $t5, is_vertical
    li $t6, 0x0000000F  # 4-block tetromino

    beq $t5, $zero, clear_horizontal
clear_vertical:
    li $t7, 0
clear_vertical_loop:
    andi $t8, $t6, 0x1
    beqz $t8, skip_clear_block1
    mul $t8, $t4, 128
    add $t8, $t8, $t7
    mul $t9, $t3, 4
    add $t8, $t8, $t9
    add $t8, $t0, $t8
    sw $t1, 0($t8)
skip_clear_block1:
    addi $t7, $t7, 128
    srl $t6, $t6, 1
    bnez $t6, clear_vertical_loop
    jr $ra

clear_horizontal:
    li $t7, 0
clear_horizontal_loop:
    andi $t8, $t6, 0x1
    beqz $t8, skip_clear_block2
    mul $t8, $t4, 128
    mul $t9, $t3, 4
    add $t9, $t9, $t7
    add $t8, $t8, $t9
    add $t8, $t0, $t8
    sw $t1, 0($t8)
skip_clear_block2:
    addi $t7, $t7, 4
    srl $t6, $t6, 1
    bnez $t6, clear_horizontal_loop
    jr $ra

can_move_left:
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
    blt $t6, 1, cannot_move_left
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
    blt $t6, 1, cannot_move_left
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

can_move_right:
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
    bge $t6, 31, cannot_move_right
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
    bge $t6, 31, cannot_move_right
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

can_move_down:
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
    bge $t6, 31, cannot_move_down
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
    bge $t6, 31, cannot_move_down
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

can_rotate:
    lw $t0, current_x
    lw $t1, current_y
    lw $t2, is_vertical
    li $t3, 0x0000000F  # 4-block tetromino

    beq $t2, $zero, check_horizontal_to_vertical
    
check_vertical_to_horizontal:
    addi $t0, $t0, -1  # Adjust for rotation point
    li $t4, 0  # Counter
check_v_to_h_loop:
    add $t5, $t0, $t4  # New x position
    blt $t5, 1, cannot_rotate    # Check left wall
    bge $t5, 31, cannot_rotate   # Check right wall
    
    mul $t6, $t1, 128   # y * 128
    mul $t7, $t5, 4     # x * 4
    add $t6, $t6, $t7   # (y * 128) + (x * 4)
    la $t7, playing_field
    add $t6, $t6, $t7
    lw $t7, 0($t6)
    bnez $t7, cannot_rotate  # Check if space is occupied
    
    addi $t4, $t4, 1
    blt $t4, 4, check_v_to_h_loop
    j can_rotate_end

check_horizontal_to_vertical:
    addi $t1, $t1, -1  # Adjust for rotation point
    li $t4, 0  # Counter
check_h_to_v_loop:
    add $t5, $t1, $t4  # New y position
    blt $t5, 1, cannot_rotate    # Check top wall
    bge $t5, 31, cannot_rotate   # Check bottom wall
    
    mul $t6, $t5, 128   # y * 128
    mul $t7, $t0, 4     # x * 4
    add $t6, $t6, $t7   # (y * 128) + (x * 4)
    la $t7, playing_field
    add $t6, $t6, $t7
    lw $t7, 0($t6)
    bnez $t7, cannot_rotate  # Check if space is occupied
    
    addi $t4, $t4, 1
    blt $t4, 4, check_h_to_v_loop

can_rotate_end:
    li $v0, 1  # Can rotate
    jr $ra

cannot_rotate:
    li $v0, 0  # Cannot rotate
    jr $ra

perform_rotation:
    lw $t0, current_x
    lw $t1, current_y
    lw $t2, is_vertical
    xori $t2, $t2, 1
    sw $t2, is_vertical
    beq $t2, $zero, rotate_to_horizontal
rotate_to_vertical:
    addi $t0, $t0, 1  # Move right by 1
    addi $t1, $t1, -1  # Move up by 1
    j end_perform_rotation
rotate_to_horizontal:
    addi $t0, $t0, -1  # Move left by 1
    addi $t1, $t1, 1  # Move down by 1
end_perform_rotation:
    sw $t0, current_x
    sw $t1, current_y
    jr $ra

add_to_playing_field:
    la $t0, playing_field
    lw $t1, current_x
    lw $t2, current_y
    lw $t3, is_vertical
    li $t4, 0x0000000F
    la $t5, COLOR_TETROMINO
    lw $t5, 0($t5)

    beq $t3, $zero, add_horizontal
add_vertical:
    li $t7, 0
add_vertical_loop:
    andi $t6, $t4, 0x1
    beqz $t6, skip_add1
    mul $t8, $t2, 128
    add $t8, $t8, $t7
    mul $t9, $t1, 4
    add $t8, $t8, $t9
    add $t8, $t0, $t8
    sw $t5, 0($t8)
skip_add1:
    addi $t7, $t7, 128
    srl $t4, $t4, 1
    bnez $t4, add_vertical_loop
    jr $ra

add_horizontal:
    li $t7, 0
add_horizontal_loop:
    andi $t6, $t4, 0x1
    beqz $t6, skip_add2
    mul $t8, $t2, 128
    mul $t9, $t1, 4
    add $t9, $t9, $t7
    add $t8, $t8, $t9
    add $t8, $t0, $t8
    sw $t5, 0($t8)
skip_add2:
    addi $t7, $t7, 4
    srl $t4, $t4, 1
    bnez $t4, add_horizontal_loop
    jr $ra

generate_new_tetromino:
    li $t0, 14  # Reset X position to center
    sw $t0, current_x
    li $t0, 1   # Reset Y position to top
    sw $t0, current_y
    li $t0, 1   # Reset to vertical 
    sw $t0, is_vertical
    jr $ra

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
    li $v0, 10
    syscall
