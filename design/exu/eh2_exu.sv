// SPDX-License-Identifier: Apache-2.0
// Copyright 2020 Western Digital Corporation or its affiliates.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIESOR OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module eh2_exu
import eh2_pkg::*;
#(
`include "eh2_param.vh",
parameter POSIT_LEN    = 16,
parameter ES           =  2,
parameter REGIME_BW    =  $clog2(POSIT_LEN)             ,
parameter POSIT        = 1                              , // Should the core have float or posit capabilities
parameter FRACTION_BW  = POSIT_LEN - ES - 1 - (2*POSIT) , // Number of fraction bits
parameter PRODUCT_FRA  = (FRACTION_BW)*2 + 1            , // Number of production fraction bits, except for MSB
parameter FRAC_W_GRS   = POSIT_LEN - ES                 , // Fraction bit width with GRS
parameter PIPED_BW     = 2 + ES +REGIME_BW + FRAC_W_GRS , // The amount of bits needed to be pipedlined
parameter DOUBLE_POSIT = 2*(1+ES+REGIME_BW+FRACTION_BW)   // The number of bits pipelined from Decode to EX1
)
  (

   input logic                                   clk,                          // Top level clock
   input logic [pt.NUM_THREADS-1:0]              active_thread_l2clk,
   input logic                                   clk_override,                 // Override multiply clock enables
   input logic                                   rst_l,                        // Reset
   input logic                                   scan_mode,                    // Scan control

   input logic                                   dec_i0_secondary_d,           // I0 Secondary ALU at  D-stage.  Used for clock gating
   input logic                                   dec_i0_secondary_e1,          // I0 Secondary ALU at E1-stage.  Used for clock gating
   input logic                                   dec_i0_secondary_e2,          // I0 Secondary ALU at E2-stage.  Used for clock gating

   input logic                                   dec_i1_secondary_d,           // I1 Secondary ALU at  D-stage.  Used for clock gating
   input logic                                   dec_i1_secondary_e1,          // I1 Secondary ALU at E1-stage.  Used for clock gating
   input logic                                   dec_i1_secondary_e2,          // I1 Secondary ALU at E2-stage.  Used for clock gating

   input logic                                   dec_i0_branch_d,              // I0 Branch at  D-stage.  Used for clock gating
   input logic                                   dec_i0_branch_e1,             // I0 Branch at E1-stage.  Used for clock gating
   input logic                                   dec_i0_branch_e2,             // I0 Branch at E2-stage.  Used for clock gating
   input logic                                   dec_i0_branch_e3,             // I0 Branch at E3-stage.  Used for clock gating

   input logic                                   dec_i1_branch_d,              // I0 Branch at  D-stage.  Used for clock gating
   input logic                                   dec_i1_branch_e1,             // I0 Branch at E1-stage.  Used for clock gating
   input logic                                   dec_i1_branch_e2,             // I0 Branch at E2-stage.  Used for clock gating
   input logic                                   dec_i1_branch_e3,             // I0 Branch at E3-stage.  Used for clock gating

   input logic                                   dec_i0_pc4_e4,                // I0 PC4 to PMU
   input logic                                   dec_i1_pc4_e4,                // I1 PC4 to PMU

   input logic                                   dec_extint_stall,             // External interrupt mux select
   input logic                      [31:2]       dec_tlu_meihap,               // External interrupt mux data

   input logic [4:1]                             dec_i0_data_en,               // Slot I0 clock enable {e1, e2, e3    }, one cycle pulse
   input logic [4:1]                             dec_i0_ctl_en,                // Slot I0 clock enable {e1, e2, e3, e4}, two cycle pulse
   input logic [4:1]                             dec_i1_data_en,               // Slot I1 clock enable {e1, e2, e3    }, one cycle pulse
   input logic [4:1]                             dec_i1_ctl_en,                // Slot I1 clock enable {e1, e2, e3, e4}, two cycle pulse

   input logic                                   dec_debug_wdata_rs1_d,        // Debug select to primary I0 RS1

   input logic [31:0]                            dbg_cmd_wrdata,               // Debug data   to primary I0 RS1

   input logic [31:0]                            lsu_result_dc3,               // Load result

   input eh2_predict_pkt_t                       i0_predict_p_d,               // DEC branch predict packet
   input eh2_predict_pkt_t                       i1_predict_p_d,               // DEC branch predict packet
   input logic [pt.BHT_GHR_SIZE-1:0]             i0_predict_fghr_d,            // DEC predict fghr
   input logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]   i0_predict_index_d,           // DEC predict index
   input logic [pt.BTB_BTAG_SIZE-1:0]            i0_predict_btag_d,            // DEC predict branch tag
   input logic [pt.BTB_TOFFSET_SIZE-1:0]         i0_predict_toffset_d,         // DEC predict branch toffset
   input logic [pt.BHT_GHR_SIZE-1:0]             i1_predict_fghr_d,            // DEC predict fghr
   input logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]   i1_predict_index_d,           // DEC predict index
   input logic [pt.BTB_BTAG_SIZE-1:0]            i1_predict_btag_d,            // DEC predict branch tag
   input logic [pt.BTB_TOFFSET_SIZE-1:0]         i1_predict_toffset_d,         // DEC predict branch toffset

   input logic                                   dec_i0_rs1_bypass_en_e2,      // DEC bypass bus select for E2 stage
   input logic                                   dec_i0_rs2_bypass_en_e2,      // DEC bypass bus select for E2 stage
   input logic                                   dec_i1_rs1_bypass_en_e2,      // DEC bypass bus select for E2 stage
   input logic                                   dec_i1_rs2_bypass_en_e2,      // DEC bypass bus select for E2 stage
   input logic [31:0]                            i0_rs1_bypass_data_e2,        // DEC bypass bus
   input logic [31:0]                            i0_rs2_bypass_data_e2,        // DEC bypass bus
   input logic [31:0]                            i1_rs1_bypass_data_e2,        // DEC bypass bus
   input logic [31:0]                            i1_rs2_bypass_data_e2,        // DEC bypass bus

   input logic                                   dec_i0_rs1_bypass_en_e3,      // DEC bypass bus select for E3 stage
   input logic                                   dec_i0_rs2_bypass_en_e3,      // DEC bypass bus select for E3 stage
   input logic                                   dec_i1_rs1_bypass_en_e3,      // DEC bypass bus select for E3 stage
   input logic                                   dec_i1_rs2_bypass_en_e3,      // DEC bypass bus select for E3 stage
   input logic [31:0]                            i0_rs1_bypass_data_e3,        // DEC bypass bus
   input logic [31:0]                            i0_rs2_bypass_data_e3,        // DEC bypass bus
   input logic [31:0]                            i1_rs1_bypass_data_e3,        // DEC bypass bus
   input logic [31:0]                            i1_rs2_bypass_data_e3,        // DEC bypass bus

   input logic                                   dec_i0_sec_decode_e3,         // Secondary ALU valid
   input logic                                   dec_i1_sec_decode_e3,         // Secondary ALU valid
   input logic [31:1]                            dec_i0_pc_e3,                 // Secondary ALU PC
   input logic [31:1]                            dec_i1_pc_e3,                 // Secondary ALU PC

   input logic [pt.NUM_THREADS-1:0][31:1]        pred_correct_npc_e2,          // npc e2 if the prediction is correct

   input logic                                   dec_i1_valid_e1,              // I1 valid E1

   input logic                                   dec_i0_mul_d,                 // Select for Multiply GPR value
   input logic                                   dec_i1_mul_d,                 // Select for Multiply GPR value

   input logic                                   dec_i0_div_d,                 // Select for Divide GPR value
   input logic                                   dec_div_cancel,               // Cancel divide operation due to write-after-write

   input logic [31:0]                            gpr_i0_rs1_d,                 // DEC data gpr
   input logic [31:0]                            gpr_i0_rs2_d,                 // DEC data gpr
   input logic [31:0]                            dec_i0_immed_d,               // DEC data immediate

   input logic [31:0]                            gpr_i1_rs1_d,                 // DEC data gpr
   input logic [31:0]                            gpr_i1_rs2_d,                 // DEC data gpr
   input logic [31:0]                            dec_i1_immed_d,               // DEC data immediate

   input logic [31:0]                            i0_rs1_bypass_data_d,         // DEC bypass data
   input logic [31:0]                            i0_rs2_bypass_data_d,         // DEC bypass data
   input logic [31:0]                            i1_rs1_bypass_data_d,         // DEC bypass data
   input logic [31:0]                            i1_rs2_bypass_data_d,         // DEC bypass data

   input logic [pt.BTB_TOFFSET_SIZE:1]           dec_i0_br_immed_d,            // Branch immediate
   input logic [pt.BTB_TOFFSET_SIZE:1]           dec_i1_br_immed_d,            // Branch immediate

   input logic                                   dec_i0_lsu_d,                 // Bypass control for LSU operand bus
   input logic                                   dec_i1_lsu_d,                 // Bypass control for LSU operand bus

   input logic                                   dec_i0_csr_ren_d,             // Clear I0 RS1 primary

   input eh2_alu_pkt_t                          i0_ap,                        // DEC alu {valid,predecodes}
   input eh2_alu_pkt_t                          i1_ap,                        // DEC alu {valid,predecodes}

   input eh2_mul_pkt_t                          mul_p,                        // DEC {valid, operand signs, low, operand bypass}
   input eh2_div_pkt_t                          div_p,                        // DEC {valid, unsigned, rem}

   input logic                                   dec_i0_alu_decode_d,          // Valid to Primary ALU
   input logic                                   dec_i1_alu_decode_d,          // Valid to Primary ALU

   input logic                                   dec_i0_select_pc_d,           // PC select to RS1
   input logic                                   dec_i1_select_pc_d,           // PC select to RS1

   input logic [31:1]                            dec_i0_pc_d,                  // I0 Instruction PC
   input logic [31:1]                            dec_i1_pc_d,                  // I1 Instruction PC

   input logic                                   dec_i0_rs1_bypass_en_d,       // DEC bypass select
   input logic                                   dec_i0_rs2_bypass_en_d,       // DEC bypass select
   input logic                                   dec_i1_rs1_bypass_en_d,       // DEC bypass select
   input logic                                   dec_i1_rs2_bypass_en_d,       // DEC bypass select

   input logic [pt.NUM_THREADS-1:0]              dec_tlu_flush_lower_wb,       // Flush divide and secondary ALUs
   input logic [pt.NUM_THREADS-1:0] [31:1]       dec_tlu_flush_path_wb,        // Redirect target

   input logic                                   dec_tlu_i0_valid_e4,          // Valid for GHR
   input logic                                   dec_tlu_i1_valid_e4,          // Valid for GHR

   input logic                                   posit_rs1_sgn,                // Register 1 Posit Sign     Bit
   input logic [REGIME_BW-1:0]                   posit_rs1_reg,                // Register 1 Posit Regime   Bit
   input logic [ES-1:0]                          posit_rs1_exp,                // Register 1 Posit Exponent Bit
   input logic [FRACTION_BW-1:0]                 posit_rs1_fra,                // Register 1 Posit Fraction Bit

   input logic                                   posit_rs2_sgn,                // Register 2 Posit Sign     Bit
   input logic [REGIME_BW-1:0]                   posit_rs2_reg,                // Register 2 Posit Regime   Bit
   input logic [ES-1:0]                          posit_rs2_exp,                // Register 2 Posit Exponent Bit
   input logic [FRACTION_BW-1:0]                 posit_rs2_fra,                // Register 2 Posit Fraction Bit

   input logic                                   is_special_rs1,               // If the decoded posit is either NaR or zero
   input logic                                   is_special_rs2,               // If the decoded posit is either NaR or zero



   output logic [31:0]                           exu_i0_result_e1,             // Primary ALU result to DEC
   output logic [31:0]                           exu_i1_result_e1,             // Primary ALU result to DEC
   output logic [31:1]                           exu_i0_pc_e1,                 // Primary PC  result to DEC
   output logic [31:1]                           exu_i1_pc_e1,                 // Primary PC  result to DEC

   output logic [31:0]                           exu_i0_result_e4,             // Secondary ALU result
   output logic [31:0]                           exu_i1_result_e4,             // Secondary ALU result

   output logic [31:0]                           exu_lsu_rs1_d,                // LSU operand
   output logic [31:0]                           exu_lsu_rs2_d,                // LSU operand

   output logic [31:0]                           exu_i0_csr_rs1_e1,            // RS1 source for a CSR instruction

   output logic [pt.NUM_THREADS-1:0]             exu_flush_final,              // Pipe is being flushed this cycle
   output logic [pt.NUM_THREADS-1:0]             exu_i0_flush_final,           // I0 flush to DEC
   output logic [pt.NUM_THREADS-1:0]             exu_i1_flush_final,           // I1 flush to DEC


   output logic [pt.NUM_THREADS-1:0][31:1]       exu_flush_path_final,         // Target for the oldest flush source

   output logic [pt.NUM_THREADS-1:0]             exu_flush_final_early,        // Pipe is being flushed this cycle
   output logic [pt.NUM_THREADS-1:0][31:1]       exu_flush_path_final_early,   // Target for the oldest flush source

   output logic [31:0]                           exu_mul_result_e3,            // Multiply result

   output logic [31:0]                           exu_div_result,               // Divide result
   output logic                                  exu_div_wren,                 // Divide write enable to GPR
   output logic [pt.NUM_THREADS-1:0] [31:1]      exu_npc_e4,                   // Divide NPC

   output logic [pt.NUM_THREADS-1:0]             exu_i0_flush_lower_e4,        // to TLU - lower branch flush
   output logic [pt.NUM_THREADS-1:0]             exu_i1_flush_lower_e4,        // to TLU - lower branch flush

   output logic [31:1]                           exu_i0_flush_path_e4,         // to TLU - lower branch flush path
   output logic [31:1]                           exu_i1_flush_path_e4,         // to TLU - lower branch flush path



   output eh2_predict_pkt_t [pt.NUM_THREADS-1:0]                    exu_mp_pkt,      // to IFU_DP - final mispredict
   output logic [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           exu_mp_eghr,     // to IFU_DP - for bht write
   output logic [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]           exu_mp_fghr,     // to IFU_DP - fghr repair value
   output logic [pt.NUM_THREADS-1:0] [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO] exu_mp_index,    // to IFU_DP - misprecict index
   output logic [pt.NUM_THREADS-1:0] [pt.BTB_BTAG_SIZE-1:0]          exu_mp_btag,     // to IFU_DP - mispredict tag
   output logic [pt.NUM_THREADS-1:0] [pt.BTB_TOFFSET_SIZE-1:0]       exu_mp_toffset,  // to IFU_DP - mispredict toffset


   output logic [1:0]                            exu_i0_br_hist_e4,            // to DEC  I0 branch history
   output logic                                  exu_i0_br_bank_e4,            // to DEC  I0 branch bank
   output logic                                  exu_i0_br_error_e4,           // to DEC  I0 branch error
   output logic                                  exu_i0_br_start_error_e4,     // to DEC  I0 branch start error
   output logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]  exu_i0_br_index_e4,           // to DEC  I0 branch index
   output logic                                  exu_i0_br_valid_e4,           // to DEC  I0 branch valid
   output logic                                  exu_i0_br_mp_e4,              // to DEC  I0 branch mispredict
   output logic                                  exu_i0_br_way_e4,             // to DEC  I0 branch way
   output logic                                  exu_i0_br_middle_e4,          // to DEC  I0 branch middle
   output logic [pt.BHT_GHR_SIZE-1:0]            exu_i0_br_fghr_e4,            // to DEC  I0 branch fghr
   output logic                                  exu_i0_br_ret_e4,             // to DEC  I0 branch return
   output logic                                  exu_i0_br_call_e4,            // to DEC  I0 branch call

   output logic [1:0]                            exu_i1_br_hist_e4,            // to DEC  I1 branch history
   output logic                                  exu_i1_br_bank_e4,            // to DEC  I1 branch bank
   output logic                                  exu_i1_br_error_e4,           // to DEC  I1 branch error
   output logic                                  exu_i1_br_start_error_e4,     // to DEC  I1 branch start error
   output logic [pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]  exu_i1_br_index_e4,           // to DEC  I1 branch index
   output logic                                  exu_i1_br_valid_e4,           // to DEC  I1 branch valid
   output logic                                  exu_i1_br_mp_e4,              // to DEC  I1 branch mispredict
   output logic                                  exu_i1_br_way_e4,             // to DEC  I1 branch way
   output logic                                  exu_i1_br_middle_e4,          // to DEC  I1 branch middle
   output logic [pt.BHT_GHR_SIZE-1:0]            exu_i1_br_fghr_e4,            // to DEC  I1 branch fghr
   output logic                                  exu_i1_br_ret_e4,             // to DEC  I1 branch return
   output logic                                  exu_i1_br_call_e4,            // to DEC  I1 branch call

   output logic                                  exu_pmu_i0_br_misp,           // to PMU - I0 E4 branch mispredict
   output logic                                  exu_pmu_i0_br_ataken,         // to PMU - I0 E4 taken
   output logic                                  exu_pmu_i0_pc4,               // to PMU - I0 E4 PC
   output logic                                  exu_pmu_i1_br_misp,           // to PMU - I1 E4 branch mispredict
   output logic                                  exu_pmu_i1_br_ataken,         // to PMU - I1 E4 taken
   output logic                                  exu_pmu_i1_pc4                // to PMU - I1 E4 PC
   );


   logic [31:0]                      i0_rs1_d,i0_rs2_d,i1_rs1_d,i1_rs2_d;

   logic [pt.NUM_THREADS-1:0]        i0_flush_upper_e1, i1_flush_upper_e1;

   logic [31:1]                      i0_flush_path_e1;
   logic [31:1]                      i1_flush_path_e1;

   logic [31:0]                      i0_rs1_final_d;

   logic [31:0]                      mul_rs1_d, mul_rs2_d;

   logic [31:0]                      div_rs1_d, div_rs2_d;

   logic                             i1_valid_e2;

   logic [31:0]                      i0_rs1_e1, i0_rs2_e1;
   logic [31:0]                      i0_rs1_e2, i0_rs2_e2;
   logic [31:0]                      i0_rs1_e3, i0_rs2_e3;
   logic [pt.BTB_TOFFSET_SIZE:1]     i0_br_immed_e1, i0_br_immed_e2, i0_br_immed_e3;

   logic [31:0]                      i1_rs1_e1, i1_rs2_e1;
   logic [31:0]                      i1_rs1_e2, i1_rs2_e2;
   logic [31:0]                      i1_rs1_e3, i1_rs2_e3;

   logic [pt.BTB_TOFFSET_SIZE:1]     i1_br_immed_e1, i1_br_immed_e2, i1_br_immed_e3;

   logic [31:0]                      i0_rs1_e2_final, i0_rs2_e2_final;
   logic [31:0]                      i1_rs1_e2_final, i1_rs2_e2_final;
   logic [31:0]                      i0_rs1_e3_final, i0_rs2_e3_final;
   logic [31:0]                      i1_rs1_e3_final, i1_rs2_e3_final;
   logic [31:1]                      i0_alu_pc_unused, i1_alu_pc_unused;
   logic [pt.NUM_THREADS-1:0]        i0_flush_upper_e2, i1_flush_upper_e2;
   logic                             i1_valid_e3, i1_valid_e4;
   logic [pt.NUM_THREADS-1:0] [31:1] pred_correct_npc_e3, pred_correct_npc_e4;
   logic [pt.NUM_THREADS-1:0]        i0_flush_upper_e3;
   logic [pt.NUM_THREADS-1:0]        i0_flush_upper_e4;
   logic                             i1_pred_correct_upper_e1, i0_pred_correct_upper_e1;
   logic                             i1_pred_correct_upper_e2, i0_pred_correct_upper_e2;
   logic                             i1_pred_correct_upper_e3, i0_pred_correct_upper_e3;
   logic                             i1_pred_correct_upper_e4, i0_pred_correct_upper_e4;
   logic                             i1_pred_correct_lower_e4, i0_pred_correct_lower_e4;

   logic [pt.NUM_THREADS-1:0]        i1_valid_e4_eff;
   logic                             i1_sec_decode_e4, i0_sec_decode_e4;
   logic                             i1_pred_correct_e4_eff, i0_pred_correct_e4_eff;
   logic [31:1]                      i1_flush_path_e4_eff, i0_flush_path_e4_eff;
   logic [31:1]                      i1_flush_path_upper_e2, i0_flush_path_upper_e2;
   logic [31:1]                      i1_flush_path_upper_e3, i0_flush_path_upper_e3;
   logic [31:1]                      i1_flush_path_upper_e4, i0_flush_path_upper_e4;

   eh2_alu_pkt_t                    i0_ap_e1, i0_ap_e2, i0_ap_e3, i0_ap_e4, i0_ap_e5;
   eh2_alu_pkt_t                    i1_ap_e1, i1_ap_e2, i1_ap_e3, i1_ap_e4;

   logic                             i0_e1_data_en, i0_e2_data_en, i0_e3_data_en, i0_e4_data_en;
   logic                             i0_e1_ctl_en,  i0_e2_ctl_en,  i0_e3_ctl_en,  i0_e4_ctl_en;

   logic                             i1_e1_data_en, i1_e2_data_en, i1_e3_data_en, i1_e4_data_en;
   logic                             i1_e1_ctl_en,  i1_e2_ctl_en,  i1_e3_ctl_en,  i1_e4_ctl_en;

   localparam PREDPIPESIZE = pt.BTB_ADDR_HI-pt.BTB_ADDR_LO+1+pt.BHT_GHR_SIZE+pt.BTB_BTAG_SIZE+pt.BTB_TOFFSET_SIZE;
   logic [PREDPIPESIZE-1:0]          i0_predpipe_d, i0_predpipe_e1, i0_predpipe_e2, i0_predpipe_e3, i0_predpipe_e4;
   logic [PREDPIPESIZE-1:0]          i1_predpipe_d, i1_predpipe_e1, i1_predpipe_e2, i1_predpipe_e3, i1_predpipe_e4;

   logic                             i0_taken_e1, i1_taken_e1, dec_i0_alu_decode_e1, dec_i1_alu_decode_e1;
   logic [pt.NUM_THREADS-1:0]        flush_final_f;

   eh2_predict_pkt_t                i0_predict_p_e1, i0_predict_p_e4;
   eh2_predict_pkt_t                i1_predict_p_e1, i1_predict_p_e4;

   eh2_predict_pkt_t                i0_pp_e2, i0_pp_e3, i0_pp_e4_in;
   eh2_predict_pkt_t                i1_pp_e2, i1_pp_e3, i1_pp_e4_in;
   eh2_predict_pkt_t                i0_predict_newp_d, i1_predict_newp_d;


   logic [pt.NUM_THREADS-1:0]                        i0_valid_e1, i1_valid_e1;
   logic [pt.NUM_THREADS-1:0]                        i0_valid_e4, i1_pred_valid_e4;
   logic [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]  ghr_e1_ns, ghr_e1;
   logic [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]  ghr_e4_ns, ghr_e4;
   logic [pt.NUM_THREADS-1:0]                        fp_enable, fp_enable_ff;
   logic [pt.NUM_THREADS-1:0] [pt.BHT_GHR_SIZE-1:0]  after_flush_eghr;
   logic [pt.NUM_THREADS-1:0] [PREDPIPESIZE-1:0]     final_predpipe_mp, final_predpipe_mp_ff;
   eh2_predict_pkt_t [pt.NUM_THREADS-1:0]            final_predict_mp;
   logic [pt.NUM_THREADS-1:0] [31:1]                 flush_path_e2;

   eh2_mul_pkt_t                                     mp;

   /////////////////
   ///Posit Wires///
   /////////////////

  logic                   posit_e1;
  logic                   posit_e2;
  logic                   posit_e3;
  logic                   is_oflw_or_uflw_e1;
  logic                   is_oflw_or_uflw_e2;
  logic                   is_zero_alu_e1;
  logic                   is_zero_alu_e4;
  logic                   is_special_rs1_e1;
  logic                   is_special_rs2_e1;
  logic                   is_special_rs1_e2;
  logic                   is_special_rs2_e2;
  logic                   is_special_rs1_e3;
  logic                   is_special_rs2_e3;
  logic                   is_special_rs1_e4;
  logic                   is_special_rs2_e4;
  logic                   posit_rs1_sgn_e2;
  logic                   posit_rs2_sgn_e2;

  logic                   posit_rs1_sgn_e1;
  logic [  REGIME_BW-1:0] posit_rs1_reg_e1;
  logic [         ES-1:0] posit_rs1_exp_e1;
  logic [FRACTION_BW-1:0] posit_rs1_fra_e1;

  logic                   posit_rs2_sgn_e1;
  logic [  REGIME_BW-1:0] posit_rs2_reg_e1;
  logic [         ES-1:0] posit_rs2_exp_e1;
  logic [FRACTION_BW-1:0] posit_rs2_fra_e1;

  logic                   posit_mul_sgn_e1;
  logic [  REGIME_BW-1:0] posit_mul_reg_e1;
  logic [         ES-1:0] posit_mul_exp_e1;
  logic [ FRAC_W_GRS-1:0] posit_mul_fra_e1;

  logic                   posit_mul_sgn_e2;
  logic [  REGIME_BW-1:0] posit_mul_reg_e2;
  logic [         ES-1:0] posit_mul_exp_e2;
  logic [ FRAC_W_GRS-1:0] posit_mul_fra_e2;

  logic [  POSIT_LEN-1:0] posit_mul_sgn_e3;

  logic                   posit_alu_sgn_e1;
  logic [  REGIME_BW-1:0] posit_alu_reg_e1;
  logic [         ES-1:0] posit_alu_exp_e1;
  logic [ FRAC_W_GRS-1:0] posit_alu_fra_e1;

  logic                   posit_rs1_sgn_e3;
  logic [  REGIME_BW-1:0] posit_rs1_reg_e3;
  logic [         ES-1:0] posit_rs1_exp_e3;
  logic [ FRAC_W_GRS-1:0] posit_rs1_fra_e3;

  logic                   posit_rs2_sgn_e3;
  logic [  REGIME_BW-1:0] posit_rs2_reg_e3;
  logic [         ES-1:0] posit_rs2_exp_e3;
  logic [ FRAC_W_GRS-1:0] posit_rs2_fra_e3;

  logic                   posit_rs1_sgn_e4;
  logic [  REGIME_BW-1:0] posit_rs1_reg_e4;
  logic [         ES-1:0] posit_rs1_exp_e4;
  logic [ FRAC_W_GRS-1:0] posit_rs1_fra_e4;

  logic                   posit_rs2_sgn_e4;
  logic [  REGIME_BW-1:0] posit_rs2_reg_e4;
  logic [         ES-1:0] posit_rs2_exp_e4;
  logic [ FRAC_W_GRS-1:0] posit_rs2_fra_e4;

  logic                   posit_alu_sgn_e4;
  logic [  REGIME_BW-1:0] posit_alu_reg_e4;
  logic [         ES-1:0] posit_alu_exp_e4;
  logic [ FRAC_W_GRS-1:0] posit_alu_fra_e4;

  logic                   is_oflw_or_uflw_alu_e1;
  logic                   is_oflw_or_uflw_alu_e4;

  logic [31:0]            exu_i0_result_alu_e1;
  logic [31:0]            exu_i0_result_posit_e1;

  logic [31:0]            exu_i0_result_mul_e3;
  logic [31:0]            exu_i0_result_posit_e3;

  logic [31:0]            exu_i0_result_alu_e4;
  logic [31:0]            exu_i0_result_posit_e4;

  logic [POSIT_LEN-1:0]  posit_mul_e3;

  /////////////////////
  ///Posit Buffering///
  /////////////////////

   rvdff  #(3)                    posit_flag_ff (.*,
                                           .din ({(mul_p.posit | i0_ap.posit),posit_e1,posit_e2}),
                                           .dout({posit_e1                   ,posit_e2,posit_e3}));

   rvdffs #(DOUBLE_POSIT)          e1_ff (.*,
                                    .din ({posit_rs1_sgn   ,posit_rs1_reg   ,posit_rs1_exp   ,posit_rs1_fra   ,
                                           posit_rs2_sgn   ,posit_rs2_reg   ,posit_rs2_exp   ,posit_rs2_fra   }),
                                    .en  ((mul_p.posit | i0_ap.posit)                                          ),
                                    .dout({posit_rs1_sgn_e1,posit_rs1_reg_e1,posit_rs1_exp_e1,posit_rs1_fra_e1,
                                           posit_rs2_sgn_e1,posit_rs2_reg_e1,posit_rs2_exp_e1,posit_rs2_fra_e1}));

   rvdffs #(PIPED_BW)              e2_ff (.*,
                                    .din ({is_oflw_or_uflw_e1,posit_mul_sgn_e1,posit_mul_reg_e1,posit_mul_exp_e1,posit_mul_fra_e1}),
                                    .en  (posit_e1                                                                                           ),
                                    .dout({is_oflw_or_uflw_e2,posit_mul_sgn_e2,posit_mul_reg_e2,posit_mul_exp_e2,posit_mul_fra_e2}));

   rvdffs #(POSIT_LEN)             e3_ff (.*,
                                    .din (posit_mul_e3          ),
                                    .en  (posit_e2              ),
                                    .dout(exu_i0_result_posit_e3));

   rvdffs #(DOUBLE_POSIT)          e4_ff (.*,
                                    .din ({posit_rs1_sgn_e3,posit_rs1_reg_e3,posit_rs1_exp_e3,posit_rs1_fra_e3,
                                           posit_rs2_sgn_e3,posit_rs2_reg_e3,posit_rs2_exp_e3,posit_rs2_fra_e3}),
                                    .en  (posit_e3                                                             ),
                                    .dout({posit_rs1_sgn_e4,posit_rs1_reg_e4,posit_rs1_exp_e4,posit_rs1_fra_e4,
                                           posit_rs2_sgn_e4,posit_rs2_reg_e4,posit_rs2_exp_e4,posit_rs2_fra_e4}));

   rvdff  #(6)                    special_ff (.*,
                                        .din ({is_special_rs1   ,is_special_rs2   ,
                                               is_special_rs1_e1,is_special_rs2_e1,
                                               is_special_rs1_e3,is_special_rs2_e3}),
                                        .dout({is_special_rs1_e1,is_special_rs2_e1,
                                               is_special_rs1_e2,is_special_rs2_e2,
                                               is_special_rs1_e4,is_special_rs2_e4}));

   rvdff  #(2)                       sign_ff (.*,
                                        .din ({posit_rs1_sgn_e1,posit_rs2_sgn_e1}),
                                        .dout({posit_rs1_sgn_e2,posit_rs2_sgn_e2}));


   assign i0_rs1_d[31:0]       = ({32{~dec_i0_rs1_bypass_en_d}} & ((dec_debug_wdata_rs1_d) ? dbg_cmd_wrdata[31:0] : gpr_i0_rs1_d[31:0])) |
                                 ({32{~dec_i0_rs1_bypass_en_d   & dec_i0_select_pc_d}} & { dec_i0_pc_d[31:1], 1'b0}) |    // for jal's
                                 ({32{ dec_i0_rs1_bypass_en_d}} & i0_rs1_bypass_data_d[31:0]);


   assign i0_rs1_final_d[31:0] =  {32{~dec_i0_csr_ren_d}}       & i0_rs1_d[31:0];

   assign i0_rs2_d[31:0]       = ({32{~dec_i0_rs2_bypass_en_d}} & gpr_i0_rs2_d[31:0]        ) |
                                 ({32{~dec_i0_rs2_bypass_en_d}} & dec_i0_immed_d[31:0]      ) |
                                 ({32{ dec_i0_rs2_bypass_en_d}} & i0_rs2_bypass_data_d[31:0]);

   assign i1_rs1_d[31:0]       = ({32{~dec_i1_rs1_bypass_en_d}} & gpr_i1_rs1_d[31:0]) |
                                 ({32{~dec_i1_rs1_bypass_en_d   & dec_i1_select_pc_d}} & { dec_i1_pc_d[31:1], 1'b0}) |  // pc orthogonal with rs1
                                 ({32{ dec_i1_rs1_bypass_en_d}} & i1_rs1_bypass_data_d[31:0]);


   assign i1_rs2_d[31:0]       = ({32{~dec_i1_rs2_bypass_en_d}} & gpr_i1_rs2_d[31:0]        ) |
                                 ({32{~dec_i1_rs2_bypass_en_d}} & dec_i1_immed_d[31:0]      ) |
                                 ({32{ dec_i1_rs2_bypass_en_d}} & i1_rs2_bypass_data_d[31:0]);


   assign exu_lsu_rs1_d[31:0]  = ({32{ ~dec_i0_rs1_bypass_en_d &  dec_i0_lsu_d & ~dec_extint_stall               }} & gpr_i0_rs1_d[31:0]        ) |
                                 ({32{ ~dec_i1_rs1_bypass_en_d & ~dec_i0_lsu_d & ~dec_extint_stall & dec_i1_lsu_d}} & gpr_i1_rs1_d[31:0]        ) |
                                 ({32{  dec_i0_rs1_bypass_en_d &  dec_i0_lsu_d & ~dec_extint_stall               }} & i0_rs1_bypass_data_d[31:0]) |
                                 ({32{  dec_i1_rs1_bypass_en_d & ~dec_i0_lsu_d & ~dec_extint_stall & dec_i1_lsu_d}} & i1_rs1_bypass_data_d[31:0]) |
                                 ({32{                                            dec_extint_stall               }} & {dec_tlu_meihap[31:2],2'b0});

   assign exu_lsu_rs2_d[31:0]  = ({32{ ~dec_i0_rs2_bypass_en_d &  dec_i0_lsu_d & ~dec_extint_stall               }} & gpr_i0_rs2_d[31:0]        ) |
                                 ({32{ ~dec_i1_rs2_bypass_en_d & ~dec_i0_lsu_d & ~dec_extint_stall & dec_i1_lsu_d}} & gpr_i1_rs2_d[31:0]        ) |
                                 ({32{  dec_i0_rs2_bypass_en_d &  dec_i0_lsu_d & ~dec_extint_stall               }} & i0_rs2_bypass_data_d[31:0]) |
                                 ({32{  dec_i1_rs2_bypass_en_d & ~dec_i0_lsu_d & ~dec_extint_stall & dec_i1_lsu_d}} & i1_rs2_bypass_data_d[31:0]);


   assign mul_rs1_d[31:0]      = ({32{ ~dec_i0_rs1_bypass_en_d &  dec_i0_mul_d               }} & gpr_i0_rs1_d[31:0]        ) |
                                 ({32{ ~dec_i1_rs1_bypass_en_d & ~dec_i0_mul_d & dec_i1_mul_d}} & gpr_i1_rs1_d[31:0]        ) |
                                 ({32{  dec_i0_rs1_bypass_en_d &  dec_i0_mul_d               }} & i0_rs1_bypass_data_d[31:0]) |
                                 ({32{  dec_i1_rs1_bypass_en_d & ~dec_i0_mul_d & dec_i1_mul_d}} & i1_rs1_bypass_data_d[31:0]);

   assign mul_rs2_d[31:0]      = ({32{ ~dec_i0_rs2_bypass_en_d &  dec_i0_mul_d               }} & {27'b0,dec_i0_immed_d[4:0]}) |
                                 ({32{ ~dec_i1_rs2_bypass_en_d & ~dec_i0_mul_d & dec_i1_mul_d}} & {27'b0,dec_i1_immed_d[4:0]}) |
                                 ({32{ ~dec_i0_rs2_bypass_en_d &  dec_i0_mul_d               }} & gpr_i0_rs2_d[31:0]         ) |
                                 ({32{ ~dec_i1_rs2_bypass_en_d & ~dec_i0_mul_d & dec_i1_mul_d}} & gpr_i1_rs2_d[31:0]         ) |
                                 ({32{  dec_i0_rs2_bypass_en_d &  dec_i0_mul_d               }} & i0_rs2_bypass_data_d[31:0] ) |
                                 ({32{  dec_i1_rs2_bypass_en_d & ~dec_i0_mul_d & dec_i1_mul_d}} & i1_rs2_bypass_data_d[31:0] );



   assign div_rs1_d[31:0]      = ({32{ ~dec_i0_rs1_bypass_en_d &  dec_i0_div_d               }} & gpr_i0_rs1_d[31:0]) |
                                 ({32{  dec_i0_rs1_bypass_en_d &  dec_i0_div_d               }} & i0_rs1_bypass_data_d[31:0]);

   assign div_rs2_d[31:0]      = ({32{ ~dec_i0_rs2_bypass_en_d &  dec_i0_div_d               }} & gpr_i0_rs2_d[31:0]) |
                                 ({32{  dec_i0_rs2_bypass_en_d &  dec_i0_div_d               }} & i0_rs2_bypass_data_d[31:0]);



   assign {i0_e1_data_en, i0_e2_data_en, i0_e3_data_en, i0_e4_data_en}  = dec_i0_data_en[4:1];
   assign {i0_e1_ctl_en,  i0_e2_ctl_en,  i0_e3_ctl_en,  i0_e4_ctl_en }  = dec_i0_ctl_en[4:1];

   assign {i1_e1_data_en, i1_e2_data_en, i1_e3_data_en, i1_e4_data_en}  = dec_i1_data_en[4:1];
   assign {i1_e1_ctl_en,  i1_e2_ctl_en,  i1_e3_ctl_en,  i1_e4_ctl_en }  = dec_i1_ctl_en[4:1];




   rvdffe #(32) i0_csr_rs1_ff (.*, .clk(clk), .en(i0_e1_data_en & dec_i0_csr_ren_d), .din(i0_rs1_d[31:0]), .dout(exu_i0_csr_rs1_e1[31:0]));

   generate
      if (POSIT == 1) begin
       eh2_posit_mul  #(.POSIT_LEN(POSIT_LEN), .ES(ES), .REGIME_BW(REGIME_BW))
                            posit_mul           (
                              .multiplier_sgn   ( posit_rs1_sgn_e1                      ),  //I
                              .multiplier_reg   ( posit_rs1_reg_e1                      ),  //I
                              .multiplier_exp   ( posit_rs1_exp_e1                      ),  //I
                              .multiplier_fra   ( posit_rs1_fra_e1                      ),  //I
                              .multiplicand_sgn ( posit_rs2_sgn_e1                      ),  //I
                              .multiplicand_reg ( posit_rs2_reg_e1                      ),  //I
                              .multiplicand_exp ( posit_rs2_exp_e1                      ),  //I
                              .multiplicand_fra ( posit_rs2_fra_e1                      ),  //I
                              .product_sgn      ( posit_mul_sgn_e1                      ),  //O
                              .product_reg      ( posit_mul_reg_e1                      ),  //O
                              .product_exp      ( posit_mul_exp_e1                      ),  //O
                              .product_fra      ( posit_mul_fra_e1                      ),  //O
                              .is_oflw_or_uflw  (is_oflw_or_uflw_e1                     )); //O

      //----------------------
      // Posit Encoder
      //----------------------
       eh2_posit_encode #(.POSIT_LEN(POSIT_LEN), .ES(ES), .REGIME_BW(REGIME_BW))
                   posit_mul_encode  (
                    .posit_data_out  (posit_mul_e3         ), //O
                    .sign            (posit_mul_sgn_e2     ), //I
                    .regime          (posit_mul_reg_e2     ), //I
                    .exponent        (posit_mul_exp_e2     ), //I
                    .fraction        (posit_mul_fra_e2     ), //I
                    .rs1_sign        (posit_rs1_sgn_e2     ), //I
                    .rs2_sign        (posit_rs2_sgn_e2     ), //I
                    .is_special_rs1  (is_special_rs1_e2    ), //I
                    .is_special_rs2  (is_special_rs2_e2    ), //I
                    .mul             (posit_e2             ), //I
                    .is_zero         (1'b0                 ), //I
                    .is_oflw_or_uflw (is_oflw_or_uflw_e2  )); //I

         assign exu_mul_result_e3 = posit_e3 ? exu_i0_result_posit_e3 : exu_i0_result_mul_e3; // Sees if the output result needs to be posit or not
       end else begin
        logic                 stickyBit_mul     ;
        logic [          1:0] trailingBits_mul  ;
        logic [FRACTION_BW:0] mantissa_mul      ;
        Float #(.EXP(ES), .FRAC(FRACTION_BW)) inA_e3();
        Float #(.EXP(ES), .FRAC(FRACTION_BW)) inB_e3();
        Float #(.EXP(ES), .FRAC(FRACTION_BW)) out_e3();
        Float #(.EXP(ES), .FRAC(FRACTION_BW)) last_e3();

        ///////////////
        ///Operation///
        ///////////////
        assign inA_e3.data = {posit_rs1_sgn,posit_rs1_exp,posit_rs1_fra};

        assign inB_e3.data = {posit_rs1_sgn,posit_rs1_exp,posit_rs1_fra};

         FloatMultiply #(.EXP_IN_A(ES), .FRAC_IN_A(FRACTION_BW),
                         .EXP_IN_B(ES), .FRAC_IN_B(FRACTION_BW),
                         .EXP_OUT (ES), .FRAC_OUT (FRACTION_BW))
                  float_mul      (
                    .clock       ( clk                ),
                    .reset       (~rst_l              ),
                    .inA         ( inA_e3             ),
                    .inB         ( inB_e3             ),
                    .out         ( out_e3             ),
                    .trailingBits( trailingBits_mul   ),
                    .stickyBit   ( stickyBit_mul      ),
                    .isNan       ( is_oflw_or_uflw_e1 ));

        //////////////
        ///Encoding///
        //////////////
        FloatRoundToNearestEven #(.EXP(ES), .FRAC(FRACTION_BW))
                Float_encode_e3 ( .in            ( out_e3             ),
                                  .trailingBitsIn( trailingBits_mul   ),
                                  .stickyBitIn   ( stickyBit_mul      ),
                                  .isNanIn       ( is_oflw_or_uflw_e1 ),
                                  .out           ( last_e3            ));

        assign exu_mul_result_e3 = posit_e3 ? {{(32){1'b0}},last_e3.data.sign,last_e3.data.exponent,last_e3.data.fraction}
                                            :               exu_i0_result_mul_e3; // Sees if the output result needs to be float or not
    end
  endgenerate
   assign mp = mul_p & ~mul_p.posit;

   eh2_exu_mul_ctl #(.pt(pt)) mul_e1    (.*,
                          .clk_override  ( clk_override                             ),   // I
                          .mp            ( mp                                       ),   // I
                          .a             ( mul_rs1_d[31:0]                          ),   // I
                          .b             ( mul_rs2_d[31:0]                          ),   // I
                          .out           ( exu_i0_result_mul_e3[31:0]               ));  // O

   eh2_exu_div_ctl #(.pt(pt)) div_e1    (.*,
                          .cancel        ( dec_div_cancel                           ),   // I
                          .dp            ( div_p                                    ),   // I
                          .dividend      ( div_rs1_d[31:0]                          ),   // I
                          .divisor       ( div_rs2_d[31:0]                          ),   // I
                          .finish_dly    ( exu_div_wren                             ),   // O
                          .out           ( exu_div_result[31:0]                     ));  // O


   always_comb begin
      i0_predict_newp_d         = i0_predict_p_d;
      i0_predict_newp_d.boffset = dec_i0_pc_d[1];  // from the start of inst
      i0_predict_newp_d.bank    = i0_predict_p_d.bank;

      i1_predict_newp_d         = i1_predict_p_d;
      i1_predict_newp_d.boffset = dec_i1_pc_d[1];
      i1_predict_newp_d.bank    = i1_predict_p_d.bank;

   end




   eh2_exu_alu_ctl #(.pt(pt)) i0_alu_e1 (.*,
                          .b_enable      ( dec_i0_branch_d                          ),   // I
                          .c_enable      ( i0_e1_ctl_en                             ),   // I
                          .d_enable      ( i0_e1_data_en                            ),   // I
                          .predict_p     ( i0_predict_newp_d                        ),   // I
                          .valid         ( dec_i0_alu_decode_d & ~i0_ap_e1.posit    ),   // I
                          .flush         ( exu_flush_final                          ),   // I
                          .a             ( i0_rs1_final_d[31:0]                     ),   // I
                          .b             ( i0_rs2_d[31:0]                           ),   // I
                          .pc            ( dec_i0_pc_d[31:1]                        ),   // I
                          .brimm         ( dec_i0_br_immed_d[pt.BTB_TOFFSET_SIZE:1] ),   // I
                          .ap_in_tid     ( i0_ap.tid                                ),   // I
                          .ap            ( i0_ap_e1                                 ),   // I
                          .out           ( exu_i0_result_alu_e1[31:0]               ),   // O
                          .flush_upper   ( i0_flush_upper_e1                        ),   // O
                          .flush_path    ( i0_flush_path_e1[31:1]                   ),   // O
                          .predict_p_ff  ( i0_predict_p_e1                          ),   // O
                          .pc_ff         ( exu_i0_pc_e1[31:1]                       ),   // O
                          .pred_correct  ( i0_pred_correct_upper_e1                 ));  // O


   eh2_exu_alu_ctl #(.pt(pt)) i1_alu_e1 (.*,
                          .b_enable      ( dec_i1_branch_d                          ),   // I
                          .c_enable      ( i1_e1_ctl_en                             ),   // I
                          .d_enable      ( i1_e1_data_en                            ),   // I
                          .predict_p     ( i1_predict_newp_d                        ),   // I
                          .valid         ( dec_i1_alu_decode_d                      ),   // I
                          .flush         ( exu_flush_final                          ),   // I
                          .a             ( i1_rs1_d[31:0]                           ),   // I
                          .b             ( i1_rs2_d[31:0]                           ),   // I
                          .pc            ( dec_i1_pc_d[31:1]                        ),   // I
                          .brimm         ( dec_i1_br_immed_d[pt.BTB_TOFFSET_SIZE:1] ),   // I
                          .ap_in_tid     ( i1_ap.tid                                ),   // I
                          .ap            ( i1_ap_e1                                 ),   // I
                          .out           ( exu_i1_result_e1[31:0]                   ),   // O
                          .flush_upper   ( i1_flush_upper_e1                        ),   // O
                          .flush_path    ( i1_flush_path_e1[31:1]                   ),   // O
                          .predict_p_ff  ( i1_predict_p_e1                          ),   // O
                          .pc_ff         ( exu_i1_pc_e1[31:1]                       ),   // O
                          .pred_correct  ( i1_pred_correct_upper_e1                 ));  // O

   generate
      if (POSIT == 1) begin
       eh2_posit_alu #(.POSIT_LEN(POSIT_LEN), .ES(ES), .REGIME_BW(REGIME_BW))
                            i0_posit_alu_e1   (
                              .first_sgn       ( posit_rs1_sgn_e1                      ),  //I
                              .first_reg       ( posit_rs1_reg_e1                      ),  //I
                              .first_exp       ( posit_rs1_exp_e1                      ),  //I
                              .first_fra       ( posit_rs1_fra_e1                      ),  //I
                              .second_sgn      ( posit_rs2_sgn_e1                      ),  //I
                              .second_reg      ( posit_rs2_reg_e1                      ),  //I
                              .second_exp      ( posit_rs2_exp_e1                      ),  //I
                              .second_fra      ( posit_rs2_fra_e1                      ),  //I
                              .product_sgn     ( posit_alu_sgn_e1                      ),  //O
                              .product_reg     ( posit_alu_reg_e1                      ),  //O
                              .product_exp     ( posit_alu_exp_e1                      ),  //O
                              .product_fra     ( posit_alu_fra_e1                      ),  //O
                              .add_or_sub      ( i0_ap_e1.sub                          ),  //I
                              .is_zero         ( is_zero_alu_e1                        ),  //O
                              .is_oflw_or_uflw ( is_oflw_or_uflw_alu_e1               ));  //O
       //----------------------
       // Posit Encoder
       //----------------------
       eh2_posit_encode #(.POSIT_LEN(POSIT_LEN), .ES(ES), .REGIME_BW(REGIME_BW))
                posit_alu_encode_e1  (
                    .posit_data_out  (exu_i0_result_posit_e1 ), //O
                    .sign            (posit_alu_sgn_e1       ), //I
                    .regime          (posit_alu_reg_e1       ), //I
                    .exponent        (posit_alu_exp_e1       ), //I
                    .fraction        (posit_alu_fra_e1       ), //I
                    .rs1_sign        (posit_rs1_sgn_e1       ), //I
                    .rs2_sign        (posit_rs2_sgn_e1       ), //I
                    .is_special_rs1  (is_special_rs1_e1      ), //I
                    .is_special_rs2  (is_special_rs2_e1      ), //I
                    .mul             (1'b0                   ), //I
                    .is_zero         (is_zero_alu_e1         ), //I
                    .is_oflw_or_uflw (is_oflw_or_uflw_alu_e1)); //I
   assign exu_i0_result_e1 =  i0_ap_e1.posit ? exu_i0_result_posit_e1 : exu_i0_result_alu_e1; // Sees if the output result needs to be posit or not
       end else begin
        logic                 stickyBit_e1   ;
        logic [          1:0] trailingBits_e1;
        logic [FRACTION_BW:0] mantissa_e1    ;
        Float #(.EXP(ES), .FRAC(FRACTION_BW)) inA_e1();
        Float #(.EXP(ES), .FRAC(FRACTION_BW)) inB_e1();
        Float #(.EXP(ES), .FRAC(FRACTION_BW)) out_e1();
        Float #(.EXP(ES), .FRAC(FRACTION_BW)) last_e1();

        ///////////////
        ///Operation///
        ///////////////
        assign inA_e1.data = {posit_rs1_sgn,posit_rs1_exp,posit_rs1_fra};

        assign inB_e1.data = {posit_rs2_sgn,posit_rs2_exp,posit_rs2_fra};

        FloatAdd       #(.EXP_IN_A(ES), .FRAC_IN_A(FRACTION_BW),
                         .EXP_IN_B(ES), .FRAC_IN_B(FRACTION_BW),
                         .EXP_OUT (ES), .FRAC_OUT (FRACTION_BW))
                  float_alu_e1   (
                    .clock       ( clk                    ),
                    .reset       (~rst_l                  ),
                    .inA         ( inA_e1                 ),
                    .inB         ( inB_e1                 ),
                    .out         ( out_e1                 ),
                    .subtract    ( i0_ap_e1.sub           ),
                    .trailingBits( trailingBits_e1        ),
                    .stickyBit   ( stickyBit_e1           ),
                    .isNan       ( is_oflw_or_uflw_alu_e1 ));

        //////////////
        ///Encoding///
        //////////////
        FloatRoundToNearestEven #(.EXP(ES), .FRAC(FRACTION_BW))
                Float_encode_e1 ( .in            ( out_e1                 ),
                                  .trailingBitsIn( trailingBits_e1        ),
                                  .stickyBitIn   ( stickyBit_e1           ),
                                  .isNanIn       ( is_oflw_or_uflw_alu_e1 ),
                                  .out           ( last_e1                ));
        assign exu_i0_result_posit_e1 = last_e1.data;
        assign exu_i0_result_e1       =  i0_ap_e2.posit ? exu_i0_result_posit_e1 : exu_i0_result_alu_e1; // Sees if the output result needs to be posit or not
    end
  endgenerate

   assign i0_predpipe_d[PREDPIPESIZE-1:0] = {i0_predict_fghr_d, i0_predict_index_d, i0_predict_btag_d, i0_predict_toffset_d};
   assign i1_predpipe_d[PREDPIPESIZE-1:0] = {i1_predict_fghr_d, i1_predict_index_d, i1_predict_btag_d, i1_predict_toffset_d};


   rvdffppie #(.WIDTH($bits(eh2_predict_pkt_t)),.LEFT(19),.RIGHT(9))  i0_pp_e2_ff         (.*, .clk(clk), .en ( i0_e2_ctl_en ), .den(i0_e2_data_en & dec_i0_branch_e1), .din( i0_predict_p_e1 ),  .dout( i0_pp_e2       ) );
   rvdffppie #(.WIDTH($bits(eh2_predict_pkt_t)),.LEFT(19),.RIGHT(9))  i0_pp_e3_ff         (.*, .clk(clk), .en ( i0_e3_ctl_en ), .den(i0_e3_data_en & dec_i0_branch_e2), .din( i0_pp_e2        ),  .dout( i0_pp_e3       ) );
   rvdffppie #(.WIDTH($bits(eh2_predict_pkt_t)),.LEFT(19),.RIGHT(9))  i1_pp_e2_ff         (.*, .clk(clk), .en ( i1_e2_ctl_en ), .den(i1_e2_data_en & dec_i1_branch_e1), .din( i1_predict_p_e1 ),  .dout( i1_pp_e2       ) );
   rvdffppie #(.WIDTH($bits(eh2_predict_pkt_t)),.LEFT(19),.RIGHT(9))  i1_pp_e3_ff         (.*, .clk(clk), .en ( i1_e3_ctl_en ), .den(i1_e3_data_en & dec_i1_branch_e2), .din( i1_pp_e2        ),  .dout( i1_pp_e3       ) );


   rvdffe #(PREDPIPESIZE)                                   i0_predpipe_e1_ff   (.*, .clk(clk), .en ( i0_e1_data_en & dec_i0_branch_d ),  .din( i0_predpipe_d   ),  .dout( i0_predpipe_e1 ) );
   rvdffe #(PREDPIPESIZE)                                   i0_predpipe_e2_ff   (.*, .clk(clk), .en ( i0_e2_data_en & dec_i0_branch_e1),  .din( i0_predpipe_e1  ),  .dout( i0_predpipe_e2 ) );
   rvdffe #(PREDPIPESIZE)                                   i0_predpipe_e3_ff   (.*, .clk(clk), .en ( i0_e3_data_en & dec_i0_branch_e2),  .din( i0_predpipe_e2  ),  .dout( i0_predpipe_e3 ) );
   rvdffe #(PREDPIPESIZE)                                   i0_predpipe_e4_ff   (.*, .clk(clk), .en ( i0_e4_ctl_en  & dec_i0_branch_e3),  .din( i0_predpipe_e3  ),  .dout( i0_predpipe_e4 ) );

   rvdffe #(PREDPIPESIZE)                                   i1_predpipe_e1_ff   (.*, .clk(clk), .en ( i1_e1_data_en & dec_i1_branch_d ),  .din( i1_predpipe_d   ),  .dout( i1_predpipe_e1 ) );
   rvdffe #(PREDPIPESIZE)                                   i1_predpipe_e2_ff   (.*, .clk(clk), .en ( i1_e2_data_en & dec_i1_branch_e1),  .din( i1_predpipe_e1  ),  .dout( i1_predpipe_e2 ) );
   rvdffe #(PREDPIPESIZE)                                   i1_predpipe_e3_ff   (.*, .clk(clk), .en ( i1_e3_data_en & dec_i1_branch_e2),  .din( i1_predpipe_e2  ),  .dout( i1_predpipe_e3 ) );
   rvdffe #(PREDPIPESIZE)                                   i1_predpipe_e4_ff   (.*, .clk(clk), .en ( i1_e4_ctl_en  & dec_i1_branch_e3),  .din( i1_predpipe_e3  ),  .dout( i1_predpipe_e4 ) );


   assign exu_pmu_i0_br_misp   = i0_predict_p_e4.misp;
   assign exu_pmu_i0_br_ataken = i0_predict_p_e4.ataken;
   assign exu_pmu_i0_pc4       = dec_i0_pc4_e4;
   assign exu_pmu_i1_br_misp   = i1_predict_p_e4.misp;
   assign exu_pmu_i1_br_ataken = i1_predict_p_e4.ataken;
   assign exu_pmu_i1_pc4       = dec_i1_pc4_e4;



   assign i0_pp_e4_in = i0_pp_e3;
   assign i1_pp_e4_in = i1_pp_e3;


   rvdfflie #(.WIDTH($bits(eh2_alu_pkt_t)),.LEFT(25)) i0_ap_e1_ff (.*,  .clk(clk), .en(i0_e1_data_en), .din(i0_ap),   .dout(i0_ap_e1) );
   rvdfflie #(.WIDTH($bits(eh2_alu_pkt_t)),.LEFT(25)) i0_ap_e2_ff (.*,  .clk(clk), .en(i0_e2_data_en), .din(i0_ap_e1),.dout(i0_ap_e2) );
   rvdfflie #(.WIDTH($bits(eh2_alu_pkt_t)),.LEFT(25)) i0_ap_e3_ff (.*,  .clk(clk), .en(i0_e3_data_en), .din(i0_ap_e2),.dout(i0_ap_e3) );
   rvdfflie #(.WIDTH($bits(eh2_alu_pkt_t)),.LEFT(25)) i0_ap_e4_ff (.*,  .clk(clk), .en(i0_e4_data_en), .din(i0_ap_e3),.dout(i0_ap_e4) );
   rvdfflie #(.WIDTH($bits(eh2_alu_pkt_t)),.LEFT(25)) i0_ap_e5_ff (.*,  .clk(clk), .en(1'b1),          .din(i0_ap_e4),.dout(i0_ap_e5) );

   rvdfflie #(.WIDTH($bits(eh2_alu_pkt_t)),.LEFT(25)) i1_ap_e1_ff (.*,  .clk(clk), .en(i1_e1_data_en), .din(i1_ap),   .dout(i1_ap_e1) );
   rvdfflie #(.WIDTH($bits(eh2_alu_pkt_t)),.LEFT(25)) i1_ap_e2_ff (.*,  .clk(clk), .en(i1_e2_data_en), .din(i1_ap_e1),.dout(i1_ap_e2) );
   rvdfflie #(.WIDTH($bits(eh2_alu_pkt_t)),.LEFT(25)) i1_ap_e3_ff (.*,  .clk(clk), .en(i1_e3_data_en), .din(i1_ap_e2),.dout(i1_ap_e3) );
   rvdfflie #(.WIDTH($bits(eh2_alu_pkt_t)),.LEFT(25)) i1_ap_e4_ff (.*,  .clk(clk), .en(i1_e4_data_en), .din(i1_ap_e3),.dout(i1_ap_e4) );



   rvdffe #(64+pt.BTB_TOFFSET_SIZE) i0_src_e1_ff (.*, .clk(clk),
                            .en  (i0_e1_data_en & dec_i0_secondary_d),
                            .din ({i0_rs1_d [31:0], i0_rs2_d [31:0], dec_i0_br_immed_d [pt.BTB_TOFFSET_SIZE:1]}),
                            .dout({i0_rs1_e1[31:0], i0_rs2_e1[31:0],     i0_br_immed_e1[pt.BTB_TOFFSET_SIZE:1]}));

   rvdffe #(64+pt.BTB_TOFFSET_SIZE) i0_src_e2_ff (.*, .clk(clk),
                            .en  (i0_e2_data_en & dec_i0_secondary_e1),
                            .din( {i0_rs1_e1[31:0], i0_rs2_e1[31:0], i0_br_immed_e1[pt.BTB_TOFFSET_SIZE:1]}),
                            .dout({i0_rs1_e2[31:0], i0_rs2_e2[31:0], i0_br_immed_e2[pt.BTB_TOFFSET_SIZE:1]}));

   rvdffe #(64+pt.BTB_TOFFSET_SIZE) i0_src_e3_ff (.*, .clk(clk),
                            .en  (i0_e3_data_en & dec_i0_secondary_e2),
                            .din( {i0_rs1_e2_final[31:0], i0_rs2_e2_final[31:0], i0_br_immed_e2[pt.BTB_TOFFSET_SIZE:1]}),
                            .dout({i0_rs1_e3[31:0],       i0_rs2_e3[31:0],       i0_br_immed_e3[pt.BTB_TOFFSET_SIZE:1]}));



   rvdffe #(64+pt.BTB_TOFFSET_SIZE) i1_src_e1_ff (.*, .clk(clk),
                            .en  (i1_e1_data_en & dec_i1_secondary_d),
                            .din ({i1_rs1_d [31:0], i1_rs2_d [31:0], dec_i1_br_immed_d [pt.BTB_TOFFSET_SIZE:1]}),
                            .dout({i1_rs1_e1[31:0], i1_rs2_e1[31:0],     i1_br_immed_e1[pt.BTB_TOFFSET_SIZE:1]}));

   rvdffe #(64+pt.BTB_TOFFSET_SIZE) i1_src_e2_ff (.*, .clk(clk),
                            .en  (i1_e2_data_en & dec_i1_secondary_e1),
                            .din ({i1_rs1_e1[31:0], i1_rs2_e1[31:0], i1_br_immed_e1[pt.BTB_TOFFSET_SIZE:1]}),
                            .dout({i1_rs1_e2[31:0], i1_rs2_e2[31:0], i1_br_immed_e2[pt.BTB_TOFFSET_SIZE:1]}));

   rvdffe #(64+pt.BTB_TOFFSET_SIZE) i1_src_e3_ff (.*, .clk(clk),
                            .en  (i1_e3_data_en & dec_i1_secondary_e2),
                            .din ({i1_rs1_e2_final[31:0], i1_rs2_e2_final[31:0], i1_br_immed_e2[pt.BTB_TOFFSET_SIZE:1]}),
                            .dout({i1_rs1_e3[31:0],       i1_rs2_e3[31:0],       i1_br_immed_e3[pt.BTB_TOFFSET_SIZE:1]}));




   assign i0_rs1_e2_final[31:0] = (dec_i0_rs1_bypass_en_e2) ? i0_rs1_bypass_data_e2[31:0] : i0_rs1_e2[31:0];
   assign i0_rs2_e2_final[31:0] = (dec_i0_rs2_bypass_en_e2) ? i0_rs2_bypass_data_e2[31:0] : i0_rs2_e2[31:0];
   assign i1_rs1_e2_final[31:0] = (dec_i1_rs1_bypass_en_e2) ? i1_rs1_bypass_data_e2[31:0] : i1_rs1_e2[31:0];
   assign i1_rs2_e2_final[31:0] = (dec_i1_rs2_bypass_en_e2) ? i1_rs2_bypass_data_e2[31:0] : i1_rs2_e2[31:0];


   assign i0_rs1_e3_final[31:0] = (dec_i0_rs1_bypass_en_e3) ? i0_rs1_bypass_data_e3[31:0] : i0_rs1_e3[31:0];
   assign i0_rs2_e3_final[31:0] = (dec_i0_rs2_bypass_en_e3) ? i0_rs2_bypass_data_e3[31:0] : i0_rs2_e3[31:0];
   assign i1_rs1_e3_final[31:0] = (dec_i1_rs1_bypass_en_e3) ? i1_rs1_bypass_data_e3[31:0] : i1_rs1_e3[31:0];
   assign i1_rs2_e3_final[31:0] = (dec_i1_rs2_bypass_en_e3) ? i1_rs2_bypass_data_e3[31:0] : i1_rs2_e3[31:0];



   assign i0_taken_e1  = (i0_predict_p_e1.ataken & dec_i0_alu_decode_e1) | (i0_predict_p_e1.hist[1] & ~dec_i0_alu_decode_e1);
   assign i1_taken_e1  = (i1_predict_p_e1.ataken & dec_i1_alu_decode_e1) | (i1_predict_p_e1.hist[1] & ~dec_i1_alu_decode_e1);





   eh2_exu_alu_ctl #(.pt(pt)) i0_alu_e4 (.*,
                          .b_enable      ( dec_i0_branch_e3                         ),   // I
                          .c_enable      ( i0_e4_ctl_en                             ),   // I
                          .d_enable      ( i0_e4_data_en                            ),   // I
                          .predict_p     ( i0_pp_e4_in                              ),   // I
                          .valid         ( dec_i0_sec_decode_e3 & ~i0_ap_e3.posit   ),   // I
                          .flush         ( dec_tlu_flush_lower_wb                   ),   // I
                          .a             ( i0_rs1_e3_final[31:0]                    ),   // I
                          .b             ( i0_rs2_e3_final[31:0]                    ),   // I
                          .pc            ( dec_i0_pc_e3[31:1]                       ),   // I
                          .brimm         ( i0_br_immed_e3[pt.BTB_TOFFSET_SIZE:1]    ),   // I
                          .ap_in_tid     ( i0_ap_e3.tid                             ),   // I
                          .ap            ( i0_ap_e4                                 ),   // I
                          .out           ( exu_i0_result_alu_e4[31:0]               ),   // O
                          .flush_upper   ( exu_i0_flush_lower_e4                    ),   // O
                          .flush_path    ( exu_i0_flush_path_e4[31:1]               ),   // O
                          .predict_p_ff  ( i0_predict_p_e4                          ),   // O
                          .pc_ff         ( i0_alu_pc_unused[31:1]                   ),   // O
                          .pred_correct  ( i0_pred_correct_lower_e4                 ));  // O


   eh2_exu_alu_ctl #(.pt(pt)) i1_alu_e4 (.*,
                          .b_enable      ( dec_i1_branch_e3                         ),   // I
                          .c_enable      ( i1_e4_ctl_en                             ),   // I
                          .d_enable      ( i1_e4_data_en                            ),   // I
                          .predict_p     ( i1_pp_e4_in                              ),   // I
                          .valid         ( dec_i1_sec_decode_e3                     ),   // I
                          .flush         ( dec_tlu_flush_lower_wb                   ),   // I
                          .a             ( i1_rs1_e3_final[31:0]                    ),   // I
                          .b             ( i1_rs2_e3_final[31:0]                    ),   // I
                          .pc            ( dec_i1_pc_e3[31:1]                       ),   // I
                          .brimm         ( i1_br_immed_e3[pt.BTB_TOFFSET_SIZE:1]    ),   // I
                          .ap_in_tid     ( i1_ap_e3.tid                             ),   // I
                          .ap            ( i1_ap_e4                                 ),   // I
                          .out           ( exu_i1_result_e4[31:0]                   ),   // O
                          .flush_upper   ( exu_i1_flush_lower_e4                    ),   // O
                          .flush_path    ( exu_i1_flush_path_e4[31:1]               ),   // O
                          .predict_p_ff  ( i1_predict_p_e4                          ),   // O
                          .pc_ff         ( i1_alu_pc_unused[31:1]                   ),   // O
                          .pred_correct  ( i1_pred_correct_lower_e4                 ));  // O

  generate

    if (POSIT == 1) begin
      //----------------------
      // Posit Decoders
      //----------------------
      eh2_posit_decode #(.POSIT_LEN(POSIT_LEN), .ES(ES), .REGIME_BW(REGIME_BW))
               posit_rs1(
                  .posit_data_in (i0_rs1_e3_final   ), //I                      Takes the same input as i0_alu_e4
                  .sign          (posit_rs1_sgn_e3  ), //O
                  .regime        (posit_rs1_reg_e3  ), //O
                  .exponent      (posit_rs1_exp_e3  ), //O
                  .fraction      (posit_rs1_fra_e3  ), //O
                  .is_special    (is_special_rs1_e3)); //O

      eh2_posit_decode #(.POSIT_LEN(POSIT_LEN), .ES(ES), .REGIME_BW(REGIME_BW))
               posit_rs2(
                  .posit_data_in (i0_rs2_e3_final   ), //I                      Takes the same input as i0_alu_e4
                  .sign          (posit_rs2_sgn_e3  ), //O
                  .regime        (posit_rs2_reg_e3  ), //O
                  .exponent      (posit_rs2_exp_e3  ), //O
                  .fraction      (posit_rs2_fra_e3  ), //O
                  .is_special    (is_special_rs2_e3)); //O

       eh2_posit_alu #(.POSIT_LEN(POSIT_LEN), .ES(ES), .REGIME_BW(REGIME_BW))
                             i0_posit_alu_e4   (
                              .first_sgn       ( posit_rs1_sgn_e4                      ),  //I
                              .first_reg       ( posit_rs1_reg_e4                      ),  //I
                              .first_exp       ( posit_rs1_exp_e4                      ),  //I
                              .first_fra       ( posit_rs1_fra_e4                      ),  //I
                              .second_sgn      ( posit_rs2_sgn_e4                      ),  //I
                              .second_reg      ( posit_rs2_reg_e4                      ),  //I
                              .second_exp      ( posit_rs2_exp_e4                      ),  //I
                              .second_fra      ( posit_rs2_fra_e4                      ),  //I
                              .product_sgn     ( posit_alu_sgn_e4                      ),  //O
                              .product_reg     ( posit_alu_reg_e4                      ),  //O
                              .product_exp     ( posit_alu_exp_e4                      ),  //O
                              .product_fra     ( posit_alu_fra_e4                      ),  //O
                              .add_or_sub      ( i0_ap_e4.sub                          ),  //I
                              .is_zero         ( is_zero_alu_e4                        ),  //O
                              .is_oflw_or_uflw ( is_oflw_or_uflw_alu_e4               ));  //O

       //----------------------
       // Posit Encoder
       //----------------------
       eh2_posit_encode #(.POSIT_LEN(POSIT_LEN), .ES(ES), .REGIME_BW(REGIME_BW))
                posit_alu_encode_e4  (
                    .posit_data_out  (exu_i0_result_posit_e4  ), //O
                    .sign            (posit_alu_sgn_e4        ), //I
                    .regime          (posit_alu_reg_e4        ), //I
                    .exponent        (posit_alu_exp_e4        ), //I
                    .fraction        (posit_alu_fra_e4        ), //I
                    .rs1_sign        (posit_rs1_sgn_e4        ), //I
                    .rs2_sign        (posit_rs2_sgn_e4        ), //I
                    .is_special_rs1  (is_special_rs1_e4       ), //I
                    .is_special_rs2  (is_special_rs2_e4       ), //I
                    .mul             (1'b0                    ), //I
                    .is_zero         (is_zero_alu_e4          ), //I
                    .is_oflw_or_uflw (is_oflw_or_uflw_alu_e4 )); //I
          assign exu_i0_result_e4                     =  i0_ap_e4.posit ? exu_i0_result_posit_e4 : exu_i0_result_alu_e4; // Sees if the output result needs to be posit or not
    end else begin
        logic                 stickyBit_e4   ;
        logic [          1:0] trailingBits_e4;
        logic [FRACTION_BW:0] mantissa_e4    ;
        Float #(.EXP(ES), .FRAC(FRACTION_BW)) inA_e4();
        Float #(.EXP(ES), .FRAC(FRACTION_BW)) inB_e4();
        Float #(.EXP(ES), .FRAC(FRACTION_BW)) out_e4();
        Float #(.EXP(ES), .FRAC(FRACTION_BW)) last_e4();

        //////////////
        ///Decoding///
        //////////////

        assign inA_e4.data     = i0_rs1_e3_final;
        assign inB_e4.data     = i0_rs2_e3_final;

        ///////////////
        ///Operation///
        ///////////////
        FloatAdd       #(.EXP_IN_A(ES), .FRAC_IN_A(FRACTION_BW),
                         .EXP_IN_B(ES), .FRAC_IN_B(FRACTION_BW),
                         .EXP_OUT (ES), .FRAC_OUT (FRACTION_BW))
                  float_alu_e4   (
                    .clock       ( clk                    ),
                    .reset       (~rst_l                  ),
                    .inA         ( inA_e4                 ),
                    .inB         ( inB_e4                 ),
                    .out         ( out_e4                 ),
                    .subtract    ( i0_ap_e4.sub           ),
                    .trailingBits( trailingBits_e4        ),
                    .stickyBit   ( stickyBit_e4           ),
                    .isNan       ( is_oflw_or_uflw_alu_e4 ));

        //////////////
        ///Encoding///
        //////////////
        FloatRoundToNearestEven #(.EXP(ES), .FRAC(FRACTION_BW))
                Float_encode_e1 ( .in            ( out_e4                 ),
                                  .trailingBitsIn( trailingBits_e4        ),
                                  .stickyBitIn   ( stickyBit_e4           ),
                                  .isNanIn       ( is_oflw_or_uflw_alu_e4 ),
                                  .out           ( last_e4                ));

        assign exu_i0_result_posit_e4 = last_e4.data;
        assign exu_i0_result_e4                     =  i0_ap_e5.posit ? exu_i0_result_posit_e4 : exu_i0_result_alu_e4; // Sees if the output result needs to be posit or not
    end
  endgenerate


   assign exu_i0_br_hist_e4[1:0]               =  i0_predict_p_e4.hist[1:0];
   assign exu_i0_br_bank_e4                    =  i0_predict_p_e4.bank;
   assign exu_i0_br_error_e4                   =  i0_predict_p_e4.br_error;
   assign exu_i0_br_middle_e4                  =  i0_predict_p_e4.pc4 ^ i0_predict_p_e4.boffset;
   assign exu_i0_br_start_error_e4             =  i0_predict_p_e4.br_start_error;

   assign exu_i0_br_valid_e4                   =  i0_predict_p_e4.valid;
   assign exu_i0_br_mp_e4                      =  i0_predict_p_e4.misp; // needed to squash i1 error
   assign exu_i0_br_ret_e4                     =  i0_predict_p_e4.pret;
   assign exu_i0_br_call_e4                    =  i0_predict_p_e4.pcall;
   assign exu_i0_br_way_e4                     =  i0_predict_p_e4.way;

   assign {exu_i0_br_fghr_e4[pt.BHT_GHR_SIZE-1:0],
           exu_i0_br_index_e4[pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]} =  i0_predpipe_e4[PREDPIPESIZE-1:pt.BTB_BTAG_SIZE+pt.BTB_TOFFSET_SIZE];

   assign exu_i1_br_hist_e4[1:0]               =  i1_predict_p_e4.hist[1:0];
   assign exu_i1_br_bank_e4                    =  i1_predict_p_e4.bank;
   assign exu_i1_br_middle_e4                  =  i1_predict_p_e4.pc4 ^ i1_predict_p_e4.boffset;
   assign exu_i1_br_error_e4                   =  i1_predict_p_e4.br_error;

   assign exu_i1_br_start_error_e4             =  i1_predict_p_e4.br_start_error;
   assign exu_i1_br_valid_e4                   =  i1_predict_p_e4.valid;
   assign exu_i1_br_mp_e4                      =  i1_predict_p_e4.misp;
   assign exu_i1_br_way_e4                     =  i1_predict_p_e4.way;
   assign exu_i1_br_ret_e4                     =  i1_predict_p_e4.pret;
   assign exu_i1_br_call_e4                    =  i1_predict_p_e4.pcall;

   assign {exu_i1_br_fghr_e4[pt.BHT_GHR_SIZE-1:0],
           exu_i1_br_index_e4[pt.BTB_ADDR_HI:pt.BTB_ADDR_LO]} =  i1_predpipe_e4[PREDPIPESIZE-1:pt.BTB_BTAG_SIZE+pt.BTB_TOFFSET_SIZE];



   for (genvar i=0; i<pt.NUM_THREADS; i++) begin

      assign fp_enable[i]                             = (exu_i0_flush_lower_e4[i]) | (exu_i1_flush_lower_e4[i]) |
                                                        (i0_flush_upper_e1[i])     | (i1_flush_upper_e1[i]);

      assign final_predict_mp[i]                      = (exu_i0_flush_lower_e4[i])  ?  i0_predict_p_e4 :
                                                        (exu_i1_flush_lower_e4[i])  ?  i1_predict_p_e4 :
                                                        (i0_flush_upper_e1[i])      ?  i0_predict_p_e1 :
                                                        (i1_flush_upper_e1[i])      ?  i1_predict_p_e1 : '0;

      assign final_predpipe_mp[i][PREDPIPESIZE-1:0]   = (exu_i0_flush_lower_e4[i])  ?  i0_predpipe_e4  :
                                                        (exu_i1_flush_lower_e4[i])  ?  i1_predpipe_e4  :
                                                        (i0_flush_upper_e1[i])      ?  i0_predpipe_e1  :
                                                        (i1_flush_upper_e1[i])      ?  i1_predpipe_e1  : '0;


      assign after_flush_eghr[i][pt.BHT_GHR_SIZE-1:0] = (i0_flush_upper_e2[i] | i1_flush_upper_e2[i] & ~dec_tlu_flush_lower_wb[i]) ? ghr_e1[i][pt.BHT_GHR_SIZE-1:0] : ghr_e4[i][pt.BHT_GHR_SIZE-1:0];

      assign exu_mp_fghr[i][pt.BHT_GHR_SIZE-1:0]      =  after_flush_eghr[i][pt.BHT_GHR_SIZE-1:0];     // fghr repair value

      assign {exu_mp_index[i][pt.BTB_ADDR_HI:pt.BTB_ADDR_LO],
              exu_mp_btag[i][pt.BTB_BTAG_SIZE-1:0],
              exu_mp_toffset[i][pt.BTB_TOFFSET_SIZE-1:0]}   =  final_predpipe_mp_ff[i][PREDPIPESIZE-pt.BHT_GHR_SIZE-1:0];
      assign  exu_mp_eghr[i][pt.BHT_GHR_SIZE-1:0]     =  final_predpipe_mp_ff[i][PREDPIPESIZE-1:pt.BTB_ADDR_HI-pt.BTB_ADDR_LO+pt.BTB_BTAG_SIZE+pt.BTB_TOFFSET_SIZE+1]; // mp ghr for bht write


     // E1 GHR - fill in the ptaken for secondary branches.

      assign i0_valid_e1[i]  = ~exu_flush_final[i] & (i0_ap_e1.tid==i) & ~flush_final_f[i] & (i0_predict_p_e1.valid | i0_predict_p_e1.misp);
      assign i1_valid_e1[i]  = ~exu_flush_final[i] & (i1_ap_e1.tid==i) & ~flush_final_f[i] & (i1_predict_p_e1.valid | i1_predict_p_e1.misp) & ~(i0_flush_upper_e1[i]);

      assign ghr_e1_ns[i][pt.BHT_GHR_SIZE-1:0]  = ({pt.BHT_GHR_SIZE{ dec_tlu_flush_lower_wb[i]}}                                                                  &  ghr_e4[i][pt.BHT_GHR_SIZE-1:0]) |
                                                  ({pt.BHT_GHR_SIZE{~dec_tlu_flush_lower_wb[i] & ~i0_valid_e1[i] &  ~i1_valid_e1[i]}}                             &  ghr_e1[i][pt.BHT_GHR_SIZE-1:0]) |
                                                  ({pt.BHT_GHR_SIZE{~dec_tlu_flush_lower_wb[i] & ~i0_valid_e1[i] &   i1_valid_e1[i] & ~i0_predict_p_e1.br_error}} & {ghr_e1[i][pt.BHT_GHR_SIZE-2:0], i1_taken_e1}) |
                                                  ({pt.BHT_GHR_SIZE{~dec_tlu_flush_lower_wb[i] &  i0_valid_e1[i] & (~i1_valid_e1[i] |  i0_predict_p_e1.misp   )}} & {ghr_e1[i][pt.BHT_GHR_SIZE-2:0], i0_taken_e1}) |
                                                  ({pt.BHT_GHR_SIZE{~dec_tlu_flush_lower_wb[i] &  i0_valid_e1[i] &   i1_valid_e1[i] & ~i0_predict_p_e1.misp    }} & {ghr_e1[i][pt.BHT_GHR_SIZE-3:0], i0_taken_e1, i1_taken_e1});


      // E4 GHR - the ataken is filled in by e1 stage if e1 stage executes the branch, otherwise by e4 stage.
      assign i0_valid_e4[i]                     =  dec_tlu_i0_valid_e4 & (i0_ap_e4.tid==i) & ((i0_predict_p_e4.valid) | i0_predict_p_e4.misp);
      assign i1_pred_valid_e4[i]                =  dec_tlu_i1_valid_e4 & (i1_ap_e4.tid==i) & ((i1_predict_p_e4.valid) | i1_predict_p_e4.misp) & ~i0_flush_upper_e4[i];
      assign ghr_e4_ns[i][pt.BHT_GHR_SIZE-1:0]  = ({pt.BHT_GHR_SIZE{ i0_valid_e4[i] & (i0_predict_p_e4.misp |     ~i1_pred_valid_e4[i])}} & {ghr_e4[i][pt.BHT_GHR_SIZE-2:0], i0_predict_p_e4.ataken}) |
                                                  ({pt.BHT_GHR_SIZE{ i0_valid_e4[i] & ~i0_predict_p_e4.misp &      i1_pred_valid_e4[i]}}  & {ghr_e4[i][pt.BHT_GHR_SIZE-3:0], i0_predict_p_e4.ataken, i1_predict_p_e4.ataken}) |
                                                  ({pt.BHT_GHR_SIZE{~i0_valid_e4[i] & ~i0_predict_p_e4.br_error &  i1_pred_valid_e4[i]}}  & {ghr_e4[i][pt.BHT_GHR_SIZE-2:0], i1_predict_p_e4.ataken}) |
                                                  ({pt.BHT_GHR_SIZE{~i0_valid_e4[i] &                             ~i1_pred_valid_e4[i]}}  &  ghr_e4[i][pt.BHT_GHR_SIZE-1:0]);



      rvdfflie #(.WIDTH($bits(eh2_predict_pkt_t)),.LEFT(24)) predict_mp_ff     (.*, .clk(active_thread_l2clk[i]), .en(fp_enable[i] | fp_enable_ff[i]), .din(final_predict_mp [i]),                .dout(exu_mp_pkt[i]));
      rvdffe #(PREDPIPESIZE)                                  predictpipe_mp_ff (.*, .clk(active_thread_l2clk[i]), .en(fp_enable[i] | fp_enable_ff[i]), .din(final_predpipe_mp[i]),                .dout(final_predpipe_mp_ff[i]));



      assign flush_path_e2[i][31:1]           = (i0_flush_upper_e2[i])       ?  i0_flush_path_upper_e2[31:1]    :  i1_flush_path_upper_e2[31:1];

      // quiet this bus when there are no flushes
      assign exu_flush_path_final[i][31:1]    = (dec_tlu_flush_lower_wb[i])                     ?  dec_tlu_flush_path_wb[i][31:1]  :
                                                ((i0_flush_upper_e2[i] | i1_flush_upper_e2[i])  ?  flush_path_e2[i][31:1]          : '0);



      assign exu_i0_flush_final[i]         =    dec_tlu_flush_lower_wb[i] | i0_flush_upper_e2[i];
      assign exu_i1_flush_final[i]         =    dec_tlu_flush_lower_wb[i] | i1_flush_upper_e2[i];
      assign exu_flush_final[i]            =    dec_tlu_flush_lower_wb[i] | i0_flush_upper_e2[i]  | i1_flush_upper_e2[i];

      rvdffie #(6+pt.BHT_GHR_SIZE+pt.BHT_GHR_SIZE,1)  i_misc_thr_ff  (.*, .clk(clk),
                                                                      .din ({exu_flush_final[i]  , fp_enable[i]        , ghr_e1_ns[i][pt.BHT_GHR_SIZE-1:0], ghr_e4_ns[i][pt.BHT_GHR_SIZE-1:0],
                                                                             i0_flush_upper_e1[i], i1_flush_upper_e1[i], i0_flush_upper_e2[i]             , i0_flush_upper_e3[i]  }),
                                                                      .dout({flush_final_f[i]    , fp_enable_ff[i]     , ghr_e1[i][pt.BHT_GHR_SIZE-1:0]   , ghr_e4[i][pt.BHT_GHR_SIZE-1:0]   ,
                                                                             i0_flush_upper_e2[i], i1_flush_upper_e2[i], i0_flush_upper_e3[i]             , i0_flush_upper_e4[i] }));


      logic [pt.NUM_THREADS-1:0] [31:1] flush_path_e1, flush_path_e4, flush_path_wb;
      if(pt.BTB_USE_SRAM) begin
         assign flush_path_e1[i][31:1]           = (i0_flush_upper_e1[i])       ?  i0_flush_path_e1[31:1]     :  i1_flush_path_e1[31:1];
         assign flush_path_e4[i][31:1]           = (exu_i0_flush_lower_e4[i])         ?  exu_i0_flush_path_e4[31:1] :  exu_i1_flush_path_e4[31:1];

         // SRAM BTB arch moves flushes to BF stage, but only mispredicts. TLU flushesare still a cycle later
         assign exu_flush_path_final_early[i][31:1]    =  (exu_i0_flush_lower_e4[i] | exu_i1_flush_lower_e4[i])     ?  flush_path_e4[i][31:1]  :
                                                         ((i0_flush_upper_e1[i] | i1_flush_upper_e1[i]) ?  flush_path_e1[i][31:1]   : '0);
         assign exu_flush_final_early[i]            =    exu_i0_flush_lower_e4[i] | exu_i1_flush_lower_e4[i] | i0_flush_upper_e1[i]  | i1_flush_upper_e1[i];
      end
      else begin
         assign exu_flush_path_final_early[i][31:1] =    '0;
         assign exu_flush_final_early[i]            =    '0;
      end


   rvdffpcie #(31) i_pred_correct_npc_e3 (.*, .clk(clk),
                                    .en  ( i0_e3_data_en | i1_e3_data_en),
                                    .din ( pred_correct_npc_e2[i]       ),
                                    .dout( pred_correct_npc_e3[i]       ));

   rvdffpcie #(31) i_pred_correct_npc_e4 (.*, .clk(clk),
                                    .en  ( i0_e4_data_en | i1_e4_data_en),
                                    .din ( pred_correct_npc_e3[i]       ),
                                    .dout( pred_correct_npc_e4[i]       ));

   end






   rvdffpcie #(31) i0_upper_flush_e2_ff  (.*, .clk(clk),
                                    .en  ( i0_e2_data_en                ),
                                    .din ( i0_flush_path_e1[31:1]       ),
                                    .dout( i0_flush_path_upper_e2[31:1] ));

   rvdffpcie #(31) i0_upper_flush_e3_ff  (.*, .clk(clk),
                                    .en  ( i0_e3_data_en                ),
                                    .din ( i0_flush_path_upper_e2[31:1] ),
                                    .dout( i0_flush_path_upper_e3[31:1] ));

   rvdffpcie #(31) i0_upper_flush_e4_ff  (.*, .clk(clk),
                                    .en  ( i0_e4_data_en                ),
                                    .din ( i0_flush_path_upper_e3[31:1] ),
                                    .dout( i0_flush_path_upper_e4[31:1] ));


   rvdffpcie #(31) i1_upper_flush_e2_ff  (.*, .clk(clk),
                                    .en  ( i1_e2_data_en                ),
                                    .din ( i1_flush_path_e1[31:1]       ),
                                    .dout( i1_flush_path_upper_e2[31:1] ));

   rvdffpcie #(31) i1_upper_flush_e3_ff  (.*, .clk(clk                  ),
                                    .en  ( i1_e3_data_en                ),
                                    .din ( i1_flush_path_upper_e2[31:1] ),
                                    .dout( i1_flush_path_upper_e3[31:1] ));

   rvdffpcie #(31) i1_upper_flush_e4_ff  (.*, .clk(clk),
                                    .en  ( i1_e4_data_en                ),
                                    .din ( i1_flush_path_upper_e3[31:1] ),
                                    .dout( i1_flush_path_upper_e4[31:1] ));


   // npc for commit
   rvdffie #(13) i_misc_ff              (.*, .clk (clk),
                                         .din ({i1_pred_correct_upper_e1,i0_pred_correct_upper_e1,
                                                i1_pred_correct_upper_e2,i0_pred_correct_upper_e2,
                                                i1_pred_correct_upper_e3,i0_pred_correct_upper_e3,
                                                dec_i0_alu_decode_d     , dec_i1_alu_decode_d,
                                                dec_i1_valid_e1,          i1_valid_e2             , i1_valid_e3,
                                                dec_i0_sec_decode_e3    , dec_i1_sec_decode_e3    }),
                                         .dout({i1_pred_correct_upper_e2,i0_pred_correct_upper_e2,
                                                i1_pred_correct_upper_e3,i0_pred_correct_upper_e3,
                                                i1_pred_correct_upper_e4,i0_pred_correct_upper_e4,
                                                dec_i0_alu_decode_e1    , dec_i1_alu_decode_e1,
                                                i1_valid_e2             , i1_valid_e3             , i1_valid_e4,
                                                i0_sec_decode_e4        , i1_sec_decode_e4        }));


   assign i1_pred_correct_e4_eff     = (i1_sec_decode_e4) ? i1_pred_correct_lower_e4 : i1_pred_correct_upper_e4;
   assign i0_pred_correct_e4_eff     = (i0_sec_decode_e4) ? i0_pred_correct_lower_e4 : i0_pred_correct_upper_e4;

   assign i1_flush_path_e4_eff[31:1] = (i1_sec_decode_e4) ? exu_i1_flush_path_e4[31:1] : i1_flush_path_upper_e4[31:1];
   assign i0_flush_path_e4_eff[31:1] = (i0_sec_decode_e4) ? exu_i0_flush_path_e4[31:1] : i0_flush_path_upper_e4[31:1];


   for (genvar i=0; i<pt.NUM_THREADS; i++) begin
     assign i1_valid_e4_eff[i]  =  i1_valid_e4 & (i1_ap_e4.tid==i) & ~((i0_sec_decode_e4 & (i0_ap_e4.tid==i)) ?  exu_i0_flush_lower_e4[i]  :  i0_flush_upper_e4[i]);

     assign exu_npc_e4[i][31:1] = (i1_valid_e4_eff[i]) ? ((i1_pred_correct_e4_eff & (i1_ap_e4.tid==i)) ? pred_correct_npc_e4[i][31:1] : i1_flush_path_e4_eff[31:1]) :
                                                         ((i0_pred_correct_e4_eff & (i0_ap_e4.tid==i)) ? pred_correct_npc_e4[i][31:1] : i0_flush_path_e4_eff[31:1]);
   end


endmodule // exu
