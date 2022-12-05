module eh2_posit_encode #(
  parameter POSIT_LEN   = 32                ,
  parameter ES          = 3                 ,
  parameter REGIME_BW   = $clog2(POSIT_LEN) ,
  parameter FRACTION_BW = POSIT_LEN - ES    , // Number of fraction bits
  parameter DOUBLE_BITS = (POSIT_LEN-1)*2   , // Nearly double the amount of bits
  parameter WO_SIGN     = POSIT_LEN -1      , // Posit length without sign bit
  parameter WO_1ST_REG  = POSIT_LEN - 2       // The posit length without first regime bit
) (
  input  logic                   sign           ,
  input  logic [  REGIME_BW-1:0] regime         ,
  input  logic [         ES-1:0] exponent       ,
  input  logic [FRACTION_BW-1:0] fraction       ,
  input  logic                   rs1_sign       ,
  input  logic                   rs2_sign       ,
  input  logic                   is_special_rs1 ,
  input  logic                   is_special_rs2 ,
  input  logic                   is_oflw_or_uflw,
  input  logic                   mul            ,
  input  logic                   is_zero        ,
  output logic [  POSIT_LEN-1:0] posit_data_out
);

  logic                   regime_sign_bit;
  logic                   rounding_bit   ;
  logic [    WO_SIGN-1:0] reg_temp       ;
  logic [DOUBLE_BITS-1:0] all, not_round_posit;
  logic [    WO_SIGN-1:0] rounded_posit  ;
  logic [  REGIME_BW-1:0] expanded_regime;

  assign regime_sign_bit   = regime[REGIME_BW-1];

  assign reg_temp          = regime_sign_bit             ?{{(WO_1ST_REG){1'b0}},1'b1}  : {{(WO_1ST_REG){1'b1}},1'b0};            // Create regime bits

  assign all               = {reg_temp,exponent,fraction};                                                                       // Put all parts together

  assign expanded_regime   = regime_sign_bit             ? ~regime[REGIME_BW-1:0]      : regime[REGIME_BW-1:0];                  // Calculate how much there should be shifted

  assign not_round_posit   = all >> (expanded_regime);                                                                           // The -1 is for the getting a rounding bit
  assign rounding_bit      = (not_round_posit[2] & (not_round_posit[1] | not_round_posit[0]));                                   // Find if there is a need to be rounded
  assign rounded_posit     = all < FRACTION_BW ? not_round_posit[POSIT_LEN+2:3] + rounding_bit : not_round_posit[POSIT_LEN+2:3]; // If there is any part of the fraction in the posit, then add rounding bit

  assign posit_data_out[POSIT_LEN-1:0]  = (is_special_rs1 & is_special_rs2 &
                                          (rs1_sign ^ rs2_sign) & mul)            ? {       (POSIT_LEN)  {1'b0}}    :            // If NaR and zero is being multiplied
                                           is_oflw_or_uflw                        |                                              // If there is an overflow or an underflow set to NaR
                                          (is_special_rs1 & rs1_sign)             |                                              // If there is a NaR input set to NaR
                                          (is_special_rs2 & rs2_sign)             ? {1'b1, {(POSIT_LEN-1){1'b0}}}   :            // If there is a NaR input set to NaR
                                           is_zero                                |                                              // If the ALU says the result is zero set to zero
                                        ((is_special_rs1 | is_special_rs2) & mul) ? {       (POSIT_LEN)  {1'b0}}    :            // If one is a special case then set to zero
                                          sign                                    ? {sign,~rounded_posit  + 1'b1}   :            // If nothing special check if there needs to be taken 2's complement
                                                                                    {sign, rounded_posit        }   ;            // Else set it to the calculated result

endmodule