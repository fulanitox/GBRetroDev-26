include "../include/hardware.inc"

SECTION "Render System", ROM0

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
    ld a, [$FF40]
    or %00000110
    ld [$FF40], a

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

sys_render_setUp:
    call LCDCoff

    call sys_render_limpiar_pantalla
    call sys_render_ActivarSpritesYPaleta
    call sys_render_cleanOAM

    call LCDCon
ret

;;------------------------------------------------------
;; Función que pinta cualquier escena que sea de 20x18
;; INPUT: HL -> Direccion inicio pantalla ($9800 para arriba izquierda)
;;        BC -> Direccion inicio timemap
;; DESTROYS: AF, HL, DE, BC
sys_render_drawTilemap20x18::
    ld d, 18
    .row
        ld e, 20
        .column
            ld a, [bc]
            ld [hl], a
            inc hl
            inc bc
            dec e
        jr nz, .column
        
        push bc
        ld bc, 12
        add hl, bc
        pop bc
        dec d
    jr nz, .row
ret