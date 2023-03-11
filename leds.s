/* This program turns on and off 5 leds embedded in a protoboard through. The leds are 
 * connected to the following pins: PA0, PA1, PA2, PA3, PA4. This pins works as a GPIO,
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

addition:
        # Prologue
        push    {r7, lr}
        sub     sp, sp, #8
        add     r7, sp,
        str     r0, [r7, #4] @ backs up counter
        # Function body
        
        # Epilogue
        adds    r7, r7, #8
        mov     sp, r7
        pop     {r7, lr}
        bx      lr
subtraction:

reset:
        # Prologue
        push    {r7, lr}
        sub     sp, sp, #8
        add     r7, sp,
        str     r0, [r7, #4] @ backs up counter
        # Function body
        mov     r0, #0
        str     r0, [r7, #4] @ resets counter to 0
        ldr     r0, =GPIOA_ODR
        ldr     r3, [r7, #4]
        str     r3, [r0] 
        ldr     r0, [r7, #4]
        # Epilogue
        adds    r7, r7, #8
        mov     sp, r7
        pop     {r7, lr}
        bx      lr

delay:
        # Prologue
        push    {r7} @ backs r7 up
        sub     sp, sp, #28 @ reserves a 32-byte function frame
        add     r7, sp, #0 @ updates r7
        str     r0, [r7] @ backs ms up
        # Function body
        mov     r0, #255 @ ticks = 255, adjust to achieve 1 ms delay
        str     r0, [r7, #16]
        # for (i = 0; i < ms; i++)
        mov     r0, #0 @ i = 0;
        str     r0, [r7, #8]
        b       F3
        # for (j = 0; j < tick; j++)
F4:     mov     r0, #0 @ j = 0;
        str     r0, [r7, #12]
        b       F5
F6:     ldr     r0, [r7, #12] @ j++;
        add     r0, #1
        str     r0, [r7, #12]
F5:     ldr     r0, [r7, #12] @ j < ticks;
        ldr     r1, [r7, #16]
        cmp     r0, r1
        blt     F6
        ldr     r0, [r7, #8] @ i++;
        add     r0, #1
        str     r0, [r7, #8]
F3:     ldr     r0, [r7, #8] @ i < ms
        ldr     r1, [r7]
        cmp     r0, r1
        blt     F4
        # Epilogue
        adds    r7, r7, #28
        mov     sp, r7
        pop     {r7}
        bx      lr

setup:
        # Prologue
        push    {r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0

        # enabling clock in port B
        ldr     r0, =RCC_APB2ENR @ move 0x40021018 to r0
        mov     r3, 0x4 @ loads 16 in r1 to enable clock in port A (IOPC bit)
        str     r3, [r0] @ M[RCC_APB2ENR] gets 4

        # set pin 0 to 4 as digital output
        ldr     r0, =GPIOA_CRL @ moves address of GPIOA_CRL register to r0
        ldr     r3, =0x44433333 @ PA0, PA1, PA2, PA3, PA4: output push-pull, max speed 50 MHz
        str     r3, [r0] @ M[GPIOA_CRL] gets 0x44433333

        # set pins 8-9 as digital input
        ldr     r0, =GPIOA_CRH @ moves address of GPIOA_CRH register to r0
        ldr     r3, =0x44444488 @ : input pull-down
        str     r3, [r0] @ M[GPIOB_CRH] gets 0x44444488

        # set led status initial value
        ldr     r0, =GPIOA_ODR @ moves address of GPIOA_ODR register to r0
        mov     r3, #0
        str     r3, [r0]

        # counter = 0;
        mov     r0, #0
        str     r0, [r7]
loop:   
        # if(2 buttons pressed)
        ldr     r0, =GPIOA_IDR
        ldr     r1, [r0]
        and     r1, 0x300
        cmp     r1, 0x300
        bne     .L1

        bl      reset
        str     r0, [r7]
        mov     r0, #500
        bl      delay

        
.L1:    # else if(addition button is pressed)
        ldr     r0, =GPIOA_IDR
        ldr     r0, [r0]
        and     r0, 0x100
        cmp     r0, 0x100
        bne     .L2

        ldr     r0, [r7]
        bl      addition

        # else if(subtraction button is pressed)
        and     r0, 0x200

        bge     .L1
        b       loop
