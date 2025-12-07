[org 0x0100]
jmp start
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

old_timer: dd 0

hitbox_coords: dw 51616,56085,62496,56110


shift_car_right: db 0

shift_car_left: db 0


end_game: db 0

coin_lane_no: dw 0

coin_add: dw 0

is_coin_active: db 0



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
    cmp ax, 0
    jne pn_convert
    mov byte [di], '0'
    jmp pn_done
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
    mov ah, 0x13
    mov al, 1 ; update cursor, write
    mov bh, 0 ; page
    mov bl, 0x0F ; white
    mov cx, si ; corrected length
    mov bp, di ; pointer to digits
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
    push word 10 ; <<< row 10
    push word 32 ; col (aligned after "Coins: ")
    push word [bp+4] ; coin count
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
                    mov byte [end_game],1
                    jmp detect_collision_exit
detect_collision_l2:                    
                    mov si,[hitbox_coords+2]
                    cmp byte [es:si],0x07
                    je detect_collision_l3
                    mov byte [end_game],1
                    jmp detect_collision_exit
detect_collision_l3:                    
                    mov si,[hitbox_coords+4]
                    cmp byte [es:si],0x07
                    je detect_collision_l4
                    mov byte [end_game],1
                    jmp detect_collision_exit
detect_collision_l4:
                     mov si,[hitbox_coords+4]
                     cmp byte [es:si],0x07
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
                 


            
start:
mov ax, 0013h
int 0x10

xor ax,ax

mov es,ax



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


; mov ax,0xa000
 ;mov es,ax

; mov byte [es:25694],0x02

mov ax,0


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
       jmp game_over
no_fuel_drop:

       ;cmp byte [end_game],1
       ;je game_over
       
      call timer_interval
      ; call detect_collision
      
        
       
       jmp l1
game_over:
mov ax, 0003h ; back to text mode
int 10h
mov ax, 0x4c00
int 0x21
