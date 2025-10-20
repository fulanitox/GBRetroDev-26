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

    ld a, 0
    ld [idle_counter], a
    ld [gravity], a
ret

scene_game_buttons: 
    .checkB
        ld a, [flancoAscendente]
        bit 0, a
        jr z, .checkA

        ld hl, vector_spikes_left
        call sys_spikes_generate
        call man_entity_create_spikes

    .checkA
        ld a, [flancoAscendente]
        bit 1, a
        jr z, .anyKey

        ld hl, vector_spikes_right
        call sys_spikes_generate
        call man_entity_create_spikes

        ld a, -4
        call sys_physics_change_velocity
        
    .anyKey

ret

scene_game_update::
    call scene_game_buttons
    call sys_physics_update_gravity
    call sys_physics_update
    call sys_render_update
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

load_background_sprites_VRAM:
    ld hl, Mapa
    ld bc, MapaEnd - Mapa
    ld de, $8000
    call sys_render_load_sprite
ret

load_mazorca_sprites_VRAM:
    ld hl, MazorcaFront
    ld bc, MazorcaBackEnd - MazorcaFront
    ld de, $8100
    call sys_render_load_sprite
ret

load_spikeRight_sprites_VRAM:
    ld hl, FuegoRight0
    ld bc, FuegoRight4End - FuegoRight0
    ld de, $8300
    call sys_render_load_sprite
ret

load_spikeLeft_sprites_VRAM:
    ld hl, FuegoLeft0
    ld bc, FuegoLeft4End - FuegoLeft0
    ld de, $8500
    call sys_render_load_sprite
ret