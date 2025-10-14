SECTION "Scene menu", ROM0


scene_menu_init::
    call LCDCoff
    call scene_menu_load_all_sprites_VRAM
    call LCDCon
ret


scene_menu_update::
    call wait_VBLANK
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
    
    ld hl, $FE00

    ld a, 16
    ld [hl+], a

    ld a, 16
    ld [hl+], a

    ld a, $02
    ld [hl+], a

    ld a, %00000000
    ld [hl+], a

    ld a, 24
    ld [hl+], a

    ld a, 16
    ld [hl+], a

    ld a, $03
    ld [hl+], a

    ld a, %00000000
    ld [hl+], a

    ld a, 24
    ld [hl+], a

    ld a, 8
    ld [hl+], a

    ld a, $01
    ld [hl+], a

    ld a, %00000000
    ld [hl+], a

    ld a, 16
    ld [hl+], a

    ld a, 8
    ld [hl+], a

    ld a, $00
    ld [hl+], a

    ld a, %00000000
    ld [hl+], a
ret
