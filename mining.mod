set YEARS;
set MINES;

param royalties {MINES} > 0;
param capacity {MINES} > 0;
param quality {MINES} > 0;

param target {YEARS} > 0;

param max_mines;
param price;

param time_discount {i in YEARS} = (1/(1+1/10.0)) ** (i-1);


# DECISION  VARIBALES #

var blend {YEARS} >= 0;
var extract {YEARS, MINES} >= 0;
var working {YEARS, MINES} binary;
var available {YEARS, MINES} binary;


#  CONSTRAINTS #

#1. Operating Mines
subject to OperatingMines_constraint {yr in YEARS}:
    sum {mn in MINES} working[yr, mn] <= max_mines;

#2. Quality
subject to quality_constraint {yr in YEARS}:
    sum {mn in MINES} quality[mn] * extract[yr, mn] = target[yr] * blend[yr];

#3. Mass Conservation

subject to massConservation_constraint {yr in YEARS}:
    sum {mn in MINES} extract[yr, mn] = blend[yr];

#4. Mine Capacity
subject to mine_capacity_constraint {yr in YEARS, mn in MINES}:
    extract[yr, mn] <= capacity[mn] * working[yr, mn];

# Open to operate
subject to open_to_operate_constraint {yr in YEARS, mn in MINES}:
    working[yr, mn] <= available[yr, mn];

# Shutdown Mine
subject to shutdown_mine_constraint {yr in YEARS, mn in MINES : yr < card(YEARS)}:
    available[yr + 1, mn] <= available[yr, mn];


#  OBJECTIVE FUNCTION #
maximize total_profit:
    sum {yr in YEARS} (price * time_discount[yr] * blend[yr])
  - sum {yr in YEARS, mn in MINES} (royalties[mn] * time_discount[yr] * available[yr, mn]);



