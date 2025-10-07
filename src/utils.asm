SECTION "UTILS", ROM0
wait_vblank_start::
    ld a, [$FF44]
    cp 144
    jr nz, wait_vblank_start
ret