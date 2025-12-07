[org 0x0100]
jmp menu_start
; --- Data Section ---
player_name db 20, 0
             times 20 db 0
player_roll db 10, 0
             times 10 db 0
game_state db 0
exit_confirm db 0
; Strings
welcome_lbl db "WELCOME TO",0
start_msg db "R E G E N E S I S : N I T R O E S C A P E",0
start_opt1 db " [Y] Instructions",0
start_opt2 db " [P] Start Game",0
start_opt3 db " [ESC] Exit Game",0
start_opt4 db " [C] Credits",0
; Instructions
instr_title db "MISSION BRIEFING",0
instr_1 db " < LEFT ARROW > Steer Left",0
instr_2 db " < RIGHT ARROW > Steer Right",0
instr_3 db " ( $ ) Collect for Points",0
instr_4 db " [ ESC ] Pause / Menu",0
main_msg db "ESCAPE THE VOID :)))...",0
venture_msg db "Press any key to venture on escaping the void...",0
confirm_title db "ABANDON GAME?",0
confirm_opts db "Y: Yes | N: No",0
end_msg db "GAME OVER",0
; --- STATS STRINGS ---
stats_msg db "MISSION REPORT",0
name_lbl db "Name:",0
roll_lbl db "Roll No:",0
coins_msg db "Score:",0
; Credits
credits_msg db "--- DEVELOPERS ---",0
dev1 db "Hasnain Ahmad Saeed (24L-0661) [Game Mechanics]",0
dev2 db "Hashir Khalid (24L-0668) [Game Visuals]",0
press_key db "Press any key...",0
name_prompt db "Enter Name: ",0
roll_prompt db "Enter Roll: ",0
return_msg db " SPACE: Main Menu | ESC: Exit ",0
; ---------------------------------------------------------
; Optimized Subroutines
; ---------------------------------------------------------
; Set Text Mode, Hide Cursor, Set ES to Video Mem, Clear Screen




buffer: times 320 db 0
copied_car: times 841 db 0
coin_str: db 'Coins: '
fuel_str: db 'Fuel: '
num_buffer: times 6 db 0
bar_buffer: db '[ ]',0
coin_buffer: times 30 db 0
coin_char: db 'O',0
coin_bitmap: db 00111100b, 01100110b, 11000011b, 11000011b, 11000011b, 11000011b, 01100110b, 00111100b


copied_object: times 840 db 0 

coin_timer: dw 0

coin_spawn_line: dw 12

copied_coin: times 150 db 0

car_coords: dw 0,0
; NEW VARIABLES
fuel_level dw 4

old_isr: dd 0

is_active: db 0

last_tick dw 0

is_right_arrow_key_pressed: db 0
is_left_arrow_key_pressed: db 0


timer_count: dw 0

object_coords: dw 0,0

spawn_coords: db 50,90,131

object_spawn_line: dw 30

object_add: dw 0

object_lane_no: dw 0

car_lane_no: db 1


hitbox_coords: dw 51616,56085,62496,56110


shift_car_right: db 0

shift_car_left: db 0


end_game: db 0
 
coin_lane_no: dw 0

coin_add: dw 0

is_coin_active: db 0

coins_collected: dw 0


wait_timer: dw 0

first_coin: db 0


printnum: push bp
mov bp, sp
push es
push ax
push bx
push cx
push dx
push di
mov ax, 0xb800
mov es, ax ; point es to video base
mov ax, [bp+4] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigit: mov dx, 0 ; zero upper half of dividend
div bx ; divide by 10
add dl, 0x30 ; convert digit into ascii value
push dx ; save ascii value on stack
inc cx ; increment count of values
cmp ax, 0 ; is the quotient zero
jnz nextdigit ; if no divide it again
mov di, 2140 ; point di to top left column
nextpos: pop dx ; remove a digit from the stack
mov dh, 0x0f ; use normal attribute
mov [es:di], dx ; print char on screen
add di, 2 ; move to next screen location
loop nextpos ; repeat for all digits on stack
pop di
pop dx
pop cx
pop bx
pop ax
pop es
pop bp
ret 2


setup_video:
    mov ax, 0003h ; Set mode 3
    int 10h
    mov ch, 20h ; Hide Cursor
    mov ah, 01h
    int 10h
    mov ax, 0B800h
    mov es, ax
    xor di, di
    mov cx, 2000
    mov ax, 0720h ; Default clear
    rep stosw
    ret
; Show Cursor
show_cursor:
    mov ah, 01h
    mov ch, 06h
    mov cl, 07h
    int 10h
    ret
; Draw Box: Expects DI=Start, CX=InnerWidth, DH=Height, AH=Attribute
draw_box:
    pusha
    mov bx, cx ; Save inner width
    ; Top
    mov al, 201
    stosw
    mov cx, bx
    mov al, 205
    rep stosw
    mov al, 187
    stosw
    add di, 160 ; Next row
    sub di, bx
    sub di, bx
    sub di, 4 ; Adjust DI back
    ; Middle
mid:
    mov al, 186
    stosw
    mov cx, bx
    mov al, 32 ; Space
    push ax ; Save attr
    and ah, 0F0h ; Keep background
    rep stosw
    pop ax ; Restore attr
    mov al, 186
    stosw
    add di, 160
    sub di, bx
    sub di, bx
    sub di, 4
    dec dh
    jnz mid
    ; Bottom
    mov al, 200
    stosw
    mov cx, bx
    mov al, 205
    rep stosw
    mov al, 188
    stosw
    popa
    ret
; Draw Shadow
draw_shadow:
    pusha
    mov ax, 08B0h ; Dark Gray Block
sh_loop:
    push di
    push cx
    rep stosw
    pop cx
    pop di
    add di, 160
    dec dh
    jnz sh_loop
    popa
    ret
print_str_color: ; DI=Pos, SI=String, AH=Attr
    push ax
    push di
next:
    lodsb
    cmp al, 0
    je done
    stosw
    jmp next
done:
    pop di
    pop ax
    ret
print_str: ; BIOS string print
    pusha
.loop:
    lodsb
    cmp al, 0
    je .exit
    mov ah, 0Eh
    int 10h
    jmp .loop
.exit:
    popa
    ret
wait_key:
    mov ah, 00h
    int 16h
    ret
; ---------------------------------------------------------
; Screens
; ---------------------------------------------------------
start_screen:
    call game_reset
    mov byte [game_state], 0
    call setup_video
    ; Background Pattern (Tech Grid)
    xor di, di
    mov cx, 2000
    mov ax, 08FAh ; '·' Dark Gray
    rep stosw
    ; Shadow
    mov di, 674 ; Row 4, Col 17
    mov cx, 47
    mov dh, 14
    call draw_shadow
    ; Main Box
    mov di, 510 ; Row 3, Col 15
    mov cx, 45
    mov dh, 12
    mov ah, 0Bh ; Light Cyan
    call draw_box
    ; Header Bar
    mov di, 992
    mov cx, 45
    mov ax, 01DBh ; Solid Blue Block
    rep stosw
    ; Text
    mov di, 706
    lea si, [welcome_lbl]
    mov ah, 0Fh
    call print_str_color
    mov di, 996
    lea si, [start_msg]
    mov ah, 1Fh
    call print_str_color
    mov di, 1316
    lea si, [start_opt1]
    mov ah, 03h
    call print_str_color
   
    mov di, 1636
    lea si, [start_opt2]
    mov ah, 0Ah
    call print_str_color
   
    mov di, 1956
    lea si, [start_opt3]
    mov ah, 0Ch
    call print_str_color
   
    mov di, 2276
    lea si, [start_opt4]
    mov ah, 0Dh
    call print_str_color
    ; Slogan
    mov di, 2458
    lea si, [main_msg]
    mov ah, 8Eh ; Blink Yellow
    call print_str_color
input_loop:
    call wait_key
    cmp al, 'Y'
    je go_instr
    cmp al, 'y'
    je go_instr
    cmp al, 'P'
    je go_player
    cmp al, 'p'
    je go_player
    cmp al, 'C'
    je go_credits
    cmp al, 'c'
    je go_credits
    cmp al, 1Bh
    je esc_start
    jmp input_loop
go_instr:
jmp instruction_screen
go_player:
jmp player_input_screen
go_credits:
jmp credits_screen
esc_start:
    mov byte [exit_confirm], 1
    mov byte [game_state], 5
    call handle_confirm
    jmp start_screen
; ---------------------------------------------------------
player_input_screen:
    mov byte [game_state], 1
    call setup_video
   
    call show_cursor
    ; Inputs
    mov dx, 0A0Ah
    mov ah, 2
    int 10h
    lea si, [name_prompt]
    call print_str
    lea dx, [player_name]
    mov ah, 0Ah
    int 21h
    mov dx, 0C0Ah
    mov ah, 2
    int 10h
    lea si, [roll_prompt]
    call print_str
    lea dx, [player_roll]
    mov ah, 0Ah
    int 21h
    ; Hide Cursor
    mov ah, 1
    mov ch, 20h
    int 10h
    ; Venture Msg
    mov di, 2432
    lea si, [venture_msg]
    mov ah, 0Bh
    call print_str_color
   
    call wait_key
   ; jmp ending_message
   jmp game_start
; ---------------------------------------------------------
instruction_screen:
    mov byte [game_state], 2
    call setup_video
    ; Background
    xor di, di
    mov cx, 2000
    mov ax, 08FAh
    rep stosw
    ; Shadow
    mov di, 996
    mov cx, 44
    mov dh, 10
    call draw_shadow
    ; Box
    mov di, 832
    mov cx, 42
    mov dh, 8
    mov ah, 0Bh
    call draw_box
   ; Text
    mov di, 1000        
    lea si, [instr_title]
    mov ah, 0Eh         
    call print_str_color

    mov di, 1318        
    lea si, [instr_1]
    mov ah, 03h         ; Cyan
    call print_str_color

    mov di, 1478        
    lea si, [instr_2]
    mov ah, 0Dh         ; <--- PURPLE (Magenta)
    call print_str_color

    mov di, 1638        
    lea si, [instr_3]
    mov ah, 0Eh         ; <--- YELLOW
    call print_str_color

    mov di, 1798        
    lea si, [instr_4]
    mov ah, 0Ch         ; Red
    call print_str_color

    mov di, 2118        
    lea si, [press_key]
    mov ah, 08h         
    call print_str_color

    call wait_key
    jmp start_screen
; ---------------------------------------------------------
credits_screen:
    mov byte [game_state], 8
    call setup_video
    mov di, 820
    lea si, [credits_msg]
    mov ah, 0Eh
    call print_str_color
    mov di, 1140
    lea si, [dev1]
    mov ah, 0Fh
    call print_str_color
    mov di, 1460
    lea si, [dev2]
    call print_str_color
    mov di, 1940
    lea si, [press_key]
    mov ah, 08h
    call print_str_color
    call wait_key
    jmp start_screen
; ---------------------------------------------------------
handle_confirm:
    push word [game_state]
    mov byte [game_state], 5
    mov ax, 0B800h
    mov es, ax
    ; Popup Shadow
    mov di, 1634
    mov cx, 48
    mov dh, 5
    call draw_shadow
    ; Popup Box
    mov di, 1470
    mov cx, 48
    mov dh, 4
    mov ah, 4Fh ; White on Red
    call draw_box
    mov di, 1808
    lea si, [confirm_title]
    mov ah, 4Fh
    call print_str_color
    mov di, 1976
    lea si, [confirm_opts]
    call print_str_color
.loop:
    call wait_key
    cmp al, 'y'
    je .exit
    cmp al, 'Y'
    je .exit
    cmp al, 'n'
    je cancel
    cmp al, 'N'
    je cancel
    jmp .loop
.exit:
    pop ax
    jmp exit_game
cancel:
    pop ax
    cmp al, 0
    je start_screen
    cmp al, 2
    je instruction_screen
    cmp al, 7
    je ending_screen
    ret
; ---------------------------------------------------------
ending_message:
    xor ax,ax
    mov es,ax
    cli
    mov ax,[old_isr]
    mov word [es:9*4],ax
    mov ax,[old_isr+2]
    mov word [es:9*4+2],ax
    sti
    mov ax,0
    mov byte [game_state], 6
    call setup_video
    mov di, 1960
    lea si, [end_msg]
    mov ah, 4Fh
    call print_str_color
    call wait_key
    ; Fall through to ending_screen
; ---------------------------------------------------------
ending_screen:
    mov byte [game_state], 7
    call setup_video
    ; 1. Plain Black Background (No Dots)
    xor di, di
    mov cx, 2000
    mov ax, 0020h ; Space with Black BG
    rep stosw
    ; 2. Draw Header Background (Blue Bar)
    mov di, 840 ; Row 5, Width 40
    mov cx, 40
    mov ax, 0120h ; Blue Bar
    rep stosw
    ; 3. Print Header Text (Centered)
    mov di, 866
    lea si, [stats_msg]
    mov ah, 1Fh ; White on Blue
    call print_str_color
    ; 4. Name
    mov di, 1480 ; Row 9
    lea si, [name_lbl]
    mov ah, 03h ; Cyan
    call print_str_color
   
    mov di, 1500 ; Value
    lea si, [player_name+2]
    mov ah, 0Fh ; White
    mov cl, [player_name+1]
    xor ch, ch
    call print_str_loop
    ; 5. Roll (RED COLOR)
    mov di, 1800 ; Row 11
    lea si, [roll_lbl]
    mov ah, 0Ch ; <--- RED
    call print_str_color
    mov di, 1820 ; Value
    lea si, [player_roll+2]
    mov ah, 0Fh ; White
    mov cl, [player_roll+1]
    xor ch, ch
    call print_str_loop
    ; 6. Score
    mov di, 2120 ; Row 13
    lea si, [coins_msg]
    mov ah, 0Eh ; Yellow
    call print_str_color
    push word [coins_collected]
    call printnum
    ; 7. Footer
    mov di, 3680 ; Row 23
    lea si, [return_msg]
    mov ah, 70h ; Black on Gray
    call print_str_color
.loop:
    call wait_key
    cmp al, ' '
    je start_screen
    cmp al, 1Bh
    je .esc
    jmp .loop
.esc:
    call handle_confirm
    jmp ending_screen
; Helper
print_str_loop:
    lodsb
    cmp al, 0
    je .ret
    stosw
    loop print_str_loop
.ret: ret



make_road:
             push bp
             mov bp,sp
             pusha
             mov cx,159
             mov dx,200
             mov ax,0c07h
make_road_l1:
             int 10h
             dec cx
             cmp cx,40
             jne make_road_l1
             mov cx,159
             dec dx
             jnz make_road_l1
              mov si,20
              mov cx,78
              mov dx,200
              mov ax,0c0fh
make_road_l2:
             int 10h
             dec dx
             dec si
             jnz make_road_l2
             mov si,20
             sub dx,40
             cmp dx,0
             jg make_road_l2
      
              mov si,20
              mov cx,117
              mov dx,200
make_road_l3:
      
             int 10h
             dec dx
             dec si
             jnz make_road_l3
             mov si,20
             sub dx,40
             cmp dx,0
             jg make_road_l3
              popa
              pop bp
              ret
    
make_Grass:
             push bp
             mov bp,sp
             pusha
  
             mov ax,0c02h ; light Green Colour for Grass
             mov cx,40 ; x pos
             mov dx,200 ; y pos
    
             mov si,20
             mov di,0c02h
make_grass_l1:
            int 10h
            loop make_grass_l1
            mov cx,40
            dec si
            jnz make_grass_l2
            xchg ax,di
            mov si,20
make_grass_l2:
             dec dx
             jnz make_grass_l1
        
             mov ax,0c02h
             mov di,0c02h
             mov cx,160
             mov dx,200
             mov si,20
             mov di,0c02h
make_grass_l3:
               int 10h
               inc cx
               cmp cx,200
               jne make_grass_l3
  
      
               dec si
               jnz make_grass_l4
               xchg ax,di
               mov si,20
      
make_grass_l4:
               mov cx,160
               dec dx
               jnz make_grass_l3
      
               popa
               pop bp
               ret
make_car:
               push bp
               mov bp,sp
               pusha
               mov bh, 0
               ; Draw thick black outline first: 16 wide x 27 high
               mov ax, 0c00h ; black
               mov cx, [bp+4]
               sub cx, 1 ; x start
               mov dx, [bp+6]
               add dx, 1 ; y start (extended bottom)
               push 16
               push 27
               call car_draw_rect
               ; Draw inner body: light blue 14 wide x 25 high
               mov ax, 0c04h ; light blue
               mov cx, [bp+4] ; x start
               mov dx, [bp+6] ; y start
               push 14
               push 25
               call car_draw_rect
               ; Draw window: checkerboard pattern 10x8, positioned relatively
               mov ax, 0c03h ; cyan
               mov bx, 0c0bh ; light cyan
               mov si, 8 ; height
               mov cx, [bp+4]
               add cx, 2 ; x start
               mov dx, [bp+6]
               sub dx, 8 ; y start
make_car_window_y:
               push cx
               mov di, 10 ; width
               push ax ; save start color for row
make_car_window_x:
               int 10h
               inc cx
               xchg ax, bx ; toggle color
               dec di
               jnz make_car_window_x
               pop ax ; restore start color
               pop cx
               xchg ax, bx ; toggle start color for next row
               dec dx
               dec si
               jnz make_car_window_y
               ; Draw wheels: black 4x4 squares
               mov ax, 0c00h ; black
               mov cx, [bp+4]
               sub cx, 4
               mov dx, [bp+6]
               push 4
               push 4
               call car_draw_rect
               mov cx, [bp+4]
               add cx, 14
               mov dx, [bp+6]
               push 4
               push 4
               call car_draw_rect
               mov cx, [bp+4]
               sub cx, 4
               mov dx, [bp+6]
               sub dx, 21
               push 4
               push 4
               call car_draw_rect
               mov cx, [bp+4]
               add cx, 14
               mov dx, [bp+6]
               sub dx, 21
               push 4
               push 4
               call car_draw_rect
               ; Add white 'O' highlights (2x2 square) on tyres
               mov ax, 0c0fh ; white
               mov cx, [bp+4]
               sub cx, 3
               mov dx, [bp+6]
               sub dx, 1
               push 2
               push 2
               call car_draw_rect
               mov cx, [bp+4]
               add cx, 15
               mov dx, [bp+6]
               sub dx, 1
               push 2
               push 2
               call car_draw_rect
               mov cx, [bp+4]
               sub cx, 3
               mov dx, [bp+6]
               sub dx, 22
               push 2
               push 2
               call car_draw_rect
               mov cx, [bp+4]
               add cx, 15
               mov dx, [bp+6]
               sub dx, 22
               push 2
               push 2
               call car_draw_rect
               ; Add yellow headlights at front in * shape, shifted to front
               mov ax, 0c0eh ; yellow
               mov di, 3
               call car_draw_headlight
               mov di, 10
               call car_draw_headlight
               ; Add mini exhaust at rear: dark gray 2x5, shifted right
               mov ax, 0c08h ; dark gray
               mov cx, [bp+4]
               add cx, 9 ; x start (shifted right)
               mov dx, [bp+6]
               add dx, 2 ; y start (below body)
               push 2
               push 5
               call car_draw_rect
               ; Add spoiler at rear: black 12x2
               mov ax, 0c00h ; black
               mov cx, [bp+4]
               add cx, 1 ; x start
               mov dx, [bp+6]
               add dx, 1 ; y start (rear)
               push 12
               push 2
               call car_draw_rect
               jmp end_subs
car_draw_headlight:
               mov bx, [bp+4]
               add bx, di
               mov cx, bx
               mov dx, [bp+6]
               sub dx, 26
               int 10h
               dec cx
               int 10h
               add cx, 2
               int 10h
               mov cx, bx
               dec dx
               int 10h
               mov cx, bx
               add dx, 2
               int 10h
               ret
car_draw_rect:
               push bp
               mov bp, sp
               mov si, [bp+4] ; height
make_car_rect_y:
               push cx
               mov di, [bp+6] ; width
make_car_rect_x:
               int 10h
               inc cx
               dec di
               jnz make_car_rect_x
               pop cx
               dec dx
               dec si
               jnz make_car_rect_y
               pop bp
               ret 4
_car_done:
        popa
        pop bp
        ret
make_tree:
push bp
mov bp, sp
pusha
mov bx, [bp+4] ; x pos (center)
mov dx, [bp+6] ; y pos (bottom)
; Draw trunk: brown 7x20
mov ax, 0c06h ; brown
mov si, 20 ; height
mov di, 7 ; width
mov cx, bx
sub cx, 3 ; start x-3
call draw_layers
; Draw foliage level 1 (bottom): cyan (spruce) 13 wide
mov ax, 0c0ah ; cyan (acts as Blue Spruce/Teal)
mov si, 4
mov di, 13
mov cx, bx
sub cx, 6
call draw_layers
; Draw foliage level 2: cyan (spruce) 11 wide
mov ax, 0c0ah ; cyan
mov si, 4
mov di, 11
mov cx, bx
sub cx, 5
call draw_layers
; Draw foliage level 3 (top): cyan (spruce) 7 wide
mov ax, 0c0ah ; cyan
mov si, 4
mov di, 7
mov cx, bx
sub cx, 3
call draw_layers
popa
pop bp
ret 4
draw_layers:
draw_ys:
push cx
push di
draw_xs:
int 10h
inc cx
dec di
jnz draw_xs
pop di
pop cx
dec dx
dec si
jnz draw_ys
ret
draw_layer:
draw_y:
               push cx
               push di
draw_x:
               int 10h
               inc cx
               dec di
               jnz draw_x
               pop di
               pop cx
               dec dx
               dec si
               jnz draw_y
               ret
make_lamp:
push bp
mov bp, sp
pusha
mov cx, [bp+4] ; x pos
mov dx, [bp+6] ; y pos (bottom)
; Draw pole: gray vertical 1x20
mov ax, 0c07h ; light gray
mov si, 20 ; height
make_lamp_pole: int 10h
dec dx
dec si
jnz make_lamp_pole
; Draw light: yellow 3x3
mov ax, 0c0eh ; yellow
mov si, 3
dec cx ; center
sub dx, 2 ; above pole
make_lamp_light_y: int 10h
inc cx
int 10h
inc cx
int 10h
sub cx, 2
dec dx
dec si
jnz make_lamp_light_y
popa
pop bp
ret 4
make_object:
               push bp
               mov bp,sp
               pusha
               mov bh, 0
               ; Draw thick black outline first: 16 wide x 27 high
               mov ax, 0c00h ; black
               mov cx, [bp+4]
               sub cx, 1 ; x start
               mov dx, [bp+6]
               add dx, 1 ; y start (extended bottom)
               push 16
               push 27
               call draw_rect
               ; Draw inner body: light blue 14 wide x 25 high
               mov ax, 0c09h ; light blue
               mov cx, [bp+4] ; x start
               mov dx, [bp+6] ; y start
               push 14
               push 25
               call draw_rect
               ; Draw window: checkerboard pattern 10x8, positioned relatively
               mov ax, 0c03h ; cyan
               mov bx, 0c0bh ; light cyan
               mov si, 8 ; height
               mov cx, [bp+4]
               add cx, 2 ; x start
               mov dx, [bp+6]
               sub dx, 8 ; y start
make_object_window_y:
               push cx
               mov di, 10 ; width
               push ax ; save start color for row
make_object_window_x:
               int 10h
               inc cx
               xchg ax, bx ; toggle color
               dec di
               jnz make_object_window_x
               pop ax ; restore start color
               pop cx
               xchg ax, bx ; toggle start color for next row
               dec dx
               dec si
               jnz make_object_window_y
               ; Draw wheels: black 4x4 squares
               mov ax, 0c00h ; black
               mov cx, [bp+4]
               sub cx, 4
               mov dx, [bp+6]
               push 4
               push 4
               call draw_rect
               mov cx, [bp+4]
               add cx, 14
               mov dx, [bp+6]
               push 4
               push 4
               call draw_rect
               mov cx, [bp+4]
               sub cx, 4
               mov dx, [bp+6]
               sub dx, 21
               push 4
               push 4
               call draw_rect
               mov cx, [bp+4]
               add cx, 14
               mov dx, [bp+6]
               sub dx, 21
               push 4
               push 4
               call draw_rect
               ; Add white 'O' highlights (2x2 square) on tyres
               mov ax, 0c0fh ; white
               mov cx, [bp+4]
               sub cx, 3
               mov dx, [bp+6]
               sub dx, 1
               push 2
               push 2
               call draw_rect
               mov cx, [bp+4]
               add cx, 15
               mov dx, [bp+6]
               sub dx, 1
               push 2
               push 2
               call draw_rect
               mov cx, [bp+4]
               sub cx, 3
               mov dx, [bp+6]
               sub dx, 22
               push 2
               push 2
               call draw_rect
               mov cx, [bp+4]
               add cx, 15
               mov dx, [bp+6]
               sub dx, 22
               push 2
               push 2
               call draw_rect
               ; Add yellow headlights at front in * shape, shifted to front
               mov ax, 0c0eh ; yellow
               mov di, 3
               call draw_headlight
               mov di, 10
               call draw_headlight
               ; Add mini exhaust at rear: dark gray 2x5, shifted right
               mov ax, 0c08h ; dark gray
               mov cx, [bp+4]
               add cx, 9 ; x start (shifted right)
               mov dx, [bp+6]
               add dx, 2 ; y start (below body)
               push 2
               push 5
               call draw_rect
               ; Add spoiler at rear: black 12x2
               mov ax, 0c00h ; black
               mov cx, [bp+4]
               add cx, 1 ; x start
               mov dx, [bp+6]
               add dx, 1 ; y start (rear)
               push 12
               push 2
               call draw_rect
               jmp end_subs
draw_headlight:
               mov bx, [bp+4]
               add bx, di
               mov cx, bx
               mov dx, [bp+6]
               sub dx, 26
               int 10h
               dec cx
               int 10h
               add cx, 2
               int 10h
               mov cx, bx
               dec dx
               int 10h
               mov cx, bx
               add dx, 2
               int 10h
               ret
draw_rect:
               push bp
               mov bp, sp
               mov si, [bp+4] ; height
make_object_rect_y:
               push cx
               mov di, [bp+6] ; width
make_object_rect_x:
               int 10h
               inc cx
               dec di
               jnz make_object_rect_x
               pop cx
               dec dx
               dec si
               jnz make_object_rect_y
               pop bp
               ret 4
end_subs:
               popa
               pop bp
               ret 4
make_strips:
               pusha
               mov bh, 0 ; page 0
               ; Left side hazard stripes ( / direction)
               mov cx, 40
left_strip_x:
               push cx
               mov dx, 199
left_strip_y:
               mov ax, cx
               add ax, dx ; (x + y)
               mov bl, 20
               div bl ; period 20 → 10px yellow, 10px black
               cmp ah, 10
               jb yellow_l
               mov al, 0 ; black
               jmp plot_l
yellow_l: mov al, 0Eh ; yellow
plot_l:
               mov ah, 0Ch
               int 10h
               dec dx
               jns left_strip_y
               pop cx
               inc cx
               cmp cx, 45
               jb left_strip_x
               ; Right side hazard stripes ( \ mirrored direction, no crash, perfect symmetry)
               mov cx, 155
right_strip_x:
               push cx
               mov dx, 199
right_strip_y:
               mov ax, 319
               sub ax, cx ; 319 - x (mirrors the x coordinate)
               add ax, dx ; + y
               mov bl, 20
               div bl
               cmp ah, 10
               jb yellow_r
               mov al, 0
               jmp plot_r
yellow_r: mov al, 0Eh
plot_r:
               mov ah, 0Ch
               int 10h
               dec dx
               jns right_strip_y
               pop cx
               inc cx
               cmp cx, 160
               jb right_strip_x
               popa
               ret
scroll_down:
             push bp
             mov bp,sp
             pusha
             push es
             push ds
             ; save values of old pixels
      
             ; copy ds val to es
      
      
             mov ax,0xA000
             mov es,ax
  
             mov si,buffer
             mov di,63681
             mov cx, 199
      
scroll_down_l1:
                mov bl,[es:di]
                mov [si],bl
                add si,1
                add di,1
      
                loop scroll_down_l1
      
             ; scroll down
             push ds ; save old value for later use
             mov ds,ax
      
             mov cx,199
             mov dx,199
             mov si,63559 ; start at the 2nd last line
             mov di,63879 ; start at the last line
             push si ; save old offset of si
      
             std ; set direction flag
                 
scroll_down_l2:
                       rep movsb
                
                       dec dx
                       cmp dx,0
                
                       jna scroll_down_exit
                
                       mov cx,199
                       pop di
                
                       mov bx, dx
                       shl bx, 6 ; bx = y*64
                       mov si, bx
                       shl bx, 2 ; bx = y*256
                       add si, bx
                       add si,199 ; si = final offset
                       push si
                       jmp scroll_down_l2
                       
                       
; make last row of the 3 lanes grey to ensure erasure of objects, coins

scroll_down_exit:

cld

mov di,63729
mov cx,24
mov al,07h

rep stosb

mov di,63760
mov cx,32
rep stosb

mov di,63807
mov cx,28
rep stosb



                       ; wrap-around
                       pop si
                
                       pop ds
                       mov si,buffer
                       mov di,321
                       mov cx,199
                
                       cld
                       rep movsb
                
                       pop es
                       pop ds
                       popa
                       pop bp
                       ret
delay:
        pusha
 
        mov cx,0xffff
delay_l1:
          loop delay_l1
   
   
          popa
          ret
erase_car:
           push bp
           mov bp,sp
           pusha
           push ds
           push es
    
           mov cx,[bp+4]
           mov dx,[bp+6]
    
           shl dx,6 ; Y = Y*256
           mov di,dx
           shl dx,2 ; Y = Y*64
           add di,dx
           add di,cx ; di = Y*320 + X
    
           add di,636 ; Offset Calculated
    
           mov ax,0xa000
           mov es,ax
    
           mov si,copied_car
    
           mov cx,22
           mov dx,32
    
erase_car_l1:
              push cx
              push di
       
erase_car_l2:
              mov bl,[es:di]
              mov [si],bl
              add si,1
              mov byte [es:di],0x07 ; light Grey Colour
              add di,1
              loop erase_car_l2
       
              pop di
              pop cx
              sub di,320
              dec dx
              jnz erase_car_l1
       
erase_car_exit:
                 pop es
                 pop ds
                 popa
                 pop bp
                 ret 4
                 
                 
                 
                 
                 
paste_car:
           push bp
           mov bp,sp
           pusha
           push ds
           push es
    
           mov cx,[bp+4]
           mov dx,[bp+6]
    
           shl dx,6 ; Y = Y*256
           mov di,dx
           shl dx,2 ; Y = Y*64
           add di,dx
           add di,cx ; di = Y*320 + X
    
           add di,636 ; Offset Calculated
    
           mov ax,0xa000
           mov es,ax
    
           mov si,copied_car
    
           mov cx,22
           mov dx,32
    
paste_car_l1:
              push cx
              push di
       
paste_car_l2:
              cmp byte [es:di],0x0e
              jne paste_car_l3
              cmp byte [first_coin],1
              je paste_car_l3
              mov byte [first_coin],1
              inc word [coins_collected]
               
paste_car_l3:              
              mov bl,[si]
              mov [es:di],bl
              add si,1
              add di,1
              loop paste_car_l2
       
              pop di
              pop cx
              sub di,320
              dec dx
              jnz paste_car_l1
       
paste_car_exit:
                 push word 24
                 push word 36
                 push word [coins_collected]
                 call print_number
                 
                 pop es
                 pop ds
                 popa
                 pop bp
                 ret 4
move_car_up:
     
           push bp
           mov bp,sp
           pusha
           push ds
           push es
    
           mov cx,[bp+4]
           mov dx,[bp+6]
    
           shl dx,6 ; Y = Y*256
           mov di,dx
           shl dx,2 ; Y = Y*64
           add di,dx
           add di,cx ; di = Y*320 + X
    
           sub di,8964 ; Offset Calculated, i.e go 30 rows up to the top left of the car
    
    
           mov ax,0xa000
           mov es,ax
    
           mov si,di
           add si,320
    
           push es
           pop ds
    
           mov cx,24
           mov dx,35
           cld
move_car_up_l1:
              push cx
              push di
              push si
       
move_car_up_l2:
               rep movsb
       
                pop si
                pop di
                pop cx
                add di,320
                add si,320
                dec dx
                jnz move_car_up_l1
       
              ; make the last row grey
              mov cx,24
              mov al,0x07
              rep stosb
       
       
move_car_up_exit:
                 pop es
                 pop ds
                 popa
                 pop bp
                 ret 4
                 
                 
                 
erase_object:
           push bp
           mov bp,sp
           pusha
           push ds
           push es
    
           mov cx,[bp+4]
           mov dx,[bp+6]
    
           shl dx,6 ; Y = Y*256
           mov di,dx
           shl dx,2 ; Y = Y*64
           add di,dx
           add di,cx ; di = Y*320 + X
    
           add di,636 ; Offset Calculated
    
           mov ax,0xa000
           mov es,ax
    
           mov si,copied_object
    
           mov cx,22
           mov dx,30
    
erase_object_l1:
              push cx
              push di
       
erase_object_l2:
              mov bl,[es:di]
              mov [si],bl
              add si,1
              mov byte [es:di],0x07 ; light Grey Colour
              add di,1
              loop erase_object_l2
       
              pop di
              pop cx
              sub di,320
              dec dx
              jnz erase_object_l1
       
erase_object_exit:
                 pop es
                 pop ds
                 popa
                 pop bp
                 ret 4

paste_object:
                 push bp
                 mov bp,sp
                 pusha
                 push es
                 push ds
                 
                 mov bx,[bp+4]               ; pass the random number
                 mov ax,0xa000
                 mov es,ax
                
                
                 mov si,[object_add]
                 ; copy on the first line
                 
                 mov al,[spawn_coords+bx]
                 mov ah,0
                 
paste_object_l1: cld
                 mov cx,22
                 mov di,320
                 add di,ax
                 rep movsb 
                 
                 mov [object_add],si
              
                 
                 dec word [object_spawn_line]
                 jz paste_object_reset
                 jmp paste_object_exit
                 
paste_object_reset:
                        mov si,copied_object
                        mov [object_add],si
                        mov word [object_spawn_line],30
                        mov byte [is_active],0
                 
paste_object_exit:

                  pop ds
                  pop es
                  popa
                  pop bp
                  ret 2
                 
print_number:
    push bp
    mov bp, sp
    pusha
    mov dh, [bp+6] ; row
    mov dl, [bp+8] ; col
    mov ax, [bp+4] ; number
    mov di, num_buffer + 5
   
pn_convert:
    mov bx, 10
pn_loop:
    xor dx, dx
    div bx
    add dl, '0'
    mov [di], dl
    dec di
    test ax, ax
    jnz pn_loop
pn_done:
    inc di ; DI now at first digit
    ; --- NEW: compute length properly ---
    mov si, num_buffer + 5
    sub si, di
    inc si ; length = SI
    ; Print using BIOS INT 10h
    push ds
    pop es ; ES = DS (string segment)
    mov ax,[bp+6]
    mov dh,al
    mov ax,[bp+8]
    mov dl,al
    mov bh, 0 ; page
    mov bl, 0x0F ; white
    mov cx, si ; corrected length
    mov bp, di ; pointer to digits
    mov ah, 0x13
    mov al, 1 ; update cursor, write
    int 10h
    popa
    pop bp
    ret 6
make_coin:
    push bp
    mov bp, sp
    pusha
    ; print "Coins: " using BIOS INT 10h AH=13
    push bp ; save frame pointer
    lea bp, [coin_str] ; temporarily point BP at string
    push es
    push ds
    pop es
    mov ah, 0x13
    mov al, 0x01
    mov bh, 0
    mov bl, 0x0f
    mov dh, 10 ; <<< MOVED BELOW Fuel (row 10)
    mov dl, 25
    mov cx, 7
    int 0x10
    pop es
    pop bp ; restore original frame pointer
    ; print the numeric coin count (preserves original call convention)
    push word 24 ; <<< row 10
    push word 36 ; col (aligned after "Coins: ")
    push word 0 ; coin count
    call print_number
    popa
    pop bp
    ret 2
make_fuel_gauge:
    push bp
    mov bp,sp
    pusha
    ; --- print "Fuel: " using BIOS safely ---
    push bp
    lea bp,[fuel_str]
    push es
    push ds
    pop es
    mov ah,0x13
    mov al,0x01
    mov bh,0
    mov bl,0x0f
    mov dh,7
    mov dl,25
    mov cx,6
    int 0x10
    pop es
    pop bp
    ; --- Draw outline: black 12w x 42h at x=265 ---
    mov ax,0c00h
    mov cx, 265
    mov dx, 63
    mov si, 42
outline_y:
    push cx
    mov di, 12
outline_x:
    int 10h
    inc cx
    dec di
    jnz outline_x
    pop cx
    dec dx
    dec si
    jnz outline_y
    ; --- Draw inner background: dark gray 10w x 40h at x=266 ---
    mov ax, 0c08h
    mov cx, 266
    mov dx, 62
    mov si, 40
empty_y:
    push cx
    mov di, 10
empty_x:
    int 10h
    inc cx
    dec di
    jnz empty_x
    pop cx
    dec dx
    dec si
    jnz empty_y
    ; --- Choose bar color based on current level ---
    mov si, [bp+4]
    cmp si, 4
    jbe level_ok
    mov si, 4
level_ok:
    cmp si, 0
    je fuel_done
    mov ax, 0c0ah ; default = light green
    cmp si, 3
    jae got_color
    cmp si, 2
    je yellow_color
    mov ax, 0c0ch ; 1 bar = bright red
    jmp got_color
yellow_color:
    mov ax, 0c0eh ; 2 bars = yellow
got_color:
    mov dx, 62
    mov cx, 266
fuel_level_loop:
    push si
    push cx
    push dx
    mov si, 9
bar_loop_y:
    push cx
    mov di, 10
bar_loop_x:
    int 10h
    inc cx
    dec di
    jnz bar_loop_x
    pop cx
    dec dx
    dec si
    jnz bar_loop_y
    pop dx
    pop cx
    pop si
    sub dx, 10
    dec si
    jnz fuel_level_loop
fuel_done:
    popa
    pop bp
    ret 2
make_coin_on_road:
push bp
mov bp, sp
pusha
mov al, 0Eh ; yellow pixel color
mov ah, 0Ch ; write graphics pixel
mov bh, 0 ; page
; Compute starting x = col * 8
mov cl, [bp+4] ; col
xor ch, ch
shl cx, 3
; Compute starting y = row * 8
mov dl, [bp+6] ; row
xor dh, dh
shl dx, 3
lea si, [coin_bitmap]
mov di, 8 ; 8 rows
draw_row:
push cx ; save starting x
mov bl, [si]
inc si
mov bh, 8 ; 8 bits
draw_bit:
shl bl, 1
jnc skip_plot
int 10h ; plot pixel
skip_plot:
inc cx ; next x
dec bh
jnz draw_bit
pop cx ; restore x
inc dx ; next y row
dec di
jnz draw_row
popa
pop bp
ret 4

timer_interval:
                 cmp byte [first_coin],1
                 jne timer_interval_l1
                 inc word [wait_timer]
                 cmp word [wait_timer],70
                 jne timer_interval_l1
                 mov word [wait_timer],0
                 mov byte [first_coin],0
 
timer_interval_l1:  
                      
                
                 inc word [timer_count]
                 cmp word [timer_count],73
                 jne skip_timer_1
                 
                 mov byte [is_active],1
                 call random_num
                 mov [object_lane_no],ax
                 mov word [timer_count],0
                 

skip_timer_1:
                inc word [coin_timer]
                cmp word [coin_timer],123
                jne skip_coin_timer
                
                mov byte [is_coin_active],1
                call random_num_coin
                mov [coin_lane_no],ax
                mov word [coin_timer],0
                cmp ax,[object_lane_no]
                jne skip_coin_timer
                mov byte [is_coin_active],0

skip_coin_timer:
                    
                    cmp byte [is_coin_active],1
                    jne skip_timer
                    push word [coin_lane_no]
                    call paste_coin
                    
                 
                 
skip_timer:
                 
                 cmp byte [is_active],1
                 jne timer_exit
                 push word [object_lane_no]
                 call paste_object
                 
                 
timer_exit:             
                 call car_movement
                 call scroll_down
                 push word [car_coords+2]
                 push word [car_coords]
                 call move_car_up
                
                 ret

random_num:
            push bp
            push cx
            push dx
            
            push ds
                        
            mov ax, 0x40
            mov ds, ax
            mov bx, [0x006C]       ; low word
            mov dx, [0x006E]       ; high word
            xor bx, dx             ; combine both
            mov ax, bx             ; AX is your seed
            
            mov dx,ax
            mov dx,0
            
            pop ds
            
            mov cx,3
            div cx
            mov ax,dx
            
random_num_exit:           pop dx
                           pop cx
                           pop bp
                           ret
                           
                           
                           
random_num_coin:
            push bp
            push cx
            push dx
            
            push ds
                        
            mov ax, 0x40
            mov ds, ax
            mov bx, [0x006C]       ; low word
            mov dx, [0x006E]       ; high word
            add bx, dx             ; combine both
            mov ax, bx             ; AX is your seed
            
            mov dx,ax
            mov dx,0
            
            pop ds
            
            mov cx,3
            div cx
            mov ax,dx
            
random_num_coin_exit:      pop dx
                           pop cx
                           pop bp
                           ret
                           


paste_object_2:
           push bp
           mov bp,sp
           pusha
           push ds
           push es
    
           mov cx,[bp+4]
           mov dx,[bp+6]
    
           shl dx,6 ; Y = Y*256
           mov di,dx
           shl dx,2 ; Y = Y*64
           add di,dx
           add di,cx ; di = Y*320 + X
    
           add di,636 ; Offset Calculated
    
           mov ax,0xa000
           mov es,ax
    
           mov si,copied_object
    
           mov cx,22
           mov dx,30
    
paste_object_l1_2:
              push cx
              push di
       
paste_object_l2_2:
              mov bl,[si]
              mov [es:di],bl
              add si,1
              add di,1
              loop paste_object_l2_2
       
              pop di
              pop cx
              sub di,320
              dec dx
              jnz paste_object_l1_2
       
paste_object_exit_2:
                 pop es
                 pop ds
                 popa
                 pop bp
                 ret 4


kbisr:
            pusha
            push ds
            push es
            
            mov ax,cs
            mov ds,ax
             
            mov ax,0
            
            in al,0x60
            
            cmp al,0xcb ; was the left arrow key released?
            jne kbisr_l1
            mov byte [is_left_arrow_key_pressed],0
            jmp kbisr_exit
            
kbisr_l1:   cmp al,0x4b ; is the left arrow key pressed?
            jne nextcmp
            
            cmp byte [is_left_arrow_key_pressed],1   ; was the left arrow key already pressed?
            je  kbisr_exit
            mov byte [shift_car_left],1
            
            jmp kbisr_exit
            
nextcmp:
            cmp al,0xcd ; was the right arrow key released?
            jne kbisr_l2
            mov byte [is_right_arrow_key_pressed],0
            jmp kbisr_exit
            
kbisr_l2:
            cmp al,0x4d ; is the right arrow key pressed?
            jne kbisr_exit
            
            cmp byte [is_right_arrow_key_pressed],1   ; was the right arrow key already pressed?
            je  kbisr_exit
            
            mov byte [shift_car_right],1

kbisr_exit:
             mov al,0x20    ; send EOI 
             out 0x20,al
             
             pop es
             pop ds
             popa
             iret
            

move_car_left:
                cmp byte [car_lane_no],0
                je move_car_left_exit
                   
                   
                 push word [car_coords+2]
                 push word [car_coords]
                 call erase_car
                 
                 sub word [car_coords],40    ; update coordinates of car
                 dec byte [car_lane_no]      ; update lane number of car
                 mov byte [is_left_arrow_key_pressed],1 ; arrow key is now pressed
                 sub word [hitbox_coords],40
                 sub word [hitbox_coords+2],40
                 sub word [hitbox_coords+4],40
                 sub word [hitbox_coords+6],40
                 
                push word [car_coords+2]
                push word [car_coords]
                call paste_car

move_car_left_exit:                  
                mov byte [shift_car_left],0
                 
                ret


move_car_right:
                 cmp byte [car_lane_no],2
                 je move_car_right_exit
                 push word [car_coords+2]
                 push word [car_coords]
                 call erase_car
                 
                 add word [car_coords],40    ; update coordinates of car
                 inc byte [car_lane_no]      ; update lane number of car
                 mov byte [is_right_arrow_key_pressed],1 ; arrow key is now pressed
                 add word [hitbox_coords],40
                 add word [hitbox_coords+2],40
                 add word [hitbox_coords+4],40
                 add word [hitbox_coords+6],40
                 push word [car_coords+2]
                 push word [car_coords]
                 call paste_car
move_car_right_exit:                 
                 mov byte [shift_car_right],0

                 ret



make_grey:
               push bp
               mov bp,sp
               
               push es
               push ds
              
               
           
    
           mov cx,[bp+4]
           mov dx,[bp+6]
    
           shl dx,6 ; Y = Y*256
           mov di,dx
           shl dx,2 ; Y = Y*64
           add di,dx
           add di,cx ; di = Y*320 + X
    
           add di,636 ; Offset Calculated
    
           mov ax,0xa000
           mov es,ax
    
           mov cx,22
           mov dx,32
               
           mov al,0x07 ; light grey colour    
make_grey_l1:
                push cx     
                push di
make_grey_l2:
              std
              rep stosb       
                                    
              pop di
              pop cx
              sub di,320
              dec dx
              jnz erase_car_l1
       
make_grey_exit:
                 pop ds
                 pop es
                 popa
                 pop bp
                 ret 4
                 
             

car_movement:
                        cmp byte [shift_car_right],1
                        jne car_movement_l2
                        call move_car_right
                        jmp car_movement_l3
car_movement_l2:
                        cmp byte [shift_car_left],1
                        jne car_movement_l3
                        call move_car_left
car_movement_l3:
                        ret


detect_coin:
                    pusha
                    push es
                    push ds
                    
                    mov ax,0xa000
                    mov es,ax
                    
                    mov si,[hitbox_coords]
                    
                    cmp byte [first_coin],1
                    je near detect_coin_exit
detect_coin_l1:
                    cmp byte [es:si],0x0e
                    jne detect_coin_l2
                    inc word [coins_collected]
                    push word 24
                    push word 36
                    push word [coins_collected]
                    call print_number
                    mov byte [first_coin],1
                    jmp detect_coin_exit

detect_coin_l2:
                    mov si,[hitbox_coords+2]
                    cmp byte [es:si],0x0e
                    jne detect_coin_l3
                    inc word [coins_collected]
                    push word 24
                    push word 36
                    push word [coins_collected]
                    call print_number
                    mov byte [first_coin],1
                    jmp detect_coin_exit

detect_coin_l3:
                    mov si,[hitbox_coords+4]
                    cmp byte [es:si],0x0e
                    jne detect_coin_l4
                    inc word [coins_collected]
                    push word 24
                    push word 36
                    push word [coins_collected]
                    call print_number
                    mov byte [first_coin],1
                    jmp detect_coin_exit
                    

detect_coin_l4:
                    mov si,[hitbox_coords+6]
                    cmp byte [es:si],0x0e
                    jne detect_coin_exit
                    inc word [coins_collected]
                    push word 24
                    push word 36
                    push word [coins_collected]
                    call print_number
                    mov byte [first_coin],1
detect_coin_exit:
                        pop ds
                        pop es
                        popa
                       
                        ret

                    
                    

detect_collision:
                    push ax
                    push es
                    push ds
                    
                    mov ax,0xa000
                    mov es,ax
                    mov si,[hitbox_coords]
detect_collision_l1:
                    cmp byte [es:si],0x07   ; is it still Grey, if not we have hit something
                    je detect_collision_l2
                    cmp byte [es:si],0x0e
                    je detect_collision_exit
                    mov byte [end_game],1
                    jmp detect_collision_exit
detect_collision_l2:                    
                    mov si,[hitbox_coords+2]
                    cmp byte [es:si],0x07
                    je detect_collision_l3
                    cmp byte[es:si],0x0e
                    je detect_collision_exit
                    mov byte [end_game],1
                    jmp detect_collision_exit
detect_collision_l3:                    
                    mov si,[hitbox_coords+4]
                    cmp byte [es:si],0x07
                    je detect_collision_l4
                    cmp byte[es:si],0x0e
                    je detect_collision_exit
                    mov byte [end_game],1
                    jmp detect_collision_exit
detect_collision_l4:
                     mov si,[hitbox_coords+6]
                     cmp byte [es:si],0x07
                     je detect_collision_exit
                    cmp byte[es:si],0x0e
                    je detect_collision_exit
                     mov byte [end_game],1
                     
detect_collision_exit:

                          pop ds
                          pop es
                          pop ax
                             
                          ret
                  
                  
copy_coin:
            pusha
            push es
            push ds
            
           
            
            mov ax,0xa000
            mov es,ax
            
            
            
               mov cx,12
               mov dx,12
               mov di,29534
               mov si,copied_coin
copy_coin_l2:
               push di
copy_coin_l1:  
               mov al,[es:di]
               mov [si],al
               mov byte [es:di], 0x07 ; Clear the space
               add si,1
               add di,1
               loop copy_coin_l1
               
               
               pop di
               sub di,320
               mov cx,12
               dec dx
               jnz copy_coin_l2

copy_coin_exit:
                  pop ds
                  pop es
                  popa
                  ret



paste_coin:
                push bp
                mov bp,sp
                pusha
                push ds
                push es
                
                mov ax,0xa000
                mov es,ax
                
                
                mov bx,[bp+4]   ; Move Lane Number in BX
                
                
                mov si,[coin_add]
                
                mov al,[spawn_coords+bx]
                mov ah,0
                mov di,ax
                add di,320
                mov cx,12
                cld
paste_coin_l1:
                rep movsb
                mov [coin_add],si
                
                dec byte [coin_spawn_line]
                jnz paste_coin_exit
                
                mov byte [coin_spawn_line],12
                mov ax,copied_coin
                mov [coin_add],ax
                mov byte [is_coin_active],0


paste_coin_exit:
                 pop es
                 pop ds
                 popa
                 pop bp
                 ret 2
                 

menu_start:
             call start_screen
             jmp exit_game


game_reset:
                mov word [coin_timer],0
                mov word [coin_spawn_line],12
                mov byte [car_lane_no],1
                mov word [object_spawn_line],30
                mov word [fuel_level],4
                mov word [last_tick],0
                mov byte [shift_car_left],0
                mov byte [shift_car_right],0
                mov byte [end_game],0
                mov byte [first_coin],0
                mov word [wait_timer],0
                mov byte [is_coin_active],0
                mov word [coins_collected],0
                mov byte [coin_lane_no],0
                mov byte [is_right_arrow_key_pressed],0
                mov byte [is_left_arrow_key_pressed],0
                mov byte [is_active],0
                mov word [hitbox_coords],51616
                mov word [hitbox_coords+2],56085
                mov word [hitbox_coords+4],62496
                mov word [hitbox_coords+6],56110
                
                mov dx, 0A0Ah
                mov ah, 2
                mov bx,0
                int 10h
                ;51616,56085,62496,56110
                ret

            
game_start:
mov ax, 0013h
int 0x10

xor ax,ax

mov es,ax

mov ax,[es:9*4]
mov [old_isr],ax
mov ax,[es:9*4+2]
mov [old_isr+2],ax

cli
mov word [es:9*4],kbisr
mov [es:9*4+2],cs
sti

mov word [car_coords],90
mov word [car_coords+2],190

call make_Grass
call make_road
call make_strips ; diagonal yellow/black hazard stripes (arrow-like slant)
push word [car_coords+2]
push word [car_coords]
call make_car

mov word [object_coords],133
mov word [object_coords+2],50


push word [object_coords+2]
push word [object_coords]
call make_object
; trees/lamps...
push word 190
push word 20
call make_tree
push word 140
push word 20
call make_lamp
push word 90
push word 20
call make_tree
push word 40
push word 20
call make_lamp
push word 190
push word 180
call make_tree
push word 140
push word 180
call make_lamp
push word 90
push word 180
call make_tree
push word 40
push word 180
call make_lamp
; initialise fuel
mov word [fuel_level], 4
push word 0
call make_coin
push word [fuel_level]
call make_fuel_gauge
; initialise timer
xor ah, ah
int 1ah ; cx:dx = ticks
mov [last_tick], dx
push word 10
push word 92
call make_coin_on_road


push word [object_coords+2]
push word [object_coords]
call erase_object


push word [car_coords+2]
push word [car_coords]
call erase_car


push word [car_coords+2]
push word [car_coords]
call paste_car

call copy_coin

mov ax,copied_object
mov [object_add],ax

mov ax,copied_coin
mov [coin_add],ax

mov ax,0

mov byte [end_game],0

l1:
       ; ---- FUEL CONSUMPTION (every ~25 seconds) ----
       xor ah, ah
       int 1ah
       mov ax, dx
       sub ax, [last_tick]
       cmp ax, 455 ; 25 seconds ≈ 455 ticks
       jb no_fuel_drop
       add word [last_tick], 455
       mov ax, [fuel_level]
       test ax, ax
       jz no_fuel_drop ; already empty
       dec word [fuel_level]
       push word [fuel_level]
       call make_fuel_gauge
       cmp word [fuel_level], 0
       jne no_fuel_drop
       jmp ending_message
no_fuel_drop:

       cmp byte [end_game],1
       je ending_message
       
      call timer_interval
      call detect_collision
      call detect_coin
        
       
       jmp l1
       
exit_game:
mov ax, 0003h ; back to text mode
int 10h
mov ax, 0x4c00
int 0x21
