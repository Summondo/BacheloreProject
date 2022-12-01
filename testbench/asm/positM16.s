
#include "defines.h"

#define STDOUT 0xd0580000

// Code to execute
.section .text
.global _start
_start:

    //Lauras test
    li x15, 0x00006c27
    li  x1, 0x00006508
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8



    //Only regime bits--------------------------------------------------------------------------------------------------
    li x15, 0x00000001 //Only Regime
    li  x1, 0x00000001 //Only Regime
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FFB //No fraction
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x000044F2 //One positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00006C27 //Small positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FD4 //Big positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000381A //One negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00000B0F //Small negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000004F //Big negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8


    //No fraction bits--------------------------------------------------------------------------------------------------
    li x15, 0x00000001 //Only Regime
    li  x1, 0x00007FFB //No fraction
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FFB //No fraction
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x000044F2 //One positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00006C27 //Small positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FD4 //Big positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000381A //One negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00000B0F //Small negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000004F //Big negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8


    //One positive regime bit--------------------------------------------------------------------------------------------------
    li x15, 0x00000001 //Only Regime
    li  x1, 0x000044F2 //One positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FFB //No fraction
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x000044F2 //One positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00006C27 //Small positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FD4 //Big positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000381A //One negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00000B0F //Small negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000004F //Big negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8


    //Small positive regime bit--------------------------------------------------------------------------------------------------
    li x15, 0x00000001 //Only Regime
    li  x1, 0x00006C27 //Small positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FFB //No fraction
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x000044F2 //One positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00006C27 //Small positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FD4 //Big positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000381A //One negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00000B0F //Small negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000004F //Big negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8


    //Big positive regime bit--------------------------------------------------------------------------------------------------
    li x15, 0x00000001 //Only Regime
    li  x1, 0x00007FD4 //Big positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FFB //No fraction
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x000044F2 //One positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00006C27 //Small positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FD4 //Big positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000381A //One negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00000B0F //Small negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000004F //Big negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    //One negative regime bit--------------------------------------------------------------------------------------------------
    li x15, 0x00000001 //Only Regime
    li  x1, 0x0000381A //One negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FFB //No fraction
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x000044F2 //One positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00006C27 //Small positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FD4 //Big positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000381A //One negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00000B0F //Small negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000004F //Big negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    //Small negative regime bit--------------------------------------------------------------------------------------------------
    li x15, 0x00000001 //Only Regime
    li  x1, 0x00000B0F //Small negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FFB //No fraction
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x000044F2 //One positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00006C27 //Small positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FD4 //Big positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000381A //One negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00000B0F //Small negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000004F //Big negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    //Big negative regime bit--------------------------------------------------------------------------------------------------
    li x15, 0x00000001 //Only Regime
    li  x1, 0x0000004F //Big negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FFB //No fraction
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x000044F2 //One positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00006C27 //Small positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00007FD4 //Big positive regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000381A //One negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x00000B0F //Small negative regime bit
    .long 0x10F08453   //PMUL  rs1 1, rs2 15, rd 8

    li x15, 0x0000004F //Big negative regime bit
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
