;; config
; output opcode and macro listing files during assembly
	.list
	.mlist


;; code
	.bank	$0
	.org	$e000
	.code

_system_reset:
	sei			; disable interrupts
	cld			; use normal mode instead of decimal mode
	csh			; set high-speed mode (7.16 MHz)

	; init the stack pointer
	ldx	#$ff
	txs

	; bring i/o and ram into the memory pages
	lda	#$ff		; load in the i/o (located at bank $ff)
	tam	#0		; transfer to MPR0

	lda	#$f8		; load in the ram (located at bank $f8)
	tam	#1		; transfer to MPR1


_start:
initChannel:
	; select channel 0
	lda	#0
	sta	$800

	; disable noise
	stz	$807

	; disable lfo
	stz	$808		; LFO frequency = 0
	stz	$809		; LFO=OFF, LFO Ctrl=0

	; set L and R global volume (#$LR)
	lda	#$ee
	sta	$801

writeWavetable:
	; write wavetable (square wave)
	;     0              15              31
	; $1f ---------------+
	;                    |
	; $00                +----------------
	;
	; wavetable values are 5-bit so max value is $1f
	;
	; first write the the square wave peak
	ldx	#16
	lda	#$1f
writeWavetable_writePeak:
	sta	$806
	dex
	bne	writeWavetable_writePeak

	; now write the the square wave valley
	ldx	#16
	lda	#$0
writeWavetable_writeValley:
	sta	$806
	dex
	bne	writeWavetable_writeValley

	; set pitch frequency
	lda	#$99
	sta	$802
	stz	$803

	; set amplitude of wave ($LR)
	lda	#$ff
	sta	$805

; clock speed -> 7.16 MHz (7.16e6)
; 
; 120 bpm -> 2 clicks per second
; 1 click
;   - 0.1 second on
noteOn:
	lda	#%1_0_0_11111		; 2
	sta	$804			; 4

	ldy	#155			; 2
noteOn_loop:
	ldx	#255			; 2
noteOn_loopInner:
	nop				; 2
	nop				; 2
	nop				; 2
	nop				; 2

	nop				; 2
	nop				; 2
	dex				; 2
	bne	noteOn_loopInner	; 2 

	dey		   		; 2
	bne	noteOn_loop		; 2

;   - 0.4 second off
noteOff:
	stz	$804			; 2

	ldy	#255			; 2
noteOff_loop:
	ldx	#255			; 2
noteOff_loopInner:
	nop				; 2

	nop				; 2
	nop				; 2
	nop				; 2
	nop				; 2

	nop				; 2
	nop				; 2
	nop				; 2
	nop				; 2

	nop				; 2
	nop				; 2
	nop				; 2
	nop				; 2

	nop				; 2
	nop				; 2
	nop				; 2
	nop				; 2

	nop				; 2
	nop				; 2
	dex				; 2
	bne	noteOff_loopInner	; 2 

	dey		   		; 2
	bne	noteOff_loop		; 2

	bra	noteOn



_end:
	.org	$fffe
	.dw	_system_reset
