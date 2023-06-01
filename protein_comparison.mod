param num_nodes_1 > 0;
param num_nodes_2 > 0;

set NODES_1 := 1 .. num_nodes_1;
set NODES_2 := 1 .. num_nodes_2;

set IJKL;
set NOX;

set IJ within {NODES_1, NODES_2};

param list_1_i {IJKL} > 0;
param list_1_j {IJKL} > 0;
param list_1_k {IJKL} > 0;
param list_1_l {IJKL} > 0;

param list_2_i {NOX} > 0;
param list_2_j {NOX} > 0;
param list_2_k {NOX} > 0;
param list_2_l {NOX} > 0;


#       DECISION    VARIABLES       #
# Map nodes in G1 with nodes in G2
# map_nodes = model.addVars(ij, vtype=GRB.BINARY, name="map")
var map_nodes {IJ} binary;


#       CONSTRAINTS                #
# At most one node in G1 is matched with a node in G2
subject to at_most_1_node_G1_G2_constraint {j in NODES_2}:
    sum {i in NODES_1} map_nodes[i, j] <= 1 ;

# At most one node in G2 is matched with a node in G1
subject to at_most_1_node_G2_G1_constraint {i in NODES_1}:
    sum {j in NODES_2} map_nodes[i, j] <= 1 ;

# No crossovers
subject to no_crossover_constraint {p in NOX}:
    map_nodes[list_2_i[p], list_2_j[p]] + map_nodes[list_2_k[p], list_2_l[p]] <= 1 ;


#       OBJECTIVES                 #
maximize matchings_edges_G1_G2:
    sum {p in IJKL} (map_nodes[list_1_i[p], list_1_j[p]] * map_nodes[list_1_k[p], list_1_l[p]]) ;
