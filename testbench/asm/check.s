#include "defines.h"

#define STDOUT 0xd0580000

// Code to execute
.section .text
.global _start
_start:
    li x15, 0x00006c27
    li  x1, 0x00006507
    addi x1, x1, 1
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li    x3, STDOUT
    addi  x5,   x0, 0xff
    beq   x0,  x0,  _finish

_finish:
    li    x3, STDOUT
    addi  x5,   x0, 0xff
    sb    x5, 0(x3)
    beq   x0,  x0,  _finish
.rept 100
    nop
.endr  beq   x0,  x0,  _finish