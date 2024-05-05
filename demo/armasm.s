
.4byte 0xFFFFFFFF
.4byte 0xFFFFFFFF
.ascii "CXVE"

.arm
.balign 4, 0

init:
	mov r0, PSR_IRQ_MODE
	msr cpsr_cf, r0
	ldr sp, sp_irq
	mov r0, PSR_SYS_MODE
	msr cpsr_cf, r0
	ldr sp, sp_sys
	ldr r1, =INTR_VECTOR
	adr r0, intr_main
	str r0, [r1]
	ldr r1, =main
	mov lr, pc
	bx r1
	b init

.Lfoundintr:
	strh r0, [r3, OFFSET_REG_IF - 0x200]
	mov r1, INTR_FLAG_SERIAL | INTR_FLAG_TIMER3 | INTR_FLAG_HBLANK
	bic r2, r2, r0
	and r1, r1, r2
	strh r1, [r3, OFFSET_REG_IE - 0x200]
	mrs r3, cpsr
	bic r3, r3, PSR_I_BIT | PSR_F_BIT | PSR_MODE_MASK
	orr r3, r3, PSR_SYS_MODE
	msr cpsr_cf, r3
	ldr r1, =intr_table
	add r1, r1, r12
	ldr r0, [r1]
	stmdb sp!, {lr}
	adr lr, .Lretaddr
	bx r0
.Lretaddr:
	ldmia sp!, {lr}
	mrs r3, cpsr
	bic r3, r3, PSR_I_BIT | PSR_F_BIT | PSR_MODE_MASK
	orr r3, r3, PSR_I_BIT | PSR_IRQ_MODE
	msr cpsr_cf, r3
	ldmia sp!, {r0-r3,lr}
	strh r2, [r3, OFFSET_REG_IE - 0x200]
	strh r1, [r3, OFFSET_REG_IME - 0x200]
	msr spsr_cf, r0
	bx lr

.pool

.balign 4, 0 @ don't pad with nop.
