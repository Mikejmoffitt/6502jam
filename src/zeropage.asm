.segment "ZEROPAGE"

	 temp:				.res 1
	 temp2:				.res 1
	 temp3:				.res 1
	 temp4:				.res 1
	 temp5:				.res 1
	 temp6:				.res 1
	 temp7:				.res 1
	 temp8:				.res 1
	 addr_ptr:			.res 2

disc_state:
	 disc_x:			.res 2
	 disc_y:			.res 2
	 disc_z:			.res 2
	 disc_dx:			.res 2
	 disc_dy:			.res 2
	 disc_dz:			.res 2
	 disc_anim:			.res 1

player_state:
	 p1_x:				.res 2
	 p1_y:				.res 2
	 p1_dx:				.res 2
	 p1_dy:				.res 2
	 p1_num:			.res 1
	 p1_dirx:			.res 1
	 p1_diry:			.res 1
	 p1_slide_cnt:			.res 1
	 p1_block_cnt:			.res 1
	 p1_spr_num:			.res 1
	 p1_anim_frame:			.res 1

	 p2_x:				.res 2
	 p2_y:				.res 2
	 p2_dx:				.res 2
	 p2_dy:				.res 2
	 p2_num:			.res 1
	 p2_dirx:			.res 1
	 p2_diry:			.res 1
	 p2_slide_cnt:			.res 1
	 p2_block_cnt:			.res 1
	 p2_spr_num:			.res 1
	 p2_anim_frame:			.res 1
