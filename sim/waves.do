# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave UUT/top_state
add wave -uns UUT/UART_timer

add wave -divider -height 10 {SRAM signals}
add wave -uns UUT/SRAM_address
add wave -hex UUT/SRAM_write_data
add wave -bin UUT/SRAM_we_n
add wave -hex UUT/SRAM_read_data

#add wave -divider -height 10 {VGA signals}
#add wave -bin UUT/VGA_unit/VGA_HSYNC_O
#add wave -bin UUT/VGA_unit/VGA_VSYNC_O
#add wave -uns UUT/VGA_unit/pixel_X_pos
#add wave -uns UUT/VGA_unit/pixel_Y_pos
#add wave -hex UUT/VGA_unit/VGA_red
#add wave -hex UUT/VGA_unit/VGA_green
#add wave -hex UUT/VGA_unit/VGA_blue

add wave -divider -height 10 {Milestone2}

add wave UUT/Milestone2_unit/M2_state

add wave -divider -height 10 {DPRAM}

add wave -hex UUT/Milestone2_unit/address1
add wave -hex UUT/Milestone2_unit/address2
add wave -hex UUT/Milestone2_unit/address3
add wave -hex UUT/Milestone2_unit/address4
add wave -hex UUT/Milestone2_unit/address5
add wave -hex UUT/Milestone2_unit/address6

add wave -hex {UUT/Milestone2_unit/write_data_a[0]}
add wave -hex {UUT/Milestone2_unit/write_data_a[1]}
add wave -hex {UUT/Milestone2_unit/write_data_a[2]}
add wave -hex {UUT/Milestone2_unit/write_data_b[0]}
add wave -hex {UUT/Milestone2_unit/write_data_b[1]}
add wave -hex {UUT/Milestone2_unit/write_data_b[2]}
add wave -hex {UUT/Milestone2_unit/write_enable_a[0]}
add wave -hex {UUT/Milestone2_unit/write_enable_a[1]}
add wave -hex {UUT/Milestone2_unit/write_enable_a[2]}
add wave -hex {UUT/Milestone2_unit/write_enable_b[0]}
add wave -hex {UUT/Milestone2_unit/write_enable_b[1]}
add wave -hex {UUT/Milestone2_unit/write_enable_b[2]}
add wave -hex {UUT/Milestone2_unit/read_data_a[0]}
add wave -hex {UUT/Milestone2_unit/read_data_a[1]}
add wave -hex {UUT/Milestone2_unit/read_data_a[2]}
add wave -hex {UUT/Milestone2_unit/read_data_b[0]}
add wave -hex {UUT/Milestone2_unit/read_data_b[1]}
add wave -hex {UUT/Milestone2_unit/read_data_b[2]}

add wave -divider -height 10 {ROW/COL}

add wave -hex UUT/Milestone2_unit/row_index
add wave -hex UUT/Milestone2_unit/col_index
add wave -hex UUT/Milestone2_unit/fs_flag
add wave -hex UUT/Milestone2_unit/row_block
add wave -hex UUT/Milestone2_unit/col_block
add wave -hex UUT/Milestone2_unit/row_address
add wave -hex UUT/Milestone2_unit/col_address

add wave -divider -height 10 {FST}

add wave -hex UUT/Milestone2_unit/fs_buf
add wave -hex UUT/Milestone2_unit/fs_counter

add wave -hex UUT/Milestone2_unit/t_counter
add wave -hex UUT/Milestone2_unit/t_acc


add wave -hex UUT/Milestone2_unit/s_counter
add wave -hex UUT/Milestone2_unit/s_buf
add wave -hex UUT/Milestone2_unit/s_flag
add wave -hex UUT/Milestone2_unit/s_offset
add wave -hex UUT/Milestone2_unit/s0
add wave -hex UUT/Milestone2_unit/s1
add wave -hex UUT/Milestone2_unit/s2
add wave -hex UUT/Milestone2_unit/s3


add wave -hex UUT/Milestone2_unit/c0
add wave -hex UUT/Milestone2_unit/c1
add wave -hex UUT/Milestone2_unit/c2
add wave -hex UUT/Milestone2_unit/c3

add wave -hex UUT/Milestone2_unit/c_column_count



add wave -divider -height 10 {Multiplications}

add wave -hex UUT/Milestone2_unit/op0
add wave -hex UUT/Milestone2_unit/op1
add wave -hex UUT/Milestone2_unit/op2
add wave -hex UUT/Milestone2_unit/op3

add wave -hex UUT/Milestone2_unit/C0
add wave -hex UUT/Milestone2_unit/C1
add wave -hex UUT/Milestone2_unit/C2
add wave -hex UUT/Milestone2_unit/C3

add wave -hex UUT/Milestone2_unit/result1
add wave -hex UUT/Milestone2_unit/result2
add wave -hex UUT/Milestone2_unit/result3
add wave -hex UUT/Milestone2_unit/result4



#add wave -divider -height 10 {Milestone1}
#
#add wave UUT/Milestone1_unit/M1_state
#
#add wave -hex UUT/Milestone1_unit/case_flag
#
#
#add wave -hex UUT/Milestone1_unit/y_buf
#add wave -hex UUT/Milestone1_unit/u_buf
#add wave -hex UUT/Milestone1_unit/v_buf
#
#add wave -divider -height 10 {Decoded YUV}
#
#add wave -hex UUT/Milestone1_unit/u_prime_even
#add wave -hex UUT/Milestone1_unit/v_prime_even
#
#add wave -hex UUT/Milestone1_unit/u_prime_odd
#add wave -hex UUT/Milestone1_unit/v_prime_odd
#
#add wave -divider -height 10 {Counters}
# 
#add wave -hex UUT/Milestone1_unit/y_counter
#add wave -hex UUT/Milestone1_unit/u_counter
#add wave -hex UUT/Milestone1_unit/v_counter
#add wave -hex UUT/Milestone1_unit/pixel_counter
#add wave -hex UUT/Milestone1_unit/row_counter
#add wave -hex UUT/Milestone1_unit/rgb_counter
#add wave -hex UUT/Milestone1_unit/leadout_counter
#
#add wave -divider -height 10 {SR Structure}
#
#add wave -hex UUT/Milestone1_unit/u_minus_five
#add wave -hex UUT/Milestone1_unit/u_minus_three
#add wave -hex UUT/Milestone1_unit/u_minus_one
#add wave -hex UUT/Milestone1_unit/u_plus_one
#add wave -hex UUT/Milestone1_unit/u_plus_three 
#add wave -hex UUT/Milestone1_unit/u_plus_five
#
#add wave -hex UUT/Milestone1_unit/v_minus_five
#add wave -hex UUT/Milestone1_unit/v_minus_three
#add wave -hex UUT/Milestone1_unit/v_minus_one
#add wave -hex UUT/Milestone1_unit/v_plus_one
#add wave -hex UUT/Milestone1_unit/v_plus_three 
#add wave -hex UUT/Milestone1_unit/v_plus_five
#
#add wave -divider -height 10 {Unclipped}
#
#add wave -hex UUT/Milestone1_unit/r_acc_even
#add wave -hex UUT/Milestone1_unit/g_acc_even
#add wave -hex UUT/Milestone1_unit/b_acc_even
#
#add wave -hex UUT/Milestone1_unit/r_acc_odd
#add wave -hex UUT/Milestone1_unit/g_acc_odd
#add wave -hex UUT/Milestone1_unit/b_acc_odd
#
#add wave -divider -height 10 {Clipped}
#
#add wave -hex UUT/Milestone1_unit/r_clip_even
#add wave -hex UUT/Milestone1_unit/g_clip_even
#add wave -hex UUT/Milestone1_unit/b_clip_even
#
#add wave -hex UUT/Milestone1_unit/r_clip_odd
#add wave -hex UUT/Milestone1_unit/g_clip_odd
#add wave -hex UUT/Milestone1_unit/b_clip_odd
#
#
#add wave -divider -height 10 {Multiplications}
#
#add wave -hex UUT/Milestone1_unit/op1
#add wave -hex UUT/Milestone1_unit/op2
#add wave -hex UUT/Milestone1_unit/op3
#add wave -hex UUT/Milestone1_unit/op4
#add wave -hex UUT/Milestone1_unit/op5
#add wave -hex UUT/Milestone1_unit/op6
#add wave -hex UUT/Milestone1_unit/op7
#add wave -hex UUT/Milestone1_unit/op8
#add wave -hex UUT/Milestone1_unit/result1
#add wave -hex UUT/Milestone1_unit/result2
#add wave -hex UUT/Milestone1_unit/result3
#add wave -hex UUT/Milestone1_unit/result4
#

