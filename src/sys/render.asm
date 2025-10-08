include "../include/hardware.inc"

SECTION "RENDER", ROM0

sys_render_limpiar_pantalla:
    ld hl, $9800
    ld a, $90
    ld b, 32
    ld c, 32

    .total
        .pintar
            ld [hl], a
            inc hl
            dec b
        jr nz, .pintar
        dec c
    jr nz, .total
ret

sys_render_ActivarSpritesYPaleta:
    ld a, [rLCDC]
    or %00000010 
    ld [rLCDC], a

    ld a, %11100100
    ld [$FF48], a

    ld a, %11100100
    ld [$FF47], a
ret

sys_render_cleanOAM:
    ld hl, $FE00    ; Dirección de la OAM
    ld b, 160       ; En la OAM caben 40 sprites * 4 bytes
    ld a, 0

    .limpiar
        ld [hl], a
        inc hl
        dec b
    jr nz, .limpiar

ret

; CARGAR SPRITES EN VRAM
; INPUT: HL (Etiqueta comienzo), BC (Longitud, final - comienzo), DE (Dirección VRAM)
sys_render_load_sprite:
    .loop
        ld a, [hl]
        ld [de], a
        inc hl
        inc de
        dec bc
        ld a, b
        or c
        jr nz, .loop
ret

; Se llama con la pantalla apagada
sys_render_load_all_sprites_VRAM:
    ld hl, Protagonista
    ld bc, ProtagonistaEnd - Protagonista
    ld de, $8000
    call sys_render_load_sprite
ret
sys_render_pintar_inicio:
    
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
sys_render_setUp:
    call wait_vblank_start

    ld a, [rLCDC]
    res 7, a
    ld [rLCDC], a

    call sys_render_limpiar_pantalla
    call sys_render_ActivarSpritesYPaleta
    call sys_render_cleanOAM
    
    call sys_render_load_all_sprites_VRAM

    call sys_render_pintar_inicio

    ld a, [rLCDC]
    set 7, a
    ld [rLCDC], a
    

ret