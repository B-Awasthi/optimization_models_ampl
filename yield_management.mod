set CLASSES;
set OPTIONS;
set SCENARIOS;


set CLASS_OPT within {CLASSES, OPTIONS} ;
set SCEN_CLASS_OPT within {SCENARIOS, CLASSES, OPTIONS} ;
set IJCH within {SCENARIOS, SCENARIOS, CLASSES, OPTIONS} ;
set IJKCH within {SCENARIOS, SCENARIOS, SCENARIOS, CLASSES, OPTIONS} ;
set IJK within {SCENARIOS, SCENARIOS, SCENARIOS} ;
set IJKC within {SCENARIOS, SCENARIOS, SCENARIOS, CLASSES} ;

param price1 {CLASS_OPT} > 0;
param price2 {CLASS_OPT} > 0;
param price3 {CLASS_OPT} > 0;

param fcst1 {SCEN_CLASS_OPT} > 0;
param fcst2 {SCEN_CLASS_OPT} > 0;
param fcst3 {SCEN_CLASS_OPT} > 0;

param demand1 {CLASS_OPT} > 0;
param demand2 {CLASS_OPT} > 0;
param demand3 {CLASS_OPT} > 0;

param prob {SCENARIOS} > 0;
param cap {CLASSES} > 0;

param cost > 0;

#          DECISION    VARIABLES           #
# Decision variables

# price option binary variables at each week
var p1ch {CLASS_OPT} binary;

var p2ich {SCEN_CLASS_OPT} binary;

var p3ijch {IJCH} binary;

# # tickets to be sold at each week
var s1ich {SCEN_CLASS_OPT} >= 0;

var s2ijch {IJCH} >= 0;

var s3ijkch {IJKCH} >= 0;

# # number of planes to fly
var n >= 0 integer, <= 6;


#       CONSTRAINTS             #
# Price option constraints for week 1
subject to priceOption1_constraint {c in CLASSES}:
    sum {h in OPTIONS} p1ch[c,h] = 1 ;

# sales constraints for week 1
subject to sales1_constraint {(i,c,h) in SCEN_CLASS_OPT}:
    s1ich[i,c,h] <= fcst1[i,c,h] * p1ch[c,h] ;

# Price option constraints for week 2
subject to priceOption2_constraint {i in SCENARIOS, c in CLASSES}:
    sum {h in OPTIONS} p2ich[i,c,h] = 1 ;

# sales constraints for week 2
subject to sales2_constraint {(i,j,c,h) in IJCH}:
    s2ijch[i,j,c,h] <= fcst2[j,c,h] * p2ich[i,c,h] ;

# Price option constraints for week 3
subject to priceOption3_constraint {i in SCENARIOS, j in SCENARIOS, c in CLASSES}:
    sum {h in OPTIONS} p3ijch[i,j,c,h] = 1 ;

# sales constraints for week 3
subject to sales3_constraint {(i,j,k,c,h) in IJKCH}:
    s3ijkch[i,j,k,c,h] <= fcst3[k,c,h] * p3ijch[i,j,c,h] ;

# Class capacity constraints
subject to classCap_constraint {(i,j,k,c) in IJKC}:
    sum {h in OPTIONS} s1ich[i,c,h] + sum {h in OPTIONS} s2ijch[i,j,c,h] + sum {h in OPTIONS} s3ijkch[i,j,k,c,h] <= cap[c] * n ;

#           OBJECTIVE   FUNCTION            #

maximize obj:
    sum {(i,c,h) in SCEN_CLASS_OPT} prob[i] * price1[c,h] * p1ch[c,h] * s1ich[i,c,h]
    + sum {(i,j,c,h) in IJCH} prob[i] * prob[j] * price2[c,h] * p2ich[i,c,h] * s2ijch[i,j,c,h]
    + sum {(i,j,k,c,h) in IJKCH} prob[i] * prob[j] * prob[k] * price3[c,h] * p3ijch[i,j,c,h] * s3ijkch[i,j,k,c,h]
    - cost * n ;