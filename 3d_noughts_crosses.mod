param SIZE;

set ID;

set INDEX = 0 .. SIZE - 1;

param one_x {ID};
param one_y {ID};
param one_z {ID};

param two_x {ID};
param two_y {ID};
param two_z {ID};

param three_x {ID};
param three_y {ID};
param three_z {ID};

#   DECISION  VARIABLES   #
var isX {INDEX, INDEX, INDEX} binary ;

var isLine {ID} binary ;

#   CONSTRAINTS   #
subject to cons1:
    sum {i in INDEX, j in INDEX, k in INDEX} isX[i, j, k] <= 14 ;

subject to cons2 {i in ID}:
    isLine[i] = 0 ==> isX[one_x[i], one_y[i], one_z[i]] + 
                      isX[two_x[i], two_y[i], two_z[i]] + 
                      isX[three_x[i], three_y[i], three_z[i]] >= 1;

subject to cons3 {i in ID}:
    isLine[i] = 0 ==> isX[one_x[i], one_y[i], one_z[i]] + 
                      isX[two_x[i], two_y[i], two_z[i]] + 
                      isX[three_x[i], three_y[i], three_z[i]] <= 2;

minimize num_completed_lines:
    sum {i in ID} isLine[i];
