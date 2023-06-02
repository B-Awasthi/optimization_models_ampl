set FARMS;
set dayType;

set ARCS within {FARMS, FARMS};#{i in FARMS, j in FARMS : i < j};
set ARCS_ALL = ARCS union {i in FARMS, j in FARMS : i > j};

param tankerCap > 0;
param everyDayReq > 0;
param point_x {FARMS};
param point_y {FARMS};
param collect {FARMS};
param dist {ARCS} > 0;

set everyDay = {i in FARMS : i < 10} ;
set otherDay = {i in FARMS : i >= 10} ;

#       DECISION    VARIABLES       #

# Edge variables = 1, if farm 'i' is adjacent to farm 'j' on the tour of day type 'k'.
# vars = m.addVars(dist, dayType, vtype=GRB.BINARY, name='x')
var vars {ARCS_ALL, dayType} binary;

# Other day variables = 1, if farm 'i' is visited on the tour of day type 'k'.
# other_var = m.addVars(otherDay, dayType, vtype=GRB.BINARY, name='y') 
var other_var {otherDay, dayType} binary;

# Symmetry constraints: copy the object (not a constraint)
# for i,j,k in vars.keys():
#     vars[j, i, k] = vars[i, j, k]
subject to symmetry_constraints {(i,j) in ARCS_ALL, k in dayType}:
    vars[j, i, k] = vars[i, j, k];

var u {i in FARMS, k in dayType : i > 0} >= 0 ;

#       CONSTRAINTS             #

# Every day constraints: two edges incident to an every day farm on tour of day type 'k'. 
# m.addConstrs((vars.sum(i,'*',k) == 2 for i in everyDay for k in dayType  ), name='everyDay')
subject to every_day_constraints {i in everyDay, k in dayType}:
    sum {(i, j) in ARCS_ALL} vars[i, j, k] = 2 ;

# Other day constraints: two edges incident to an other day farm on tour of day type 'k'.
# m.addConstrs((vars.sum(i,'*',k) == 2*other_var[i,k] for i in otherDay for k in dayType ), name='otherDay')
subject to other_day_constraints {i in otherDay, k in dayType}:
    sum {(i, j) in ARCS_ALL} vars[i, j, k] = 2 * other_var[i, k] ;

# Tanker capacity constraint.
# m.addConstrs(( gp.quicksum(collect[i]*other_var[i,k] for i in otherDay ) <= tankerCap-everyDayReq for k in dayType ),
#              name='tankerCap')
subject to tanker_capacity_constraint {k in dayType}:   
    sum {i in otherDay} (collect[i] * other_var[i, k]) <= tankerCap - everyDayReq ;

# Other day farms are visited on day type 1 or 2.
# otherDayFarms = m.addConstrs((other_var.sum(i, '*') == 1 for i in otherDay), name='visited')
subject to other_day_farms_visit_dayType_1_2 {i in otherDay}:
    sum {j in dayType} other_var[i, j] = 1 ;

# Avoid symmetric alternative solutions
# other_var[11,1].lb = 1
subject to avoid_symmetry_constraint:
    other_var[11,1] = 1 ;

# subject to const_1 {k in dayType}:
#     sum {i in FARMS : i > 0} vars[0, i, k] = 1;

# subject to const_2 {k in dayType, j in FARMS : j > 0}:
#     sum {(i, j) in ARCS_ALL} vars[i, j, k] = 1;


# MTZ FORMULATION to eliminate sub-tours 
# subject to mtz_constraint_1 {k in dayType, i in FARMS, j in FARMS : i <> j and i > 0 and j > 0}:
#     u[j, k] - u[i, k] >= 1 - 1000 * (1 - vars[i, j, k]) ;

# subject to mtz_constraint_2 {k in dayType, i in FARMS : i > 0}:
#     1 <= u[i, k] <= 1000 ;

#       OBJECTIVE      FUNCTION        #
# m.setObjective(gp.quicksum(dist[i,j]*vars[i,j,k] for i,j in dist.keys() for k in dayType), GRB.MINIMIZE)
minimize total_distance_travelled:
    sum {(i, j) in ARCS, k in dayType}
        dist[i, j] * vars[i, j, k] ;