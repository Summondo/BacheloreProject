package eh2_param_pkg;
    
typedef struct packed {
    bit [4:0]      ATOMIC_ENABLE;
    bit [7:0]      BHT_ADDR_HI;
    bit [5:0]      BHT_ADDR_LO;
    bit [15:0]     BHT_ARRAY_DEPTH;
    bit [4:0]      BHT_GHR_HASH_1;
    bit [7:0]      BHT_GHR_SIZE;
    bit [16:0]     BHT_SIZE;
    bit [4:0]      BITMANIP_ZBA;
    bit [4:0]      BITMANIP_ZBB;
    bit [4:0]      BITMANIP_ZBC;
    bit [4:0]      BITMANIP_ZBE;
    bit [4:0]      BITMANIP_ZBF;
    bit [4:0]      BITMANIP_ZBP;
    bit [4:0]      BITMANIP_ZBR;
    bit [4:0]      BITMANIP_ZBS;
    bit [8:0]      BTB_ADDR_HI;
    bit [6:0]      BTB_ADDR_LO;
    bit [14:0]     BTB_ARRAY_DEPTH;
    bit [4:0]      BTB_BTAG_FOLD;
    bit [9:0]      BTB_BTAG_SIZE;
    bit [4:0]      BTB_BYPASS_ENABLE;
    bit [4:0]      BTB_FOLD2_INDEX_HASH;
    bit [4:0]      BTB_FULLYA;
    bit [8:0]      BTB_INDEX1_HI;
    bit [8:0]      BTB_INDEX1_LO;
    bit [8:0]      BTB_INDEX2_HI;
    bit [8:0]      BTB_INDEX2_LO;
    bit [8:0]      BTB_INDEX3_HI;
    bit [8:0]      BTB_INDEX3_LO;
    bit [7:0]      BTB_NUM_BYPASS;
    bit [7:0]      BTB_NUM_BYPASS_WIDTH;
    bit [16:0]     BTB_SIZE;
    bit [8:0]      BTB_TOFFSET_SIZE;
    bit [4:0]      BTB_USE_SRAM;
    bit            BUILD_AHB_LITE;
    bit [4:0]      BUILD_AXI4;
    bit [4:0]      BUILD_AXI_NATIVE;
    bit [5:0]      BUS_PRTY_DEFAULT;
    bit [35:0]     DATA_ACCESS_ADDR0;
    bit [35:0]     DATA_ACCESS_ADDR1;
    bit [35:0]     DATA_ACCESS_ADDR2;
    bit [35:0]     DATA_ACCESS_ADDR3;
    bit [35:0]     DATA_ACCESS_ADDR4;
    bit [35:0]     DATA_ACCESS_ADDR5;
    bit [35:0]     DATA_ACCESS_ADDR6;
    bit [35:0]     DATA_ACCESS_ADDR7;
    bit [4:0]      DATA_ACCESS_ENABLE0;
    bit [4:0]      DATA_ACCESS_ENABLE1;
    bit [4:0]      DATA_ACCESS_ENABLE2;
    bit [4:0]      DATA_ACCESS_ENABLE3;
    bit [4:0]      DATA_ACCESS_ENABLE4;
    bit [4:0]      DATA_ACCESS_ENABLE5;
    bit [4:0]      DATA_ACCESS_ENABLE6;
    bit [4:0]      DATA_ACCESS_ENABLE7;
    bit [35:0]     DATA_ACCESS_MASK0;
    bit [35:0]     DATA_ACCESS_MASK1;
    bit [35:0]     DATA_ACCESS_MASK2;
    bit [35:0]     DATA_ACCESS_MASK3;
    bit [35:0]     DATA_ACCESS_MASK4;
    bit [35:0]     DATA_ACCESS_MASK5;
    bit [35:0]     DATA_ACCESS_MASK6;
    bit [35:0]     DATA_ACCESS_MASK7;
    bit [6:0]      DCCM_BANK_BITS;
    bit [8:0]      DCCM_BITS;
    bit [6:0]      DCCM_BYTE_WIDTH;
    bit [9:0]      DCCM_DATA_WIDTH;
    bit [6:0]      DCCM_ECC_WIDTH;
    bit [4:0]      DCCM_ENABLE;
    bit [9:0]      DCCM_FDATA_WIDTH;
    bit [7:0]      DCCM_INDEX_BITS;
    bit [8:0]      DCCM_NUM_BANKS;
    bit [7:0]      DCCM_REGION;
    bit [35:0]     DCCM_SADR;
    bit [13:0]     DCCM_SIZE;
    bit [5:0]      DCCM_WIDTH_BITS;
    bit [6:0]      DIV_BIT;
    bit [4:0]      DIV_NEW;
    bit [6:0]      DMA_BUF_DEPTH;
    bit [8:0]      DMA_BUS_ID;
    bit [5:0]      DMA_BUS_PRTY;
    bit [7:0]      DMA_BUS_TAG;
    bit [4:0]      FAST_INTERRUPT_REDIRECT;
    bit [4:0]      ICACHE_2BANKS;
    bit [6:0]      ICACHE_BANK_BITS;
    bit [6:0]      ICACHE_BANK_HI;
    bit [5:0]      ICACHE_BANK_LO;
    bit [7:0]      ICACHE_BANK_WIDTH;
    bit [6:0]      ICACHE_BANKS_WAY;
    bit [7:0]      ICACHE_BEAT_ADDR_HI;
    bit [7:0]      ICACHE_BEAT_BITS;
    bit [4:0]      ICACHE_BYPASS_ENABLE;
    bit [17:0]     ICACHE_DATA_DEPTH;
    bit [6:0]      ICACHE_DATA_INDEX_LO;
    bit [10:0]     ICACHE_DATA_WIDTH;
    bit [4:0]      ICACHE_ECC;
    bit [4:0]      ICACHE_ENABLE;
    bit [10:0]     ICACHE_FDATA_WIDTH;
    bit [8:0]      ICACHE_INDEX_HI;
    bit [10:0]     ICACHE_LN_SZ;
    bit [7:0]      ICACHE_NUM_BEATS;
    bit [7:0]      ICACHE_NUM_BYPASS;
    bit [7:0]      ICACHE_NUM_BYPASS_WIDTH;
    bit [6:0]      ICACHE_NUM_WAYS;
    bit [4:0]      ICACHE_ONLY;
    bit [7:0]      ICACHE_SCND_LAST;
    bit [12:0]     ICACHE_SIZE;
    bit [6:0]      ICACHE_STATUS_BITS;
    bit [4:0]      ICACHE_TAG_BYPASS_ENABLE;
    bit [16:0]     ICACHE_TAG_DEPTH;
    bit [6:0]      ICACHE_TAG_INDEX_LO;
    bit [8:0]      ICACHE_TAG_LO;
    bit [7:0]      ICACHE_TAG_NUM_BYPASS;
    bit [7:0]      ICACHE_TAG_NUM_BYPASS_WIDTH;
    bit [4:0]      ICACHE_WAYPACK;
    bit [6:0]      ICCM_BANK_BITS;
    bit [8:0]      ICCM_BANK_HI;
    bit [8:0]      ICCM_BANK_INDEX_LO;
    bit [8:0]      ICCM_BITS;
    bit [4:0]      ICCM_ENABLE;
    bit [4:0]      ICCM_ICACHE;
    bit [7:0]      ICCM_INDEX_BITS;
    bit [8:0]      ICCM_NUM_BANKS;
    bit [4:0]      ICCM_ONLY;
    bit [7:0]      ICCM_REGION;
    bit [35:0]     ICCM_SADR;
    bit [13:0]     ICCM_SIZE;
    bit [4:0]      IFU_BUS_ID;
    bit [5:0]      IFU_BUS_PRTY;
    bit [7:0]      IFU_BUS_TAG;
    bit [35:0]     INST_ACCESS_ADDR0;
    bit [35:0]     INST_ACCESS_ADDR1;
    bit [35:0]     INST_ACCESS_ADDR2;
    bit [35:0]     INST_ACCESS_ADDR3;
    bit [35:0]     INST_ACCESS_ADDR4;
    bit [35:0]     INST_ACCESS_ADDR5;
    bit [35:0]     INST_ACCESS_ADDR6;
    bit [35:0]     INST_ACCESS_ADDR7;
    bit [4:0]      INST_ACCESS_ENABLE0;
    bit [4:0]      INST_ACCESS_ENABLE1;
    bit [4:0]      INST_ACCESS_ENABLE2;
    bit [4:0]      INST_ACCESS_ENABLE3;
    bit [4:0]      INST_ACCESS_ENABLE4;
    bit [4:0]      INST_ACCESS_ENABLE5;
    bit [4:0]      INST_ACCESS_ENABLE6;
    bit [4:0]      INST_ACCESS_ENABLE7;
    bit [35:0]     INST_ACCESS_MASK0;
    bit [35:0]     INST_ACCESS_MASK1;
    bit [35:0]     INST_ACCESS_MASK2;
    bit [35:0]     INST_ACCESS_MASK3;
    bit [35:0]     INST_ACCESS_MASK4;
    bit [35:0]     INST_ACCESS_MASK5;
    bit [35:0]     INST_ACCESS_MASK6;
    bit [35:0]     INST_ACCESS_MASK7;
    bit [4:0]      LOAD_TO_USE_BUS_PLUS1;
    bit [4:0]      LOAD_TO_USE_PLUS1;
    bit [4:0]      LSU_BUS_ID;
    bit [5:0]      LSU_BUS_PRTY;
    bit [7:0]      LSU_BUS_TAG;
    bit [8:0]      LSU_NUM_NBLOAD;
    bit [6:0]      LSU_NUM_NBLOAD_WIDTH;
    bit [8:0]      LSU_SB_BITS;
    bit [7:0]      LSU_STBUF_DEPTH;
    bit [4:0]      NO_ICCM_NO_ICACHE;
    bit [4:0]      NO_SECONDARY_ALU;
    bit [5:0]      NUM_THREADS;
    bit [4:0]      PIC_2CYCLE;
    bit [35:0]     PIC_BASE_ADDR;
    bit [8:0]      PIC_BITS;
    bit [7:0]      PIC_INT_WORDS;
    bit [7:0]      PIC_REGION;
    bit [12:0]     PIC_SIZE;
    bit [11:0]     PIC_TOTAL_INT;
    bit [12:0]     PIC_TOTAL_INT_PLUS1;
    bit [7:0]      RET_STACK_SIZE;
    bit [4:0]      SB_BUS_ID;
    bit [5:0]      SB_BUS_PRTY;
    bit [7:0]      SB_BUS_TAG;
    bit [4:0]      TIMER_LEGAL_EN;
} eh2_param_t;

localparam eh2_param_t pt = '{
   ATOMIC_ENABLE          : 5'h01         ,
   BHT_ADDR_HI            : 8'h09         ,
   BHT_ADDR_LO            : 6'h03         ,
   BHT_ARRAY_DEPTH        : 16'h0080       ,
   BHT_GHR_HASH_1         : 5'h00         ,
   BHT_GHR_SIZE           : 8'h07         ,
   BHT_SIZE               : 17'h00200      ,
   BITMANIP_ZBA           : 5'h01         ,
   BITMANIP_ZBB           : 5'h01         ,
   BITMANIP_ZBC           : 5'h01         ,
   BITMANIP_ZBE           : 5'h00         ,
   BITMANIP_ZBF           : 5'h00         ,
   BITMANIP_ZBP           : 5'h00         ,
   BITMANIP_ZBR           : 5'h00         ,
   BITMANIP_ZBS           : 5'h01         ,
   BTB_ADDR_HI            : 9'h009        ,
   BTB_ADDR_LO            : 7'h03         ,
   BTB_ARRAY_DEPTH        : 15'h0080       ,
   BTB_BTAG_FOLD          : 5'h00         ,
   BTB_BTAG_SIZE          : 10'h005        ,
   BTB_BYPASS_ENABLE      : 5'h01         ,
   BTB_FOLD2_INDEX_HASH   : 5'h00         ,
   BTB_FULLYA             : 5'h00         ,
   BTB_INDEX1_HI          : 9'h009        ,
   BTB_INDEX1_LO          : 9'h003        ,
   BTB_INDEX2_HI          : 9'h010        ,
   BTB_INDEX2_LO          : 9'h00A        ,
   BTB_INDEX3_HI          : 9'h017        ,
   BTB_INDEX3_LO          : 9'h011        ,
   BTB_NUM_BYPASS         : 8'h08         ,
   BTB_NUM_BYPASS_WIDTH   : 8'h04         ,
   BTB_SIZE               : 17'h00200      ,
   BTB_TOFFSET_SIZE       : 9'h00C        ,
   BTB_USE_SRAM           : 5'h00         ,
   BUILD_AHB_LITE         : 4'h0          ,
   BUILD_AXI4             : 5'h01         ,
   BUILD_AXI_NATIVE       : 5'h01         ,
   BUS_PRTY_DEFAULT       : 6'h03         ,
   DATA_ACCESS_ADDR0      : 36'h000000000  ,
   DATA_ACCESS_ADDR1      : 36'h0C0000000  ,
   DATA_ACCESS_ADDR2      : 36'h0A0000000  ,
   DATA_ACCESS_ADDR3      : 36'h080000000  ,
   DATA_ACCESS_ADDR4      : 36'h000000000  ,
   DATA_ACCESS_ADDR5      : 36'h000000000  ,
   DATA_ACCESS_ADDR6      : 36'h000000000  ,
   DATA_ACCESS_ADDR7      : 36'h000000000  ,
   DATA_ACCESS_ENABLE0    : 5'h01         ,
   DATA_ACCESS_ENABLE1    : 5'h01         ,
   DATA_ACCESS_ENABLE2    : 5'h01         ,
   DATA_ACCESS_ENABLE3    : 5'h01         ,
   DATA_ACCESS_ENABLE4    : 5'h00         ,
   DATA_ACCESS_ENABLE5    : 5'h00         ,
   DATA_ACCESS_ENABLE6    : 5'h00         ,
   DATA_ACCESS_ENABLE7    : 5'h00         ,
   DATA_ACCESS_MASK0      : 36'h07FFFFFFF  ,
   DATA_ACCESS_MASK1      : 36'h03FFFFFFF  ,
   DATA_ACCESS_MASK2      : 36'h01FFFFFFF  ,
   DATA_ACCESS_MASK3      : 36'h00FFFFFFF  ,
   DATA_ACCESS_MASK4      : 36'h0FFFFFFFF  ,
   DATA_ACCESS_MASK5      : 36'h0FFFFFFFF  ,
   DATA_ACCESS_MASK6      : 36'h0FFFFFFFF  ,
   DATA_ACCESS_MASK7      : 36'h0FFFFFFFF  ,
   DCCM_BANK_BITS         : 7'h03         ,
   DCCM_BITS              : 9'h011        ,
   DCCM_BYTE_WIDTH        : 7'h04         ,
   DCCM_DATA_WIDTH        : 10'h020        ,
   DCCM_ECC_WIDTH         : 7'h07         ,
   DCCM_ENABLE            : 5'h01         ,
   DCCM_FDATA_WIDTH       : 10'h027        ,
   DCCM_INDEX_BITS        : 8'h0C         ,
   DCCM_NUM_BANKS         : 9'h008        ,
   DCCM_REGION            : 8'h0F         ,
   DCCM_SADR              : 36'h0F0040000  ,
   DCCM_SIZE              : 14'h0080       ,
   DCCM_WIDTH_BITS        : 6'h02         ,
   DIV_BIT                : 7'h04         ,
   DIV_NEW                : 5'h01         ,
   DMA_BUF_DEPTH          : 7'h05         ,
   DMA_BUS_ID             : 9'h001        ,
   DMA_BUS_PRTY           : 6'h02         ,
   DMA_BUS_TAG            : 8'h01         ,
   FAST_INTERRUPT_REDIRECT : 5'h01         ,
   ICACHE_2BANKS          : 5'h01         ,
   ICACHE_BANK_BITS       : 7'h01         ,
   ICACHE_BANK_HI         : 7'h03         ,
   ICACHE_BANK_LO         : 6'h03         ,
   ICACHE_BANK_WIDTH      : 8'h08         ,
   ICACHE_BANKS_WAY       : 7'h02         ,
   ICACHE_BEAT_ADDR_HI    : 8'h05         ,
   ICACHE_BEAT_BITS       : 8'h03         ,
   ICACHE_BYPASS_ENABLE   : 5'h01         ,
   ICACHE_DATA_DEPTH      : 18'h00200      ,
   ICACHE_DATA_INDEX_LO   : 7'h04         ,
   ICACHE_DATA_WIDTH      : 11'h040        ,
   ICACHE_ECC             : 5'h01         ,
   ICACHE_ENABLE          : 5'h01         ,
   ICACHE_FDATA_WIDTH     : 11'h047        ,
   ICACHE_INDEX_HI        : 9'h00C        ,
   ICACHE_LN_SZ           : 11'h040        ,
   ICACHE_NUM_BEATS       : 8'h08         ,
   ICACHE_NUM_BYPASS      : 8'h04         ,
   ICACHE_NUM_BYPASS_WIDTH : 8'h03         ,
   ICACHE_NUM_WAYS        : 7'h04         ,
   ICACHE_ONLY            : 5'h00         ,
   ICACHE_SCND_LAST       : 8'h06         ,
   ICACHE_SIZE            : 13'h0020       ,
   ICACHE_STATUS_BITS     : 7'h03         ,
   ICACHE_TAG_BYPASS_ENABLE : 5'h01         ,
   ICACHE_TAG_DEPTH       : 17'h00080      ,
   ICACHE_TAG_INDEX_LO    : 7'h06         ,
   ICACHE_TAG_LO          : 9'h00D        ,
   ICACHE_TAG_NUM_BYPASS  : 8'h02         ,
   ICACHE_TAG_NUM_BYPASS_WIDTH : 8'h02         ,
   ICACHE_WAYPACK         : 5'h00         ,
   ICCM_BANK_BITS         : 7'h02         ,
   ICCM_BANK_HI           : 9'h003        ,
   ICCM_BANK_INDEX_LO     : 9'h004        ,
   ICCM_BITS              : 9'h010        ,
   ICCM_ENABLE            : 5'h01         ,
   ICCM_ICACHE            : 5'h01         ,
   ICCM_INDEX_BITS        : 8'h0C         ,
   ICCM_NUM_BANKS         : 9'h004        ,
   ICCM_ONLY              : 5'h00         ,
   ICCM_REGION            : 8'h0E         ,
   ICCM_SADR              : 36'h0EE000000  ,
   ICCM_SIZE              : 14'h0040       ,
   IFU_BUS_ID             : 5'h01         ,
   IFU_BUS_PRTY           : 6'h02         ,
   IFU_BUS_TAG            : 8'h04         ,
   INST_ACCESS_ADDR0      : 36'h000000000  ,
   INST_ACCESS_ADDR1      : 36'h0C0000000  ,
   INST_ACCESS_ADDR2      : 36'h0A0000000  ,
   INST_ACCESS_ADDR3      : 36'h080000000  ,
   INST_ACCESS_ADDR4      : 36'h000000000  ,
   INST_ACCESS_ADDR5      : 36'h000000000  ,
   INST_ACCESS_ADDR6      : 36'h000000000  ,
   INST_ACCESS_ADDR7      : 36'h000000000  ,
   INST_ACCESS_ENABLE0    : 5'h01         ,
   INST_ACCESS_ENABLE1    : 5'h01         ,
   INST_ACCESS_ENABLE2    : 5'h01         ,
   INST_ACCESS_ENABLE3    : 5'h01         ,
   INST_ACCESS_ENABLE4    : 5'h00         ,
   INST_ACCESS_ENABLE5    : 5'h00         ,
   INST_ACCESS_ENABLE6    : 5'h00         ,
   INST_ACCESS_ENABLE7    : 5'h00         ,
   INST_ACCESS_MASK0      : 36'h07FFFFFFF  ,
   INST_ACCESS_MASK1      : 36'h03FFFFFFF  ,
   INST_ACCESS_MASK2      : 36'h01FFFFFFF  ,
   INST_ACCESS_MASK3      : 36'h00FFFFFFF  ,
   INST_ACCESS_MASK4      : 36'h0FFFFFFFF  ,
   INST_ACCESS_MASK5      : 36'h0FFFFFFFF  ,
   INST_ACCESS_MASK6      : 36'h0FFFFFFFF  ,
   INST_ACCESS_MASK7      : 36'h0FFFFFFFF  ,
   LOAD_TO_USE_BUS_PLUS1  : 5'h01         ,
   LOAD_TO_USE_PLUS1      : 5'h00         ,
   LSU_BUS_ID             : 5'h01         ,
   LSU_BUS_PRTY           : 6'h02         ,
   LSU_BUS_TAG            : 8'h04         ,
   LSU_NUM_NBLOAD         : 9'h008        ,
   LSU_NUM_NBLOAD_WIDTH   : 7'h03         ,
   LSU_SB_BITS            : 9'h011        ,
   LSU_STBUF_DEPTH        : 8'h0A         ,
   NO_ICCM_NO_ICACHE      : 5'h00         ,
   NO_SECONDARY_ALU       : 5'h00         ,
   NUM_THREADS            : 6'h02         ,
   PIC_2CYCLE             : 5'h01         ,
   PIC_BASE_ADDR          : 36'h0F00C0000  ,
   PIC_BITS               : 9'h00F        ,
   PIC_INT_WORDS          : 8'h04         ,
   PIC_REGION             : 8'h0F         ,
   PIC_SIZE               : 13'h0020       ,
   PIC_TOTAL_INT          : 12'h07F        ,
   PIC_TOTAL_INT_PLUS1    : 13'h0080       ,
   RET_STACK_SIZE         : 8'h04         ,
   SB_BUS_ID              : 5'h01         ,
   SB_BUS_PRTY            : 6'h02         ,
   SB_BUS_TAG             : 8'h01         ,
   TIMER_LEGAL_EN         : 5'h01         
};

endpackage
