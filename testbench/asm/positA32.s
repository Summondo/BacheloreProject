
#include "defines.h"

#define STDOUT 0xd0580000

// Code to execute
.section .text
.global _start
_start:

    //Lauras test
    li x15, 0x00006c27
    li  x1, 0x00006508
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop



    //--------------------------------------------------------------------------------------------------
    li x15, 0x080AF701 //
    li  x1, 0x080AF701 //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop

    li x15, 0xF9F52481 //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop

    li x15, 0x7FDBA63C //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop

    li x15, 0x8000D00F //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop


    //--------------------------------------------------------------------------------------------------
    li x15, 0x080AF701 //
    li  x1, 0xF9F52481 //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop

    li x15, 0xF9F52481 //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop

    li x15, 0x7FDBA63C //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop

    li x15, 0x8000D00F //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop


    //--------------------------------------------------------------------------------------------------
    li x15, 0x080AF701 //
    li  x1, 0x7FDBA63C //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop

    li x15, 0xF9F52481 //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop

    li x15, 0x7FDBA63C //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop

    li x15, 0x8000D00F //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop

    //--------------------------------------------------------------------------------------------------
    li x15, 0x080AF701 //
    li  x1, 0x8000D00F //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop

    li x15, 0xF9F52481 //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop

    li x15, 0x7FDBA63C //
    .long 0x00F08453   //PADD  rs1 1, rs2 15, rd 8

    nop
    nop

    li x15, 0x8000D00F //
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
