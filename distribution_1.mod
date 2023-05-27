set FACTORIES;
set DEPOTS;
set CUSTOMERS;

set CITIES = FACTORIES union DEPOTS union CUSTOMERS;

set ARCS within {CITIES, CITIES};

param supply {FACTORIES} > 0;
param through {DEPOTS} > 0;
param demand {CUSTOMERS} > 0;

param cost {ARCS} > 0;


#      DECISION   VARIABLES     #
var flow {ARCS} >= 0 ;


#      CONSTRAINTS      #

# Production capacity limits
subject to production_capacity_constraint {fact in FACTORIES}:
    sum {(fact, j) in ARCS} flow[fact, j] <= supply[fact] ;


# Customer demand
subject to customer_demand_constraint {cust in CUSTOMERS}:
    sum {(j, cust) in ARCS} flow[j, cust] = demand[cust] ;


# Depot flow conservation
subject to flow_conservation_constraint {depot in DEPOTS}:
    sum {(depot, j) in ARCS} flow[depot, j] = sum {(k, depot) in ARCS} flow[k, depot] ;


# Depot throughput
subject to depot_throughput_constraint {depot in DEPOTS}:
    sum {(j, depot) in ARCS} flow[j, depot] <= through[depot] ;


#     OBJECTIVE   FUNCTION      #   
minimize cost_minimize:
    sum {(i, j) in ARCS} flow[i, j] * cost[i, j] ;
