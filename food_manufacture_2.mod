set MONTHS ordered;
set OIL_TYPE;
set OILS {OIL_TYPE};

set ALL_OILS = union {i in OIL_TYPE} OILS[i];

param hardness {ALL_OILS} > 0;
param production_capacity {OIL_TYPE};
param cost {MONTHS, ALL_OILS};
param revenue > 0;
param hardness_lb > 0;
param hardness_ub > 0;
param init_store > 0;
param target_store > 0;
param holding_cost > 0;
param min_consume > 0;
param max_ingredients > 0;

param ub_consume = max {i in OIL_TYPE} production_capacity[i];


# DECISION  VARIBLES #
var produce {MONTHS} >= 0;
var buy {MONTHS, ALL_OILS} >= 0;
var consume {MONTHS, ALL_OILS} >= 0, <= ub_consume;
var store {MONTHS, ALL_OILS} >= 0;
var use {MONTHS, ALL_OILS} binary;

# CONSTRAINTS #

# 1.
subject to initial_balance_constraint {ol in ALL_OILS}:
    init_store + buy[first(MONTHS), ol] = consume[first(MONTHS), ol] + store[first(MONTHS), ol];

# 2.
subject to balance_constraint {ol in ALL_OILS, mth in MONTHS : ord(mth) > 1}:
    store[prev(mth), ol] + buy[mth, ol] = consume[mth, ol] + store[mth, ol];

# 3.
subject to inventory_target_constraint {ol in ALL_OILS}:
    store[last(MONTHS), ol] = target_store;

# 4.
subject to vegetable_oil_capacity_constraint {mth in MONTHS, oltyp in OIL_TYPE}:
    sum {ol in OILS[oltyp]} consume[mth, ol] <= production_capacity[oltyp];

# 5.1
subject to hardness_min_constraint {mth in MONTHS}:
    sum {ol in ALL_OILS} hardness[ol] * consume[mth, ol] >= hardness_lb * produce[mth];

# 5.2
subject to hardness_max_constraint {mth in MONTHS}:
    sum {ol in ALL_OILS} hardness[ol] * consume[mth, ol] <= hardness_ub * produce[mth];

# 6.
subject to mass_conservation_constraint {mth in MONTHS}:
    sum {ol in ALL_OILS} consume[mth, ol] = produce[mth];

# 7. if any product is used in any period then at least 20 tons is used
# subject to consumption_range_constraint_1 {ol in ALL_OILS, mth in MONTHS}:
#     use[mth, ol] = 0 ==> consume[mth, ol] = 0;
# subject to consumption_range_constraint_2 {ol in ALL_OILS, mth in MONTHS}:
#     use[mth, ol] = 1 ==> consume[mth, ol] >= min_consume;

subject to consumption_range_constraint_1 {ol in ALL_OILS, mth in MONTHS}:
    use[mth, ol] = 0 ==> consume[mth, ol] = 0 else consume[mth, ol] >= min_consume;


# 8. each final product is only made up of at most three ingredients
subject to recipe_constraint {mth in MONTHS}:
    sum {ol in ALL_OILS} use[mth, ol] <= max_ingredients;

# 9. if vegetable one or vegetable two are used, then oil three must also be used
subject to if_then_constraint_1 {mth in MONTHS}:
    use[mth, "VEG1"] = 1 ==> use[mth, "OIL3"] = 1;

subject to if_then_constraint_2 {mth in MONTHS}:
    use[mth, "VEG2"] = 1 ==> use[mth, "OIL3"] = 1;

# OBJECTIVE FUNCTION
maximize total_profits: 
    revenue * sum {mth in MONTHS} produce[mth] 
    - sum {mth in MONTHS, ol in ALL_OILS} cost[mth, ol] * buy[mth, ol]
    - holding_cost * sum {mth in MONTHS, ol in ALL_OILS} store[mth, ol];
