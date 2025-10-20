include "../include/include.inc"

SECTION "Animations Data", WRAM0
                        ;     next_animation:     DS 2
                        ;     LastAnim:           DS 2

                        ;     DEF FinalDeAnim = -1

                        SECTION "Animations System", ROM0
                        ; sprites:
                        ; ;ROB UP WALK
                        ;     DB $10, $11, $12, $13, FinalDeAnim 


                        ; ;Inicializa las animaciones, poniendo a 0 la siguiente animacion 
                        ; anim_init:
                        ;     ld hl, sprites ;;HL -> Adress of fisrt byte of sprite
                        ;     ld a, 0
                        ;     ld [LastAnim], a     ;;Guarda el estado de la animación
                        ;     ld a, l
                        ;     ld [next_animation + 0], a   ;;Store L in the fisrt byte of anim_next    
                        ;     ld a, h
                        ;     ld [next_animation + 1], a   ;;Store H in the second byte of anim_next
                        ; ret






sprites_corn:
;ROB UP WALK
    DB $10, $14, $18, $1C, $20, $1C, $18, $14 
sprites_spike:
;ROB UP WALK
    DB $30, $34, $38, $3C, $30, $3C, $38, $34 

;;Actualizamos la entidad poneindo en su atributo de asprite el siguiente que le toca del pack de 4
quesito:
    inc hl                  ;;//
    inc hl                  ;;\\LLevamos HL hasta el contador de animacion (Entity_AnimID)
    inc hl                  ;;//
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl

    inc [hl]                ;;//Iteramos el contador de animacion



    ld a, d                 ;;//
    cp 1                    ;;\\Comprobamos si es un Player u otra cosa
    jp nz, .player           ;;//

    ;;[PINCHO]================================
    ;;Aqui si es un pincho
    ld a, [hl]               ;;//Metemos en A el contador de animacion y le restamos uno para empezar a volver hacia el tile de la entidad
    cp ANIM_DUR_SPIKES                     ;;\\Comprobamos que la animacion no haya terminado
    call nc, restart_animation;;//Si ha terminado la mandamos a restart

    ld b, 0                 ;;//Iniciamos el contador para llegar hasta el proximo sprite
    ld de, sprites_spike    ;;\\
    ld a, [hl]
    jp .loop                ;;//Usamos este salto para no hacer la animacion de otros sprites que no son de esta entidad


    ;;[PLAYER]================================
    ;;Aqui si es un player
    .player
        ld a, [hl]               ;;//Metemos en A el contador de animacion y le restamos uno para empezar a volver hacia el tile de la entidad
        cp ANIM_DUR_CORN                     ;;\\Comprobamos que la animacion no haya terminado
        call nc, restart_animation;;//Si ha terminado la mandamos a restart

        ld b, 0                 ;;//Iniciamos el contador para llegar hasta el proximo sprite
        ld de, sprites_corn     ;;\\
        ld a, [hl]
    ;;========================================



    .loop                   ;;//Bucle para llevar DE hasta la direccion de memoria del proximo sprite
    push hl
    ld h, d
    ld l, e
    ld d, 0
    ld e, a
    add hl, de      
    ld d, h
    ld e, l
    pop hl                  ;; DE= HL (posicion de los sprites) + a (iterador)

    dec hl                  ;;\\    
    dec hl                  ;;//LLevamos HL al tile de la entidad otra vez (Entity_Tile)
    ld a, [de]
    ld [hl], a              ;;//Guardamos en HL el tile utilizando el registro A
ret



restart_animation:
    ld a, 0
    ld [hl], a
ret