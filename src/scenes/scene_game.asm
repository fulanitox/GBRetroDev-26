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
    ;; ld hl, vector_spikes_left
    ;; call sys_spikes_generate    

    ; Poner a 0 el score
    ld a, 0
    ld [player_score], a
    
    ld a, 2
    ld [max_spikes], a
ret

scene_game_buttons: 
    .checkA
        ld a, [flancoAscendente]
        bit 1, a
        jr z, .anyKey

        ld a, -4
        call sys_physics_change_velocity
        
    .anyKey

ret

scene_game_update::
    call sys_render_update
    call scene_game_buttons
    call sys_collision_update
    call sys_physics_update
    call man_entity_update
ret


; scene_game_load_all_sprites_VRAM:
;     ld hl, Mapa
;     ld bc, MapaEnd - Mapa
;     ld de, $8000
;     call sys_render_load_sprite
; ret

scene_game_draw_background:
    ld hl, $9800
    ld bc, fondo
    call sys_render_drawTilemap20x18
ret



scene_game_load_all_sprites_VRAM:
    call load_background_sprites_VRAM
    call load_mazorca_sprites_VRAM
    call load_spikeRight_sprites_VRAM
    call load_spikeLeft_sprites_VRAM
ret

scene_game_hit::
    bit 7, a
    jr nz, .negativo
    .positivo
    call man_entity_delete_spikes
    ld hl, vector_spikes_right
    call sys_spikes_generate
    call man_entity_create_spikes
    jr .score
    .negativo
    call man_entity_delete_spikes
    ld hl, vector_spikes_left
    call sys_spikes_generate
    call man_entity_create_spikes
    .score
    ld a, [player_score]
    inc a
    ld [player_score], a
ret

scene_game_player_dead::
    ld a, 0
    ld [player_score], a
ret