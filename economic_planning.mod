set IND;
set HORIZON;
set FIVE_YEARS;

set YEARS_2_4 = {i in FIVE_YEARS : i >= 2 and i <= 4};

set ARCS within {IND, IND};

param inout_prod {ARCS} > 0;
param labor_prod {IND} > 0;
param inout_cap {ARCS} > 0;

param labor_extra_cap {IND} > 0;

param stock0 {IND} > 0;
param capacity0 {IND} > 0;
param demand {IND} > 0;

param static_prod {IND} > 0;

set i2h = IND cross HORIZON;
set i2f = IND cross FIVE_YEARS;


#  DECISION  VARIBALES  #

var production {i2h} >= 0;

subject to no_production_year_1:
    sum {(i, j) in i2h : j = 1} production[i, j] = 0;

var stock {i2f} >= 0;

var extra_cap {i2h} >= 0;

subject to no_extra_cap_yr_1_2:
    sum {(i, j) in i2h : j < 3} extra_cap[i,j] = 0;

#  CONSTRAINTS #

# Year 1 balance equations 
subject to balance_1_constraints {i in IND}:
    stock0[i] =     sum {j in IND} (inout_prod[i,j] * production[j,2])
                +   sum {j in IND} (inout_cap[i,j] * extra_cap[j,3])
                +   (demand[i] + stock[i,1]) ;

# Balance equations for years 2,3, and 4
subject to balance_t_constraints {i in IND, yr in YEARS_2_4}:
    production[i, yr] + stock[i, yr-1] =    sum {j in IND} (inout_prod[i,j] * production[j, yr + 1])
                                        +   sum {j in IND} (inout_cap[i,j] * extra_cap[j, yr + 2])
                                        +   (demand[i] + stock[i, yr]) ;

# Balance equations for year 5
subject to balance_5_constraint {i in IND}:
    production[i, 5] + stock[i,4] =     sum {j in IND} (inout_prod[i,j] * production[j,6])
                                    +   (demand[i] + stock[i,5]) ;
    

# Steady state production for year 6 and beyond
subject to steadyProduction_constraint {j in IND}:
    production[j,6] - static_prod[j] >= 0;

# Zero increased capacity for year 6 and beyond
subject to zero_inc_cap_yr_6:
    sum {(i, j) in i2h : j = 6} extra_cap[i, j] = 0;


# Productive capacity constraints
subject to productive_capacity_constraint {(i, j) in i2f}:
    production[i, j] - sum {t in FIVE_YEARS : t <= j} extra_cap[i, t] <= capacity0[i] ;


#  OBJECTIVE  FUNCTION #
maximize employment:
        sum {j in IND, t in FIVE_YEARS} (labor_prod[j] * production[j,t])
    +   sum {j in IND, t in FIVE_YEARS} (labor_extra_cap[j] * extra_cap[j,t]) ;