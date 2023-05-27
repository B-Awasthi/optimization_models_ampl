set DAIRY;
set COMPONENTS;

set COMP_DAIRY within {COMPONENTS, DAIRY} ;

param qtyper {COMP_DAIRY} > 0 ;
param capacity {COMPONENTS} > 0 ;

param consumption {DAIRY} > 0 ;
param price {DAIRY} > 0 ;
param elasticity {DAIRY} > 0 ;

param elasticity12 > 0 ;
param elasticity21 > 0 ;
param priceIndex > 0;


#   DECISION  VARIABLES   #

# Quantity of dairy products.
var qvar {DAIRY} >= 0;

# Price of dairy products.
var pvar {DAIRY} >= 0;


#   CONSTRAINTS   #


# Capacity constraint.
subject to capacity_constraint {c in COMPONENTS}:
    sum {d in DAIRY} qtyper[c,d] * qvar[d] <= capacity[c] ;

# Price index constraint.
subject to price_index_constraint:
    sum {d in DAIRY} consumption[d] * pvar[d] <= priceIndex ;

# Elasticity constraints
subject to elasMilk_constraint:
    (qvar['milk'] - consumption['milk']) / consumption['milk'] 
    = - elasticity['milk'] * (pvar['milk'] - price['milk']) / price['milk'] ;

subject to elasButter_constraint:
    (qvar['butter'] - consumption['butter']) / consumption['butter']  
    = - elasticity['butter'] * (pvar['butter']-price['butter']) / price['butter'] ;

subject to elasCheese1_constraint:
    (qvar['cheese1'] - consumption['cheese1']) / consumption['cheese1'] 
    =  - (elasticity['cheese1'] * (pvar['cheese1'] - price['cheese1']) / price['cheese1'])
       + (elasticity12 * (pvar['cheese2'] - price['cheese2']) / price['cheese2']) ;

subject to elasCheese2_constraint:
    (qvar['cheese2']-consumption['cheese2'])/consumption['cheese2'] 
    = - (elasticity['cheese2'] * (pvar['cheese2'] - price['cheese2']) / price['cheese2'])
      + (elasticity21 * (pvar['cheese1'] - price['cheese1']) / price['cheese1']) ;


#    OBJECTIVE FUNCTION    #


maximize revenue:
    sum {d in DAIRY} qvar[d] * pvar[d] ;
