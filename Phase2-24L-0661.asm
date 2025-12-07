[org 0x0100]


jmp start

buffer: times 320 db 0 


copied_car: times 841 db 0



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
              mov cx,75
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
              mov cx,120
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
         
       
             mov ax,0c0ah ; light Green Colour for Grass
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
               
             mov ax,0c0ah
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


scroll_down:
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
             push ds        ; save old value for later use
             mov ds,ax
             
             mov cx,199
             mov dx,199
             mov si,63559    ; start at the 2nd last line
             mov di,63879    ; start at the last line
             push si         ; save old offset of si
             
             std             ; set direction flag

                        
scroll_down_l2:
                       rep movsb
                       
                       dec dx
                       cmp dx,0
                       
                       jna scroll_down_exit
                       
                       mov cx,199
                       pop di
                       
                       mov bx, dx
                       shl bx, 6       ; bx = y*64
                       mov si, bx
                       shl bx, 2       ; bx = y*256
                       add si, bx
                       add si,199      ; si = final offset
                       push si
                       jmp scroll_down_l2


scroll_down_exit:
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
           
           shl dx,6      ; Y = Y*256
           mov di,dx
           shl dx,2      ; Y = Y*64
           add di,dx 
           add di,cx     ; di = Y*320 + X
           
           add di,1276   ; Offset Calculated
           
           mov ax,0xa000
           mov es,ax
           
           mov si,copied_car
           
           mov cx,24
           mov dx,35
           
erase_car_l1:
              push cx
              push di
              
erase_car_l2:
              mov bl,[es:di]
              mov [si],bl
              add si,1
              mov byte [es:di],0x07  ; light Grey Colour
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
           
           shl dx,6      ; Y = Y*256
           mov di,dx
           shl dx,2      ; Y = Y*64
           add di,dx 
           add di,cx     ; di = Y*320 + X
           
           add di,1276   ; Offset Calculated
           
           mov ax,0xa000
           mov es,ax
           
           mov si,copied_car
           
           mov cx,24
           mov dx,35
           
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
           
           shl dx,6      ; Y = Y*256
           mov di,dx
           shl dx,2      ; Y = Y*64
           add di,dx 
           add di,cx     ; di = Y*320 + X
           
           sub di,8964  ; Offset Calculated, i.e go 30 rows up to the top left of the car
           
           
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


start:
mov ax, 0013h ; set 320x200 graphics mode
int 0x10 ; bios video services
call make_Grass
call make_road
push word 190
push word 49
call make_car
push word 50
push word 125
call make_object
; Add trees and lamps on left side
push word 190 ; y=190 bottom
push word 20 ; x=20
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
; Add trees and lamps on right side
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

l1:
       push word 190
       push word 49
       call move_car_up
       call scroll_down
       call delay
       jmp l1



mov ax, 0x4c00 ; terminate program
int 0x21