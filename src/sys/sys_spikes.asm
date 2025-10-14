include "../include/include.inc"
SECTION "VARIABLES SPIKES", WRAM0
    vector_spikes_left: DS 7
    vector_spikes_right: DS 7

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

    ld e, MAX_SPIKES
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