set OBS;

param x {OBS} >= 0;
param y {OBS} >= 0;


#   DECISION  VARIABLES  #
# Constant term of the function f(x). This is a free continuous variable that can take positive and negative values. 
var a ;

# Coefficient of the linear term of the function f(x). This is a free continuous variable that can take positive 
# and negative values.
var b ;

# Non-negative continuous variables that capture the positive deviations
var u {OBS} >= 0;

# Non-negative continuous variables that capture the negative deviations
var v {OBS} >= 0;

# Non-negative continuous variables that capture the value of the maximum deviation
var z >= 0;


#  CONSTRAINTS  #
subject to deviation_constraint {i in OBS}:
    b * x[i] + a + u[i] - v[i] = y[i] ;

# Maximum deviation constraints
subject to maxPositive_deviation_constraint {i in OBS}:
    z >= u[i];

subject to maxNegative_deviation {i in OBS}:
    z >= v[i];


#  OBJECTIVE FUNCTION # 
minimize maximum_deviation:
    z;
