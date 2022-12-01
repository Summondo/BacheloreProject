# BacheloreProject
 This project is a bachelor project implementing arithemetics into an Swerv EH2 core.
 The original core can be found here: https://github.com/chipsalliance/Cores-SweRV-EH2
 There are two cores in theis repository, one in the design folder which is able to be run on the computer and one in the FPGA folder which is able to be synthesised in vivado.
 The differences of the cores comes down to some system verilog features that is not supported in vivado.
 The removal of assert functions in most files and replacing the parameter struct "pt".
 
 To run the core on your computer there are some requirements.
 For it to be able to run following software is required:
  - A risc-v compiler, for the project lowrisc rv64imac was used
 
 For you to see the run in a window one these softwares are required:
  - Verilator
  - Irun
  - Vcs
  - Vlog
  - Riviera
  - Questa

 For the testing of this project Verilator and Questa have been used.

 If all of the required software the first step to run the core is to set the envioroment variable RV_ROOT to where the folder is.
 After this take a look at the direcotory testbench/asm to find which test that you want to try.
 Go back to the root directory of the core and use the command "rm program.hex" to be sure you actually get the test you want.
 A description of all the tests that I have made can be found at the bottom of this page, the others can be found in the link above.
 Run the command "make -f $RV_ROOT/tools/Makefile program.hex TEST=<test>", where <test> is the test you choose without the ".s".
 After this edit in the tools/Makefile so the specification of the test match on line 30, 31 and 33 or set them during the run like there is done with the variable "TEST" e.g., if chosen positS16 as test then go in and set "POSIT_LEN" to 16, "ES" to 2 and "POSIT" to 1.
 Then run the command "make -f $RV_ROOT/tools/Makefile verilator TEST=<test>", if no simulation program is chosen or "make -f $RV_ROOT/tools/Makefile <simulator> TEST=<test>" if a program is chosen.
 
 
To synthesis the core in vivado then:
Start a new project.
Add all the files in the FPGA directory and in its subdirectories.
Set "eh2_param.vh" and "pd_defines.vh" as gloabal includes.
Try running the synthesis.
From here you should be able to run the different utilazation, timing and etc. commands.
The defines for editing posit and exponent size, and if it is integrated with float or posit is at the bottom of "common_defines.vh".

The tests made for this project are
- positA8 : An 8 bit posit test that test if addition is working with an exponent value of 1.
- positA16: An 16 bit posit test that test if addition is working with an exponent value of 2.
- positA32: An 32 bit posit test that test if addition is working with an exponent value of 3.
- positAS : A test created to test the special cases of the posits for 16 bits with 2 exponent bits with addition.
- positM8 : An 8 bit posit test that test if multiplication is working with an exponent value of 1.
- positM16: An 16 bit posit test that test if multiplication is working with an exponent value of 2.
- positM32: An 32 bit posit test that test if multiplication is working with an exponent value of 3.
- positMS : A test created to test the special cases of the posits for 16 bits with 2 exponent bits with multiplication.
- positS8 : An 8 bit posit test that test if subtraction is working with an exponent value of 1.
- positS16: An 16 bit posit test that test if subtraction is working with an exponent value of 2.
- positS32: An 32 bit posit test that test if subtraction is working with an exponent value of 3.
- positSS : A test created to test the special cases of the posits for 16 bits with 2 exponent bits with subtraction.
