set MONTHS ordered;

set PRODUCTS;
set MACHINES;
set LINKS_MACH_PROD within {MACHINES, PRODUCTS};

param profits {PRODUCTS} >= 0;
param time_req {LINKS_MACH_PROD} >= 0;
param down {MACHINES} >= 0;
param max_sales {MONTHS, PRODUCTS} >= 0;
param installed {MACHINES} >= 0;

param holding_cost >= 0;
param max_inventory >= 0;
param store_target >= 0;
param hours_per_month >= 0;


# DECISION  VARIBLES #
var make {MONTHS, PRODUCTS} >= 0;
var store {MONTHS, PRODUCTS} >= 0, <= max_inventory;
var sell {i in MONTHS, j in PRODUCTS} >= 0, <= max_sales[i, j];
var repair {i in MONTHS, j in MACHINES} >= 0 integer, <= down[j];

# CONSTRAINTS #

#1. Initial Balance
subject to initial_balance_constraint {prd in PRODUCTS}:
    make[first(MONTHS), prd] = sell[first(MONTHS), prd] + store[first(MONTHS), prd];

#2. Balance
subject to balance_constraint {prd in PRODUCTS, mth in MONTHS : ord(mth) > 1}:
    store[prev(mth), prd] + make[mth, prd] = sell[mth, prd] + store[mth, prd];

#3. Inventory Target
subject to inventory_target_constraint {prd in PRODUCTS}:
    store[last(MONTHS), prd] = store_target;

#4. Machine Capacity
subject to machine_capacity_constraint {mach in MACHINES, mth in MONTHS}:
    sum {(mach, j) in LINKS_MACH_PROD} time_req[mach, j] * make[mth, j] <= hours_per_month * (installed[mach] - repair[mth, mach]);

#5. Maintenance
subject to maintainance_constraint {mach in MACHINES}:
    sum {mth in MONTHS} repair[mth, mach] = down[mach];

# OBJECTIVE FUNCTION #
maximize total_profits:
    sum {mth in MONTHS, prd in PRODUCTS} (profits[prd] * sell[mth, prd]) 
    - sum {mth in MONTHS, prd in PRODUCTS} (holding_cost * store[mth, prd]);


