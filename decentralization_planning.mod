set DEPTS;
set CITIES;

set DEPTS2 = DEPTS;
set CITIES2 = CITIES;

set D2C within {DEPTS, CITIES};

set DCD2C2 within {DEPTS, CITIES, DEPTS2, CITIES};

param benefit {D2C} >= 0;
param communicationCost {DCD2C2} > 0;


#  DECISION  VARIABLES #
# locate deparment d at city c
var locate {D2C} binary;

#  CONSTRAINTS  #
subject to dept_location_constraint {d in DEPTS}:
    sum {c in CITIES} locate[d,c] = 1;

# Limit on number of departments
subject to num_depts_constraint {c in CITIES}:
    sum {d in DEPTS} locate[d,c] <= 3;

# Linearization of quadratic terms #
var y {DCD2C2} binary;

subject to linearization_constraint_1 {(d,c,d2,c2) in DCD2C2}:
    y[d,c,d2,c2] <= locate[d,c];
subject to linearization_constraint_2 {(d,c,d2,c2) in DCD2C2}:
    y[d,c,d2,c2] <= locate[d2,c2];

subject to linearization_constraint_3 {(d,c,d2,c2) in DCD2C2}:
    locate[d,c] + locate[d2,c2] - y[d,c,d2,c2] <= 1;

# OBJECTIVE FUNCTION #
maximize gross_margin_linear:
        sum {(d,c) in D2C} (benefit[d,c] * locate[d,c])
    -   sum {(d,c,d2,c2) in DCD2C2} (communicationCost[d,c,d2,c2] * y[d,c,d2,c2]) ;

# OBJECTIVE FUNCTION #
# QUADRATIC EXPRESSION #
maximize gross_margin_quadratic:
        sum {(d,c) in D2C} (benefit[d,c] * locate[d,c])
    -   sum {(d,c,d2,c2) in DCD2C2} (communicationCost[d,c,d2,c2] * locate[d,c] * locate[d2,c2]) ;

