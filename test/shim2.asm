		* = $8010
		ldx 	#$FF
		txs

		lda 	1
		and 	#$F8
		sta 	1

		lda 	#1
		sta 	$D000
		lda 	#0
		sta 	$D001

		inc 	1
		inc 	1
		ldx 	#0
_Copy:	txa
		sta 	$C000,x
		inx
		bne 	_Copy				

halt:	bra 	halt
