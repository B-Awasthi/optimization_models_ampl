set TYPES;
set PERIODS;
set HYDRO_UNITS;

param maxstart0 > 0;
param generators {TYPES} > 0;

param period_hours {PERIODS} > 0;
param demand {PERIODS} > 0;
param min_load {TYPES} > 0;
param max_load {TYPES} > 0;
param base_cost {TYPES} > 0;
param per_mw_cost {TYPES} > 0;
param startup_cost {TYPES} > 0;

param hydro_load {HYDRO_UNITS} > 0;
param hydro_cost {HYDRO_UNITS} > 0;
param hydro_height_reduction {HYDRO_UNITS} > 0;
param hydro_startup_cost {HYDRO_UNITS} > 0;


#       DECISION  VARIABLES     #
var ngen {TYPES, PERIODS} >= 0 integer;
var nstart {TYPES, PERIODS} >= 0 integer;
var output {TYPES, PERIODS} >= 0;

var hydro {HYDRO_UNITS, PERIODS} binary;
var hydrostart {HYDRO_UNITS, PERIODS} binary;

var pumping {PERIODS} >= 0;

var height {PERIODS} >= 0;


#       CONSTRAINTS             #

# Generator count
subject to generator_count_constraint {p in PERIODS, t in TYPES}:
    ngen[t, p] <= generators[t] ;

# Respect minimum and maximum output per generator type
subject to min_output_constraint {p in PERIODS, t in TYPES}:
    output[t, p] >= min_load[t] * ngen[t, p] ;

subject to max_output_constraint {p in PERIODS, t in TYPES}:
    output[t, p] <= max_load[t] * ngen[t, p] ;

# Meet demand
subject to meet_demand_constraint {p in PERIODS}:
        sum {t in TYPES} output[t, p]
    +   sum {h in HYDRO_UNITS} hydro_load[h] * hydro[h, p]
    >=   demand[p] + pumping[p] ;


# Reservoir levels
subject to reservoir_levels_constraint {p in PERIODS : p > 1}:
    height[p] = height[p - 1] + period_hours[p] * pumping[p]/3000 
              - sum {h in HYDRO_UNITS} hydro_height_reduction[h] * period_hours[p] * hydro[h, p] ;

# cyclic - height at end must equal height at beginning
subject to reservoir0_levels_constraint:
    height[1] = height[card(PERIODS)] + period_hours[1] * pumping[1]/3000
              - sum {h in HYDRO_UNITS} hydro_height_reduction[h] * period_hours[1] * hydro[h, 1] ;


# Provide sufficient reserve capacity
subject to suff_reserve_capacity_constraint {p in PERIODS}:
    sum {t in TYPES} max_load[t] * ngen[t, p] >= 1.15 * demand[p] - sum {h in HYDRO_UNITS} hydro_load[h] ;


# Startup constraint
subject to startup0_constraint {t in TYPES}:
    ngen[t, 1] <= maxstart0 + nstart[t, 1] ;

subject to startup_constraint {p in PERIODS, t in TYPES : p > 1}:
    ngen[t, p] <= ngen[t, p - 1] + nstart[t, p] ;

# Hydro startup constraint
subject to hydro_startup0_constraint {h in HYDRO_UNITS}:
    hydro[h, 1] <= hydrostart[h, 1] ;

subject to hydro_startup_constraint {p in PERIODS, h in HYDRO_UNITS : p > 1}:
    hydro[h, p] <= hydro[h, p - 1] + hydrostart[h, p] ;


#         OBJECTIVE   FUNCTION          #

var active = sum {p in PERIODS, t in TYPES}
                base_cost[t] * period_hours[p] * ngen[t, p] ;

var per_mw = sum {p in PERIODS, t in TYPES}
                per_mw_cost[t] * period_hours[p] * (output[t, p] - min_load[t] * ngen[t, p]) ;

var startup_obj = sum {p in PERIODS, t in TYPES}
                    startup_cost[t] * nstart[t, p] ;

var hydro_active = sum {p in PERIODS, h in HYDRO_UNITS}
                    hydro_cost[h] * period_hours[p] * hydro[h, p] ;

var hydro_startup = sum {p in PERIODS, h in HYDRO_UNITS}
                      hydro_startup_cost[h] * hydrostart[h, p] ;

minimize cost:
    active + per_mw + startup_obj + hydro_active + hydro_startup ;