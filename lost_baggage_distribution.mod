param n > 0 ;
param vns > 0 ;

set LOCATIONS ;
set VANS = 0 .. vns - 1;
set ARCS within {LOCATIONS, LOCATIONS} ;

param point_x {LOCATIONS} >= 0;
param point_y {LOCATIONS} >= 0;

param time {ARCS} > 0;

param vehc_capacity = 50;

suffix objpriority >= 0 integer;

#       DECISION    VARIABLES        #
var x {ARCS, VANS} binary ;

var y {LOCATIONS, VANS} binary ;

# Number of vans used is a decision variable
var z {VANS} binary ;

# Travel time per van
var t {VANS} >= 0, <= 120 ;

# Maximum travel time
var s >= 0 ;

var u {i in LOCATIONS : i > 0} >= 0 ;


#       CONSTRAINTS             #

# Van utilization constraint
subject to van_utilization_constraint {i in LOCATIONS, k in VANS : i > 0}:
    y[i,k] <= z[k] ;

# Travel time constraint
# Exclude the time to return to the depot
subject to travel_time_constraint {k in VANS}:
    t[k] = sum {(i, j) in ARCS : j > 0} (time[i, j] * x[i, j, k]) ;


# Visit all customers
subject to visit_all_customers {i in LOCATIONS : i > 0}:
    sum {k in VANS} y[i, k] = 1 ;


# Depot constraint
subject to depot_constraint {k in VANS}:
    y[0, k] = z[k] ;

# Arriving at a customer location constraint
subject to arr_cust_loc_constraint {j in LOCATIONS, k in VANS}:
    sum {(i, j) in ARCS} x[i, j, k] = y[j, k] ;


# Leaving a customer location constraint
subject to leave_cust_loc_constraint {j in LOCATIONS, k in VANS}:
    sum {(j, i) in ARCS} x[j, i, k] = y[j, k] ;


subject to break_symmetry_constraint {k in VANS : k > 0}:
    sum {i in LOCATIONS} y[i, k - 1] >= sum {i in LOCATIONS} y[i, k] ;


# subject to maxTravelTime_constraint {k in VANS}:
#     t[k] <= s ;

subject to maxTravelTime_constraint:
    s = max {k in VANS} t[k] ;

# MTZ FORMULATION to eliminate sub-tours #
subject to mtz_constraint_1 {k in VANS, i in LOCATIONS, j in LOCATIONS : i <> j and i > 0 and j > 0}:
    u[j] - u[i] >= 1 - vehc_capacity * (1 - x[i, j, k]) ;

subject to mtz_constraint_2 {i in LOCATIONS : i > 0}:
    1 <= u[i] <= vehc_capacity ;


#       OBJECTIVE   FUNCTION        #
minimize max_time_limit:
    s ;

minimize number_of_vans_used:
    sum {k in VANS} z[k] ;

# let max_time_limit.objpriority := 1 ;
# let vns := 6;
# let number_of_vans_used.objpriority := 2 ;

# option solver gurobiasl;
# option gurobiasl_options 'multiobj=1';
# option gurobiasl_options 'outlev 1';