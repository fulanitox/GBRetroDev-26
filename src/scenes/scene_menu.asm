SECTION "Scene menu", ROM0


scene_menu_init::
    call LCDCoff
    call scene_menu_load_all_sprites_VRAM
    call LCDCon
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
    ; ld hl, Protagonista
    ; ld bc, ProtagonistaEnd - Protagonista
    ; ld de, $8000
    ; call sys_render_load_sprite
    ; call scene_menu_pintar_menu
ret

scene_menu_pintar_menu:
    
ret
