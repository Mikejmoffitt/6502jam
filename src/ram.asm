.segment "ZEROPAGE"

PLAYER_SIZE = $30

	 temp:				.res 1
	 temp2:				.res 1
	 temp3:				.res 1
	 temp4:				.res 1
	 temp5:				.res 1
	 temp6:				.res 1
	 temp7:				.res 1
	 temp8:				.res 1
	 addr_ptr:			.res 2

; Player state is described in player.asm
player_state:
	.res PLAYER_SIZE
	.res PLAYER_SIZE

disc_state:
	 disc_x:			.res 2
	 disc_y:			.res 2
	 disc_z:			.res 2
	 disc_dx:			.res 2
	 disc_dy:			.res 2
	 disc_dz:			.res 2
	 disc_anim:			.res 1

.segment "RAM"
	vblank_flag:			.res 1
	frame_counter:			.res 1
	ppuctrl_config:			.res 1
	ppumask_config:			.res 1
	xscroll:			.res 2
	yscroll:			.res 2

button_table:
	btn_a:				.res 1
	btn_b:				.res 1
	btn_sel:			.res 1
	btn_start:			.res 1
	btn_up:				.res 1
	btn_down:			.res 1
	btn_left:			.res 1
	btn_right:			.res 1

pad_data:
	pad_1:				.res 1
	pad_1_prev:			.res 1
	pad_2:				.res 1
	pad_2_prev:			.res 1

game_state:
	playfield_top:			.res 1
	playfield_bottom:		.res 1
	playfield_left:			.res 1
	playfield_right:		.res 1
	playfield_center:		.res 1

; Additional player state that does not need to be in ZP
player_ex:
	.res PLAYER_SIZE
	.res PLAYER_SIZE


