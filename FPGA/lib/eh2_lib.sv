module eh2_btb_tag_hash #(
`include "eh2_param.vh"
 ) (
                       input logic [`BTB_ADDR_HI+`BTB_BTAG_SIZE+`BTB_BTAG_SIZE+`BTB_BTAG_SIZE:`BTB_ADDR_HI+1] pc,
                       output logic [`BTB_BTAG_SIZE-1:0] hash
                       );

    assign hash = {(pc[`BTB_ADDR_HI+`BTB_BTAG_SIZE+`BTB_BTAG_SIZE+`BTB_BTAG_SIZE:`BTB_ADDR_HI+`BTB_BTAG_SIZE+`BTB_BTAG_SIZE+1] ^
                   pc[`BTB_ADDR_HI+`BTB_BTAG_SIZE+`BTB_BTAG_SIZE:`BTB_ADDR_HI+`BTB_BTAG_SIZE+1] ^
                   pc[`BTB_ADDR_HI+`BTB_BTAG_SIZE:`BTB_ADDR_HI+1])};
endmodule

module eh2_btb_tag_hash_fold  #(
`include "eh2_param.vh"
 )(
                       input logic [`BTB_ADDR_HI+`BTB_BTAG_SIZE+`BTB_BTAG_SIZE:`BTB_ADDR_HI+1] pc,
                       output logic [`BTB_BTAG_SIZE-1:0] hash
                       );

    assign hash = {(
                   pc[`BTB_ADDR_HI+`BTB_BTAG_SIZE+`BTB_BTAG_SIZE:`BTB_ADDR_HI+`BTB_BTAG_SIZE+1] ^
                   pc[`BTB_ADDR_HI+`BTB_BTAG_SIZE:`BTB_ADDR_HI+1])};

endmodule

module eh2_btb_addr_hash  #(
`include "eh2_param.vh"
 )(
                        input logic [`BTB_INDEX3_HI:`BTB_INDEX1_LO] pc,
                        output logic [`BTB_ADDR_HI:`BTB_ADDR_LO] hash
                        );


if(`BTB_FOLD2_INDEX_HASH) begin : fold2
   assign hash[`BTB_ADDR_HI:`BTB_ADDR_LO] = pc[`BTB_INDEX1_HI:`BTB_INDEX1_LO] ^
                                                pc[`BTB_INDEX3_HI:`BTB_INDEX3_LO];
end
   else begin

      // overload bit pc[3] onto last bit of hash for sram case
      if(`BTB_USE_SRAM) begin
        assign hash[`BTB_ADDR_HI:`BTB_ADDR_LO+1] = pc[`BTB_INDEX1_HI:`BTB_INDEX1_LO+1] ^
                                                       pc[`BTB_INDEX2_HI:`BTB_INDEX2_LO] ^
                                                       pc[`BTB_INDEX3_HI:`BTB_INDEX3_LO];
         assign hash[3] = pc[3];
      end

      else

        assign hash[`BTB_ADDR_HI:`BTB_ADDR_LO] = pc[`BTB_INDEX1_HI:`BTB_INDEX1_LO] ^
                                                     pc[`BTB_INDEX2_HI:`BTB_INDEX2_LO] ^
                                                     pc[`BTB_INDEX3_HI:`BTB_INDEX3_LO];
end

endmodule


module eh2_btb_ghr_hash  #(
`include "eh2_param.vh"
 )(
                       input logic [`BTB_ADDR_HI:`BTB_ADDR_LO] hashin,
                       input logic [`BHT_GHR_SIZE-1:0] ghr,
                       output logic [`BHT_ADDR_HI:`BHT_ADDR_LO] hash
                       );

   if(`BHT_GHR_HASH_1) begin : ghrhash_cfg1
     assign hash[`BHT_ADDR_HI:`BHT_ADDR_LO] = { ghr[`BHT_GHR_SIZE-1:`BTB_INDEX1_HI-2], hashin[`BTB_INDEX1_HI:3]^ghr[`BTB_INDEX1_HI-3:0]};
//     assign hash[`BHT_ADDR_HI:`BHT_ADDR_LO] = {ghr[8:7], hashin[`BTB_INDEX1_HI:3]^ghr[6:0]};
   end
   else begin : ghrhash_cfg2
// this makes more sense but is lower perf on dhrystone
//     assign hash[`BHT_ADDR_HI:`BHT_ADDR_LO] = { hashin[`BHT_GHR_SIZE+2:3]^ghr[`BHT_GHR_SIZE-1:0]};
     assign hash[`BHT_ADDR_HI:`BHT_ADDR_LO] = { hashin[`BHT_GHR_SIZE+2:5]^ghr[`BHT_GHR_SIZE-1:2], ghr[1:0]};
   end


endmodule

