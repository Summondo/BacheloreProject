module eh2_posit_mul #(
  parameter POSIT_LEN   = 16                 ,
  parameter ES          = 2                  ,
  parameter REGIME_BW   = $clog2(POSIT_LEN)  ,
  parameter FRACTION_BW = POSIT_LEN - ES - 3 , // Number of fraction bits
  parameter PRODUCT_FRA = (FRACTION_BW+1)*2  , // Number of production fraction bits, except for MSB
  parameter FRAC_W_GRS  = POSIT_LEN - ES     , // Fraction bit width with GRS
  parameter MAX_REG     = POSIT_LEN - 1        // The maximal size of the regime bits
) (
  input  logic                   multiplier_sgn  ,
  input  logic [  REGIME_BW-1:0] multiplier_reg  ,
  input  logic [         ES-1:0] multiplier_exp  ,
  input  logic [FRACTION_BW-1:0] multiplier_fra  ,
  input  logic                   multiplicand_sgn,
  input  logic [  REGIME_BW-1:0] multiplicand_reg,
  input  logic [         ES-1:0] multiplicand_exp,
  input  logic [FRACTION_BW-1:0] multiplicand_fra,
  output logic                   product_sgn     ,
  output logic [  REGIME_BW-1:0] product_reg     ,
  output logic [         ES-1:0] product_exp     ,
  output logic [ FRAC_W_GRS-1:0] product_fra     ,
  output logic                   is_oflw_or_uflw
);

  logic                   sticky_bit  ;
  logic [    REGIME_BW:0] temp        ;
  logic [PRODUCT_FRA-1:0] fraction_mul;

  assign is_oflw_or_uflw              = ($signed(temp) >= MAX_REG) | ($signed(~temp + 1'b1) > MAX_REG);                                                        // Determine if there is an over- or underflow

  assign fraction_mul                 = $signed({2'b1,multiplier_fra}) * $signed({2'b1,multiplicand_fra});                                                     // The 0's is for unsigned multiplication, The 1's are for normalization
  assign sticky_bit                   = fraction_mul[FRACTION_BW-3] | fraction_mul[FRACTION_BW-4] | fraction_mul[FRACTION_BW-5];                               // Calculating sticky bit

  assign product_sgn                  = multiplier_sgn ^ multiplicand_sgn;                                                                                     // AND sign bits
  assign {temp,product_exp}           = $signed({multiplier_reg,multiplier_exp}) + $signed({multiplicand_reg,multiplicand_exp}) + fraction_mul[PRODUCT_FRA-1]; // Adding Regime and Exponent bits
  assign product_reg                  = temp[REGIME_BW-1:0];                                                                                                   // Making sure regime beats don't overflow or underflow
  assign product_fra                  = fraction_mul[PRODUCT_FRA-1] ? {fraction_mul[PRODUCT_FRA-2:FRACTION_BW-1],sticky_bit}                                   // Normalizing the result if it is too big
                                                                    : {fraction_mul[PRODUCT_FRA-3:FRACTION_BW-2],sticky_bit};                                  // Passing on the fraction bits with GRS
endmodule