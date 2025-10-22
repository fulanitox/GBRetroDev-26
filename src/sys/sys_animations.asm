include "../include/include.inc"

SECTION "Animations Data", WRAM0
    animation_time: DS 1 

SECTION "Animations System", ROM0

sprites_corn:
;ROB UP WALK
    DB $20, $24, $28, $2C, $30, $2C, $28, $24 
sprites_spike_r:
;ROB UP WALK
    DB $40, $44, $48, $4C, $40, $4C, $48, $44 
sprites_spike_l:
;ROB UP WALK
    DB $60, $64, $68, $6C, $60, $6C, $68, $64 

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




    ld a, d                 ;;//
    cp 1                    ;;\\Comprobamos si es un Player u otra cosa
    jp nz, .player           ;;//

    ;;[PINCHO]================================
    ;;Aqui si es un pincho
    inc [hl]                ;;//Iteramos el contador de animacion
    ld a, [hl]               ;;//Metemos en A el contador de animacion y le restamos uno para empezar a volver hacia el tile de la entidad
    cp ANIM_DUR_SPIKES                     ;;\\Comprobamos que la animacion no haya terminado
    call nc, restart_animation;;//Si ha terminado la mandamos a restart

    ld b, 0                 ;;//Iniciamos el contador para llegar hasta el proximo sprite
    ld a, [spikes_is_left]
    cp 1
    jr z, .spikeLeft
    ld de, sprites_spike_r
    jr .end
    .spikeLeft
    ld de, sprites_spike_l    ;;\\
    .end
    ld a, [hl]
    jp .loop                ;;//Usamos este salto para no hacer la animacion de otros sprites que no son de esta entidad


    ;;[PLAYER]================================
    ;;Aqui si es un player
    .player
        ld c, a

        ld a, [animation_time]      ;;/ =6
        dec a                       ;;\ Decrementa BC
        ld [animation_time], a      ;;/
        ld a, c
        jp nz, .endAnimation                      ;;\ Repite el bucle hasta que BC llegue a cero el contador

        ld a, $08                   ;;/ RESET CONTADOR
        ld [animation_time], a      ;;\


        inc [hl]                 ;;//Iteramos el contador de animacion
        ld a, [hl]               ;;//Metemos en A el contador de animacion y le restamos uno para empezar a volver hacia el tile de la entidad
        cp ANIM_DUR_CORN          ;;\\Comprobamos que la animacion no haya terminado
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

    .endAnimation
ret

restart_animation:
    ld a, 0
    ld [hl], a
ret