set TYPES;
set PERIODS;

param maxstart0 > 0;
param generators {TYPES} > 0;

param period_hours {PERIODS} > 0;
param demand {PERIODS} > 0;
param min_load {TYPES} > 0;
param max_load {TYPES} > 0;
param base_cost {TYPES} > 0;
param per_mw_cost {TYPES} > 0;
param startup_cost {TYPES} > 0;


#       DECISION  VARIABLES     #
var ngen {TYPES, PERIODS} >= 0 integer;
var nstart {TYPES, PERIODS} >= 0 integer;
var output {TYPES, PERIODS} >= 0;


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
    sum {t in TYPES} output[t, p] >= demand[p] ;

# Provide sufficient reserve capacity
subject to suff_reserve_capacity_constraint {p in PERIODS}:
    sum {t in TYPES} max_load[t] * ngen[t, p] >= 1.15 * demand[p] ;

# Startup constraint
subject to startup0_constraint {t in TYPES}:
    ngen[t, 1] <= maxstart0 + nstart[t, 1] ;

subject to startup_constraint {p in PERIODS, t in TYPES : p > 1}:
    ngen[t, p] <= ngen[t, p - 1] + nstart[t, p] ;


#           OBJECTIVE   FUNCTION            #

var active = sum {p in PERIODS, t in TYPES}
                base_cost[t] * period_hours[p] * ngen[t, p] ;

var per_mw = sum {p in PERIODS, t in TYPES}
                per_mw_cost[t] * period_hours[p] * (output[t, p] - min_load[t] * ngen[t, p]) ;

var startup_obj = sum {p in PERIODS, t in TYPES}
                    startup_cost[t] * nstart[t, p] ;

minimize cost:
    active + per_mw + startup_obj;