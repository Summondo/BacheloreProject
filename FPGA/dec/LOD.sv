 module LOD #(
      parameter WIDTH    = 32           ,
      parameter WIDTH_BW = $clog2(WIDTH)
) (
      input  logic [   WIDTH-1:0] pin,
      output logic [WIDTH_BW-1:0] out,
      output logic                vld
    );

      localparam LODH_WIDTH = WIDTH/2;

      generate
        if((WIDTH==2) | (WIDTH==0))
          begin
            assign vld = |pin;
            assign out = ~pin[1] & pin[0];
          end
        else
          begin
            logic                vlL,  vlH;
            logic [WIDTH_BW-2:0] outH, outL;

          LOD #(.WIDTH(LODH_WIDTH)) H (.pin(pin[WIDTH-1:LODH_WIDTH]), .out(outH), .vld(vlH));
          LOD #(.WIDTH(LODH_WIDTH)) L (.pin(pin[(LODH_WIDTH)-1:0]), .out(outL), .vld(vlL));

            assign vld = vlH | vlL;
            assign out = vlH ? {1'b0,outH} : {vlL,outL};
          end
      endgenerate
    endmodule