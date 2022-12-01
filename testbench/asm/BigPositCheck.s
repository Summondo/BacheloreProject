#include "defines.h"

#define STDOUT 0xd0580000

// Code to execute
.section .text
.global _start
_start:

	li x15, 0x00000001 //Only Regime
    li  x1, 0x00000001 //Only Regime
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8


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