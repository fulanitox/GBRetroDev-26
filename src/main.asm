SECTION "Entry point", ROM0[$150]

main::

   call man_escenas_init
   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)
