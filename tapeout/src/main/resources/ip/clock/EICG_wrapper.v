
module EICG_wrapper(
  output out,
  input en,
  input test_en,
  input in
);

//   reg en_latched ;

//   always @(*) begin
//      if (!in) begin
//         en_latched = en || test_en;
//      end
//   end


//   assign out = en_latched && in;
CLKLANQV2_140P7T35R u_icg(
    .Q(out), 
    .CK(in), 
    .E(en), 
    .TE(test_en)
);
endmodule