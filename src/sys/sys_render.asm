include "../include/hardware.inc"

SECTION "WRAM OAM", WRAM0, ALIGN[8]
    copiaOAM::
    DS 160

SECTION "DMA Routine", ROM0
    routineDMA:
        ld a, HIGH(copiaOAM) ; Obtiene el byte alto de la dirección
        ldh [$46], a ; Inicia una transferencia DMA inmediatamente tras la instrucción
        ld a, 40; Espera un total de 40x4 = 160 ciclos
        .espera
        dec a; 1 ciclo
        jr nz, .espera ; 3 ciclos
        ret
    routineDMAend:

    copiaroutineDMA::
        ld hl, routineDMA;Origen de datos
        ld b, routineDMAend - routineDMA ;Cantidad de bytes a copiar
        ld c, LOW(OAMDMA);Byte bajo de la dirección de destino
        .loop
            ld a, [hl+]
            ldh [c], a
            inc c
            dec b
        jr nz, .loop
    ret

SECTION "OAM DMA", HRAM
    OAMDMA::
    DS routineDMAend - routineDMA


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

;; ---------------------------
;; Iniciamos todo lo que tenga ue ver con el pintado en pintalla
;;

sys_render_setUp:
    call LCDCoff

    call sys_render_limpiar_pantalla
    call sys_render_ActivarSpritesYPaleta
    call sys_render_cleanOAM

    call LCDCon

    call copiaroutineDMA
ret

;;------------------------------------------------------
;; Limpia toda la WOAM
;; MODIFIES: AF, BC, HL
;;
sys_render_clear_WOAM::
    ld hl, copiaOAM
    ld a, 0
    ld b, 160
    .loop   
        ld [hl+], a
        dec b
        jr nz, .loop
ret

;;------------------------------------------------------
;; Actualiza las posiciones de la WOAM de todas las entidades activas
;; MODIFIES: AF, BC, DE, HL
;;
sys_render_load_OAM:
    ld de, sys_render_entity
    call man_entity_for_each
ret

;; ---------------------------
;; Actualizamos todas las entidades del entity array y se copian en la OAM DMA
;;
sys_render_update:
    call sys_render_clear_WOAM
    call sys_render_load_OAM;;Repintar las entidades (Cambiar posiciones, tiles o atributos en la OAM)
    
    call wait_VBLANK;;Esperar a VBLANK start
    ld a, HIGH(copiaOAM)
    call OAMDMA
ret

;; --------------------------------------------------
;; Pinta la entidad contenida en hl en la OAM
;; INPUT: HL -> direccion de la entidad
sys_render_entity::
    inc hl
    inc hl
    ld a, [hl+]     ;;HL -> Entity_PosY, a -> Entity_OAMid
    push hl
    dec a
    sla a
    sla a
    sla a                ;; A = A * 8
    ld de, copiaOAM
    ld e, a         ;;DE -> OAM_DMA Posicion Y

;;PRIMERA MITAD DEL SPRITE-----------------

    ;;PosX y PosY
    ld a, [hl+]     ;;HL -> Entiy_PosX, a -> Entity_PosY
    ld [de], a      ;;DE -> OAM_DMA Posicion Y = Entity_PosY
    inc de          ;;DE -> OAM_DMA Posicion X
    ld a, [hl+]     ;;HL -> Entiy_PosYF, a -> Entity_PosX
    ld [de], a      ;;DE -> OAM_DMA Posicion X = Entity_PosX

    ;;Tile y atributo
    inc de          ;;DE -> OAM_DMA Tile
    inc hl          ;;HL -> Entiy_PosXF
    inc hl          ;;HL -> Entity_Tile
    ld a, [hl+]     ;;HL -> Entity_Atributo, a -> Entity_Tile
    ld [de], a      ;;DE -> OAM_DMA Tile = Entity_tile
    inc de          ;;DE -> OAM_DMA Atributo
    ld a, [hl]      ;;a -> Entity_Atributo
    ld [de], a      ;;DE -> OAM_DMA Atributo = Entity_Atributo

;;SEGUNDA MITAD DEL SPRITE-----------------

    inc de          ;;DE -> segundo sprite, pos y
    pop hl          ;;HL -> Entity_Posy

    ;;PosX y PosY
    ld a, [hl+]     ;;HL -> Entiy_PosX, a -> Entity_PosY
    ld [de], a      ;;DE -> OAM_DMA Posicion Y = Entity_PosY
    inc de          ;;DE -> Posicion X
    ld a, [hl+]     ;;HL -> Entiy_PosYF, a -> Entity_PosX
    add 8           ;;a -> Entity_PosX + 8  (descuadre por ser segundo sprite)
    ld [de], a      ;;DE -> OAM_DMA Posicion X = Entity_PosX + 8 (descuadre por ser segundo sprite)

    ;;Tile y atributo
    inc de          ;;DE -> OAM_DMA Tile
    inc hl          ;;HL -> Entiy_PosXF
    inc hl          ;;HL -> Entity_Tile
    ld a, [hl+]     ;;HL -> Entity_Atributo, a -> Entity_Tile
    inc a
    inc a           ;;A -> Sprite parte derecha
    ld [de], a      ;;DE -> OAM_DMA Tile = Entity_tile + 2 posiciones por ser el segundo
    inc de          ;;DE -> OAM_DMA Atributo
    ld a, [hl]      ;;a -> Entity_Atributo
    ld [de], a      ;;DE -> OAM_DMA Atributo = Entity_Atributo
ret