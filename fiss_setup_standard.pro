pro fiss_setup_standard, id, alpha, wva, profa, bra,  wvb, profb, brb

case id of
   1: begin
   spa=fiss_spec_sim('A', 6562.8, alpha, order, wva, profa)
   spa=fiss_spec_sim1('A', alpha, order,  wva, profa, bra, file='c:\work\fiss\observation\Halpha_A')
   spb=fiss_spec_sim1('B', alpha, 26,  wvb, profb, brb, file='c:\work\fiss\observation\CaII8542_B')
   end
   2: begin
   spb=fiss_spec_sim('B', 5434., alpha, order, wvb, profb)
   spa=fiss_spec_sim1('A', alpha, 38,  wva, profa, bra, file='c:\work\fiss\observation\NaID1_A')
   spb=fiss_spec_sim1('B', alpha, order,  wvb, profb, brb, file='c:\work\fiss\observation\FeI5434_B')
   end
endcase



end