.486
IDEAL

Macro DrawLine2DDY p1X, p1Y, p2X, p2Y
	local l1, lp, nxt
	mov dx, 1
	mov ax, [p1X]
	cmp ax, [p2X]
	jbe l1
	neg dx ; turn delta to -1
l1:
	mov ax, [p2Y]
	shr ax, 1 ; div by 2
	mov [TempW], ax
	mov ax, [p1X]
	mov [pointX], ax
	mov ax, [p1Y]
	mov [pointY], ax
	mov bx, [p2Y]
	sub bx, [p1Y]
	absolute bx
	mov cx, [p2X]
	sub cx, [p1X]
	absolute cx
	mov ax, [p2Y]
lp:
	pusha
	call PIXEL
	popa
	inc [pointY]
	cmp [TempW], 0
	jge nxt
	add [TempW], bx ; bx = (p2Y - p1Y) = deltay
	add [pointX], dx ; dx = delta
nxt:
	sub [TempW], cx ; cx = abs(p2X - p1X) = daltax
	cmp [pointY], ax ; ax = p2Y
	jne lp
	call PIXEL
ENDM DrawLine2DDY

Macro DrawLine2DDX p1X, p1Y, p2X, p2Y
	local l1, lp, nxt
	mov dx, 1
	mov ax, [p1Y]
	cmp ax, [p2Y]
	jbe l1
	neg dx ; turn delta to -1
l1:
	mov ax, [p2X]
	shr ax, 1 ; div by 2
	mov [TempW], ax
	mov ax, [p1X]
	mov [pointX], ax
	mov ax, [p1Y]
	mov [pointY], ax
	mov bx, [p2X]
	sub bx, [p1X]
	absolute bx
	mov cx, [p2Y]
	sub cx, [p1Y]
	absolute cx
	mov ax, [p2X]
lp:
	pusha
	call PIXEL
	popa
	inc [pointX]
	cmp [TempW], 0
	jge nxt
	add [TempW], bx ; bx = abs(p2X - p1X) = deltax
	add [pointY], dx ; dx = delta
nxt:
	sub [TempW], cx ; cx = abs(p2Y - p1Y) = deltay
	cmp [pointX], ax ; ax = p2X
	jne lp
	call PIXEL
ENDM DrawLine2DDX
Macro absolute a
	local l1
	cmp a, 0
	jge l1
	neg a
l1:
Endm

macro RND
 mov ax, 40h

mov es, ax

mov ax, [es:6Ch]

and ax, 7
endm

MODEL small
STACK 100h

DATASEG

;Player ships:
Ship1_player db 56,1
Ship2_player db 62,63,1
Ship3_player db 35,36,37,1
Ship4_player db 2,12,22,32, 1
Ship5_player db 83,84,85,86,87,1

    Color1 db ?
	Xclick dw ?
	Yclick dw ?
	Xp dw ?
	Yp dw ?
	SquareSize dw ?
	
	
	matrix dw ?
	TempW dw ? ;;;
    pointX dw ? 
	pointY dw ?
    point1X dw ? 
	point1Y dw ?
    point2X dw ? 
	point2Y dw ?
	Color db ? ;;;
	
	;rnd
	RndCurrentPos dw start
	
	;bmp

	PicName equ 'YOUWON.bmp'
	PicName2 equ 'PCWON.bmp'
	OpenScreen equ 'Open1.bmp'
	InstructionsPic equ 'Inst1.bmp'
	InstructionsPic2 equ 'Inst2.bmp'

	FILE_NAME_IN  equ 'MyPic.bmp'
	FILE_NAME_OUT equ 'MyPic2.bmp'


	BMP_WIDTH = 320
	BMP_HEIGHT = 200

	SMALL_BMP_HEIGHT = 48
	SMALL_BMP_WIDTH = 78




	MaxFloodStackDepth = 50

	Fill_Color = 8
	Fill_Color_Border = 0

DATASEG

    OneBmpLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer
   
    ScrLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer

	;BMP File data
	PlayerPic 	db PicName ,0
	PCPic 	db PicName2 ,0
	Screen db OpenScreen, 0
	Instructions db InstructionsPic, 0
	Instructions2 db InstructionsPic2, 0
	FileNameOut	db FILE_NAME_OUT ,0
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	
	SmallPicName db 'Pic48X78.bmp',0
	
	
	BmpFileErrorMsg    	db 'Error At Opening Bmp File ',FILE_NAME_IN, 0dh, 0ah,'$'
	ErrorFile           db 0
    BB db "BB..",'$'
	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?
	
	
		MOUSE_COLORred equ 127 ; red
	MOUSE_COLORgreen equ 255 ; green
	MOUSE_COLORblue equ 127 ; blue

;-----------------------------------------------------------------------------------------------------------------------------------
;PROJECT VARIABLES

	shipStatusPlayer db 4 dup(2)   ;; 2 - wasnt danaged, 1 - partly damaged, 0 - destroyed
	shipStatuSystem db 4 dup(2)   ;; 2 - wasnt danaged, 1 - partly damaged, 0 - destroyed

	
	Ship1_pc db 100,1
	Ship2_pc db 100,100,1            ;Length: 2. last cell is the ship's status:  1 - not destroyed, 0 - destroyed.
	Ship3_pc db 100,100,100,1       ;Length: 3. last cell is the ship's status:  1 - not destroyed, 0 - destroyed.
	Ship4_pc db 100,100,100,100,1            ;Length: 2. last cell is the ship's status:  1 - not destroyed, 0 - destroyed.
	Ship5_pc db 100,100,100,100,100,1       ;Length: 3. last cell is the ship's status:  1 - not destroyed, 0 - destroyed.

;Player ships:             (too many variables caused their offset to be higher than 255 so they a little higher up)
; Ship1_player db 56,1
; Ship2_player db 62,63,1
; Ship3_player db 35,36,37,1
; Ship4_player db 2,12,22,32, 1
; Ship5_player db 83,84,85,86,87,1


	playerScreen db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ;10X10    PLAYERS ships - Right, the scrren the pc looks at 
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 
	SystemScreen db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ;10X10    PLAYERS ships - Right, the scrren the pc looks at 
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 				 
				 
	WereChecked  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    ;10X10  An array that checks duplicates in the system random cells (so it doesnt try the same cell more than once)
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
				 
				 
	SpaceAroundHit db 0,0,0,0,0,0,0,0,0
				   db 0,0,0,0,0,0,0,0,0
				   db 0,0,0,0,0,0,0,0,0
				   db 0,0,0,0,0,0,0,0,0
				   db 0,0,0,0,1,0,0,0,0     ; 1 - 40
				   db 0,0,0,0,0,0,0,0,0
				   db 0,0,0,0,0,0,0,0,0
				   db 0,0,0,0,0,0,0,0,0
				   db 0,0,0,0,0,0,0,0,0
				 
			
	
; GetCellCordinatesByPress && GetArrayLocation
	CordinateSaverX dw ?
	CordinateSaverY dw ?
	PressX dw ?
	PressY dw ?
;---------------
;PaintSelectedCell
	CellColor db 4
	Color_Found_Ship equ 3
	Color_No_Ship equ 4
;----------
;PCMove
	SelectedCell db ?
;------------
;UpdateArray
	NoShipWasntPressed equ 0
	ThereIsAshipWasntPressed equ 1
	NoShipWasPressed equ 2
	ThereIsAshipWasPressed equ 3
;-------------
;GetRemainingPcShips
	GameOver db 0
;-------------
;NextMoveAfterHitPc
	DontGoLeft  db 0
	DontGoRight db 0
	DontGoUp    db 0
	DontGoDown  db 0
	AttackRightLeft db 0
	AttackUpDown db 0
	LastHit db 0
;-------------
;KeepHittingShip
	FirstHit db 100
	SelectedCellInArrayKeepHitting db 0
	CurrentlyDestroingAShip db 0
	AmountOfShipsAtFirstHit db 0 ;(last bit is for the amount of ships before)
;--------------
;DrawShipsForPlayerToLocate
	color_for_ship_locating equ 5
	Color_Fully_Destroyed equ 13
;--------------
;GetCellCordinatesByPressForPC
	CordinateSaverXPC dw ?
	CordinateSaverYPC dw ?
	PressXPC dw ?
	PressYPC dw ?
;---------------
;LocateShips
	ChosenShip db 0
	ShipArray db offset Ship1_player, offset Ship2_player, offset Ship3_player, offset Ship4_player, offset Ship5_player
;ShipArray db 1 dup(offset Ship1_player, offset Ship2_player, offset Ship3_player, offset Ship4_player, offset Ship5_player)
	ShipSaverArray db 101,101,101,101,101
	ShipVerticalOrHorizonal db 0,0,0,1,0   ;horizonal = 0 , vertical = 1.
	AxSaver dw 0
	MouseReleaseX dw 0
	MouseReleaseY dw 0
;---------------
;RandomShipLocationPC
	ShipPotentialLocation db 101,101,101,101,101
	CODESEG
start:
	mov ax, @data
	mov ds, ax

;horizonal	
;---------------------------------------------;
; input: point1X point1Y,         ;
; 		 point2X point2Y,         ;
;		 Color                                ;
; output: line on the screen                  ;
;---------------------------------------------;
	
;rect - cx = col dx= row al = color si = height di = width	
	
	
; in dx how many cols 
; in cx how many rows
; in matrix - the bytes
; in di start byte in screen (0 64000 -1)

; --------------------------
; Your code here
; --------------------------
call SetGraphic



	mov dx, offset Screen
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] ,200
	call OpenShowBmp
	
		
	;wait for press
	loopTilPress11:
	mov bx, 0
	mov ax, 3
	int 33h
	cmp bx, 1
	jne loopTilPress11

StartGame:	

	mov ax, 2
	int 33h
	
	mov cx, 0
	mov dx, 0
	mov al, 4
	mov si, 200
	mov di, 320
	call Rect
		
;Locate Pc Ship Randomly:

	push offset Ship1_pc
	mov ax, 1
	push ax		
	call RandomShipLocationPC
	
	
	push offset Ship2_pc
	mov ax, 2
	push ax		
	call RandomShipLocationPC
	
	push offset Ship3_pc
	mov ax, 3
	push ax		
	call RandomShipLocationPC
	
	
	push offset Ship4_pc
	mov ax, 4
	push ax		
	call RandomShipLocationPC
	
	
	push offset Ship5_pc
	mov ax, 5
	push ax		
	call RandomShipLocationPC
	
	
	; mov ax, 0
	; int 16h
	
	
; fill SystemScreen:

	mov si, 0
	mov cx, 1
loopFill1:
		mov al, [Ship1_pc+si]
		mov ah, 0
		mov di, ax
		mov [SystemScreen+di], 1
		inc si
		loop loopFill1
		
	mov si, 0
	mov cx, 2
loopFill2:
		mov al, [Ship2_pc+si]
		mov ah, 0
		mov di, ax
		mov [SystemScreen+di], 1
		inc si
		loop loopFill2
		
	mov si, 0
	mov cx, 3
loopFill3:
		mov al, [Ship3_pc+si]
		mov ah, 0
		mov di, ax
		mov [SystemScreen+di], 1
		inc si
		loop loopFill3
		
	mov si, 0
	mov cx, 4
loopFill4:
		mov al, [Ship4_pc+si]
		mov ah, 0
		mov di, ax
		mov [SystemScreen+di], 1
		inc si
		loop loopFill4
		
	mov si, 0
	mov cx, 5
loopFill5:
		mov al, [Ship5_pc+si]
		mov ah, 0
		mov di, ax
		mov [SystemScreen+di], 1
		inc si
		loop loopFill5
		
		
	call LoadLocationInstructions
	call DrawSecondTable
	call DrawShipsForPlayerToLocate
	
	call LoopDelay1Sec
	
LoopShipLocating:

	mov cx, 50
@@Delay1:
	loop @@Delay1	
	mov ax, 1
	int 33h	
	mov ax, 0
	mov ah, 1
	int 16h
	jz ContinueLocating
	cmp ax, 1C0Dh    ;enter
	jne ContinueLocating
	call ShowAxDecimal
	jmp Start_Game

ContinueLocating:

	 mov ax, 3
	 int 33h
	 cmp bx, 2
	 je RotateShip
	 cmp bx, 1
	 jne LoopShipLocating
	 call PlayerLocateShips
	 call LittleDelay
	  jmp LoopShipLocating
RotateShip:
	 call PlayerRotateShip
	 call LittleDelay
	 
	 
	; mov bx, offset Ship4_player
	; mov cx, 4
	; mov si, 0
	; @@loopPrintShip444:
	; mov al, [byte bx+si]
	; mov ah, 0
	; call ShowAxDecimal
	; inc si
	; loop @@loopPrintShip444
	 
	 
	 jmp LoopShipLocating
	
Start_Game:	
	mov ax, 2
	int 33h

;background
mov cx, 0
	mov dx, 0
	mov al, 4
	mov si, 200
	mov di, 320
	call Rect
	
;gameboard background has to be black:
	mov cx, 22
	mov dx, 48
	mov al, 0
	mov si, 120
	mov di, 120
	call Rect
		
	mov cx, 178
	mov dx, 48
	mov al, 0
	mov si, 120
	mov di, 120
	call Rect
	

	call DrawFirstTable
	call DrawSecondTable
	call LoadGameInstructions
	
	mov ax, 1
	int 33h
	
	
	call UpdatePlayerScreenArrayAfterLocating
	mov cx, 100
	 
LoopForCheck:
push cx
	
loopTilPress:
	mov bx, 0
	mov ax, 3
	int 33h
	cmp bx, 1
	jne loopTilPress

	
	call CheckValidPress
	cmp ax, 1         ;invalid
	je loopTilPress
	
	
	call PlayerClick
	call PaintFullyDestroyedShips
	cmp [GameOver], 1
	je EndMenu
	call PCMove
	call PaintFullyDestroyedShips
	

	mov ax, 1
	int 33h
	pop ax
	mov cx, ax
	push cx
	call LittleDelay       ;NECESSARY
	
	
	cmp [GameOver], 2
	je EndMenu
	
	pop cx
	loop LoopForCheck
	
EndMenu:
		 call Menu
		 cmp ax, 2
		 je exit
		
; play again:
		
	call ResetAllVariables
	int 9h
	mov ah,08h   ;clean keyboard buffer            
	int 21h
	jmp StartGame
	
EndMain:
exit:
	
	mov ax, 2
	int 10h
	mov ax, 4c00h
	int 21h
	
;-----------------------------------------------------------------------------------------------------------------------------------
;PROJECT PROCS



proc ResetAllVariables

	mov cx, 100
	mov si, 0
@@reset1:
	mov [WereChecked+si], 0
	inc si
	loop @@reset1

	mov cx, 100
	mov si, 0
@@reset2:
	mov [playerScreen+si], 0
	inc si
	loop @@reset2
	
	mov cx, 100
	mov si, 0
@@reset3:
	mov [SystemScreen+si], 0
	inc si
	loop @@reset3
	
	; mov [SystemScreen+48], 1
	; mov [SystemScreen+1], 1
	; mov [SystemScreen+2], 1
	; mov [SystemScreen+15], 1
	; mov [SystemScreen+16], 1
	; mov [SystemScreen+17], 1
	; mov [SystemScreen+92], 1
	; mov [SystemScreen+93], 1
	; mov [SystemScreen+94], 1
	; mov [SystemScreen+95], 1
	; mov [SystemScreen+21], 1
	; mov [SystemScreen+31], 1
	; mov [SystemScreen+41], 1
	; mov [SystemScreen+51], 1
	; mov [SystemScreen+61], 1

	
	
	mov [GameOver], 0
	
	mov [Ship1_player], 56
	mov [Ship2_player], 62
	mov [Ship2_player+1], 63
	mov [Ship3_player], 35
	mov [Ship3_player+1], 36
	mov [Ship3_player+2], 37
	mov [Ship4_player], 2
	mov [Ship4_player+1], 12
	mov [Ship4_player+2], 22
	mov [Ship4_player+3], 32
	mov [Ship5_player], 83
	mov [Ship5_player+1], 84
	mov [Ship5_player+2], 85	
	mov [Ship5_player+3], 86
	mov [Ship5_player+4], 87
	
	mov [Ship1_player+1], 1
	mov [Ship2_player+2], 1
	mov [Ship3_player+3], 1
	mov [Ship4_player+4], 1
	mov [Ship5_player+5], 1
	
	mov [Ship1_pc+1], 1
	mov [Ship2_pc+2], 1
	mov [Ship3_pc+3], 1
	mov [Ship4_pc+4], 1
	mov [Ship5_pc+5], 1
	
	mov [AmountOfShipsAtFirstHit],0
	mov [CurrentlyDestroingAShip], 0
	mov [SelectedCellInArrayKeepHitting], 0
	mov [FirstHit], 100
	mov cx, 40
	mov si, 0
	@@LoopResetAlgorithemArray11:
	mov [SpaceAroundHit+si], 0
	inc si
	loop @@LoopResetAlgorithemArray11

	mov [SpaceAroundHit+si], 1
	inc si

	mov cx, 40
	@@LoopResetAlgorithemArray21:
	mov [SpaceAroundHit+si], 0
	inc si
	loop @@LoopResetAlgorithemArray21
	
	ret
	endp ResetAllVariables

;Debug proc
proc PrintSpaceArray

	push cx
	push si
	push bx

	mov si, 0
	mov cx, 5
	mov bx, 38
	add bx, offset SpaceAroundHit
	loopPrint:
	mov al, [bx+si]
	mov ah, 0
	call ShowAxDecimal
	inc si
	loop loopPrint

	pop bx
	pop si
	pop cx

	ret 
endp PrintSpaceArray

;Debug proc
proc PrintFullSpaceArray

	pusha
; delete previous prints
;set cursor position:
	mov ah, 2
	mov bh, 0
	mov dh, 0
	mov dl, 0
	int 10h

;black rect:
	mov cx, 0
	mov dx, 0
	mov di, 320
	mov si, 48
	mov al, 0
	call Rect

;set cursor position:
	mov ah, 2
	mov bh, 0
	mov dh, 0
	mov dl, 0
	int 10h

	mov si, 0
	mov cx, 81
@@loopPrintArray:
	mov al, [SpaceAroundHit+si]
	mov ah, 0
	call ShowAxDecimal
	inc si
	loop @@loopPrintArray

	call LoopDelay1Sec
	call LoopDelay1Sec
	call LoopDelay1Sec
	call LoopDelay1Sec

	popa
	ret
endp PrintFullSpaceArray

proc LoadLocationInstructions

	mov dx, offset Instructions
	mov [BmpLeft], 22
	mov [BmpTop], 48
	mov [BmpColSize], 150
	mov [BmpRowSize] ,94
	call OpenShowBmp
	
	ret
	endp LoadLocationInstructions
	
proc LoadGameInstructions

	mov dx, offset Instructions2
	mov [BmpLeft], 12
	mov [BmpTop], 2
	mov [BmpColSize], 140
	mov [BmpRowSize] ,40
	call OpenShowBmp
	
	ret
	endp LoadGameInstructions

proc Menu
	
	call LittleDelay
	
	mov ax, 2
	int 33h
	

	cmp [GameOver], 2
	je PcWIns
	
	mov dx, offset PlayerPic
	mov [BmpLeft],40
	mov [BmpTop],25
	mov [BmpColSize], 240
	mov [BmpRowSize] ,150
	call OpenShowBmp
	jmp @@loopWaitForMenuPress
	
PcWIns:
	
	mov dx, offset PcPic
	mov [BmpLeft],40
	mov [BmpTop],25
	mov [BmpColSize], 240
	mov [BmpRowSize] ,150
	call OpenShowBmp
	

@@loopWaitForMenuPress:
mov ax, 1
int 33h
	mov bx, 0
	mov ax, 3
	int 33h
	cmp bx, 1
	jne @@loopWaitForMenuPress

	shr cx, 1
	
	cmp cx, 95
	jb @@TryExitButton
	
	cmp cx, 210
	ja @@TryExitButton
	
	cmp dx, 87
	jb @@TryExitButton
	
	cmp dx, 108
	ja @@TryExitButton
	
; PLAY AGAIN
	mov ax, 1
	jmp @@EndThisProc
	
@@TryExitButton:
	
	cmp cx, 95
	jb @@loopWaitForMenuPress
	
	cmp cx, 210
	ja @@loopWaitForMenuPress
	
	cmp dx, 125
	jb @@loopWaitForMenuPress
	
	cmp dx, 144
	ja @@loopWaitForMenuPress
	
	mov ax, 1
	int 33h
	
; EXIT
		mov ax, 2
		jmp @@EndThisProc
		
	@@EndThisProc:
	mov [GameOver], 0
	
	
	
	ret 
	Endp Menu


proc RandomShipLocationPC

;Get a random cell, generate weither it will be horizonal or vertical, and check validty.
	push bp
	mov bp, sp
	sub sp, 4

;[bp+4] -> ship length
;[bp+6] -> ship offset
jmp @@loopGenerateShip

@@loopGenerateShip2:  ;jumps from a certain place in code the requires that.
pop ax
pop ax

@@loopGenerateShip:
	mov bl, 0
	mov bh, 99
	call RandomByCs
	mov [bp-2], ax  ;Generated Cell 

	mov bl, 0
	mov bh, 1
	call RandomByCs
	mov [bp-4], ax    ;1 - vertical ship. 0 - horizonal ship
	cmp [bp-4], 1
	je @@Vertical2
;HORIZONAL
	mov cx, [bp+4]
	mov si, 0
	mov ax, [bp-2]
	@@FillPotentialLocation2:
	mov [ShipPotentialLocation+si], al
	mov dx, si
	add [ShipPotentialLocation+si], dl
	inc si
	loop @@FillPotentialLocation2


	; mov bx, offset ShipPotentialLocation
		; mov cx, 5
		; mov si, 0
		; @@loopPrintShip10:
		; mov al, [byte bx+si]
		; mov ah, 0
		; call ShowAxDecimal
		; inc si
		; loop @@loopPrintShip10


;now check if the ship can be drawn over only one row.
	mov bx, offset ShipPotentialLocation
	mov al, [byte bx]
	mov ah, 0
	mov si, 10
	mov dx, 0
	div si  ;by that we get the ship's row.
	mov di, ax ;row
	mov si, 0
	mov cx, [bp+4]		
@@loopCheckValidtyInRow111:
	mov al, [byte bx+si]
	mov ah, 0
	push bx
	mov bx, 10
	mov dx, 0
	div bx
	pop bx
	cmp ax, di
	jne @@loopGenerateShip ;meaning the ship will be drawn over 2 rows, generate another ship/
	inc si
	loop @@loopCheckValidtyInRow111

	jmp @@locationFine2

;VERTICAL
@@Vertical2:
	mov cx, [bp+4]
	mov si, 0
	mov ax, [bp-2]
@@FillPotentialLocation2V:
	mov [ShipPotentialLocation+si], al
	push ax
	mov ax, 10
	mov dx, 0
	mul si
	add [ShipPotentialLocation+si], al
	pop ax
	inc si
	loop @@FillPotentialLocation2V



;now check if the ship can be drawn over only one column.
;Check Validty:
	mov si, 0
	mov cx, [bp+4]
	mov bx, offset ShipPotentialLocation
@@loopCheckValidtyInColumn111:
	mov al, [byte bx+si]
	mov ah, 0
	cmp ax, 100
	jge @@loopGenerateShip ;meaning ship is drawn below table y bottom border
	cmp al, 0
	jl @@loopGenerateShip	;meaning ship is drawn above table y upper border
	inc si
	loop @@loopCheckValidtyInColumn111




; mov bx, offset ShipPotentialLocation
		; mov cx, 5
		; mov si, 0
		; @@loopPrintShip10:
		; mov al, [byte bx+si]
		; mov ah, 0
		; call ShowAxDecimal
		; inc si
		; loop @@loopPrintShip10




@@locationFine2:
;Last Check:
;now check if ship is overriding another ship.
;ship1

	cmp [bp+6], offset Ship1_pc
	je @@SkipSameShip12
	mov cx, 1
	mov si, 0
	mov bx, offset ShipPotentialLocation
@@loopCompareLocations12:
	mov al, [Ship1_pc+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [bp+4]
	@@loopCompareLocationsInner12:	
		cmp al, [byte bx+si]
		je @@loopGenerateShip2
		inc si
		loop @@loopCompareLocationsInner12
	pop si
	pop cx
	inc si
	loop @@loopCompareLocations12

@@SkipSameShip12:
;ship2
	cmp [bp+6], offset Ship2_pc
	je @@SkipSameShip22
	mov cx, 2
	mov si, 0
	mov bx, offset ShipPotentialLocation
@@loopCompareLocations22:
	mov al, [Ship2_pc+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [bp+4]
	@@loopCompareLocationsInner22:
		cmp al, [byte bx+si]
		je @@loopGenerateShip2
		inc si
		loop @@loopCompareLocationsInner22
	pop si
	pop cx
	inc si
loop @@loopCompareLocations22

@@SkipSameShip22:

;ship3
	cmp [bp+6], offset Ship3_pc
	je @@SkipSameShip32
	mov cx, 3
	mov si, 0
	mov bx, offset ShipPotentialLocation
@@loopCompareLocations32:
	mov al, [Ship3_pc+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [bp+4]
	@@loopCompareLocationsInner32:
		cmp al, [byte bx+si]
		je @@loopGenerateShip2
		inc si
		loop @@loopCompareLocationsInner32
	pop si
	pop cx
	inc si
	loop @@loopCompareLocations32

@@SkipSameShip32:
;ship4

	cmp [word bp+6], offset Ship4_pc
	je @@SkipSameShip42
	mov cx, 4
	mov si, 0
	mov bx, offset ShipPotentialLocation
	@@loopCompareLocations42:
	mov al, [Ship4_pc+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [word bp+4]
	@@loopCompareLocationsInner42:
		cmp al, [byte bx+si]
		je @@loopGenerateShip2
		inc si
		loop @@loopCompareLocationsInner42
	pop si
	pop cx
	inc si
	loop @@loopCompareLocations42

@@SkipSameShip42:

	cmp [word bp+6], offset Ship5_pc
	je @@SkipSameShip52
	mov cx, 5
	mov si, 0
	mov bx, offset ShipPotentialLocation
	@@loopCompareLocations52:
	mov al, [Ship5_pc+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [word bp+4]
	@@loopCompareLocationsInner52:
		cmp al, [byte bx+si]
		je @@loopGenerateShip2
		inc si
		loop @@loopCompareLocationsInner52
	pop si
	pop cx
	inc si
	loop @@loopCompareLocations52	

@@SkipSameShip52:

;Location Fine!
	mov cx, [bp+4]
	mov si, 0
	mov bx, [bp+6] ;offset
@@loopUpdate2:
	mov bx, [bp+6] ;offset
	mov al, [ShipPotentialLocation+si]
	mov [byte bx+si], al
	; mov bl, al
	; mov bh, 0
	; mov [byte SystemScreen+bx], 1
	inc si
	loop @@loopUpdate2

	pop bp
	add sp, 4
	ret 2
endp RandomShipLocationPC

;The player has to locate their ships on the screen, so draw ships for them to locate.
proc DrawShipsForPlayerToLocate

	mov [CellColor], color_for_ship_locating


;----------------
	mov ax, 56
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell
;---------------

;----------------
	mov ax, 62
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell

	mov ax, 63
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell
;---------------

	mov ax, 35
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell

	mov ax, 36
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell

	mov ax, 37
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell
;----------------

;----------------
	mov ax, 2
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell

	mov ax, 12
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell

	mov ax, 22
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell

	mov ax, 32
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell
;---------------

;----------------
	mov ax, 83
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell

	mov ax, 84
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell

	mov ax, 85
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell

	mov ax, 86
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell

	mov ax, 87
	call ConvertCellNumberIntoCordinatesPc
	call PaintSelectedCell
;---------------

	ret
endp DrawShipsForPlayerToLocate


proc PaintFullyDestroyedShips

	mov [CellColor], Color_Fully_Destroyed

	cmp [Ship1_player+1], 1
	je @@Skip1
	mov cx, 1
	mov si, 0
@@loopPlayer1:
	mov al, [Ship1_player+si]
	mov ah, 0
	push si
	push cx
	call ConvertCellNumberIntoCordinatesPC
	call PaintSelectedCell
	pop cx
	pop si
	inc si
	loop @@loopPlayer1
@@Skip1:
	
	cmp [Ship2_player+2], 1
	je @@Skip2
	mov cx, 2
	mov si, 0
@@loopPlayer2:
	mov al, [Ship2_player+si]
	mov ah, 0
	push si
	push cx
	call ConvertCellNumberIntoCordinatesPC
	call PaintSelectedCell
	pop cx
	pop si
	inc si
	loop @@loopPlayer2
@@Skip2:

	cmp [Ship3_player+3], 1
	je @@Skip3
	mov cx, 3
	mov si, 0
@@loopPlayer3:
	mov al, [Ship3_player+si]
	mov ah, 0
	push si
	push cx
	call ConvertCellNumberIntoCordinatesPC
	call PaintSelectedCell
	pop cx
	pop si
	inc si
	loop @@loopPlayer3
@@Skip3:

	cmp [Ship4_player+4], 1
	je @@Skip4
	mov cx, 4
	mov si, 0
@@loopPlayer4:
	mov al, [Ship4_player+si]
	mov ah, 0
	push si
	push cx
	call ConvertCellNumberIntoCordinatesPC
	call PaintSelectedCell
	pop cx
	pop si
	inc si
	loop @@loopPlayer4
@@Skip4:

	cmp [Ship5_player+5], 1
	je @@Skip5
	mov cx, 5
	mov si, 0
@@loopPlayer5:
	mov al, [Ship5_player+si]
	mov ah, 0
	push si
	push cx
	call ConvertCellNumberIntoCordinatesPC
	call PaintSelectedCell
	pop cx
	pop si
	inc si
	loop @@loopPlayer5
@@Skip5:
	
;pc

	cmp [Ship1_pc+1], 1
	je @@Skip6
	mov cx, 1
	mov si, 0
@@loopPc6:
	mov al, [Ship1_pc+si]
	mov ah, 0
	push si
	push cx
	call ConvertCellNumberIntoCordinates
	call PaintSelectedCell
	pop cx
	pop si
	inc si
	loop @@loopPc6
@@Skip6:

	cmp [Ship2_pc+2], 1
	je @@Skip7
	mov cx, 2
	mov si, 0
@@loopPc7:
	mov al, [Ship2_pc+si]
	mov ah, 0
	push si
	push cx
	call ConvertCellNumberIntoCordinates
	call PaintSelectedCell
	pop cx
	pop si
	inc si
	loop @@loopPc7
@@Skip7:

	cmp [Ship3_pc+3], 1
	je @@Skip8
	mov cx, 3
	mov si, 0
@@loopPc8:
	mov al, [Ship3_pc+si]
	mov ah, 0
	push si
	push cx
	call ConvertCellNumberIntoCordinates
	call PaintSelectedCell
	pop cx
	pop si
	inc si
	loop @@loopPc8
@@Skip8:


	cmp [Ship4_pc+4], 1
	je @@Skip9
	mov cx, 4
	mov si, 0
@@loopPc9:
	mov al, [Ship4_pc+si]
	mov ah, 0
	push si
	push cx
	call ConvertCellNumberIntoCordinates
	call PaintSelectedCell
	pop cx
	pop si
	inc si
	loop @@loopPc9
@@Skip9:


	cmp [Ship5_pc+5], 1
	je @@Skip10
	mov cx, 5
	mov si, 0
@@loopPc10:
	mov al, [Ship5_pc+si]
	mov ah, 0
	push si
	push cx
	call ConvertCellNumberIntoCordinates
	call PaintSelectedCell
	pop cx
	pop si
	inc si
	loop @@loopPc10
@@Skip10:

	ret
endp PaintFullyDestroyedShips


proc UpdatePlayerScreenArrayAfterLocating


	mov bx, offset Ship1_player
	mov cx, 1
	mov si, 0
@@loopUpdateShip1:
	mov al, [byte bx+si]
	mov ah, 0
	mov di, ax
	mov [byte playerScreen +di], 1
	inc si
	loop @@loopUpdateShip1

	mov bx, offset Ship2_player
	mov cx, 2
	mov si, 0
@@loopUpdateShip2:
	mov al, [byte bx+si]
	mov ah, 0
	mov di, ax
	mov [byte playerScreen +di], 1
	inc si
	loop @@loopUpdateShip2

	mov bx, offset Ship3_player
	mov cx, 3
	mov si, 0
@@loopUpdateShip3:
	mov al, [byte bx+si]
	mov ah, 0
	mov di, ax
	mov [byte playerScreen+di], 1
	inc si
	loop @@loopUpdateShip3

	mov bx, offset Ship4_player
	mov cx, 4
	mov si, 0
@@loopUpdateShip4:
	mov al, [byte bx+si]
	mov ah, 0
	mov di, ax
	mov [byte playerScreen +di], 1
	inc si
	loop @@loopUpdateShip4

	mov bx, offset Ship5_player
	mov cx, 5
	mov si, 0
	@@loopUpdateShip5:
	mov al, [byte bx+si]
	mov ah, 0
	mov di, ax
	mov [byte playerScreen +di], 1
	inc si
	loop @@loopUpdateShip5


	ret
endp UpdatePlayerScreenArrayAfterLocating


proc PlayerRotateShip

	push bp
	mov bp, sp
	sub sp, 6

	call GetCellCordinatesByPressForPC
	call GetArrayLocationPC ;in ax
	mov [bp-2], ax ;pressed cell


	mov si, 0
	mov cx, 1
@@loopShip1:
	cmp [Ship1_player+si], al
	je RotatingShip1
	inc si
	loop @@loopShip1

	mov si, 0
	mov cx, 2
@@loopShip2:
	cmp [Ship2_player+si], al
	je RotatingShip2
	inc si
	loop @@loopShip2

	mov si, 0
	mov cx, 3
@@loopShip3:
	cmp [Ship3_player+si], al
	je RotatingShip3
	inc si
	loop @@loopShip3

	mov si, 0
	mov cx, 4
@@loopShip4:
	cmp [Ship4_player+si], al
	je RotatingShip4
	inc si
	loop @@loopShip4

	mov si, 0
	mov cx, 5
@@loopShip5:
	cmp [Ship5_player+si], al
	je RotatingShip5
	inc si
	loop @@loopShip5


	jmp @@exitProc


RotatingShip1:
	mov al, [ShipArray]
	mov ah, 0
	mov [bp-4], ax
	mov ax, 1
	mov [bp-6], ax
	jmp @@Continue2
RotatingShip2:
	mov al, [ShipArray+1] ;= offset ship 2
	mov ah, 0
	mov [bp-4], ax
	mov ax, 2
	mov [bp-6], ax
	jmp @@Continue2
RotatingShip3:
	mov al, [ShipArray+2]
	mov ah, 0
	mov [bp-4], ax
	mov ax, 3
	mov [bp-6], ax
	jmp @@Continue2
RotatingShip4:
	mov al, [ShipArray+3]
	mov ah, 0
	mov [bp-4], ax
	mov ax, 4
	mov [bp-6], ax
	jmp @@Continue2
RotatingShip5:
	mov al, [ShipArray+4]
	mov ah, 0
	mov [bp-4], ax
	mov ax, 5
	mov [bp-6], ax
	jmp @@Continue2

;[bp-2] - pressed cell
;[bp-4] - Ship offset
;[bp-6] - Ship length
@@Continue2:
	mov si, 0
	mov bx, [bp-4]
	mov cx, [bp-6]
@@LoopSaveShip1:  ;in case the new placement is invalid, save the previous location & also used to delete previous ship location on screen
	mov dl, [bx+si]
	mov [ShipSaverArray+si], dl
	inc si
	loop @@LoopSaveShip1



;find the cell's location within the ship array:
	mov si, 0
	mov cx, [bp-6]
	mov bx, [bp-4]
	mov di, [bp-2]
@@loopFindCellLocation:
	mov al, [byte bx+si]
	mov ah, 0
	cmp ax, di
	je @@FoundCellsLocationInArray
	inc si 
	loop @@loopFindCellLocation

@@FoundCellsLocationInArray:

;Continue if rotating from horizonal to vertical, jmp to @@RotateToHorizonal otherwise.
	mov di, [bp-6]
	dec di
	cmp [ShipVerticalOrHorizonal+di], 0
	jne @@RotateToHorizonal

	mov ax, si
;call ShowAxDecimal
;rotation: all cells right to the selected cell go above it, and the cells left to it go below it.
;start with the cells above:
	push si
	mov di, 0
	mov bx, [bp-4]
	mov cx, si
	cmp cx, 0
	je @@SkipThisPart
loopRotateCellsLeft:
	sub si, di
	mov ax, 10
	mov dx, 0
	mul si
	mov dx, [bp-2] ; pressed cell
	mov [byte bx+di], dl
	sub [byte bx+di], al
	add si, di
	inc di 
	loop loopRotateCellsLeft


@@SkipThisPart:
	pop si

;cells below:
	mov cx, [bp-6]
	dec cx
	sub cx, si
	cmp cx, 0
	je @@SkipThisPart1
	mov di, si
	inc di
	mov bx, [bp-4]
@@loopRotateRightCells:
	mov ax, di
	sub ax, si
	mov dx, 0
	push si
	mov si, 10
	mul si
	pop si
	mov dx, [bp-2] ; pressed cell
	mov [byte bx+di], dl
	add [byte bx+di], al
	inc di
	loop @@loopRotateRightCells
	
@@SkipThisPart1:
;Check Validty:
	mov si, 0
	mov cx, [bp-6]
	mov bx, [bp-4]
@@loopCheckValidtyInColumn2:
	mov al, [byte bx+si]
	mov ah, 0
	cmp ax, 100
	jge @@InvalidRotate  ;meaning ship is drawn below table y bottom border
	cmp ax, 100
	jae @@InvalidRotate
	cmp al, 0
	jl @@InvalidRotate	;meaning ship is drawn above table y upper border
	inc si
	loop @@loopCheckValidtyInColumn2



	mov di, [bp-6]
	dec di
	mov [ShipVerticalOrHorizonal+di], 1
	jmp @@ContinueProc
@@InvalidRotate1:
	pop ax
	pop ax

@@InvalidRotate:
	mov cx, [bp-6]
	mov si, 0
	mov bx, [bp-4]
@@loopRevertShip1:
	mov al, [ShipSaverArray+si]
	mov [bx+si], al
	inc si
	loop @@loopRevertShip1
	jmp @@exitProc ;exits proc
	
	
@@RotateToHorizonal:
;cells above pressed cell will be located RIGHT to it
	push si
	mov di, 0
	mov bx, [bp-4]
	mov cx, si
	cmp cx, 0
	je @@SkipThisPart2
@@loopRotateCellsAbove:
	mov dx, [bp-2]
	mov [byte bx+di], dl
	mov ax, di
	inc ax
	add [byte bx+di], al
	inc di
	loop @@loopRotateCellsAbove

@@SkipThisPart2:
;cells below:
	pop si
	mov cx, [bp-6]
	dec cx
	sub cx, si
	cmp cx, 0
	je @@SkipThisPart3
	mov di, si
	inc di
	mov bx, [bp-4]
@@loopRotateCellsBelow:
	mov dx, [bp-2]
	mov [byte bx+di], dl
	mov dx, di
	sub dx, si
	sub [byte bx+di], dl
	inc di
	loop @@loopRotateCellsBelow

@@SkipThisPart3:
;Check Validty:
	mov bx, [bp-4]
	mov al, [byte bx]
	mov ah, 0
	mov si, 10
	mov dx, 0
	div si  ;by that we get the ship's row.
	mov di, ax ;row
	mov si, 0
	mov cx, [bp-6]		
@@loopCheckValidtyInRow1:
	mov al, [byte bx+si]
	mov ah, 0
	push bx
	mov bx, 10
	mov dx, 0
	div bx
	pop bx
	cmp ax, di
	jne @@InvalidRotate ;meaning the ship will be drawn over 2 rows
	inc si
	loop @@loopCheckValidtyInRow1

	
;check that ship doesnt exceed the bounderies of the board:
	mov cx, [bp-6]
	mov bx, [bp-4]
	mov si, 0
@@loopCheckExceedHorizonal1:
	mov al, [byte bx+si]
	mov ah, 0	
	cmp ax, 100
	jge @@InvalidRotate ;edge of map	
	cmp ax, 0
	jl @@InvalidRotate
	inc si
	loop @@loopCheckExceedHorizonal1
	
	

	mov di, [bp-6]
	dec di
	mov [ShipVerticalOrHorizonal+di], 0

@@ContinueProc:


;now check if ship is overriding another ship.
;ship1

	cmp [bp-4], offset Ship1_player
	je @@SkipSameShip11
	mov cx, 1
	mov si, 0
	mov bx, [bp-4]
@@loopCompareLocations11:
	mov al, [Ship1_player+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [bp-12]
	@@loopCompareLocationsInner11:	
		cmp al, [byte bx+si]
		je @@InvalidRotate1
		inc si
		loop @@loopCompareLocationsInner11
	pop si
	pop cx
	inc si
	loop @@loopCompareLocations11

@@SkipSameShip11:
;ship2
	cmp [bp-4], offset Ship2_player
	je @@SkipSameShip21
	mov cx, 2
	mov si, 0
	mov bx, [bp-4]
@@loopCompareLocations21:
	mov al, [Ship2_player+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [bp-6]
	@@loopCompareLocationsInner21:
		cmp al, [byte bx+si]
		je @@InvalidRotate1
		inc si
		loop @@loopCompareLocationsInner21
	pop si
	pop cx
	inc si
loop @@loopCompareLocations21

@@SkipSameShip21:

;ship3
	cmp [bp-4], offset Ship3_player
	je @@SkipSameShip31
	mov cx, 3
	mov si, 0
	mov bx, [bp-4]
@@loopCompareLocations31:
	mov al, [Ship3_player+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [bp-6]
	@@loopCompareLocationsInner31:
		cmp al, [byte bx+si]
		je @@InvalidRotate1
		inc si
		loop @@loopCompareLocationsInner31
	pop si
	pop cx
	inc si
	loop @@loopCompareLocations31

@@SkipSameShip31:
;ship4

	cmp [bp-4], offset Ship4_player
	je @@SkipSameShip41
	mov cx, 4
	mov si, 0
	mov bx, [bp-4]
	@@loopCompareLocations41:
	mov al, [Ship4_player+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [bp-6]
	@@loopCompareLocationsInner41:
		cmp al, [byte bx+si]
		je @@InvalidRotate1
		inc si
		loop @@loopCompareLocationsInner41
	pop si
	pop cx
	inc si
	loop @@loopCompareLocations41

@@SkipSameShip41:

	cmp [bp-4], offset Ship5_player
	je @@SkipSameShip51
	mov cx, 5
	mov si, 0
	mov bx, [bp-4]
	@@loopCompareLocations51:
	mov al, [Ship5_player+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [bp-6]
	@@loopCompareLocationsInner51:
		cmp al, [byte bx+si]
		je @@InvalidRotate1
		inc si
		loop @@loopCompareLocationsInner51
	pop si
	pop cx
	inc si
	loop @@loopCompareLocations51	

@@SkipSameShip51:

 
;print ShipSaverArray
; mov cx, [bp-6]
; mov si, 0
; @@loop_print:
; mov al, [Ship3_player+si]
; mov ah, 0
; call ShowAxDecimal
; inc si
; loop @@loop_print


;Delete previous ship on screen:
	mov ax, 2
	int 33h
	mov cx, [bp-6]
	mov si, 0

@@LoopDeleteShip1:
	push cx
	push si
	mov al, [ShipSaverArray+si]
	mov ah, 0
	call ConvertCellNumberIntoCordinatesPc
	mov [CellColor], 4 ;blue
	call PaintSelectedCell
	pop si
	pop cx
	inc si
	loop @@LoopDeleteShip1

	mov ax,	 1
	int 33h
; now draw the ship at its new location:
	mov ax, 2
	int 33h
	mov cx, [bp-6]
	mov si, 0
	mov bx, [bp-4]

@@LoopDrawShipNewLocation:
	push cx
	push si
	mov al, [byte bx+si]
	mov ah, 0
	call ConvertCellNumberIntoCordinatesPc
	mov [CellColor], color_for_ship_locating
	call PaintSelectedCell
	pop si
	pop cx
	inc si
	loop @@LoopDrawShipNewLocation

	mov ax,	 1
	int 33h

;print ship
; mov bx, [bp-4]
; mov cx, [bp-6]
; mov si, 0
; @@loopPrintShip:
; mov al, [byte bx+si]
; mov ah, 0
; call ShowAxDecimal
; inc si
; loop @@loopPrintShip


@@exitProc:

	pop bp
	add sp, 6
	ret
endp PlayerRotateShip



proc PlayerLocateShips

	push bp
	mov bp,sp
	sub sp, 14

;turn on mouse
	mov ax, 1
	int 33h


	call GetCellCordinatesByPressForPC
	call GetArrayLocationPC ;in ax
	mov [bp-2], ax ;pressed cell



	mov si, 0
	mov cx, 1
@@loopShip1:
	cmp [Ship1_player+si], al
	je PressingOnShip1
	inc si
	loop @@loopShip1

	mov si, 0
	mov cx, 2
@@loopShip2:
	cmp [Ship2_player+si], al
	je PressingOnShip2
	inc si
	loop @@loopShip2

	mov si, 0
	mov cx, 3
@@loopShip3:
	cmp [Ship3_player+si], al
	je PressingOnShip3
	inc si
	loop @@loopShip3

	mov si, 0
	mov cx, 4
@@loopShip4:
	cmp [Ship4_player+si], al
	je PressingOnShip4
	inc si
	loop @@loopShip4

	mov si, 0
	mov cx, 5
@@loopShip5:
	cmp [Ship5_player+si], al
	je PressingOnShip5
	inc si
	loop @@loopShip5

	jmp NotPressingOnAnyShip


;[bp-2] now holds the offset of the ship
;[bp-12] holds its length

PressingOnShip1:
	mov al, [ShipArray]
	mov ah, 0
	mov [bp-2], ax
	mov ax, 1
	mov [bp-12], ax
	jmp @@Continue1
PressingOnShip2:
	mov al, [ShipArray+1] ;= offset ship 2
	mov ah, 0
	mov [bp-2], ax
	mov ax, 2
	mov [bp-12], ax
	jmp @@Continue1
PressingOnShip3:
	mov al, [ShipArray+2]
	mov ah, 0
	mov [bp-2], ax
	mov ax, 3
	mov [bp-12], ax
	jmp @@Continue1
PressingOnShip4:
	mov al, [ShipArray+3]
	mov ah, 0
	mov [bp-2], ax
	mov ax, 4
	mov [bp-12], ax
	jmp @@Continue1
PressingOnShip5:
	mov al, [ShipArray+4]
	mov ah, 0
	mov [bp-2], ax
	mov ax, 5
	mov [bp-12], ax
	jmp @@Continue1

@@Continue1:
	mov ax, [PressXPC]
	mov [bp-4], ax
	mov ax, [PressYPC]
	mov [bp-6], ax
;until left button is released,  check mouse to see how x and y locations change.
@@LoopMouseLocation2:

	mov ax, 3
	int 33h
	cmp bx, 1
	jne @@ButtonReleased

	call GetCellCordinatesByPressForPC
	mov ax, [PressXPC]
	mov [bp-8], ax       ;for comparison
	mov ax, [PressYPC]
	mov [bp-10], ax

	jmp @@LoopMouseLocation2 

@@ButtonReleased:
; now compare the first and last mouse locations in order to determine the new placement of the ships.

	mov ax, [bp-4]  ;first x
	mov bx, [bp-6]  ;first y
	mov cx, [bp-8]  ;last x
	mov dx, [bp-10] ;last y 

	sub cx, ax
	mov ax, cx

	sub dx, bx
	mov bx, dx
	

; ax, bx now hold the "coordinates" - how many cells the ship has been moved
; X , Y

	mov cx, ax ;save x
	mov dx, 10 ;multiplying y by 10 to add to the x, in order to know how many cells in the array to add
	mov ax, bx ; ax now contains y coordinate
	mul dx
	add ax, cx 
	; ax now holds the amount of cells the ships has to be moved.

	mov bx, [bp-2] ;offset of ship
	mov cx, [bp-12] ; ship length
	mov si, 0

@@LoopSaveShip:  ;in case the new placement is invalid, save the previous location & is used to delete previous ship on screen
	mov dl, [bx+si]
	mov [ShipSaverArray+si], dl
	inc si
	loop @@LoopSaveShip

	 


	mov [AxSaver], ax

;print ShipSaverArray
; mov cx, [bp-12]
; mov si, 0
; @@loop_print2:
; mov al, [ShipSaverArray+si]
; mov ah, 0
; call ShowAxDecimal
; inc si
; loop @@loop_print2


;check validty of new location. if invalid - revert ship. 
;first, check where mouse left button was released on screen:
; values ax is compared to are table's top left and bottom right coordinates (= borders)
	mov ax, [MouseReleaseX] ;X
; call ShowAxDecimal
	cmp ax, 168
	jbe @@Invalid
	cmp ax, 298
	jae @@Invalid

	mov ax, [MouseReleaseY] ;Y
	cmp ax, 48
	jb @@Invalid
	cmp ax, 168
	jae @@Invalid
;now, check if the ship can be placed within the same row/column.
;Check if ship's horizonal:
	mov bx, [bp-12] ; ship length
	dec bx
	cmp [ShipVerticalOrHorizonal+bx], 0
	jne @@Vertical

;HORIZONAL

	mov al, [ShipSaverArray] ;first cell.
	mov ah, 0
	add ax, [AxSaver]
	mov si, 10
	mov dx, 0
	div si  ;by that we get the ship's row.
	mov di, ax ;row
	mov si, 1
	mov cx, [bp-12]
	dec cx ;no need to check the first cell.
	cmp cx, 0
	je @@LocationOK
@@loopCheckValidtyInRow:
	mov al, [ShipSaverArray+si]
	mov ah, 0
	add ax, [AxSaver]
	mov bx, 10
	mov dx, 0
	div bx
	cmp ax, di
	jne @@Invalid ;meaning the ship will be drawn over 2 rows
	inc si
	loop @@loopCheckValidtyInRow

;check that ship doesnt exceed the bounderies of the board:
	mov cx, [bp-12]
	mov si, 0
@@loopCheckExceedHorizonal:
	mov al, [ShipSaverArray+si]
	mov ah, 0
	add ax, [AxSaver]
; add ax, si
	cmp ax, 100
	jae @@Invalid ;edge of map
	inc si
	loop @@loopCheckExceedHorizonal

	jmp @@LocationOK
;VERTICAL ship:
@@Vertical:
	mov si, 0
	mov cx, [bp-12]
	cmp cx, 0
	je @@LocationOK
@@loopCheckValidtyInColumn:
	mov bl, [ShipSaverArray]
	mov bh, 0
	mov ax, [AxSaver]  
	mov dx, 0
	mov di, 10
	div di
	push dx
	mov dx, 0
	mul di
	add bx, ax
	pop dx
	add bx, dx
	mov ax, 10
	mov dx, 0
	mul si
	add bx, ax
	cmp bx, 100
	jge @@Invalid1  ;meaning ship is drawn below table y bottom border
	cmp bx, 0
	jl @@Invalid	;meaning ship is drawn above table y upper border
	inc si
	loop @@loopCheckValidtyInColumn
	jmp @@LocationOK


@@Invalid2:
	pop ax
	pop ax
@@Invalid1:

@@Invalid:

	mov cx, [bp-12]
	mov si, 0
	mov bx, [bp-2]
@@loopRevertShip:
	mov al, [ShipSaverArray+si]
	mov [bx+si], al
	inc si
	loop @@loopRevertShip
	jmp NotPressingOnAnyShip ;exits proc


@@LocationOK:


	mov ax, [AxSaver]
	mov bx, [bp-2] 
;Update ship variable with new location
	mov cx, [bp-12]
	mov si, 0
@@LoopUpdateShip:
; mov dl, [byte bx+si]
; add dl, al
; mov [bx+si], dl
	add [bx+si], al
	inc si
	loop @@LoopUpdateShip


;now check if ship is overriding another ship.
;ship1

	cmp [bp-2], offset Ship1_player
	je @@SkipSameShip1
	mov cx, 1
	mov si, 0
	mov bx, [bp-2]
@@loopCompareLocations1:
	mov al, [Ship1_player+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [bp-12]
	@@loopCompareLocationsInner1:	
		cmp al, [byte bx+si]
		je @@Invalid2
		inc si
		loop @@loopCompareLocationsInner1
	pop si
	pop cx
	inc si
	loop @@loopCompareLocations1

@@SkipSameShip1:
;ship2
	cmp [bp-2], offset Ship2_player
	je @@SkipSameShip2
	mov cx, 2
	mov si, 0
	mov bx, [bp-2]
@@loopCompareLocations2:
	mov al, [Ship2_player+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [bp-12]
	@@loopCompareLocationsInner2:
		cmp al, [byte bx+si]
		je @@Invalid2
		inc si
		loop @@loopCompareLocationsInner2
	pop si
	pop cx
	inc si
loop @@loopCompareLocations2

@@SkipSameShip2:

;ship3
	cmp [bp-2], offset Ship3_player
	je @@SkipSameShip3
	mov cx, 3
	mov si, 0
	mov bx, [bp-2]
@@loopCompareLocations3:
	mov al, [Ship3_player+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [bp-12]
	@@loopCompareLocationsInner3:
		cmp al, [byte bx+si]
		je @@Invalid2
		inc si
		loop @@loopCompareLocationsInner3
	pop si
	pop cx
	inc si
	loop @@loopCompareLocations3

@@SkipSameShip3:
;ship4

	cmp [bp-2], offset Ship4_player
	je @@SkipSameShip4
	mov cx, 4
	mov si, 0
	mov bx, [bp-2]
	@@loopCompareLocations4:
	mov al, [Ship4_player+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [bp-12]
	@@loopCompareLocationsInner4:
		cmp al, [byte bx+si]
		je @@Invalid2
		inc si
		loop @@loopCompareLocationsInner4
	pop si
	pop cx
	inc si
	loop @@loopCompareLocations4

@@SkipSameShip4:

	cmp [bp-2], offset Ship5_player
	je @@SkipSameShip5
	mov cx, 5
	mov si, 0
	mov bx, [bp-2]
	@@loopCompareLocations5:
	mov al, [Ship5_player+si]
	mov ah, 0
	push cx
	push si
	mov si, 0
	mov cx, [bp-12]
	@@loopCompareLocationsInner5:
		cmp al, [byte bx+si]
		je @@Invalid2
		inc si
		loop @@loopCompareLocationsInner5
	pop si
	pop cx
	inc si
	loop @@loopCompareLocations5	

@@SkipSameShip5:



;Delete previous ship on screen:
	mov ax, 2
	int 33h
	push ax
	mov cx, [bp-12]
	mov si, 0

@@LoopDeleteShip:
	push cx
	push si
	mov al, [ShipSaverArray+si]
	mov ah, 0
	call ConvertCellNumberIntoCordinatesPc
	mov [CellColor], 4 ;blue
	call PaintSelectedCell
	pop si
	pop cx
	inc si
	loop @@LoopDeleteShip

	mov ax,	 1
	int 33h

	pop ax

; now draw the ship at its new location:
	mov ax, 2
	int 33h
	mov cx, [bp-12]
	mov si, 0

@@LoopDrawShipNewLocation:
	push cx
	push si
	mov al, [bx+si]
	mov ah, 0
	call ConvertCellNumberIntoCordinatesPc
	mov [CellColor], color_for_ship_locating
	call PaintSelectedCell
	pop si
	pop cx
	inc si
	loop @@LoopDrawShipNewLocation

	mov ax,	 1
	int 33h

NotPressingOnAnyShip:
;RESET ARRAY
	mov cx, 5
	mov si, 0
	@@LoopResetArray:
	mov [ShipSaverArray+si], 101
	inc si 
	loop @@LoopResetArray



	pop bp
	add sp, 14

	ret
endp PlayerLocateShips



proc UpdateAlgorithemArray

	cmp [CellColor], Color_Found_Ship
	je @@PCHitAship

	cmp [CellColor], Color_No_Ship
	je @@DidntHitAShip
	
@@PCHitAship:
	mov bl, [SelectedCellInArrayKeepHitting]
	mov bh, 0
	mov [SpaceAroundHit+bx], 1

	jmp @@outproc

@@DidntHitAShip:
	mov bl, [SelectedCellInArrayKeepHitting]
	mov bh, 0
	mov [SpaceAroundHit+bx], 2

@@outproc:


	ret
endp UpdateAlgorithemArray


proc KeepHittingShip

	push bp
	mov bp, sp
	sub sp, 4

	mov al, [FirstHit]
	mov ah, 0
	mov dx, 0
	mov si, 10
	div si
	mov [bp-2], ax  ;row
	mov [bp-4], dx  ;column

; 0 - cell hasnt been cheked yet.
; 1 - hit a ship in that cell.
; 2 - tried the cell, there was no ships.

;check if going right is still an option:
	mov cx, 4
	mov si, 1
@@LoopCheckRight:
	cmp [byte SpaceAroundHit+si+40], 2
	je @@DontGoRight

;check:
	mov ax, [bp-4]  ;the column we are at
	add ax, si
	cmp ax, 9
	ja @@DontGoRight


	cmp [SpaceAroundHit+si+40], 0
	je @@FineRight

	mov al, [SpaceAroundHit+si+40]
	mov ah, 0




	inc si
	loop @@LoopCheckRight


@@FineRight:
	mov dx, si
	add dl, 40
	mov [SelectedCellInArrayKeepHitting], dl
	mov bl, [FirstHit]
	mov bh, 0
	add bx, si
	cmp [WereChecked+bx], 1	
	je @@DontGoRight


;Go right:
	mov al, [FirstHit]
	mov ah, 0
	add ax, si
	mov ah, 0
	jmp @@EndProc1
;--------

@@DontGoRight:
;GoingRight wasnt possible, so try going up.

	mov cx, 4
	mov si, 9
@@LoopCheckUp:
	mov bx, offset SpaceAroundHit
	add bx, 40
	sub bx, si
	cmp [byte bx], 2
	je @@DontGoUp


;The array we work with in this proc is 9X9, and the real array is 10X10
;Some mathematical calculations are neccesary
;check:


	mov ax, [bp-2] ; the line

	mov di, 10
	mov dx, 0
	mul di
	add ax, [bp-4]
	push ax       ;cell number in real array!

	mov ax, si
	mov di, 9
	div di
	mov dx, ax
	pop ax
	sub ax, dx

	sub ax, si
	cmp ax, 0
	jl @@DontGoUp1 

	mov dl, 40
	mov dh, 0
	sub dx, si
	mov [SelectedCellInArrayKeepHitting], dl

	mov bx, offset SpaceAroundHit
	add bx, 40
	sub bx, si
	cmp [byte bx], 0
	je @@FineUp

	add si, 9
	loop @@LoopCheckUp

@@FineUp:

	mov bl, [FirstHit]
	mov bh, 0
	sub bx, si
	mov ax, si
	mov di, 9
	mov dx,0
	div di
	sub bx, ax
	cmp [WereChecked+bx], 1
	je @@DontGoUp


;neccecary
	mov ax, si
	mov dx, 0
	mov di, 9
	div di
	mov di, ax

;Go Up:
	mov al, [FirstHit]
	mov ah, 0
	sub ax, si
	sub ax, di
	mov ah, 0
	jmp @@EndProc1
;----------------
@@DontGoUp1:

@@DontGoUp:

;try going left

	mov cx, 4
	mov si, 1
@@LoopCheckLeft:
	mov bx, offset SpaceAroundHit
	add bx, 40
	sub bx, si
	cmp [byte bx], 2
	je @@DontGoLeft

; mov al, [bx]
; mov ah, 0
; call ShowAxDecimal
;check:
	mov ax, [bp-4] ;column
	sub ax, si
	cmp ax, 0
	jnae @@DontGoLeft1

	mov bx, offset SpaceAroundHit
	add bx, 40
	sub bx, si
	cmp [byte bx], 0
	je @@FineLeft
	inc si
	loop @@LoopCheckLeft

@@FineLeft:
	mov ax, si
	mov bl, [FirstHit]
	mov bh, 0
	sub bx, si
	cmp [WereChecked+bx], 1
	je @@DontGoLeft

	mov dl, 40 
	mov dh, 0
	sub dx, si
	mov [SelectedCellInArrayKeepHitting], dl

;Go Left:
	mov al, [FirstHit]
	mov ah, 0
	sub ax, si
	jmp @@EndProc1	
;------------------

@@DontGoLeft1:
;call ShowAxDecimal
@@DontGoLeft:


	mov si, 0
@@LoopCheckDown:
	add si, 9
	cmp [SpaceAroundHit+si+40], 0
	jne @@LoopCheckDown

	mov dl, 40
	add dx, si
	mov [SelectedCellInArrayKeepHitting], dl


;neccecary
	mov ax, si
	mov dx, 0
	mov di, 9
	div di
	mov di, ax

	mov al, [FirstHit]
	mov ah, 0
	add ax, si
	add ax, di
;------------------

@@EndProc1:
	add sp, 4
	pop bp
	ret
endp KeepHittingShip



;checks if the mouse click was within the player's screen borders.
;on return: ax = 0 -> valid, ax = 1 -> invalid
proc CheckValidPress


	push bx
	push cx
	push dx
	shr cx, 1

	cmp cx, 23
	jl @@invalid

	cmp cx, 141
	ja @@invalid

	cmp dx, 48
	jl @@invalid

	cmp dx, 167
	ja @@invalid

;check that cell wasn't pressed on before:
;convert to cell number:
	mov [CordinateSaverX], cx    
	mov [CordinateSaverY], dx

;Rows:
	mov dx, 0
	sub [CordinateSaverY], 48
	mov ax, [CordinateSaverY]
	mov si, 12  ;divider
	div si
	mov [CordinateSaverY], ax


;Columns:
	mov dx, 0
	sub [CordinateSaverX], 22
	mov ax, [CordinateSaverX]
	mov si, 12  ;divider
	div si
	mov [CordinateSaverX], ax

	mov cx, [CordinateSaverX]
	mov dx, [CordinateSaverY]

	mov ax, dx
	mov si, 10
	mov dx, 0
	mul si
	add ax, cx
	mov bx, ax

	cmp [SystemScreen + bx], ThereIsAshipWasPressed
	je @@invalid
	cmp [SystemScreen + bx], NoShipWasPressed
	je @@invalid

	mov ax, 0
	jmp @@done

@@invalid:
	mov ax, 1

@@done:
	pop dx
	pop cx
	pop bx
	ret
endp CheckValidPress


;first player-to-press cell: (22,48) (top left), ----> (142,168) (bottom right). cell:  12X12
	
proc DrawFirstTable

	mov cx, 11
	mov si, 48
@@DrawColumns1:
	push cx
	mov [point1X], 22
	mov [point1Y], si
	mov [point2X], 142
	mov [point2Y], si
	mov [color], 1

	call DrawLine2D

	add si, 12
	pop cx 
	loop @@DrawColumns1


	mov cx, 11
	mov si, 22
@@DrawRows1:
	push cx
	mov [point1X], si
	mov [point1Y], 48
	mov [point2X], si
	mov [point2Y], 168
	call DrawLine2D

	add si, 12
	pop cx
	loop @@DrawRows1
	ret
endp DrawFirstTable
	
	
;first PC cell: (178,48) (top left), ----> (298,168) (bottom right). cell:  12X12
	
proc DrawSecondTable

	mov cx, 11
	mov si, 48
@@DrawColumns2:
	push cx
	mov [point1X], 178
	mov [point1Y], si
	mov [point2X], 298
	mov [point2Y], si
	mov [color], 1

	call DrawLine2D

	add si, 12
	pop cx 
	loop @@DrawColumns2


	mov cx, 11
	mov si, 178
@@DrawRows2:
	push cx
	mov [point1X], si
	mov [point1Y], 48
	mov [point2X], si
	mov [point2Y], 168
	call DrawLine2D

	add si, 12
	pop cx
	loop @@DrawRows2
	ret	
	
endp DrawSecondTable	
	
	
;This proc gets the cordinates of a cell's top-left pixel, and colors it.
;variables: Cordinates  cx - X, Dx - Y
proc PaintSelectedCell


	add cx,1   ;in order to make the square not to be drawn over the table rows/columns.
	add dx, 1
	mov si, 11
	mov di, 11
	mov al, [CellColor]
	call Rect
	ret
endp PaintSelectedCell


;on return: ax - cordinate X, bx - cordinate Y

proc GetCellCordinatesByPress

	push bp
	mov bp, sp
	sub sp, 4

	mov ax, 3
	int 33h


shr cx,1


	mov [CordinateSaverX], cx    
	mov [CordinateSaverY], dx

;Rows:
	mov dx, 0
	sub [CordinateSaverY], 48
	mov ax, [CordinateSaverY]
	mov si, 12  ;divider (row length)
	div si
	mov [CordinateSaverY], ax


;Columns:
	mov dx, 0
	sub [CordinateSaverX], 22
	mov ax, [CordinateSaverX]
	mov si, 12  ;divider
	div si
	mov [CordinateSaverX], ax

	mov ax, [CordinateSaverX]
	mov bx, [CordinateSaverY]
	mov [PressX], ax   ;For the proc GetArrayLocation
	mov [PressY], bx

;by now, the variables CordinateSaver hold the cell location as if it was a 2D array: 0,0 , 1,1, 2,3 .....
;the  next code lines will convert these cordinates to the cordinates of the top left pixel of each cell

	mov [bp-2], 22    ;X cordinate
	mov [bp-4], 48    ;Y cordinate

	mov dx, 0
	mov bx, [CordinateSaverX]
	mov ax,12
	mul bx
	add [bp-2], ax

	mov dx, 0
	mov bx, [CordinateSaverY]
	mov ax,12
	mul bx
	add [bp-4], ax

	mov ax, [bp-2]
	mov bx, [bp-4]

	add sp, 4
	pop bp

	ret 
endp GetCellCordinatesByPress



;Same as the proc GetCellCordinatesByPress only for location in ARRAY
; on return: AX is the cell number starting from zero
proc GetArrayLocation
	
	mov ax, [PressY]
	mov si, 10
	mov dx, 0
	mul si
	add ax, [PressX]
ret
endp GetArrayLocation



proc UpdateArray

	call GetArrayLocation

	mov bx, ax
	mov dl, [byte SystemScreen + bx] ;Tells What's in this cell.
	mov dh, 0
	mov si, dx

	cmp si, ThereIsAshipWasntPressed
	je @@HitAShip

	cmp si, NoShipWasntPressed
	jne @@DoneUpdating

	mov [SystemScreen + bx], NoShipWasPressed  ;meaning the cell was pressed, no ship.
	jmp @@DoneUpdating

@@HitAShip:
	mov [SystemScreen + bx], ThereIsAshipWasPressed  ;Cell was pressed, and there was a ship.
	jmp @@DoneUpdating


@@DoneUpdating:

ret
endp UpdateArray

;Gets cell number by AX
proc UpdateArrayPC


	mov bx, ax
	mov dl, [byte playerScreen + bx] ;Tells What's in this cell.
	mov dh, 0
	mov si, dx

	cmp si, ThereIsAshipWasntPressed
	je @@HitAShip

	cmp si, NoShipWasntPressed
	jne @@DoneUpdating
	
	mov [playerScreen + bx], NoShipWasPressed  ;meaning the cell was pressed, no ship.
	jmp @@DoneUpdating

@@HitAShip:
	mov [playerScreen + bx], ThereIsAshipWasPressed  ;Cell was pressed, and there was a ship.
	jmp @@DoneUpdating


@@DoneUpdating:

	ret
endp UpdateArrayPC


;combines the cell paintig and updates the array
proc PlayerClick


	call GetCellCordinatesByPress
	push cx
	push dx
	push ax
	;Check if player pressed on a ship
	call GetArrayLocation
	mov si, ax
	cmp [byte SystemScreen + si], 0
	jne @@FoundAShip
	mov [CellColor], Color_No_Ship
	
	jmp @@DoneCheck
	
@@FoundAShip:
	mov [CellColor], Color_Found_Ship
	
	jmp @@DoneCheck
	
	
@@DoneCheck:
		
	mov ax, 2
	int 33h
	pop ax
	mov cx, ax
	mov dx, bx
	call PaintSelectedCell
	
	pop dx
	pop cx
	
	call UpdateArray
	call GetRemainingPcShips
	;call ShowAxDecimal
	
	ret
endp PlayerClick
	
	
	
; proc UpdateArray

; call GetArrayLocation
; mov bx, ax
; mov [playerScreen + bx], 1
; ret
; endp UpdateArray

;returns the amount of ships not fully destroyed in ax, updates the SHIP variable.
proc GetRemainingPcShips

;first goes over the ships and checks if they were'nt destroyed.

;----------------------------------
	mov cx, 1    ;A ship of 1 cell.
	mov di, 0    ;di will count the remaining parts of each ship and will be compared to zero.
	mov si, 0
@@ContinueCheck3:
	mov bl, [Ship1_pc + si]
	mov bh, 0
	cmp [SystemScreen + bx], ThereIsAshipWasntPressed
	jne @@PartDestroyed3

	add di, 1

@@PartDestroyed3:

	add si, 1
	loop @@ContinueCheck3

	cmp di, 0
	jne @@ShipWasntDestroyed3

	mov [Ship1_pc + 1], 0   ;Destroyed.

@@ShipWasntDestroyed3:
;-----------------------------------


;----------------------------------
	mov cx, 2    ;A ship of 2 cells.
	mov di, 0    ;di will count the remaining parts of each ship and will be compared to zero.
	mov si, 0
@@ContinueCheck1:
	mov bl, [Ship2_pc + si]
	mov bh, 0
	cmp [SystemScreen + bx], ThereIsAshipWasntPressed
	jne @@PartDestroyed1

	add di, 1

@@PartDestroyed1:

	add si, 1
	loop @@ContinueCheck1

	cmp di, 0
	jne @@ShipWasntDestroyed1

	mov [Ship2_pc + 2], 0   ;Destroyed.

@@ShipWasntDestroyed1:
;-----------------------------------


;----------------------------------
	mov cx, 3    ;A ship of 3 cells.
	mov di, 0    ;di will count the remaining parts of each ship and will be compared to zero.
	mov si, 0
@@ContinueCheck2:
	mov bl, [Ship3_pc + si]
	mov bh, 0
	cmp [SystemScreen + bx], ThereIsAshipWasntPressed
	jne @@PartDestroyed2

	add di, 1

@@PartDestroyed2:

	add si, 1
	loop @@ContinueCheck2

	cmp di, 0
	jne @@ShipWasntDestroyed2


	mov [Ship3_pc + 3], 0   ;Destroyed.

@@ShipWasntDestroyed2:
;-----------------------------------
;----------------------------------
	mov cx, 4    ;A ship of 4 cells.
	mov di, 0    ;di will count the remaining parts of each ship and will be compared to zero.
	mov si, 0
@@ContinueCheck4:
	mov bl, [Ship4_pc + si]
	mov bh, 0
	cmp [SystemScreen + bx], ThereIsAshipWasntPressed
	jne @@PartDestroyed4

	add di, 1

@@PartDestroyed4:

	add si, 1
	loop @@ContinueCheck4

	cmp di, 0
	jne @@ShipWasntDestroyed4

	mov [Ship4_pc + 4], 0   ;Destroyed.

@@ShipWasntDestroyed4:
;-----------------------------------
;----------------------------------
	mov cx, 5    ;A ship of 5 cells.
	mov di, 0    ;di will count the remaining parts of each ship and will be compared to zero.
	mov si, 0
@@ContinueCheck5:
	mov bl, [Ship5_pc + si]
	mov bh, 0
	cmp [SystemScreen + bx], ThereIsAshipWasntPressed
	jne @@PartDestroyed5

	add di, 1

@@PartDestroyed5:

	add si, 1
	loop @@ContinueCheck5

	cmp di, 0
	jne @@ShipWasntDestroyed5

	mov [Ship5_pc + 5], 0   ;Destroyed.

@@ShipWasntDestroyed5:
;-----------------------------------

;After The Updating is over, we can count the remaining ships.

	mov ax, 0
	add al, [Ship1_pc + 1]
	add al, [Ship2_pc + 2]
	add al, [Ship3_pc + 3]
	add al, [Ship4_pc + 4]
	add al, [Ship5_pc + 5]

	cmp ax, 0
	jne @@ProcOver

	mov [GameOver], 1


@@ProcOver:

	ret 
endp GetRemainingPcShips



;returns the amount of ships not fully destroyed in ax, updates the SHIP variable.
proc GetRemainingPlayerShips

;first goes over the ships and checks if they were'nt destroyed.



;----------------------------------
	mov cx, 1    ;A ship of 1 cell.
	mov di, 0    ;di will count the remaining parts of each ship and will be compared to zero.
	mov si, 0
@@ContinueCheck3:
	mov bl, [Ship1_player + si]
	mov bh, 0
	cmp [playerScreen + bx], ThereIsAshipWasntPressed
	jne @@PartDestroyed3

	add di, 1

@@PartDestroyed3:

	add si, 1
	loop @@ContinueCheck3

	cmp di, 0
	jne @@ShipWasntDestroyed3

	mov [Ship1_player + 1], 0   ;Destroyed.

@@ShipWasntDestroyed3:
;-----------------------------------

;----------------------------------
	mov cx, 2    ;A ship of 2 cells.
	mov di, 0    ;di will count the remaining parts of each ship and will be compared to zero.
	mov si, 0
@@ContinueCheck1:
	mov bl, [Ship2_player + si]
	mov bh, 0
	cmp [playerScreen + bx], ThereIsAshipWasntPressed
	jne @@PartDestroyed1

	add di, 1

@@PartDestroyed1:

	add si, 1
	loop @@ContinueCheck1

	cmp di, 0
	jne @@ShipWasntDestroyed1

	mov [Ship2_player + 2], 0   ;Destroyed.

@@ShipWasntDestroyed1:
;-----------------------------------


;----------------------------------
	mov cx, 3    ;A ship of 3 c cells.
	mov di, 0    ;di will count the remaining parts of each ship and will be compared to zero.
	mov si, 0
@@ContinueCheck2:
	mov bl, [Ship3_player + si]
	mov bh, 0
	cmp [playerScreen + bx], ThereIsAshipWasntPressed
	jne @@PartDestroyed2

	add di, 1

@@PartDestroyed2:

	add si, 1
	loop @@ContinueCheck2

	cmp di, 0
	jne @@ShipWasntDestroyed2


	mov [Ship3_player + 3], 0   ;Destroyed.

@@ShipWasntDestroyed2:
;-----------------------------------

;----------------------------------
	mov cx, 4    ;A ship of 4 cells.
	mov di, 0    ;di will count the remaining parts of each ship and will be compared to zero.
	mov si, 0
@@ContinueCheck4:
	mov bl, [Ship4_player + si]
	mov bh, 0
	cmp [playerScreen + bx], ThereIsAshipWasntPressed
	jne @@PartDestroyed4

	add di, 1

@@PartDestroyed4:

	add si, 1
	loop @@ContinueCheck4

	cmp di, 0
	jne @@ShipWasntDestroyed4

	mov [Ship4_player + 4], 0   ;Destroyed.

@@ShipWasntDestroyed4:
;-----------------------------------

;----------------------------------
	mov cx, 5    ;A ship of 5 cells.
	mov di, 0    ;di will count the remaining parts of each ship and will be compared to zero.
	mov si, 0
@@ContinueCheck5:
	mov bl, [Ship5_player + si]
	mov bh, 0
	cmp [playerScreen + bx], ThereIsAshipWasntPressed
	jne @@PartDestroyed5

	add di, 1

@@PartDestroyed5:

	add si, 1
	loop @@ContinueCheck5

	cmp di, 0
	jne @@ShipWasntDestroyed5

	mov [Ship5_player + 5], 0   ;Destroyed.

@@ShipWasntDestroyed5:
;-----------------------------------

;After The Updating process is over, we can count the remaining ships.

	mov ax, 0
	add al, [Ship1_player + 1]
	add al, [Ship2_player + 2]
	add al, [Ship3_player + 3]
	add al, [Ship4_player + 4]
	add al, [Ship5_player + 5]

	cmp ax, 0
	jne @@ProcOver

	mov [GameOver], 2   ;pc wins


@@ProcOver:

	ret 
endp GetRemainingPlayerShips

proc ConvertCellNumberIntoCordinates

	push bp
	mov bp, sp
	sub sp, 6 ;bp-4 -> x cordinate,  bp-6 -> y cordinate

	mov [bp-2], ax  ;cell number
	mov si, 10 
	mov dx, 0
	div si	; now dx is the column number, and ax is the row number.

	mov [bp-4], dx
	mov [bp-6], ax


	mov ax, [bp-4]
	mov si, 12
	mul si
	add ax, 22
	mov [bp-4], ax



	mov ax, [bp-6]
	mov si, 12
	mul si
	add ax, 48
	mov [bp-6], ax



	mov cx, [bp-4]
	mov dx, [bp-6]

	add sp, 6
	pop bp

	ret
endp ConvertCellNumberIntoCordinates

;Receives the cell number (starting from zero) by AX and converts it into 2 cordinates.
;On return: cx = x cordinate, dx = y cordinate
proc ConvertCellNumberIntoCordinatesPc

	push bp
	mov bp, sp
	sub sp, 6 ;bp-4 -> x cordinate,  bp-6 -> y cordinate

	mov [bp-2], ax  ;cell number
	mov si, 10 
	mov dx, 0
	div si	; now dx is the column number, and ax is the row number.

	mov [bp-4], dx
	mov [bp-6], ax


	mov ax, [bp-4]
	mov si, 12
	mul si
	add ax, 178
	mov [bp-4], ax

	mov ax, [bp-6]
	mov si, 12
	mul si
	add ax, 48
	mov [bp-6], ax


	mov cx, [bp-4]
	mov dx, [bp-6]

	add sp, 6
	pop bp

	ret
endp ConvertCellNumberIntoCordinatesPc
	
proc PCMove

	mov al, [byte CurrentlyDestroingAShip]
	mov ah, 0
	cmp [byte CurrentlyDestroingAShip], 1
	je @@Destroying
;Random cell:
@@RandomCell:
	mov bl, 0
	mov bh, 99
	call RandomByCs

	mov [SelectedCell], al
	mov bl, al
	mov bh, 0


;Now Check if the selected cell was marked before:
	cmp [WereChecked + bx], 0
	jne @@RandomCell
	jmp @@SkipDestroying

@@Destroying:

	call KeepHittingShip
	mov bx, ax
	mov [SelectedCell], bl


@@SkipDestroying:

	mov [WereChecked + bx], 1

	mov al, [SelectedCell]
	mov ah, 0
	call ConvertCellNumberIntoCordinatesPc

	mov bl, [SelectedCell]
	mov bh, 0
	cmp [playerScreen+bx], 1
	je @@TheresAShip

	mov [CellColor], Color_No_Ship
	jmp @@DoneChecking

@@TheresAShip:
	mov [CellColor], Color_Found_Ship

	cmp [FirstHit], 100
	jne @@NotFirstHit
	mov [FirstHit], bl
	@@NotFirstHit:

	mov [CurrentlyDestroingAShip], 1


@@DoneChecking:

	call PaintSelectedCell

	mov al, [FirstHit]   ;needs an exception
	cmp al, [byte Ship1_player]
	jne NotThe1CellShip
	mov [CurrentlyDestroingAShip], 0
	mov [FirstHit], 100
NotThe1CellShip:

	cmp [CurrentlyDestroingAShip], 1
	jne @@SkipPart
	push bx
	call UpdateAlgorithemArray
	pop bx

@@SkipPart:

	mov al, [SelectedCell]
	mov ah, 0

	call UpdateArrayPC      ;(screen array)
	cmp [CurrentlyDestroingAShip], 1
	jne @@continue1
	call CheckIfStillDestroyingShip
	jmp @@ProcOver1
@@Continue1:
	call GetRemainingPlayerShips
@@ProcOver1:
	ret
endp PCMove


proc CheckIfStillDestroyingShip	

	call GetRemainingPlayerShips

	cmp [AmountOfShipsAtFirstHit], 0
	jne @@continue
	mov [AmountOfShipsAtFirstHit], al
@@continue:
	cmp al, [AmountOfShipsAtFirstHit]
	je StillAttacking

	mov [AmountOfShipsAtFirstHit],0
	mov [CurrentlyDestroingAShip], 0
	mov [SelectedCellInArrayKeepHitting], 0
	mov [FirstHit], 100
	mov cx, 40
	mov si, 0
@@LoopResetAlgorithemArray1:
	mov [SpaceAroundHit+si], 0
	inc si
	loop @@LoopResetAlgorithemArray1

	mov [SpaceAroundHit+si], 1
	inc si

	mov cx, 40
@@LoopResetAlgorithemArray2:
	mov [SpaceAroundHit+si], 0
	inc si
	loop @@LoopResetAlgorithemArray2

StillAttacking:



	ret
endp CheckIfStillDestroyingShip

	

	
proc GetCellCordinatesByPressForPC

	push bp
	mov bp, sp
	sub sp, 4

	mov ax, 3
	int 33h

	push bx   ;in order to have the button status afterwards
	shr cx,1


	mov [CordinateSaverXPC], cx    
	mov [CordinateSaverYPC], dx

;--------------------------
; pop bx 
; cmp bx, 1
; jne @@SkipThis

; mov ax, [CordinateSaverXPC]
; call ShowAxDecimal
; mov ax, [CordinateSaverYPC]
; call ShowAxDecimal
;--------------------------
; @@SkipThis:
; push bx


;Rows:
	mov dx, 0
	sub [CordinateSaverYPC], 48
	mov ax, [CordinateSaverYPC]
	mov si, 12  ;divider (cell width)
	div si
	mov [CordinateSaverYPC], ax


;Columns:
	mov dx, 0
	sub [CordinateSaverXPC], 178
	mov ax, [CordinateSaverXPC]
	mov si, 12  ;divider
	div si
	mov [CordinateSaverXPC], ax



	mov ax, [CordinateSaverXPC]
	mov bx, [CordinateSaverYPC]
	mov [PressXPC], ax   ;For the proc GetArrayLocationPC
	mov [PressYPC], bx


;by now, the variables CordinateSaver hold the cell location as if it was a 2D array: 0,0 , 1,1, 2,3 .....
;the  next code lines will convert these cordinates to the cordinates of the top left pixel of each cell

	mov [word bp-2], 178    ;X cordinate
	mov [word bp-4], 48    ;Y cordinate

	mov dx, 0
	mov bx, [CordinateSaverXPC]
	mov ax,12
	mul bx
	add [bp-2], ax

	mov dx, 0
	mov bx, [CordinateSaverYPC]
	mov ax,12
	mul bx
	add [bp-4], ax

	mov ax, [bp-2]
	mov bx, [bp-4]

;only used in one proc, but doesnt effect anything else.
	mov [MouseReleaseX], ax
	mov [MouseReleaseY], bx


	pop bx
	add sp, 4
	pop bp

	ret 
endp GetCellCordinatesByPressForPC	

proc GetArrayLocationPC
	
	mov ax, [PressYPC]
	mov si, 10
	mov dx, 0
	mul si
	add ax, [PressXPC]
ret
endp GetArrayLocationPC

;-----------------------------------------------------------------------------------------------------------------------------------
	
	proc DrawHorizontalLine	near
	push si
	push cx
DrawLine:
	cmp si,0
	jz ExitDrawLine	
	 
    mov ah,0ch	
	int 10h    ; put pixel
	 
	
	inc cx
	dec si
	jmp DrawLine
	
	
ExitDrawLine:
	pop cx
    pop si
	ret
endp DrawHorizontalLine



proc DrawVerticalLine	near
	push si
	push dx
 
DrawVertical:
	cmp si,0
	jz @@ExitDrawLine	
	 
    mov ah,0ch	
	int 10h    ; put pixel
	
	 
	
	inc dx
	dec si
	jmp DrawVertical
	
	
@@ExitDrawLine:
	pop dx
    pop si
	ret
endp DrawVerticalLine

; in dx how many cols 
; in cx how many rows
; in matrix - the bytes
; in di start byte in screen (0 64000 -1)

proc putMatrixInScreen
	push es
	push ax
	push si
	
	mov ax, 0A000h
	mov es, ax
	cld
	
	push dx
	mov ax,cx
	mul dx
	mov bp,ax
	pop dx
	
	
	mov si,[matrix]
	
NextRow:	
	push cx
	
	mov cx, dx
	rep movsb ; Copy line to the screen
	sub di,dx
	add di, 320
	
	
	pop cx
	loop NextRow
	
	
endProc:	
	
	pop si
	pop ax
	pop es
    ret
endp putMatrixInScreen
	
proc DrawSquare
	push si
	push ax
	push cx
	push dx
	
	mov al,[Color1]
	mov si,[SquareSize]  ; line Length
 	mov cx,[Xp]
	mov dx,[Yp]
	call DrawHorizontalLine

	 
	
	call DrawVerticalLine
	 
	
	add dx ,si
	dec dx
	call DrawHorizontalLine
	 
	
	
	sub  dx ,si
	inc dx
	add cx,si
	dec cx
	call DrawVerticalLine
	
	
	 pop dx
	 pop cx
	 pop ax
	 pop si
	 
	ret
endp DrawSquare


; cx = col dx= row al = color si = height di = width 
proc Rect
	push cx
	push di
NextVerticalLine:	
	
	cmp di,0
	jz @@EndRect
	
	cmp si,0
	jz @@EndRect
	call DrawVerticalLine
	inc cx
	dec di
	jmp NextVerticalLine
	
	
@@EndRect:
	pop di
	pop cx
	ret
endp Rect
 
 
   
proc  SetGraphic
	; http://stanislavs.org/helppc/int_10-0.html

	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic	
	
; procedures
;---------------------------------------------;
; input: point1X point1Y,         ;
; 		 point2X point2Y,         ;
;		 Color                                ;
; output: line on the screen                  ;
;---------------------------------------------;
PROC DrawLine2D
	mov cx, [point1X]
	sub cx, [point2X]
	absolute cx
	mov bx, [point1Y]
	sub bx, [point2Y]
	absolute bx
	cmp cx, bx
	jae DrawLine2Dp1 ; deltaX > deltaY
	mov ax, [point1X]
	mov bx, [point2X]
	mov cx, [point1Y]
	mov dx, [point2Y]
	cmp cx, dx
	jbe DrawLine2DpNxt1 ; point1Y <= point2Y
	xchg ax, bx
	xchg cx, dx
DrawLine2DpNxt1:
	mov [point1X], ax
	mov [point2X], bx
	mov [point1Y], cx
	mov [point2Y], dx
	DrawLine2DDY point1X, point1Y, point2X, point2Y
	ret
DrawLine2Dp1:
	mov ax, [point1X]
	mov bx, [point2X]
	mov cx, [point1Y]
	mov dx, [point2Y]
	cmp ax, bx
	jbe DrawLine2DpNxt2 ; point1X <= point2X
	xchg ax, bx
	xchg cx, dx
DrawLine2DpNxt2:
	mov [point1X], ax
	mov [point2X], bx
	mov [point1Y], cx
	mov [point2Y], dx
	DrawLine2DDX point1X, point1Y, point2X, point2Y
	ret
ENDP DrawLine2D
;-----------------------------------------------;
; input: pointX pointY,      					;
;           Color								;
; output: point on the screen					;
;-----------------------------------------------;
PROC PIXEL
	mov bh,0h
	mov cx,[pointX]
	mov dx,[pointY]
	mov al,[Color]
	mov ah,0Ch
	int 10h
	ret
ENDP PIXEL	
	
	;================================================
; Description - Write on screen the value of ax (decimal)
;               the practice :  
;				Divide AX by 10 and put the Mod on stack 
;               Repeat Until AX smaller than 10 then print AX (MSB) 
;           	then pop from the stack all what we kept there. 
; INPUT: AX
; OUTPUT: Screen 
; Register Usage: AX  
;================================================
proc ShowAxDecimal
	   push ax
       push bx
	   push cx
	   push dx
	   
	   ; check if negative
	   test ax,08000h
	   jz PositiveAx
			
	   ;  put '-' on the screen
	   push ax
	   mov dl,'-'
	   mov ah,2
	   int 21h
	   pop ax

	   neg ax ; make it positive
PositiveAx:
       mov cx,0   ; will count how many time we did push 
       mov bx,10  ; the divider
   
put_mode_to_stack:
       xor dx,dx
       div bx
       add dl,30h
	   ; dl is the current LSB digit 
	   ; we cant push only dl so we push all dx
       push dx    
       inc cx
       cmp ax,9   ; check if it is the last time to div
       jg put_mode_to_stack

	   cmp ax,0
	   jz pop_next  ; jump if ax was totally 0
       add al,30h  
	   mov dl, al    
  	   mov ah, 2h
	   int 21h        ; show first digit MSB
	       
pop_next: 
       pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	   mov dl, al
       mov ah, 2h
	   int 21h        ; show all rest digits
       loop pop_next
		
	   mov dl, ','
       mov ah, 2h
	   int 21h
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal
	
	proc LoopDelay1Sec
	push cx
	
	mov cx ,1000 
@@Self1:
	
	push cx
	mov cx,3000 

@@Self2:	
	loop @@Self2
	
	pop cx
	loop @@Self1
	
	pop cx
	ret
	
endp LoopDelay1Sec


;rnd procs:
;-----------------------
proc RandomByCs
    push es
	push si
	push di
	
	mov ax, 40h
	mov	es, ax
	
	sub bh,bl  ; we will make rnd number between 0 to the delta between bl and bh
			   ; Now bh holds only the delta
	cmp bh,0
	jz @@ExitP
 
	mov di, [word RndCurrentPos]
	call MakeMask ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
RandLoop: ;  generate random number 
	mov ax, [es:06ch] ; read timer counter
	mov ah, [byte cs:di] ; read one byte from memory (from semi random byte at cs)
	xor al, ah ; xor memory and counter
	
	; Now inc di in order to get a different number next time
	inc di
	cmp di,(EndOfCsLbl - start - 1)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di
	
	and ax, si ; filter result between 0 and si (the nask)
	cmp al,bh    ;do again if  above the delta
	ja RandLoop
	
	add al,bl  ; add the lower limit to the rnd num
		 
@@ExitP:	
	pop di
	pop si
	pop es
	ret
endp RandomByCs


; Description  : get RND between any bl and bh includs (max 0 -255)
; Input        : 1. BX = min (from 0) , DX, Max (till 64k -1)
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0
;				 3. EndOfCsLbl: is label at the end of the program one line above END start		
; Output:        AX - rnd num from bx to dx  (example 50 - 1550)
; More Info:
; 	BX  must be less than DX 
; 	in order to get good random value again and again the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
proc RandomByCsWord
    push es
	push si
	push di
 
	
	mov ax, 40h
	mov	es, ax
	
	sub dx,bx  ; we will make rnd number between 0 to the delta between bl and bh
			   ; Now bh holds only the delta
	cmp dx,0
	jz @@ExitP
	
	push bx
	
	mov di, [word RndCurrentPos]
	call MakeMaskWord ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
@@RandLoop: ;  generate random number 
	mov bx, [es:06ch] ; read timer counter
	
	mov ax, [word cs:di] ; read one word from memory (from semi random bytes at cs)
	xor ax, bx ; xor memory and counter
	
	; Now inc di in order to get a different number next time
	inc di
	inc di
	cmp di,(EndOfCsLbl - start - 2)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di
	
	and ax, si ; filter result between 0 and si (the nask)
	
	cmp ax,dx    ;do again if  above the delta
	ja @@RandLoop
	pop bx
	add ax,bx  ; add the lower limit to the rnd num
		 
@@ExitP:
	
	pop di
	pop si
	pop es
	ret
endp RandomByCsWord

; make mask acording to bh size 
; output Si = mask put 1 in all bh range
; example  if bh 4 or 5 or 6 or 7 si will be 7
; 		   if Bh 64 till 127 si will be 127
Proc MakeMask    
    push bx

	mov si,1
    
@@again:
	shr bh,1
	cmp bh,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right
	inc si
	
	jmp @@again
	
@@EndProc:
    pop bx
	ret
endp  MakeMask


Proc MakeMaskWord    
    push dx
	
	mov si,1
    
@@again:
	shr dx,1
	cmp dx,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right
	inc si
	
	jmp @@again
	
@@EndProc:
    pop dx
	ret
endp  MakeMaskWord



; get RND between bl and bh includs
; output al - rnd num from bl to bh
; the distance between bl and bh  can't be greater than 100 
; Bl must be less than Bh 
proc RndBlToBh  ; by Dos  with delay
	push  cx
	push dx
	push si 


	mov     cx, 1h
	mov     dx, 0C350h
	mov     ah, 86h
	int     15h   ; Delay of 50k micro sec
	
	sub bh,bl
	cmp bh,0
	jz @@EndProc
	
	call MakeMask ; will put in si the right mask (example for 28 will put 31)
RndAgain:
	mov ah, 2ch   
	int 21h      ; get time from MS-DOS
	mov ax, dx   ; DH=seconds, DL=hundredths of second
	and ax, si  ;  Mask for Highst num in range  
	cmp al,bh    ; we deal only with al (0  to 100 )
	ja RndAgain
 	
	add al,bl

@@EndProc:
	pop si
	pop dx
	pop cx
	
	ret
endp RndBlToBh


; int 15h has known bug dont use it.
proc timeAx
    push  cx
	push dx
	
 	mov     cx, 0h
	mov     dx, 0C350h
	mov     ah, 86h
	int     15h   ; Delay of 50k micro sec

	
	
    mov ah, 2ch   
	int 21h      ; get time from MS-DOS
	mov ax, dx   ; DH=seconds, DL=hundredths of second
	
	pop dx
	pop cx
	
    ret	
endp timeAx

;--------------------------------------------

proc LittleDelay

	mov cx, 20
@@StartDelay:
	push cx
	call _25MicroSecDelay
	pop cx
	loop @@StartDelay
	ret
endp LittleDelay

proc _25MicroSecDelay
	push  cx
	push dx
	push ax


	mov     cx, 00h
	mov     dx, 46A0h
	mov     ah, 86h
	int     15h

	pop ax
	pop dx
	pop cx
	
	ret
endp _25MicroSecDelay


proc OpenShowBmp near
	
	 
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call  ShowBmp
	
	 
	call CloseBmpFile

@@ExitProc:
	ret
endp OpenShowBmp

 



; The Screen BitMap and save it into a new bmp file
; the header and palette will be same like the the file that we read before
; So , sometimes we will see color differences between screen and file. 
proc SaveVgaMemToFile near
	
	lea dx, [FileNameOut]
	call CreateBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call PutBmpHeader
	
	call PutBmpPalette
	
	call PutBmpDataIntoFile
	
	call CloseBmpFile

@@ExitProc:
	ret
endp SaveVgaMemToFile

	
; input dx filename to open
proc OpenBmpFile	near						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc
	
@@ErrorAtOpen:
	mov [ErrorFile],1
@@ExitProc:	
	ret
endp OpenBmpFile

	
; output file dx filename to open
proc CreateBmpFile	near						 
	 
	
CreateNewFile:
	mov ah, 3Ch 
	mov cx, 0 
	int 21h
	
	jnc Success
@@ErrorAtOpen:
	mov [ErrorFile],1
	jmp @@ExitProc
	
Success:
	mov [ErrorFile],0
	mov [FileHandle], ax
@@ExitProc:
	ret
endp CreateBmpFile





proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile




; Read 54 bytes the Header
proc ReadBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader



proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette

; Change the 16th color  
proc ColorTheMouse		near					
	mov si,offset Palette
	mov cx,16
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
	
@@CopyNextColor:
	cmp cx,1  ; the 16 color is the mouse so keep it whiote
	jnz nxt
	mov al,MOUSE_COLORred 		 		
	shr al,2 		 	
	out dx,al 						
	mov al,MOUSE_COLORgreen		 		
	shr al,2            
	out dx,al 							
	mov al,MOUSE_COLORblue	 		
	shr al,2            
	out dx,al 		
	add si,4 
	jmp @@ret

nxt:	
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
	loop @@CopyNextColor

@@ret:
	ret
endp ColorTheMouse


 
proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
	mov cx,[BmpRowSize]
	
 
	mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	cmp dx,0
	mov bp,0
	jz @@row_ok
	mov bp,4
	sub bp,dx

@@row_ok:	
	mov dx,[BmpLeft]
	
@@NextLine:
	push cx
	push dx
	
	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[BmpTop] ; add the Y on entire screen
	
 
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpColSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[BmpColSize]  
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	
	pop dx
	pop cx
	 
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMP 

	

; Read 54 bytes the Header
proc PutBmpHeader	near					
	mov ah,40h
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp PutBmpHeader
 



proc PutBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	mov ah,40h
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp PutBmpPalette


 
proc PutBmpDataIntoFile near
			
    mov dx,offset OneBmpLine  ; read 320 bytes (line) from file to buffer
	
	mov ax, 0A000h ; graphic mode address for es
	mov es, ax
	
	mov cx,BMP_HEIGHT
	
	cld 		; forward direction for movsb
@@GetNextLine:
	push cx
	dec cx
										 
	mov si,cx    ; set si at the end of the cx line (cx * 320) 
	shl cx,6	 ; multiply line number twice by 64 and by 256 and add them (=320) 
	shl si,8
	add si,cx
	
	mov cx,BMP_WIDTH    ; line size
	mov di,dx
    
	 push ds 
     push es
	 pop ds
	 pop es
	 rep movsb
	 push ds 
     push es
	 pop ds
	 pop es
 
	
	
	 mov ah,40h
	 mov cx,BMP_WIDTH
	 int 21h
	
	 pop cx ; pop for next line
	 loop @@GetNextLine
	
	
	
	 ret 
endp PutBmpDataIntoFile
	
	



EndOfCsLbl:
END start