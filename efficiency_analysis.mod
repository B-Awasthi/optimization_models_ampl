set INATTR;
set OUTATTR;
set DMUS;

set DMU_INATTR within {DMUS, INATTR};
set DMU_OUTATTR within {DMUS, OUTATTR};

param inputs {DMU_INATTR};
param outputs {DMU_OUTATTR};


#       DECISION      VARIABLES         #   

var wout {OUTATTR} >= 0;

var win {INATTR} >= 0;


#      CONSTRAINTS                      #

subject to ratios_constraint {h in DMUS}:
      sum {r in OUTATTR} outputs[h, r] * wout[r]
    - sum {i in INATTR} inputs[h, i] * win[i] 
    <= 0 ;

# DMU chosen as Winchester. It can be changed to any DMU
subject to normalization_constraint:
    sum {i in INATTR} inputs["Winchester", i] * win[i] = 1 ;


#       OBJECTIVE   FUNCTION        #

# DMU chosen as Winchester. It can be changed to any DMU
maximize objective_fn:
    sum {r in OUTATTR} outputs["Winchester", r] * wout[r] ;