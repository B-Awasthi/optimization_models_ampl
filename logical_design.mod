set GATES;
set GATES_47;
set ROWS;

set GATE_ROWS within {GATES, ROWS};
param valueA {GATE_ROWS};
param valueB {GATE_ROWS};

#       DECISION    VARIABLES       #

# Decision variables to select NOR gate i.
var NOR {GATES} binary;

# In order to avoid a trivial solution containing no NOR gates, it is necessary to impose a constraint 
# that selects NOR gate 1.
subject to nor_1_constraint:
    NOR[1] = 1 ;

# Variables to decide if external input A is an input to NOR gate i.
var inputA {GATES} binary;

# Variables to decide if external input B is an input to NOR gate i.
var inputB {GATES} binary;

# Output decision variables.
var output {GATE_ROWS} binary;

# For NOR gate 1, the output variables are fixed at the values specified in the truth table.
subject to constraints_1 {(i, j) in GATE_ROWS : i = 1 and j in {2, 3}}:
    output[i, j] = 1;

subject to constraints_2 {(i, j) in GATE_ROWS : i = 1 and j in {1, 4}}:
    output[i, j] = 0;


#       CONSTRAINTS         #
# External inputs constraints

subject to external_inputsA_constraint {i in GATES}:
    NOR[i] >= inputA[i] ;

subject to external_inputsB_constraint {i in GATES}:
    NOR[i] >= inputB[i] ;

# NOR gates constraints

subject to nor_gates_constraint_1:
    NOR[2] + NOR[3] + inputA[1] + inputB[1] <= 2 ;
subject to nor_gates_constraint_2:
    NOR[4] + NOR[5] + inputA[2] + inputB[2] <= 2 ;
subject to nor_gates_constraint_3:
    NOR[6] + NOR[7] + inputA[3] + inputB[3] <= 2 ;

# Output signal constraint.
subject to output_signal_constraint_1 {r in ROWS}:
    output[2,r] + output[1,r] <= 1 ;

subject to output_signal_constraint_2 {r in ROWS}:
    output[3,r] + output[1,r] <= 1 ;

subject to output_signal_constraint_3 {r in ROWS}:
    output[4,r] + output[2,r] <= 1 ;

subject to output_signal_constraint_4 {r in ROWS}:
    output[5,r] + output[2,r] <= 1 ;

subject to output_signal_constraint_5 {r in ROWS}:
    output[6,r] + output[3,r] <= 1 ;

subject to output_signal_constraint_6 {r in ROWS}:
    output[7,r] + output[3,r] <= 1 ;

subject to output_signal_constraint_7 {(i,r) in GATE_ROWS}:
    valueA[i,r] * inputA[i] + output[i,r] <= 1 ;

subject to output_signal_constraint_8 {(i,r) in GATE_ROWS}:
    valueB[i,r]*inputB[i] + output[i,r] <= 1 ;


subject to output_signal_constraint_9 {(i,r) in GATE_ROWS : i in GATES_47}:
    valueA[i,r]*inputA[i] + valueB[i,r]*inputB[i] + output[i,r] - NOR[i] >= 0 ;


subject to output_signal_constraint_10 {(i,r) in GATE_ROWS}:
    valueA[1,r]*inputA[1] + valueB[1,r]*inputB[1] 
                                    + output[2,r] + output[3,r] + output[1,r] - NOR[1] >= 0 ;


subject to output_signal_constraint_11 {(i,r) in GATE_ROWS}:
    valueA[2,r]*inputA[2] + valueB[2,r]*inputB[2] 
                                    + output[4,r] + output[5,r] + output[2,r] - NOR[2] >= 0 ;


subject to output_signal_constraint_12 {(i,r) in GATE_ROWS}:
    valueA[3,r]*inputA[3] + valueB[3,r]*inputB[3] 
                                    + output[6,r] + output[7,r] + output[3,r] - NOR[3] >= 0 ;

# Gate and output signals constraints
subject to gate_output_signals_constraints {(i, r) in GATE_ROWS}:
    NOR[i] - output[i,r] >= 0 ;


#           OBJECTIVE   FUNCTION            #
minimize number_nor_gates:
    sum {i in GATES} NOR[i] ;
