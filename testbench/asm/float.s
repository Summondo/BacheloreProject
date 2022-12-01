#include "defines.h"

#define STDOUT 0xd0580000

// Code to execute
.section .text
.global _start
_start:
	li  x1, 0xFFFFFFFF //Only Regime
	li x15, 0xFFFFFFFF //Only Regime

	li  x1, 0xFFFF4DD8 //Only Regime
    li x15, 0xFFFF4C10 //Only Regime
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    li  x5, 0xFFFF3FC0 //Only Regime
    li x15, 0xFFFF58C0 //Only Regime
    .long 0x08F28453   //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0xFFFF4DD8 //Only Regime
    li x15, 0xFFFF4C10 //Only Regime
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