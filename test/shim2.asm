zTemp0 = $80

		* = $8010
		ldx 	#$FF
		txs

		lda 	$00
		jsr 	OutHex
		lda 	$01
		jsr 	OutHex
		jsr 	CRLF
		
        lda #$80
        sta $00
        jsr 	ShowTable
	
		lda 	1
		and 	#$F8
		sta 	1

		lda 	#1 ;15
		sta 	$D000
		lda 	#1
		sta 	$D100

		stz 	$D101
		stz 	$D102
		stz 	$D103

		stz 	$D00D
		stz 	$D00E
		stz 	$D00F

		jsr 	InitialiseGraphicsLUT

		lda 	#$7C
		sta 	$4000
		lda 	$4000
		jsr 	OutHex

      	lda $0A             ; Should read RAM Location
		jsr 	OutHex
        lda #$80
        sta $00
        lda $0A             ; Should read new value
		jsr 	OutHex
        lda $0A             ; Should read Default MMU Page 0 Value
        lda #$08
        sta $0A
        lda $0A             ; Should read new value
		jsr 	OutHex
		;stz 	$00
        lda $0A             ; Should read new value
		jsr 	OutHex

		lda 	$4000
		jsr 	OutHex

		lda 	#13
		jsr 	$FFD2
        jsr 	ShowTable

halt:	bra 	halt

		xrts

OutHex:	pha
		lda 	#32
		jsr 	$FFD2
		pla
		pha
		lsr 	a
		lsr 	a
		lsr 	a
		lsr 	a
		jsr 	OutNibble
		pla
OutNibble:
		and 	#15
		cmp		#10
		bcc 	_ONKip
		adc 	#6
_ONKip:	adc 	#48
		jmp		$FFD2		

ShowTable:		
		ldx 	#8
_OutTable:
		lda 	0,x
		jsr 	OutHex
		inx
		cpx	 	#16
		bne 	_outTable
CRLF:		
		lda 	#13
		jsr 	$FFD2	
		rts

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
		cmp 	#$D8
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
