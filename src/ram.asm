; Non-zeropage RAM arrangement.

.segment "RAM"
        vblank_flag:                            .res 1
        frame_counter:                          .res 1
        ppuctrl_config:                         .res 1
        ppumask_config:                         .res 1
        xscroll:                                .res 2
        yscroll:                                .res 2

button_table:
        btn_a:                                  .res 1
        btn_b:                                  .res 1
        btn_sel:                                .res 1
        btn_start:                              .res 1
        btn_up:                                 .res 1
        btn_down:                               .res 1
        btn_left:                               .res 1
        btn_right:                              .res 1

pad_data:
        pad_1:                                  .res 1
        pad_1_prev:                             .res 1
        pad_2:                                  .res 1
        pad_2_prev:                             .res 1

game_state:
        playfield_top:                          .res 1
        playfield_bottom:                       .res 1
        playfield_left:                         .res 1
        playfield_right:                        .res 1



