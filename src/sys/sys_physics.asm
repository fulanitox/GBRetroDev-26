include "../include/include.inc"

SECTION "Physics section", WRAM0
    entity_acceleration: DS ENTITY_ARRAY_SIZE

SECTION "Physics System", ROM0

;;------------------------------------------
;; Temporizador
;; Input;   NONE
;; Output;  [C008]
;; Delete;  a
;; De momento esta a 6 el bucle habra que chekearlo
timer:
    ;;==============CONTADOR================
    ld a, [$C008]    ;;/ =6
    dec a            ;;\ Decrementa BC
    ld [$C008], a    ;;/
    ret nz           ;;\ Repite el bucle hasta que BC llegue a cero el contador

    ld a, $0A        ;;/ RESET CONTADOR
    ld [$C008], a    ;;\
    ;;=====================================
    call sys_physics_calculate
ret

;;------------------------------------------
;; Acelera la velocidad del bichillo
;; Input;   hl -> Entidad a actualizar
;; Output;  NONE
;; Delete;  a, b
sys_physics_calculate:
    ;v = v + a          ; como Δt = 1, no multiplicas
    ;x = x + v          ; aproximas el desplazamiento
    inc hl              
    inc hl
    inc hl
    inc hl
    inc hl              ;HL -> VelY

    ld a, [entity_acceleration]     ;Leemos aceleracion de la entidad
    ld b, a              ;Escribimos aceleracion en registro b
    ld a, [hl+]          ;Leemos velocidad inicial Y, HL -> VelX
    cp MAX_SPEED_Y
    jr nc, .maxAceleracion   ;Si la acelareacion llega a 10 o mas deja de acelerar
    add b             ;Sumamos y escribimos en a velocidad final

    .maxAceleracion
    dec hl
    dec hl
    dec hl              ;HL -> PosY

    ld b, a           ;Escribimos velocidad final en el registro a
    ld a, [hl]     ;Leemos posicion inicial de la entidad
    add b             ;Escribimos en a posicion final
    ld [hl+], a     ;Escribimos en la entidad su nueva posicion, HL -> PosX    
    
ret