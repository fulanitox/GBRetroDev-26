include "../include/hardware.inc"
SECTION "INPUT VARIABLES", HRAM
    estadoBotones:      DS 1
    flancoAscendente:   DS 1

SECTION "UTILS", ROM0

;;-------------------------------------------------------
;; Espera al inicio de VBLANK
;; DESTROYS: AF
;;
wait_VBLANK::
    ld a, [$FF44]
    cp 144
    jr nz, wait_VBLANK
ret

;;-------------------------------------------------------
;; Apaga LCDC, para la PPU
;; DESTROYS: AF, HL
;;
LCDCoff::
   ;;APAGAR LCDC
   call wait_VBLANK
   ld hl, $FF40
   res 7, [hl]
   ;;--------------
ret

;;-------------------------------------------------------
;; Enciende LCDC, vuelve a poner en marcha la PPU
;; DESTROYS: HL
;;
LCDCon::
   ;;ENCENDER LCDC
   ld hl, $FF40
   set 7, [hl]
   ;;------------
ret

utils_read_buttons:
    ld a, $20       ; 00100000, seleccionan los botones, desactiva las acciones y deja activado con 0 todo lo demás
    ldh [rP1], a    ; Se seleccionan del registro de entrada del joypad los botones
    ld a, [rP1]     ; Se lee el registro de entrada del Joypad

    cpl             ; Se invierten los bits ( 1 pulsado)
    and $0F         ; 0000 xxxx. Sin bits de posiciones
    swap a          ; xxxx 0000. Se cambian los nibbles ( los mueve a la izquierda, para poner a la derecha botones)

    ld b, a         ; Se guarda en B el valor de los botones de dirección

    ld a, $30
    ldh [rP1], a

    ld a, $10       ; 00010000, seleccionan las direcciones, desactiva las botones y deja activado con 0 todo lo demás
    ldh [rP1], a    ; Se seleccionan del registro de entrada del joypad las acciones
    ld a, [rP1]     ; Se lee el registro de entrada del joypad

    cpl 
    and $0F

    or b            ; xxxx 0000. Se combinan los bits de acción con los de dirección almacenados en b
                    ; 0000 xxxx
    ld b,a                      ;Se guarda en b el estado de los botones actual
    ldh a, [estadoBotones]      ;Se carga en a el estado de los botones anterior

    xor b           ; Se comparan si han cambiado ( si no ha cambiado 0)
    and b           ; Nos quedamos con los que sean 1, los que han cambiado

    ldh [flancoAscendente], a   ; Se guarda los que han cambiado

    ld a, b                 ; Se carga ek estado de los botones de ahora
    ldh [estadoBotones], a  ; Se carga en el estado de los botones el valor de los botones de ahora

    ld a, $30
    ldh [rP1], a

ret

