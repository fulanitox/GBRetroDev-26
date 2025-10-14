SECTION "Scene game", ROM0

scene_game_init::
    call LCDCoff
    call scene_game_load_all_sprites_VRAM
    call scene_game_draw_background
    call LCDCon
ret


scene_game_update::

ret

scene_game_load_all_sprites_VRAM:
    ld hl, Mapa
    ld bc, MapaEnd - Mapa
    ld de, $8000
    call sys_render_load_sprite
ret

scene_game_draw_background:
    ld hl, $9800
    ld bc, fondo
    call sys_render_drawTilemap20x18
ret