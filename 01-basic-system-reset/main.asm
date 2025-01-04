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
	nop


_end:
	.org $fffe
	.dw _system_reset
