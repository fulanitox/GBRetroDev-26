;;-------------------------------
;;CONSTANTS----------------------

;; MAN ENTITY ----------------
DEF SIZEOF_E = 10
DEF DEFAULT_CMP = $01
DEF DEFAULT_DISABLED_CMP = $00
DEF MAX_ENTITIES = 10
DEF ENTITY_ARRAY_SIZE = MAX_ENTITIES * SIZEOF_E
DEF PLAYER_TYPE = 0
DEF SPIKE_TYPE = 1
DEF SPRITE_PLAYER = $10
DEF SPRITE_SPIKE_R = $30
DEF SPRITE_SPIKE_L = $50
DEF DEFAULT_ATR = 0
DEF ANIM_DUR_SPIKES = 5
DEF ANIM_DUR_CORN = 5
DEF SPAWN_Y = $07*8+16
DEF SPAWN_X = $08*8+8


; Acceso a componentes de la entidad
DEF ACCESS_POSY = 3
DEF ACCESS_POSX = 4
DEF ACCESS_SPEEDY = 5
DEF ACCESS_SPEEDX = 6
;; ------------------------------

;; SYS PHYSICS -------------------
DEF MAX_SPEED_Y = 10
DEF MAX_SPEED_X = 10

;; SYS SPIKES --------------------
DEF LENGHT_VECT_SPIKES = 7
DEF MAX_SPIKES = 5

;; COLLISION SYS -----------------
DEF LIMIT_MIN_Y = 28    ;;Limite superior 16 + 16px margen de pantalla - 4px margen
DEF LIMIT_MAX_Y =  132   ;;Límite inferior de la pantalla 128 + 4px margen (+16px pantalla -16px sprite)
DEF LIMIT_MAX_X = 146   ;;Límite derecho de la pantalla 152px - 6px margen
DEF LIMIT_MIN_X = 16     ;;Límite izquierdo de la pantalla 8px + 8px margen de pantalla 

DEF LIMIT_Y_SPIKE = 4 ;; Lo que se le resta arriba y abajo
DEF LIMIT_X_SPIKE = 0   ;; Lo que se le resta izq y derecha

DEF LIMIT_Y_PLAYER = 4 ;; Lo que se le resta arriba y abajo
DEF LIMIT_X_PLAYER = 4   ;; Lo que se le resta izq y derecha
