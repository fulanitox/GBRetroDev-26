SECTION "Scene menu", ROM0


scene_menu_init::
    call LCDCoff
    call scene_menu_load_all_sprites_VRAM
    call sys_render_cleanOAM
    call LCDCon
    call scene_menu_save_high_score
ret


scene_menu_buttons:
    .checkB
        ld a, [flancoAscendente]
        bit 0, a
        jr z, .checkA

    .checkA
        ld a, [flancoAscendente]
        bit 1, a
        jr z, .anyKey

        ld a, 2
        ld [do_change], a

    .anyKey
ret

scene_menu_update::
    call scene_menu_buttons
ret


; Se llama con la pantalla apagada
scene_menu_load_all_sprites_VRAM:
    ld hl, Protagonista
    ld bc, ProtagonistaEnd - Protagonista
    ld de, $8000
    call sys_render_load_sprite
    call scene_menu_pintar_menu
ret

scene_menu_pintar_menu:
    ld hl, $9800
    ld bc, fondo
    call sys_render_drawTilemap20x18
ret

scene_menu_save_high_score:
    ld a, $0A
    ld [$0000], a           ; Habilitar SRAM
    
    ld a, [loaded_high_score]
    ld [saved_high_score], a       ; Cargar el highScore

    ld a, $00
    ld [$0000], a          ; Deshabilitar SRAM
ret