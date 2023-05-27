set FACTORIES;
set DEPOTS;
set CUSTOMERS;

set CITIES = FACTORIES union DEPOTS union CUSTOMERS;

set ARCS within {CITIES, CITIES};

param supply {FACTORIES} > 0;
param through {DEPOTS} > 0;
param demand {CUSTOMERS} > 0;
param opencost {DEPOTS} >= 0;

param cost {ARCS} > 0;

param save_closing = -(opencost["Newcastle"] + opencost["Exeter"]) ;


#       DECISION   VARIABLES        #

var flow {ARCS} >= 0;

var open {DEPOTS} binary;

var expand binary;

subject to fix_constraint:
    forall {d in DEPOTS : d = "Birmingham" or d = "London"} open[d] = 1;


#       CONSTRAINTS                #

# Production capacity limits
subject to production_capacity_constraint {f in FACTORIES}:
    sum {(f, j) in ARCS} flow[f, j] <= supply[f] ;

# Customer demand
subject to customer_demand_constraint {c in CUSTOMERS}:
    sum {(j, c) in ARCS} flow[j, c] = demand[c] ;


# Depot flow conservation
subject to depot_flow_conservation_constraint {d in DEPOTS}:
    sum {(d, j) in ARCS} flow[d, j] = sum {(k, d) in ARCS} flow[k,d] ;


# Depot throughput
# All but Birmingham
subject to depot_throughput_constraint {d in DEPOTS : d <> "Birmingham"}:
    sum {(d, j) in ARCS} flow[d, j] <= through[d] * open[d] ;


subject to birmingham_capacity_constraint:
    sum {(j, "Birmingham") in ARCS} flow[j, "Birmingham"] <= through['Birmingham'] + (20000 * expand) ;


subject to depot_count_constraint:
    sum {d in DEPOTS} open[d] <= 4 ;



#     OBJECTIVE   FUNCTION      #   
minimize cost_minimize:
        sum {(i, j) in ARCS} flow[i, j] * cost[i, j]
    +   sum {d in DEPOTS} open[d] * opencost[d]
    +   (expand * 3000)
    +   save_closing ;
