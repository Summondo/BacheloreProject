// E is the value of ŕegime and exponent concatenated

module eh2_posit_alu #(
  parameter POSIT_LEN      = 16                         ,
  parameter ES             = 2                          ,
  parameter REGIME_BW      = 5                          ,
  parameter FRACTION_BW    = POSIT_LEN - ES - 3         , // Number of fraction bits
  parameter PRODUCT_FRA    = (FRACTION_BW+1)*2          , // Number of production fraction bits, except for MSB
  parameter E_DIFFERENCE   = ES + REGIME_BW             , // Number of bits needed to make the overall exponent difference
  parameter MAX_E          = {(ES+REGIME_BW-2){1'b1}}   , // Maximum value of E before it goes to infinite
  parameter LEADING_ONE_BW = POSIT_LEN * 2              , // Double the bit width
  parameter ZEROS_FILLER   = LEADING_ONE_BW-PRODUCT_FRA , // The amount of zeroes to make leading one detector work
  parameter FRAC_W_GRS     = POSIT_LEN - ES             , // Fraction bit width with GRS
  parameter MSB_FRA        = PRODUCT_FRA - 2              // MSB for the final fraction value
  )(
  input  logic                      first_sgn       ,
  input  logic [  REGIME_BW-1:0]    first_reg       ,
  input  logic [         ES-1:0]    first_exp       ,
  input  logic [FRACTION_BW-1:0]    first_fra       ,

  input  logic                      second_sgn      ,
  input  logic [  REGIME_BW-1:0]    second_reg      ,
  input  logic [         ES-1:0]    second_exp      ,
  input  logic [FRACTION_BW-1:0]    second_fra      ,

  output logic                      product_sgn     ,
  output logic [  REGIME_BW-1:0]    product_reg     ,
  output logic [         ES-1:0]    product_exp     ,
  output logic [ FRAC_W_GRS-1:0]    product_fra     ,

  input  logic                      add_or_sub      , // If it is high then the operation is substitution
  output logic                      is_zero         , // Is the result zero
  output logic                      is_oflw_or_uflw   // Is there an overflow or an underflow
);

  logic                    a_bigger_exp    ;
  logic                    a_bigger_fra    ;
  logic                    zero_exp_check  ;
  logic                    range_check     ;
  logic                    vld             ;
  logic                    sticky_bit      ;
  logic [E_DIFFERENCE-1:0] E_diff          ;
  logic [ PRODUCT_FRA-1:0] result_fra      ;
  logic [ PRODUCT_FRA-2:0] shift_first_fra ;
  logic [ PRODUCT_FRA-2:0] shift_second_fra;
  logic [ PRODUCT_FRA-1:0] operation_fra   ;
  logic [   REGIME_BW-1:0] normalize       ;
  logic [ FRACTION_BW-1:0] rounded_fraction;


  assign a_bigger_exp     = $signed({first_reg,first_exp}) > $signed({second_reg,second_exp});                                                // Finding which exponent is bigger
  assign E_diff           = a_bigger_exp ? $signed({first_reg,first_exp})   - $signed({second_reg,second_exp}) :
                                           $signed({second_reg,second_exp}) - $signed({first_reg,first_exp})   ;                              // Set total exponent difference
  assign range_check      = $signed(E_diff) > FRACTION_BW;                                                                                    // Check if out of range
  assign a_bigger_fra     = first_fra > second_fra;                                                                                           // Finding which fraction is bigger
  assign zero_exp_check   = E_diff == 'd0;                                                                                                    // See if their is no difference between the two exponents


  assign shift_first_fra  = a_bigger_exp ? {1'b1,first_fra ,{FRACTION_BW{1'b0}}}           : {1'b1,first_fra ,{FRACTION_BW{1'b0}}} >> E_diff; // Shift lesser fraction bits
  assign shift_second_fra = a_bigger_exp ? {1'b1,second_fra,{FRACTION_BW{1'b0}}} >> E_diff : {1'b1,second_fra,{FRACTION_BW{1'b0}}};           // Shift lesser fraction bits

  assign operation_fra    = add_or_sub ? shift_first_fra - shift_second_fra: shift_first_fra + shift_second_fra;                              // Do addition or subtraction
  LOD #(.WIDTH(LEADING_ONE_BW)) leading_zero_counter(.pin({operation_fra,{ZEROS_FILLER{1'b0}}}), .out(normalize), .vld(vld));
  assign result_fra       = operation_fra << normalize;                                                                                       // Normalize if necersary
  assign sticky_bit       = result_fra[FRACTION_BW-2] | result_fra[FRACTION_BW-3] | result_fra[FRACTION_BW-4];                                // Finding sticky bit

  /////////////
  ///Outputs///
  /////////////

  assign is_oflw_or_uflw = ($signed({first_reg,first_exp}) ==  MAX_E) & ($signed({second_reg,second_exp}) ==  MAX_E) & ~add_or_sub |          // If both exponent values are positive max and they are added
                           ($signed({first_reg,first_exp}) == -MAX_E) & ($signed({second_reg,second_exp}) == -MAX_E) &  add_or_sub;           // If both exponent values are negative max and they are subtracted
  assign is_zero         = ~result_fra[PRODUCT_FRA-1];

always_comb begin
  if(zero_exp_check) begin                                                                                                                    // If there is no difference between the exponents
    if(result_fra == 'd0)
      product_sgn = 1'b0;                                                                                                                     // If everything is zero, then it is zero
    else if(a_bigger_fra)
      product_sgn =  first_sgn;                                                                                                               // Set sign to first if it was bigger
    else if(add_or_sub)
      product_sgn = ~second_sgn;                                                                                                              // Set sign to inverse of second if it was bigger and a subtraction
    else
      product_sgn =  second_sgn;                                                                                                              // Set sign to second if it was bigger and a addition
  end else begin
    if(a_bigger_exp)
      product_sgn = first_sgn;                                                                                                                // Set sign to first if it was bigger
    else if(add_or_sub)
      product_sgn = ~second_sgn;                                                                                                              // Set sign to inverse of second if it was bigger and a subtraction
    else
      product_sgn =  second_sgn;                                                                                                              // Set sign to second if it was bigger and a addition
  end

  assign {product_reg,product_exp}  =  a_bigger_exp ? {first_reg,first_exp}   - normalize + 1'b1:                                             // If a is bigger set it to a normalized
                                                      {second_reg,second_exp} - normalize + 1'b1;                                             // Else set it to b normalize

  if(range_check) begin
    if(a_bigger_exp)
      product_fra =  {first_fra ,3'b0};                                                                                                       // If first is bigger then first
    else if(add_or_sub)
      product_fra = ~{second_fra,3'b0} + 1'b1;                                                                                                // If the operation is sub take 2's complement
    else
      product_fra =  {second_fra,3'b0};                                                                                                       // If second is bigger then second
  end else begin
    product_fra   = {result_fra[MSB_FRA:FRACTION_BW-1],sticky_bit};                                                                           // Else set to calculated
  end
end
endmodule