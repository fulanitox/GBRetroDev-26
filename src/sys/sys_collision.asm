
include "../include/include.inc"

SECTION "Collision System", ROM0

;; -------------------------------------------
;; Actualiza las colisiones de todas las entidades
;; MOD: AF; BC; DE; HL
;;
sys_collision_update::
    ld de, sys_collision_check_player
    ld b, PLAYER_TYPE
    call man_entity_for_each_by_type
ret

;;---------------------
;; Chequea las colisiones del jugador
;; INPUT: HL-> Direccion de memoria de la entidad
;; MOD: AF; BC; DE; HL
;;
sys_collision_check_player::
    ld d, 0
    ld e, ACCESS_POSY
    add hl, de              ;; Player posY
    ;; LIMIT Y ---------------------------------
    ;; Por ahora te devuelven a la y del spawn.
    ld a, [hl]
    ;;Hay como un desajuste de 2 px d lo q se ve y el dato asique lo arreglo
    dec a
    dec a
    cp LIMIT_MAX_Y 
    jr nc, .limitY
    cp LIMIT_MIN_Y 
    jr c, .limitY
    jr .axisX ;;Vamos a la x, en Y estamos bien
    .limitY:
    ld a, SPAWN_Y
    ld [hl], a
    ;; LIMIT X ---------------------------------
    ;; Le da la vuelta a tu velocidad.
    .axisX:
    inc hl
    ld a, [hl]
    cp LIMIT_MAX_X
    jr nc, .limitX    
    cp LIMIT_MIN_X
    jr c, .limitX
    jr .entities ;;Vamos a las entidades, en X estamos bien
    .limitX:
    inc hl
    inc hl
    ld a, [hl]
    cpl
    inc a
    ld [hl], a
    call scene_game_hit
    .entities
ret