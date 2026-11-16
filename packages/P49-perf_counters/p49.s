.equ p49_PERF_BASE, 0x00020180
.equ p49_DMA_BASE, 0x00020140

.text
.globl p49_main
p49_main:
  addi sp, sp, -48
  sw ra, 44(sp)
  sw s0, 40(sp)
  sw s1, 36(sp)
  sw s2, 32(sp)
  sw s3, 28(sp)
  sw s4, 24(sp)
  sw s5, 20(sp)
  sw s6, 16(sp)
  sw s7, 12(sp)
  sw s8, 8(sp)
  sw s9, 4(sp)
  call rcv_read_dec
  mv s1, a0
  call rcv_read_dec
  mv s2, a0
  li a5, p49_PERF_BASE
  mv t2, s1
  li a0, 0
  sw zero, 8(a5)
p49_loop:
  add a0, a0, t2
  addi t2, t2, -1
  bnez t2, p49_loop
  mv s3, a0
  lw s5, 0(a5)
  lw s4, 4(a5)
  sub s6, s5, s4
  li a5, p49_PERF_BASE
  li a4, p49_DMA_BASE
  la a0, p49_src
  la a1, p49_dst
  mv a2, s2
  li a3, 1
  sw zero, 8(a5)
  sw a0, 0(a4)
  sw a1, 4(a4)
  sw a2, 8(a4)
  sw a3, 12(a4)
p49_poll:
  lw t0, 16(a4)
  andi t0, t0, 2
  beqz t0, p49_poll
  lw s8, 0(a5)
  lw s0, 4(a5)
  sw zero, 16(a4)
  sub s7, s8, s0
  sub s9, s7, s6
  la a0, p49_str1
  call rcv_puts
  mv a0, s3
  call rcv_print_dec
  la a0, p49_str2
  call rcv_puts
  mv a0, s5
  call rcv_print_dec
  la a0, p49_str3
  call rcv_puts
  mv a0, s4
  call rcv_print_dec
  la a0, p49_str4
  call rcv_puts
  mv a0, s6
  call rcv_print_dec
  call rcv_newline
  la a0, p49_str5
  call rcv_puts
  mv a0, s8
  call rcv_print_dec
  la a0, p49_str3
  call rcv_puts
  mv a0, s0
  call rcv_print_dec
  la a0, p49_str4
  call rcv_puts
  mv a0, s7
  call rcv_print_dec
  call rcv_newline
  la a0, p49_str6
  call rcv_puts
  mv a0, s9
  call rcv_print_dec
  call rcv_newline
  lw s9, 4(sp)
  lw s8, 8(sp)
  lw s7, 12(sp)
  lw s6, 16(sp)
  lw s5, 20(sp)
  lw s4, 24(sp)
  lw s3, 28(sp)
  lw s2, 32(sp)
  lw s1, 36(sp)
  lw s0, 40(sp)
  lw ra, 44(sp)
  addi sp, sp, 48
  ret
p49_str1: .asciz "loop: sum="
p49_str2: .asciz " cycles="
p49_str3: .asciz " instructions="
p49_str4: .asciz " extra="
p49_str5: .asciz "dma: cycles="
p49_str6: .asciz "stolen by DMA: "
  .align 2
p49_src: .space 256
p49_dst: .space 256
