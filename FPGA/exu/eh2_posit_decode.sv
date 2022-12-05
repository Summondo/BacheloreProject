module eh2_posit_decode #(
  parameter POSIT_LEN   = 32                ,
  parameter ES          = 2                 ,
  parameter REGIME_BW   = $clog2(POSIT_LEN) ,
  parameter FRACTION_BW = POSIT_LEN - ES - 3, // Number of fraction bits
  parameter ES_START    = POSIT_LEN - 4     , // Start bit for the exponent
  parameter ES_STOP     = POSIT_LEN - ES - 3, // Stop bit for the exponent
  parameter WO_SIGN     = POSIT_LEN - 1     , // Posit without sign bit
  parameter WO_1ST_REG  = POSIT_LEN - 2       // Without first regime bit
) (
  input  logic [  POSIT_LEN-1:0] posit_data_in,
  output logic                   sign         ,
  output logic [  REGIME_BW-1:0] regime       ,
  output logic [         ES-1:0] exponent     ,
  output logic [FRACTION_BW-1:0] fraction     ,
  output logic                   is_special     // Flag to indicate if input data is Zero/NaR
);

  logic                  vld                  ;
  logic                  sign_bit             ;
  logic                  regime_sign_bit      ;
  logic [ REGIME_BW-1:0] leading_zeros_cnt    ;
  logic [ POSIT_LEN-4:0] exp_and_frac_data    ;
  logic [WO_1ST_REG-1:0] find_leading_zeros_in;
  logic [   WO_SIGN-1:0] posit_data           ;

  assign sign_bit              = posit_data_in[POSIT_LEN-1];
  assign posit_data            = sign_bit                       ? ~posit_data_in[WO_SIGN-1:0] + 1'b1 : posit_data_in[WO_SIGN-1:0];      // If the posit sign bit is high takes 2's complement
  assign regime_sign_bit       = posit_data[WO_1ST_REG];
  assign find_leading_zeros_in = regime_sign_bit                ? ~posit_data[WO_1ST_REG-1:0]        : posit_data[WO_1ST_REG-1:0];      // If the regime bits are 1's, then inverse it

  LOD #(.WIDTH(POSIT_LEN)) leading_zero_counter (.pin({find_leading_zeros_in,2'b0}), .out(leading_zeros_cnt), .vld(vld));

  assign exp_and_frac_data     = posit_data << leading_zeros_cnt;

  ///////////
  //Outputs//
  ///////////
  assign sign       = sign_bit;
  assign regime     = regime_sign_bit                           ? {leading_zeros_cnt}           : {~leading_zeros_cnt};       // Make the regime value negative, if the regime bits are all 0's
  assign exponent   = exp_and_frac_data[ES_START:ES_STOP];
  assign fraction   = exp_and_frac_data[FRACTION_BW-1:0];
  assign is_special = posit_data_in[WO_SIGN-1:0] == 'd0;                                                                                // Zero and NaR are considered as specials
endmodule