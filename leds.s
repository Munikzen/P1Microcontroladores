/* This program turns on and off 5 leds embedded in a protoboard through. The leds are 
 * connected to the following pins: PB1 PB2 PB5 PB6 PB7. This pins works as a GPIO,
 * then they must be configured at assembly level, through the following registers:
 * 1) RCC register,
 * 2) GPIOC_CRL register, 
 * 3) GPIOC_CRH register, and
 * 4) GPIOC_ODR register.
 * 
 * Author: Brandon Chavez Salaverria.
 */

.include "gpio.inc" @ Includes definitions from gpio.inc file

.thumb              @ Assembles using thumb mode
.cpu cortex-m3      @ Generates Cortex-M3 instructions
.syntax unified

.include "nvic.inc"


setup:
        # Prologue
        push {r7}
	sub	sp, sp, #28
	add	r7, sp, #0

        # enabling clock in port B
        ldr     r0, =RCC_APB2ENR @ move 0x40021018 to r0
        mov     r3, 0x8 @ loads 8 in r1 to enable clock in port B (IOPC bit)
        str     r3, [r0] @ M[RCC_APB2ENR] gets 8

        # set pins 1-2-5-6-7 as digital output
        ldr     r0, =GPIOB_CRL @ moves address of GPIOB_CRL register to r0
        ldr     r3, =0x33344334 @ PB1, PB2, PB5, PB6, PB7: output push-pull, max speed 50 MHz
        str     r3, [r0] @ M[GPIOB_CRL] gets 0x33344334

        # set pins 8-9 as digital input
        ldr     r0, =GPIOB_CRH @ moves address of GPIOB_CRH register to r0
        ldr     r3, =0x44444488 @ : input pull-down
        str     r3, [r0] @ M[GPIOB_CRH] gets 0x44444488

        # set led status initial value
        ldr     r0, =GPIOB_ODR @ moves address of GPIOB_ODR register to r0
        mov     r1, 0x0
        str     r1, [r7, #12] @ sets num variable at 0
        str     r1, [r7, #16] @ sets bit[0] at 0
        str     r1, [r7, #20] @ sets bit[1] at 0
        str     r1, [r7, #24] @ sets bit[2] at 0
        str     r1, [r7, #28] @ sets bit[3] at 0
        str     r1, [r7, #32] @ sets bit[4] at 0
loop:   
        mov     r2, 0x0
        b .F1

.L1:    

        
        add     r2, #0x1

.F1     ldr     r2, [r7,#12]
        cmp     r2, #5
        bge     .L1
        b       loop
