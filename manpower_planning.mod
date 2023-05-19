set YEARS;
set SKILLS ordered;

param curr_workforce {SKILLS} > 0;
param demand {YEARS, SKILLS} >= 0;
param rookie_attrition {SKILLS} >= 0;
param veteran_attrition {SKILLS} >= 0;
param demoted_attrition >= 0;

param max_hiring {YEARS, SKILLS} >= 0;

param max_overmanning > 0;
param max_parttime > 0;
param parttime_cap > 0;
param max_train_unskilled > 0;
param max_train_semiskilled > 0;

param training_cost {i in SKILLS : i <> "skilled"} > 0;

param layoff_cost {SKILLS} > 0;
param parttime_cost {SKILLS} > 0;
param overmanning_cost {SKILLS} > 0;

# DECISION VARIABLES #
var hire {y in YEARS, s in SKILLS} >=0 , <= max_hiring[y, s];

var part_time {YEARS, SKILLS} >= 0, <= max_parttime;

var workforce {YEARS, SKILLS} >= 0;

var layoff {YEARS, SKILLS} >= 0;

var excess {YEARS, SKILLS} >= 0;

var train {YEARS, SKILLS, SKILLS} >= 0;

# CONSTRAINTS #

# 1. Balance constraint
subject to balance_constraint {year in YEARS, level in SKILLS}:
    workforce[year, level] = ((1-veteran_attrition[level]) * (if year = 1 then curr_workforce[level] else workforce[year-1, level]))
    + ((1-rookie_attrition[level])*hire[year, level])
    + sum {level2 in SKILLS : ord(level2) < ord(level)} 
            (((1- veteran_attrition[level])* train[year, level2, level]) - train[year, level, level2])
    + sum {level2 in SKILLS : ord(level2) > ord(level)} 
            (((1- demoted_attrition)* train[year, level2, level]) -train[year, level, level2])
    - layoff[year, level];

#2.1 & 2.2  Unskilled training
subject to unskilled_training_constraint_1 {year in YEARS}:
    train[year, 'unskilled', 'semi_skilled'] <= max_train_unskilled;

subject to unskilled_training_constraint_2 {year in YEARS}:
    train[year, 'unskilled', 'skilled'] = 0;

#3. Semi-skilled training
subject to semi_skilled_training_constraint {year in YEARS}:
    train[year,'semi_skilled', 'skilled'] <= max_train_semiskilled * workforce[year,'skilled'];

#4. Overmanning
subject to overmanning_constraint {year in YEARS}:
    sum {sk in SKILLS} excess[year, sk] <= max_overmanning;

#5. Demand
subject to demand_constraint {year in YEARS, level in SKILLS}:
    workforce[year, level] = demand[year,level] + excess[year, level] + parttime_cap * part_time[year, level];

# OBEJCTIVE FUNCTIONS #

# Objective 1 : Objective Function: Minimize layoffs
minimize minimize_layoffs:
    sum {year in YEARS, level in SKILLS} layoff[year, level];


# Objective 2 : Minimize the total cost of all employed workers and costs for retraining
minimize total_cost:
    sum {year in YEARS, level in SKILLS : ord(level) < card(SKILLS)}
        (training_cost[level] * train[year, level, next(level, SKILLS)])
    +
    sum {year in YEARS, level in SKILLS}
        ((layoff_cost[level]*layoff[year, level])
        + (parttime_cost[level]*part_time[year, level])
        + (overmanning_cost[level] * excess[year, level]));
