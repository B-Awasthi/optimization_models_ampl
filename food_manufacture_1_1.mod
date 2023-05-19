set OIL_TYPE;
set OILS {OIL_TYPE};

set ALL_OILS = union {i in OIL_TYPE} OILS[i];

param prices {ALL_OILS} > 0;
param hardness {ALL_OILS} > 0;
param production_capacity {OIL_TYPE};
param revenue > 0;
param hardness_lb > 0;
param hardness_ub > 0;

var Quantity_brought {ALL_OILS} >= 0;
var Quantity_made >= 0;

maximize total_profits: - sum {o in ALL_OILS} prices[o] * Quantity_brought[o] + Quantity_made * revenue;

subject to production_cap_constraint {i in OIL_TYPE}:
    sum {o in OILS[i]} Quantity_brought[o] <= production_capacity[i];

subject to hardness_constraint_1: 
    sum {o in ALL_OILS} hardness[o] * Quantity_brought[o] >= hardness_lb * Quantity_made;

subject to hardness_constraint_2: 
    sum {o in ALL_OILS} hardness[o] * Quantity_brought[o] <= hardness_ub * Quantity_made;

subject to balance_constraint:
    sum {o in ALL_OILS} Quantity_brought[o] = Quantity_made;
