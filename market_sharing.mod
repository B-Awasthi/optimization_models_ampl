set RETAILERS;
set RETAILERS_1;
set RETAILERS_2;
set RETAILERS_3;
set GROUP_A;
set GROUP_B;

param deliveryPoints {RETAILERS} > 0;
param spiritMarket {RETAILERS} >= 0;
param oilMarket1 {RETAILERS_1} > 0;
param oilMarket2 {RETAILERS_2} > 0;
param oilMarket3 {RETAILERS_3} > 0;
param retailerA {GROUP_A} > 0;
param retailerB {GROUP_B} > 0;

param  deliveryPoints40 > 0;
param  deliveryPoints5 > 0;
param  spiritMarket40 > 0;
param  spiritMarket5 > 0;
param  oilMarket1_40 > 0;
param  oilMarket1_5 > 0;
param  oilMarket2_40 > 0;
param  oilMarket2_5 > 0;
param  oilMarket3_40 > 0;
param  oilMarket3_5 > 0;
param  retailerA40 > 0;
param  retailerA5 > 0;
param  retailerB40 > 0;
param  retailerB5 > 0;


#       DECISION      VARIABLES         #

#  Allocation of retailers to Division 1.
var allocate {RETAILERS} binary;

# Positive and negative deviation of delivery points goal.
var deliveryPointsPos >= 0, <= deliveryPoints5;
var deliveryPointsNeg >= 0, <= deliveryPoints5;

# Positive and negative deviation of spirit market goal.
var spiritMarketPos >= 0, <= spiritMarket5;
var spiritMarketNeg >= 0, <= spiritMarket5;

# Positive and negative deviation of oil market in region 1 goal.
var oilMarket1Pos >= 0, <= oilMarket1_5;
var oilMarket1Neg >= 0, <= oilMarket1_5;

# Positive and negative deviation of oil market in region 2 goal.
var oilMarket2Pos >= 0, <= oilMarket2_5;
var oilMarket2Neg >= 0, <= oilMarket2_5;

# Positive and negative deviation of oil market in region 3 goal.
var oilMarket3Pos >= 0, <= oilMarket3_5;
var oilMarket3Neg >= 0, <= oilMarket3_5;

# Positive and negative deviation of retailers in group A goal.
var retailerAPos >= 0, <= retailerA5;
var retailerANeg >= 0, <= retailerA5;

# Positive and negative deviation of retailers in group B goal.
var retailerBPos >=0, <= retailerB5;
var retailerBNeg >= 0, <= retailerB5;


#           CONSTRAINTS             #
# Delivery points constraint.
subject to DPConstr:
    sum {r in RETAILERS} deliveryPoints[r] * allocate[r] + deliveryPointsPos - deliveryPointsNeg = deliveryPoints40 ;

# Spirit market constraint.
subject to SMConstr:
    sum {r in RETAILERS} spiritMarket[r] * allocate[r] + spiritMarketPos - spiritMarketNeg = spiritMarket40;

# Oil market in region 1 constraint.
subject to OM1Constr:
    sum {r in RETAILERS_1} oilMarket1[r] * allocate[r] + oilMarket1Pos - oilMarket1Neg = oilMarket1_40;

# Oil market in region 2 constraint.
subject to OM2Constr:
    sum {r in RETAILERS_2} oilMarket2[r] * allocate[r] + oilMarket2Pos - oilMarket2Neg = oilMarket2_40;

# Oil market in region 3 constraint.
subject to OM3Constr:
    sum {r in RETAILERS_3} oilMarket3[r] * allocate[r] + oilMarket3Pos - oilMarket3Neg = oilMarket3_40;

# Group A constraint.
subject to AConstr:
    sum {r in GROUP_A} retailerA[r] * allocate[r] + retailerAPos - retailerANeg = retailerA40;

# Group B constraint.
subject to BConstr:
    sum {r in GROUP_B} retailerB[r] * allocate[r] + retailerBPos - retailerBNeg == retailerB40;

#       OBJECTIVE       FUNCTION            #
minimize sum_pos_neg_deviations:
    deliveryPointsPos + deliveryPointsNeg+ spiritMarketPos + spiritMarketNeg + oilMarket1Pos + oilMarket1Neg + oilMarket2Pos + oilMarket2Neg + oilMarket3Pos + oilMarket3Neg + retailerAPos + retailerANeg + retailerBPos + retailerBNeg ;


