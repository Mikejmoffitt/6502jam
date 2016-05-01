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

disc_state:
	 disc_x:			.res 2
	 disc_y:			.res 2
	 disc_z:			.res 2
	 disc_dx:			.res 2
	 disc_dy:			.res 2
	 disc_dz:			.res 2
	 disc_anim:			.res 1

player_state:
	.res PLAYER_SIZE
	.res PLAYER_SIZE
