SECTION "Scene game", ROM0

scene_game_init::
    call LCDCoff
    call sys_render_cleanOAM
    call scene_game_load_all_sprites_VRAM
    call scene_game_draw_background    
    call LCDCon

    call man_entity_init

    ; Inicializar la semilla de aleatorio
    call init_random_7
    ld hl, vector_spikes_left
    call sys_spikes_generate    

    ; Poner a 0 el score
    ld a, 0
    ld [player_score], a
ret

scene_game_buttons: 
    .checkB
        ld a, [flancoAscendente]
        bit 0, a
        jr z, .checkA

        ld hl, vector_spikes_left
        call sys_spikes_generate
        
    .checkA
        ld a, [flancoAscendente]
        bit 1, a
        jr z, .anyKey

        ld hl, vector_spikes_right
        call sys_spikes_generate
    .anyKey

ret

scene_game_update::
    call scene_game_buttons
    call sys_render_update
ret


scene_game_load_all_sprites_VRAM:
    ld hl, Mapa
    ld bc, MapaEnd - Mapa
    ld de, $8000
    call sys_render_load_sprite
ret

scene_game_draw_background:
    ld hl, $9800
    ld bc, fondo
    call sys_render_drawTilemap20x18
ret