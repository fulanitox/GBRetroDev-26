include "../include/include.inc"
SECTION "VARIABLES SPIKES", WRAM0
    vector_spikes_left: DS 7
    vector_spikes_right: DS 7
    spikes_is_left: DS 1
    max_spikes: DS 1

SECTION "SYS SPIKES", ROM0

; INPUT: HL(Dirección del vector)
sys_spikes_clean_one:
    ld b, LENGHT_VECT_SPIKES
    ld a, 0
    .loop
        ld [hl+], a
        dec b
    jr nz, .loop
ret

sys_spikes_clean_lr:
    ld hl, vector_spikes_left
    call sys_spikes_clean_one
    ld hl, vector_spikes_right
    call sys_spikes_clean_one
ret

; INPUT: HL(Dirección del vector de spikes)
sys_spikes_generate:
    push hl
        call sys_spikes_clean_lr
    pop hl
    
    ld a, [max_spikes]
    ld e, a
    ld b, h
    ld c, l

    .spike
    call generate_random_7
        push bc
            ld b, 0
            ld c, a
            add hl, bc
        pop bc

            ld a, [hl]
            cp 1
            jr nz, .noSpike
            
            ld h, b
            ld l, c
            jr .spike

            .noSpike
            ld a, 1
            ld [hl], a

            ld h, b
            ld l, c

        
        dec e
        jr nz, .spike

ret

sys_spikes_update_max:
    ld hl, player_score
    ld a, [hl]

    ld de, ACCESS_SPEEDX
    ld hl, entity_array
    add hl, de              ; Velocidad X
    ld d, h
    ld e, l

    ld hl, max_spikes

    cp 10
    jr nz, .check20
    ld b, 2
    ld [hl], b

    .check20
    cp 20
    jr nz, .check30
    push af
    ld a, [de]
    
    ld a, 2
    ld [de], a
    pop af

    .check30
    cp 30
    jr nz, .check40
    ld b, 3
    ld [hl], b

    .check40
    cp 40
    jr nz, .check50
    push af
    ld a, 3
    ld [de], a
    pop af

    .check50
    cp 50
    jr nz, .ok
    ld b, 5
    ld [hl], b

    .ok
ret

sys_spikes_update::
    ;;Muevo los sprites
    ld a, [spikes_is_left]
    cp 1
    jr z, .is_Left
    ld de, sys_spikes_update_pos_r
    jr .next
    .is_Left
    ld de, sys_spikes_update_pos_l
    .next
    ld b, SPIKE_TYPE
    call man_entity_for_each_by_type
    call sys_spikes_update_max
ret

sys_spikes_update_pos_r::
    ld d, 0
    ld e, ACCESS_POSX
    add hl, de
    ld a, [hl]
    cp SPIKE_R_X
    jr z, .end
    dec a
    ld [hl], a
    .end
ret

sys_spikes_update_pos_l::
    ld d, 0
    ld e, ACCESS_POSX
    add hl, de
    ld a, [hl]
    cp SPIKE_L_X
    jr z, .end
    inc a
    ld [hl], a
    .end
ret