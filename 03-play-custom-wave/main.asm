;; config
; output opcode and macro listing files during assembly
	.list
	.mlist

;; data
d_wave00:
	.byte	$08,$08,$08,$08, $09,$09,$09,$09, $0a,$0a,$0a,$0a, $0b,$0b,$0b,$0b
	.byte	$0c,$0c,$0c,$0c, $0d,$0d,$0d,$0d, $0e,$0e,$0e,$0e, $0f,$0f,$0f,$0f

d_wave01:
	.byte	$09,$0c,$0d,$0c, $09,$07,$08,$0a, $0d,$0f,$0f,$0c, $09,$06,$05,$06
	.byte	$09,$0a,$09,$06, $03,$00,$00,$02, $05,$07,$08,$06, $03,$02,$03,$06

d_wave02:
	.byte	$1f,$1f,$1f,$1f, $1f,$1f,$1f,$1f, $1f,$1f,$1f,$1f, $1f,$1f,$1f,$1f
	.byte	$00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00

d_wave03:
	.byte	$11,$14,$17,$1a, $1c,$1e,$1f,$1f, $1f,$1f,$1e,$1c, $1a,$17,$14,$11
	.byte	$0e,$0b,$08,$05, $03,$01,$00,$00, $00,$00,$01,$03, $05,$08,$0b,$0e

d_wave04:
	.byte	$00,$01,$02,$03, $04,$05,$06,$07, $08,$09,$0a,$0b, $0c,$0d,$0e,$0f
	.byte	$10,$11,$12,$13, $14,$15,$16,$17, $18,$19,$1a,$1b, $1c,$1d,$1e,$1f

d_wave__:
	.byte	$00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00
	.byte	$00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00

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
playCustomWave:
	; select channel 0
	stz	$800

	; disable noise
	stz	$807

	; disable lfo
	stz	$808		; LFO frequency = 0
	stz	$809		; LFO=OFF, LFO Ctrl=0

	; set L and R global volume (#$LR)
	lda	#$ee
	sta	$801

	; write wavetable using our custom wave at d_wave00
	clx			; use x as wavetable data pointer index
playCustomWave_write:
	lda	d_wave04, x	; get data at d_wave00 + x and store in accumulator
	sta	$806		; write accumulator into PSG wave data
	inx
	cpx	#32
	bne	playCustomWave_write

	; set pitch frequency
	lda	#$ac
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
