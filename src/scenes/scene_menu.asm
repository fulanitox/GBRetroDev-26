SECTION "Scene menu", ROM0


scene_menu_init::

ret


scene_menu_update::
    call wait_VBLANK
    call sys_render_pintar_menu
ret