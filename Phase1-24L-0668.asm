; draw environment in graphics mode
[org 0x0100]

jmp start



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

          
         
             mov ax,0c0ah     ; light Green Colour for Grass
             mov cx,40        ;  x pos
             mov dx,200       ;  y pos
             
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
               
               mov si,40  ; height of the car
               

               mov ax,0c04h   ; red colour
               mov bh,0
               mov cx,45
               mov dx,190

make_car_l1:
              int 10h
              inc cx
              cmp cx,65
           
                
              jne make_car_l1

              mov cx,45
              dec dx
              dec si
              jnz make_car_l1


              popa
              pop bp 
              ret

make_object:
               push bp
               mov bp,sp
               pusha
 
               mov si,40  ; height of the car
               mov di,20  ; width of the car

               mov ax,0c01h   ; blue colour
               mov bh,0
               mov cx,[bp+4]  ; x pos
               mov dx,[bp+6]  ; y pos
              
                
make_object_l1:
                              
                int 10h
                inc cx
                dec di
                      
                jnz make_object_l1

                mov cx,[bp+4]
                mov di,20
                dec dx
                dec si
                jnz make_object_l1


                popa
                pop bp 
                ret 4


start:

mov ax, 000Dh ; set 320x200 graphics mode
int 0x10       ; bios video services

call make_Grass
call make_road
call make_car
push word 50
push word 125
call make_object

mov ax, 0x4c00 ; terminate program
int 0x21