include "../include/hardware.inc"
include "../include/constantes.inc"

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

sys_render_setUp:
    call wait_vblank_start

    ld a, [rLCDC]
    res 7, a
    ld [rLCDC], a

    call sys_render_limpiar_pantalla
    call sys_render_ActivarSpritesYPaleta
    call sys_render_cleanOAM
    

ret