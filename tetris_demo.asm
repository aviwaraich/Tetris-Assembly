.data
ADDR_DSPL: .word 0x10008000  # Base address for display
COLOR_GRAY: .word 0x00808080  # Wall color

.text
.globl main

main:
    la $t0, ADDR_DSPL
    lw $t0, 0($t0)

    # Drawing the top border
    li $t2, 0
    la $t3, COLOR_GRAY
    lw $t3, 0($t3)
top_border:
    beq $t2, 32, top_done 
    sw $t3, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, 1
    j top_border
top_done:

    # Drawing the bottom border
    li $t2, 0
    li $t0, 0x10008F80  # Start address at last row (bottom border) [Base address + (31 rows * 32 units per row * 4 bytes per unit)]
bottom_border:
    beq $t2, 32, bottom_done 
    sw $t3, 0($t0)
    addi $t0, $t0, 4
    addi $t2, $t2, 1
    j bottom_border
bottom_done:

    # Drawing the left border
    li $t2, 0
    li $t0, 0x10008000  # Start at first column (left border)
left_border:
    beq $t2, 32, left_done
    sw $t3, 0($t0)
    addi $t0, $t0, 128  # Move to the next row (32 * 4 bytes per unit)
    addi $t2, $t2, 1
    j left_border
left_done:

    # Drawing the right border
    li $t2, 0
    li $t0, 0x1000807C  # Start at last column (right border) [Base address + (31 * 4)]
right_border:
    beq $t2, 32, right_done 
    sw $t3, 0($t0)
    addi $t0, $t0, 128 
    addi $t2, $t2, 1
    j right_border
right_done:

    # End program
    li $v0, 10
    syscall
