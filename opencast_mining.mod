set BLOCKS;
set ARCS within {BLOCKS, BLOCKS};

param profit {BLOCKS};

param value {ARCS} > 0;


#  DECISION  VARIABLES  #
var extract {BLOCKS} >= 0, <= 1;

#  CONSTRAINTS  #

subject to extraction_constraint {(b1, b2) in ARCS}:
    extract[b1] <= extract[b2];

#  OBJECTIVE  FUNCTION  #
maximize extractionProfit:
    sum {b in BLOCKS} profit[b] * extract[b];


