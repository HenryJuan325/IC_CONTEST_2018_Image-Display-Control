#design.v 
#-sv testbench.sv 
#testbench.v
#+access+r 
#+define+RTL
#+debug
#+notimingchecks

LCD_CTRL_syn.v
-timescale 1ns/10ps
testfixture.v
#-v path for the tsmc13_neg.v
-v ~/IC_CONTEST/CBDK_IC_Contest_v2.5/Verilog/tsmc13_neg.v 
+define+SDF 
+ncmaxdelays
+debug
