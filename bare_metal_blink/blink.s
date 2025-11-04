	.file	"blink.c"
__SP_H__ = 0x3e
__SP_L__ = 0x3d
__SREG__ = 0x3f
__tmp_reg__ = 0
__zero_reg__ = 1
	.text
.global	main
	.type	main, @function
main:
	push r28
	push r29
	in r28,__SP_L__
	in r29,__SP_H__
	sbiw r28,8
	in __tmp_reg__,__SREG__
	cli
	out __SP_H__,r29
	out __SREG__,__tmp_reg__
	out __SP_L__,r28
/* prologue: function */
/* frame size = 8 */
/* stack size = 10 */
.L__stack_usage = 10
	ldi r24,lo8(36)
	ldi r25,0
	ldi r18,lo8(32)
	movw r30,r24
	st Z,r18
.L6:
	ldi r24,lo8(37)
	ldi r25,0
	ldi r18,lo8(32)
	movw r30,r24
	st Z,r18
	std Y+1,__zero_reg__
	std Y+2,__zero_reg__
	std Y+3,__zero_reg__
	std Y+4,__zero_reg__
	rjmp .L2
.L3:
	ldi r24,lo8(37)
	ldi r25,0
	ldi r18,lo8(32)
	movw r30,r24
	st Z,r18
	ldd r24,Y+1
	ldd r25,Y+2
	ldd r26,Y+3
	ldd r27,Y+4
	adiw r24,1
	adc r26,__zero_reg__
	adc r27,__zero_reg__
	std Y+1,r24
	std Y+2,r25
	std Y+3,r26
	std Y+4,r27
.L2:
	ldd r24,Y+1
	ldd r25,Y+2
	ldd r26,Y+3
	ldd r27,Y+4
	cpi r24,65
	sbci r25,66
	sbci r26,15
	cpc r27,__zero_reg__
	brlt .L3
	ldi r24,lo8(37)
	ldi r25,0
	movw r30,r24
	st Z,__zero_reg__
	std Y+5,__zero_reg__
	std Y+6,__zero_reg__
	std Y+7,__zero_reg__
	std Y+8,__zero_reg__
	rjmp .L4
.L5:
	ldi r24,lo8(37)
	ldi r25,0
	movw r30,r24
	st Z,__zero_reg__
	ldd r24,Y+5
	ldd r25,Y+6
	ldd r26,Y+7
	ldd r27,Y+8
	adiw r24,1
	adc r26,__zero_reg__
	adc r27,__zero_reg__
	std Y+5,r24
	std Y+6,r25
	std Y+7,r26
	std Y+8,r27
.L4:
	ldd r24,Y+5
	ldd r25,Y+6
	ldd r26,Y+7
	ldd r27,Y+8
	cpi r24,65
	sbci r25,66
	sbci r26,15
	cpc r27,__zero_reg__
	brlt .L5
	rjmp .L6
	.size	main, .-main
	.ident	"GCC: (GNU) 7.3.0"
