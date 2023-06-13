set CRUDE_NUMBERS;
set PETROLS;
set END_PRODUCT_NAMES;
set DISTILLATION_PRODUCTS_NAMES;
set NAPHTHAS;
set INTERMEDIATE_OILS;
set CRACKING_PRODUCTS_NAMES;
set USED_FOR_MOTOR_FUEL_NAMES;
set USED_FOR_JET_FUEL_NAMES;

set INT_OILS_CRACK_PRD_NAMES within {INTERMEDIATE_OILS, CRACKING_PRODUCTS_NAMES};

param buy_limit {CRUDE_NUMBERS} > 0;
param lbo_min > 0;
param lbo_max > 0;

param distill_cap > 0;
param reform_cap > 0;
param crack_cap > 0;

param distillation_splitting_coefficients_1 {DISTILLATION_PRODUCTS_NAMES} > 0;
param distillation_splitting_coefficients_2 {DISTILLATION_PRODUCTS_NAMES} > 0;

param cracking_splitting_coefficients {INT_OILS_CRACK_PRD_NAMES} > 0;

param reforming_splitting_coefficients {NAPHTHAS} > 0;
param end_product_profit {END_PRODUCT_NAMES} > 0;

param blending_coefficients {USED_FOR_JET_FUEL_NAMES} > 0;

param lube_oil_factor > 0;
param pmf_rmf_ratio > 0;

param octance_number_coefficients {USED_FOR_MOTOR_FUEL_NAMES} > 0;
param octance_number_fuel {PETROLS} > 0;

param vapor_pressure_constants {USED_FOR_JET_FUEL_NAMES} > 0;

#           DECISION    VARIBALES               #

var crudes {i in CRUDE_NUMBERS} >= 0, <= buy_limit[i] ;
var end_products {END_PRODUCT_NAMES} >= 0;

subject to end_products_constraint:
    lbo_min <= end_products["Lube_oil"] <= lbo_max ;

var distillation_products {DISTILLATION_PRODUCTS_NAMES} >= 0;
var reform_usage {NAPHTHAS} >= 0;
var reformed_gasoline >= 0;
var cracking_usage {INTERMEDIATE_OILS} >= 0;
var cracking_products {CRACKING_PRODUCTS_NAMES} >= 0;
var used_for_regular_motor_fuel {USED_FOR_MOTOR_FUEL_NAMES} >= 0;
var used_for_premium_motor_fuel {USED_FOR_MOTOR_FUEL_NAMES} >= 0;
var used_for_jet_fuel {USED_FOR_JET_FUEL_NAMES} >= 0;
var used_for_lube_oil >=0 ;

#       CONSTRAINTS            #

# 1. Distillation capacity
subject to DistillationCap_constraint:
    sum {i in CRUDE_NUMBERS} crudes[i] <= distill_cap ;


# 2. Reforming capacity
subject to ReformingCap_constraint:
    sum {i in NAPHTHAS} reform_usage[i] <= reform_cap ;

# 3. Cracking capacity
subject to CrackingCap_constraint:
    sum {i in INTERMEDIATE_OILS} cracking_usage[i] <= crack_cap;

# 4.1-4.6 Yield (Crude oil products)
subject to YieldCrudeOil_constraint {dpn in DISTILLATION_PRODUCTS_NAMES}:
    (distillation_splitting_coefficients_1[dpn] * crudes[1]) + (distillation_splitting_coefficients_2[dpn] * crudes[2])
    = distillation_products[dpn] ;

# 4.7 Yield (Reforming of Naphthas)
subject to YieldNaphthas_constraint:
    sum {i in NAPHTHAS} reform_usage[i] * reforming_splitting_coefficients[i] = reformed_gasoline;

# 4.8-4.9 Yield (Cracking of oils)
subject to YieldCrackingOil_constraint {crack_prod in CRACKING_PRODUCTS_NAMES}:
    sum {oil in INTERMEDIATE_OILS} cracking_splitting_coefficients[oil, crack_prod] * cracking_usage[oil] = cracking_products[crack_prod] ;

# 4.10 Yield (Lube oil)
subject to YieldLubeOil_constraint:
    lube_oil_factor * used_for_lube_oil = end_products["Lube_oil"] ;

# 4.11 Yield (Premium gasoline)
subject to YieldPremium_constraint:
    sum {i in USED_FOR_MOTOR_FUEL_NAMES} used_for_premium_motor_fuel[i] = end_products["Premium_fuel"] ;

# 4.12 Yield (Regular gasoline)
subject to YieldRegular_constraint:
    sum {i in USED_FOR_MOTOR_FUEL_NAMES}  used_for_regular_motor_fuel[i] = end_products["Regular_fuel"] ;

# 4.13 Yield (Jet fuel)
subject to YieldJetFuel_constraint:
    sum {i in USED_FOR_JET_FUEL_NAMES} used_for_jet_fuel[i] = end_products["Jet_fuel"] ;

# 5.1-5.3 Mass conservation (Naphthas)
subject to MassBalNaphthas_constraints {naphtha in NAPHTHAS}:
    reform_usage[naphtha] + used_for_regular_motor_fuel[naphtha] + used_for_premium_motor_fuel[naphtha] 
    = distillation_products[naphtha] ;

# 5.4 Mass Conservation (Light oil)
subject to MassBalLightOil_constraint:
    cracking_usage["Light_oil"] + used_for_jet_fuel["Light_oil"]+blending_coefficients["Light_oil"] * end_products["Fuel_oil"] 
    = distillation_products["Light_oil"] ;

# 5.5 Mass Conservation (Heavy oil)
subject to MassBalHeavyOil_constraint:
    cracking_usage["Heavy_oil"] + used_for_jet_fuel["Heavy_oil"] + blending_coefficients["Heavy_oil"]*end_products["Fuel_oil"] 
    = distillation_products["Heavy_oil"] ;

# 5.6 Mass Conservation (Cracked oil)
subject to MassBalCrackedOil_constraint:
    used_for_jet_fuel["Cracked_oil"] + blending_coefficients["Cracked_oil"]*end_products["Fuel_oil"] 
    = cracking_products["Cracked_oil"] ;


# 5.7 Mass Conservation (Residuum)
subject to MassBalResiduum_constraint:
    used_for_lube_oil + used_for_jet_fuel["Residuum"]+ blending_coefficients["Residuum"]*end_products["Fuel_oil"] 
    = distillation_products["Residuum"] ;

# 5.8 Mass conservation (Cracked gasoline)
subject to MassBalCrackedGas_constraint:
    used_for_regular_motor_fuel["Cracked_gasoline"] + used_for_premium_motor_fuel["Cracked_gasoline"] 
    = cracking_products["Cracked_gasoline"] ;

# 5.9 Mass conservation (Reformed gasoline)
subject to MassBalReformedGas_constraint:
    used_for_regular_motor_fuel["Reformed_gasoline"] + used_for_premium_motor_fuel["Reformed_gasoline"] 
    = reformed_gasoline ;

# 7. Premium-to-regular proportion
subject to Premium2Regular_constraint:
    end_products["Premium_fuel"] >= pmf_rmf_ratio * end_products["Regular_fuel"] ;

# 8.1-8.2 Octane tolerance
subject to OctaneRegular_constraint:
    sum {i in USED_FOR_MOTOR_FUEL_NAMES} used_for_regular_motor_fuel[i] * octance_number_coefficients[i] 
    >= octance_number_fuel["Regular_fuel"] * end_products["Regular_fuel"] ;

subject to OctanePremium_constraint:
    sum {i in USED_FOR_MOTOR_FUEL_NAMES} used_for_premium_motor_fuel[i] * octance_number_coefficients[i]
    >= octance_number_fuel["Premium_fuel"] * end_products["Premium_fuel"] ;

# 9. Vapor-pressure tolerance
subject to VaporPressure_constraint:
    used_for_jet_fuel["Light_oil"] + 
    vapor_pressure_constants["Heavy_oil"] * used_for_jet_fuel["Heavy_oil"] +
    vapor_pressure_constants["Cracked_oil"] * used_for_jet_fuel["Cracked_oil"] +
    vapor_pressure_constants["Residuum"] * used_for_jet_fuel["Residuum"] 
    <= end_products["Jet_fuel"] ;


#          OBJECTIVE       FUNCTION         #
maximize profits:
    sum {i in END_PRODUCT_NAMES} end_products[i] * end_product_profit[i] ;