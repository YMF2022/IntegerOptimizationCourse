#=
Consider the following instance of the MKP:
- Items: I = {1, 2, 3, 4, 5} with weights w = {2, 3, 4, 5, 6} and values v = {3, 4, 5, 8, 10}.
- Knapsacks: K = {1, 2} with capacities c = {10, 12}.

Determine the optimal assignment of items to knapsacks as well as the maximum total value.
=#

#Load the instances and functions 

include("Instance.jl")
include("f_exact_DynamicProgramming.jl")
include("f_exact_jump.jl")
include("f_heuristics_greedy.jl")

##################################################
#  Run the exact solution
##################################################

# ============= Using optimisation package =======#
# no constraints for the number of knapsack
optimal_value, assignment = solve_mkp(weights, values, capacities)
println("Optimal Value: ", optimal_value)
println("Assignment Matrix: \n", assignment)

#=================Dynamic programming solution====#
# 2 knapsacks
#=
max_value, assignment = mkp_dp(weights, values, capacities)
println("Optimal Value: ", max_value)
println("Assigned Items: ", assignment)
=#
# 3 knapsacks

# 4 knapsacks


# 5 knapsacks

##################################################
#  Run the heuristics solution
##################################################

#========== Greedy solution ===============# 
total_value, assigned_items = knapsack_heuristic(weights, values, capacities)
println( "Optimal Value: ", total_value)
println("Assigned Items: ", assigned_items)