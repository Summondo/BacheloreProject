
#include "defines.h"

#define STDOUT 0xd0580000

// Code to execute
.section .text
.global _start
_start:

    //Lauras test
    li  x1, 0x00006c27
    li x15, 0x00006508
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8



    //Signed multiplied with special numbers--------------------------------------------------------------------------------------------------
    li x15, 0x0000F4AB //Signed number
    li  x1, 0x0000F4AB //Signed number
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x000001F5 //Unsigned number
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00000000 //Zero
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00008000 //Infinity
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00000001 //Min pos
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00007FFE //Max pos
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8



    //Unsigned multiplied with special numbers--------------------------------------------------------------------------------------------------
    li x15, 0x000001F5 //Unsigned number
    li  x1, 0x0000F4AB //Signed number
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x000001F5 //Unsigned number
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00000000 //Zero
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00008000 //Infinity
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00000001 //Min pos
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00007FFE //Max pos
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8



    //Zero multiplied with special numbers--------------------------------------------------------------------------------------------------
    li x15, 0x00000000 //Zero
    li  x1, 0x0000F4AB //Signed number
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x000001F5 //Unsigned number
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00000000 //Zero
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00008000 //Infinity
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00000001 //Min pos
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00007FFE //Max pos
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8


    //Infinity multiplied with special numbers--------------------------------------------------------------------------------------------------
    li x15, 0x00008000 //Infinity
    li  x1, 0x0000F4AB //Signed number
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x000001F5 //Unsigned number
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00000000 //Zero
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00008000 //Infinity
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00000001 //Min pos
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00007FFE //Max pos
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8


    //Min positive multiplied with special numbers--------------------------------------------------------------------------------------------------
    li x15, 0x00000001 //Min pos
    li  x1, 0x0000F4AB //Signed number
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x000001F5 //Unsigned number
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00000000 //Zero
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00008000 //Infinity
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00000001 //Min pos
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00007FFE //Max pos
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8


    //Max positive multiplied with special numbers--------------------------------------------------------------------------------------------------
    li x15, 0x00007FFE //Max pos
    li  x1, 0x0000F4AB //Signed number
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x000001F5 //Unsigned number
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00000000 //Zero
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00008000 //Infinity
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00000001 //Min pos
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

    li  x1, 0x00007FFE //Max pos
    .long 0x08F08453 //PSUB  rs1 1, rs2 15, rd 8

  beq   x0,  x0,  _finish

_finish:
    li    x3, STDOUT
    addi  x5,   x0, 0xff
    sb    x5, 0(x3)
    beq   x0,  x0,  _finish
.rept 100
    nop
.endr  beq   x0,  x0,  _finish