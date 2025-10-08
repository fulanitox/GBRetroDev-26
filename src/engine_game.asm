SECTION "ENGINE GAME", ROM0

engine_game_check_inputs:

    call utils_read_buttons

    .checkB
        ld a, [flancoAscendente]
        bit 0, a
        jr z, .checkA
        call sys_render_cleanOAM

    .checkA
        ld a, [flancoAscendente]
        bit 1, a
        jr z, .anyKey

    .anyKey


ret
    
