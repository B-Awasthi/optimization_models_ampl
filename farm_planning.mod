set YEARS;
set LANDS;
set AGES;
set COW_AGES;

param gr_area {LANDS} > 0;
param gr_yield {LANDS} > 0;

param sb_yield ;
param housing_cap ;
param gr_intake ;
param sb_intake ;
param hf_land ;
param land_cap ;
param hf_labor ;
param cow_labor ;
param gr_labor ;
param sb_labor ;
param labor_cap ;
param cow_decay ;
param hf_decay ;
param initial_hf ;
param initial_cows ;
param birthrate ;
param min_final_cows ;
param max_final_cows ;
param bl_price ;
param hf_price ;
param cow_price ;
param milk_price ;
param gr_price ;
param sb_price ;
param gr_cost ;
param sb_cost ;
param overtime_cost ;
param regular_time_cost ;
param hf_cost ;
param cow_cost ;
param gr_land_cost ;
param sb_land_cost ;
param installment ;

#           DECSION     VARIABLES       #
var sb {YEARS} >= 0;
var gr_buy {YEARS} >= 0;
var gr_sell {YEARS} >= 0;
var sb_buy {YEARS} >= 0;
var sb_sell {YEARS} >= 0;
var overtime {YEARS} >= 0;
var outlay {YEARS} >= 0;
var hf_sell {YEARS} >= 0;
var newborn {YEARS} >= 0;
var profit {YEARS} >= 0;
var gr {YEARS, LANDS} >= 0;
var cows {YEARS, AGES} >= 0;


#          CONSTRAINTS          #
# 1. Housing capacity
subject to housing_capacity_constraint {year in YEARS}:
        newborn[year] + cows[year,1] 
    +   sum {age in COW_AGES} cows[year,age] 
    -   sum {d in YEARS : d <= year} outlay[d] <= housing_cap ;

# 2.1 Food consumption (Grain)
subject to GrainConsumption_constraint {year in YEARS}:
    sum {age in COW_AGES} gr_intake*cows[year, age] <= gr_buy[year] - gr_sell[year] + sum {l in LANDS} gr[year, l] ;

# 2.1 Food consumption (Sugar beet)
subject to SugarbeetConsumption_constraint {year in YEARS}:
    sum {age in COW_AGES} sb_intake*cows[year, age] <= sb_buy[year] - sb_sell[year] + sb[year] ;

# 3. Grain growing
subject to GrainGrowing_constraint {year in YEARS, land in LANDS}:
    gr[year, land] <= gr_yield[land]*gr_area[land] ;

# 4. Land capacity
subject to LandCapacity_constraint {year in YEARS}:
        (sb[year]/sb_yield) + hf_land*(newborn[year] + cows[year,1])
    +   sum {land in LANDS} (1/gr_yield[land])*gr[year, land]
    +   sum {age in COW_AGES} cows[year, age] <= land_cap ;


# 5. Labor
subject to Labor_constraint {year in YEARS}:
        hf_labor*(newborn[year] + cows[year,1])
    +   sum {age in COW_AGES} cow_labor*cows[year, age]
    +   sum {land in LANDS} gr_labor/gr_yield[land]*gr[year,land]
    +   sb_labor/sb_yield*sb[year] <= labor_cap + overtime[year] ;

# 6.1 Continuity
subject to Continuity1_constraint {year in YEARS : year > 1}:
    cows[year,1] = (1-hf_decay)*newborn[year-1] ;

# 6.2 Continuity
subject to Continuity2_constraint {year in YEARS : year > 1}:
    cows[year,2] = (1-hf_decay)*cows[year-1,1] ;

# 6.3 Continuity
subject to Continuity3_constraint {year in YEARS, age in COW_AGES : year > 1}:
    cows[year,age+1] = (1-cow_decay)*cows[year-1,age] ;


# 7. Heifers birth
subject to Heifers_birth_constraint {year in YEARS}:
    newborn[year] + hf_sell[year] = sum {age in COW_AGES} birthrate/2*cows[year,age] ;

# 8. Final dairy cows
subject to FinalDairyCows_constraint:
    min_final_cows <= sum {age in COW_AGES} cows[5, age] <= max_final_cows ;


# 9.1-9.2 Initial conditions
subject to InitialHeifers_constraint {age in AGES : age < 3}:
    initial_hf = cows[1, age] ;

# 9.3 Initial conditions
subject to InitialCows_constraint {age in AGES : age >= 3}:
    initial_cows = cows[1, age] ;

# 10. Yearly profit
subject to YearlyProfit_constraint {year in YEARS}:
    profit[year] = bl_price * birthrate/2* sum {age in COW_AGES} cows[year, age]
                +  hf_price*hf_sell[year] + cow_price*cows[year, 12]
                +  milk_price*sum {age in COW_AGES} cows[year, age]
                +  gr_price*gr_sell[year] + sb_price*sb_sell[year]
                -  gr_cost*gr_buy[year] - sb_cost*sb_buy[year]
                -  overtime_cost*overtime[year] - regular_time_cost
                -  hf_cost*(newborn[year] + cows[year,1])
                -  cow_cost*sum {age in COW_AGES} cows[year, age]
                -  gr_land_cost* sum {land in LANDS} gr[year, land]/gr_yield[land]
                -  sb_land_cost*sb[year]/sb_yield
                -  installment*sum {d in YEARS : d <= year} outlay[d] ;


#           OBJECTIVE       FUNCTION            #
maximize total_profit:
    sum {year in YEARS} profit[year] - sum {year in YEARS} installment*(year+4)*outlay[year];