.segment "ZEROPAGE"

         temp:                                  .res 1
         temp2:                                 .res 1
         addr_ptr:                              .res 2

disc_state:
         disc_x:                                .res 2
         disc_y:                                .res 2
         disc_dx:                               .res 2
         disc_dy:                               .res 2
         disc_anim:                             .res 1

player_state:
         p1_x:                                  .res 2
         p1_y:                                  .res 2
         p1_dx:                                 .res 2
         p1_dy:                                 .res 2
         p1_num:                                .res 1
         p1_dir:                                .res 1
         p1_slide_cnt:                          .res 1
         p1_block_cnt:                          .res 1
         p1_anim_frame:                         .res 1
