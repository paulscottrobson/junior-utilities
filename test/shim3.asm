zTemp0 = $20

		* = $8010
		ldx 	#$FF
		txs
		lda 	#42
		jsr 	$FFD2
		jsr 	$FFD2

		lda 	1
		and 	#$F8
		sta 	1

		lda 	#15
		sta 	$D000
		lda 	#1
		sta 	$D100

		stz 	$D101
		stz 	$D102
		stz 	$D103

		stz 	$D00D
		stz 	$D00E
		stz 	$D00F


			lda 	$00 						; Read MMU Control
			pha 								; save original value
			and 	#$0F 						
			ora 	#$80 						; set edit bit and MMU0
			sta 	$00

			lda 	#1  						; set $4000-$5FFF and $6000-$7FFF to use page 1 e.g. $2000-$3FFF					
			sta 	$0A
			sta 	$0B

			pla 								; restore MMU
			sta 	0

		jsr 	InitialiseGraphicsLUT

_Fill0:
		lda 	#$20
		sta 	zTemp0+1
		lda 	#$80
		sta 	zTemp0
_Fill1:	ldy 	#0
_Fill2:	tya
		lsr 	a
		lsr 	a
		sta 	(zTemp0),y
		iny
		bne 	_Fill2
		inc 	zTemp0+1
		ldy 	#0
_Fill3:	txa
		sta 	(zTemp0),y
		iny
		cpy 	#64
		bne 	_Fill3		
		clc
		lda 	zTemp0
		adc 	#64
		sta 	zTemp0			
		bcc 	_Fill1
		inc 	zTemp0+1		
		lda 	zTemp0+1
		cmp 	#$40
		bcc 	_Fill1
		inx 	
		bra 	_Fill0

halt:	bra 	halt


InitialiseGraphicsLUT:
		inc 	1 							; access I/O page 1 (was called from p0)
		lda 	#$D0 						; point zTemp0 to GLUT Memory
		sta 	zTemp0+1
		stz 	zTemp0
_IGLoop:
		lda 	zTemp0  					; use bits 76 54 32 of address to make RGB colour						
		jsr		IGLShiftWrite1				
		jsr		IGLShiftWrite1				
		jsr		IGLShiftWrite1				
		lda 	#$FF 						; Alpha $FF, could do it a fourth time.
		sta 	(zTemp0)
		jsr 	IGLBumpzTemp0
		lda 	zTemp0+1 					; until filled all four GLUTs
		cmp 	#$E0
		bne 	_IGLoop
		dec 	1
		rts

IGLShiftWrite1:
		pha 								; save current bit pattern
		and 	#$C0 						; isolate MSBs, put in slot
		beq 	_NoBump
		ora 	#$1F
_NoBump:		
		sta 	(zTemp0) 					; write to GLUT
		pla 								; restore and shift next bits in.
		asl 	a
		asl 	a
IGLBumpzTemp0: 								; next GLUT slot.
		inc 	zTemp0
		bne 	_IGLExit
		inc 	zTemp0+1
_IGLExit:
		rts				
