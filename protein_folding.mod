param num_acids > 0;
set ACIDS = 1 .. num_acids ;
set H_PHOBIC ;

set IND_HP within {H_PHOBIC, H_PHOBIC} ;
set IK1J;
set IK2J;
set IJ_FOLD;

param list_1_i {IK1J} ;
param list_1_k1 {IK1J} ;
param list_1_j {IK1J} ;

param list_2_i {IK2J} ;
param list_2_k2 {IK2J} ;
param list_2_j {IK2J} ;

param list_3_i {IJ_FOLD} ;
param list_3_j {IJ_FOLD} ;


#        DECISION    VARIABLES      #

# Matching variables
var match {IND_HP} binary ;

# Folding variables
var fold {ACIDS} binary ;

#        CONSTRAINTS                #

# Constraint 1:
subject to C1_constraint {p in IK1J}:
    fold[list_1_j[p]] + match[list_1_i[p], list_1_k1[p]] <= 1 ;

# Constraint 2:
subject to C2_constraint {p in IK2J}:
    match[list_2_i[p], list_2_k2[p]] <= fold[list_2_j[p]] ;


#       OBJECTIVE   FUNCTION         #

maximize obj1:
    sum {p in IJ_FOLD} match[list_3_i[p], list_3_j[p]] ;