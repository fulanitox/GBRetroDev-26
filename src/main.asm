SECTION "Entry point", ROM0[$150]

main::

   call man_escenas_init

   .bucle

      call wait_vblank_start
      call engine_game_check_inputs
      
   jr .bucle
   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)
