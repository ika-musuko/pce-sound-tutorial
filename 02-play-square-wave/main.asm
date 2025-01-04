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
playSquareWave:
	; select channel 0
	lda	#0
	sta	$800

	; disable noise
	stz	$807

	; disable lfo
	stz	$808		; LFO frequency = 0
	stz	$809		; LFO=OFF, LFO Ctrl=0

	; set volume of L and R speakers (#$LR)
	lda	#$ee
	sta	$801

	; clear wavetable index
	lda	#$40
	sta	$804
	stz	$804

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
playSquareWave_writePeak:
	sta	$806
	dex
	bne	playSquareWave_writePeak

	; now write the the square wave valley
	ldx	#16
	lda	#$0
playSquareWave_writeValley:
	sta	$806
	dex
	bne	playSquareWave_writeValley

	; set pitch frequency
	; freq_value = 111860.78125 / real_freq
	;
	; let's get a low A = 220Hz
	; 111860.78125 / 220Hz = $1fc
	lda	#$fc
	sta	$802	; freq_value low bits in $802
	lda	#$1
	sta	$803	; freq_value high bits in $803

	; set amplitude of wave ($LR)
	lda	#$ff
	sta	$805

	; now play the note
	lda	#%1_0_0_11111
	sta	$804

_mainloop:
	bra	_mainloop

_end:
	.org	$fffe
	.dw	_system_reset
