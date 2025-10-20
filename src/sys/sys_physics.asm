include "../include/include.inc"

SECTION "Physics section", WRAM0
    entity_acceleration: DS ENTITY_ARRAY_SIZE
    idle_counter: DS 1
    gravity: DS 1
    speedY_sub: DS 1                                ; SubPixeles. Cuando haya carry aumenta velocidad.
    speedY: DS 1                              

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

;------------------------------------------
; Cambiar la velocidad Y
; INPUT: A
; OUTPUT: nada
; MODIFICA: HL, DE
;------------------------------------------
sys_physics_change_velocity:
    ld hl, entity_array
    ld d, 0
    ld e, ACCESS_SPEEDY
    add hl, de
    ld [hl], a
ret

;------------------------------------------
; Actualiza el contador de inactividad y la gravedad
; INPUT: nada
; OUTPUT: nada
; MODIFICA: A
;------------------------------------------
sys_physics_update_gravity:
    ldh a, [estadoBotones]
    cp 0
    jr nz, .button_pressed

    ;No se pulsa boton
    ld a, [idle_counter]
    inc a
    ld [idle_counter], a
    cp 26
    jr nz, .done

    ; Ha llegado a frames
    xor a
    ld [idle_counter], a

    ld a, [gravity]
    inc a 
    ld [gravity], a
    
    ; limitar la gravedad a un maximo
    cp MAX_GRAVITY
    jr c, .done
    ld a, MAX_GRAVITY
    ld [gravity], a
    
    jr .done
   
    ; Si se ha pulsado un boton (Reiniciar todo)
    .button_pressed
        xor a
        ld [idle_counter], a
        ld a, 1
        ld [gravity], a
    .done
ret

sys_physics_v1:

    ld hl, entity_array     ; Jugador
    inc hl
    inc hl
    inc hl                  ; PosY
    ld a, [gravity]
    ld d,a 
    ld a, [hl]
    add d
    ld [hl], a


    ld hl, entity_array     ; Jugador
    ld d, 0
    ld e, ACCESS_SPEEDY
    add hl, de

    ld a, [hl]
    sub 4
    jr c, .end

    ld [hl], a

    dec hl
    dec hl
    ld a, [hl]
    sub 4
    ld [hl], a

    .end
ret


sys_physics_update1:
    ; -- 1. Obtener velocidad actual --
    ld hl, entity_array
    ld d, 0
    ld e, ACCESS_SPEEDY
    add hl, de
    ld a, [hl]           ; A = speedY

    ; -- 2. Aplicar gravedad --
    ld b, a
    ld a, 1
    add b
    ld [hl], a           ; speedY += gravity

    ; -- 3. Actualizar posición Y --
    ld hl, entity_array
    inc hl
    inc hl
    inc hl               ; PosY
    srl a
    srl a
    srl a
    srl a
    ld b, a              ; B = nueva velocidad
    ld a, [hl]
    add b
    ld [hl], a           ; posY += speedY
ret


sys_physics_update:
    call sys_physics_update_vertical
    call sys_physics_update_horizontal
ret

;; ------------------------------------------
;; Aplica la velociad Y, aplicando la gravedad cada 4 frames y teniendo en cuenta límites
;; INPUT: NaN
;; OUTPUT: NaN
;; MODIFICA: HL, DE, BC, A
;; ------------------------------------------
sys_physics_update_vertical:

    ; 0 - Comprobar subPixeles
    ld hl, entity_array
    ld d, 0
    ld e, ACCESS_SPEEDY
    add hl, de
    ld b, h
    ld c, l

    ld hl, speedY_sub
    ld a, [hl]
    add a, 64
    ld [hl],a

    ; 1 - Obtener la velocidad en Y
    ld a, [bc]
    jr nc, .ok

    ld [hl], 0
    
    
    ; 2 - Aplicar la gravedad (+1 cada frame)
    add a, 1

    ; ---- Limitar valores ----
    bit 7, a
    jr nz, .check_min      ; si bit7=1 => negativo

    ; Si positivo -> limitar a +4
    cp 3
    jr c, .ok              ; A < 4 -> ok
    ld a, 3
    jr .ok

.check_min
    ; Si negativo -> limitar a -36 ($DC)
    cp $DC
    jr nc, .ok             ; si A >= $DC (menos negativo), ok
    ld a, $DC

.ok
    ld h, b
    ld l, c

    ld [hl], a             ; guardar velocidad final

    ; 3 - Aplicar velocidad (posY += speedY)
    dec hl
    dec hl
    ld b, [hl]              ; posY
    add a, b
    ld [hl], a

ret

;------------------------------------------
;; Suma la velocidad X a la posicón X
;; INPUT: NaN
;; OUTPUT: NaN
;; MODIFICA: A, B
;------------------------------------------
sys_physics_update_horizontal:

    ld hl, entity_array
    ld d, 0
    ld e, ACCESS_POSX

    add hl, de

    push hl
    inc hl
    inc hl
    ld a, [hl]      ; Velocidad X
    pop hl
    
    ld b, a
    ld a, [hl]      ; Posición X
    add a, b
    ld  [hl], a
ret




;; Tiempo sin pulsar un boton es la caida. Cada 10 se suma 1
;; MAL PORQUE VELY SE SUMA 1 CADA FRAME HASTA LO QUE TENGA Y GRAVEDAD 4 CADA FRAME POR EJEMPLO
;; ACELERACION AL SUBIR CON LA A 
;; Que la gravedad no modifique posición sin oque pase por velocidad