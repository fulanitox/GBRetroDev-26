SECTION "Entry point", ROM0[$150]

main::
   di     ;; Disable Interrupts
   halt   ;; Halt the CPU (stop procesing here)
