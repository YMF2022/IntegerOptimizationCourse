#=
MKP for Tai-Yu's course
Determine the optimal assignment of items to knapsacks as well as the maximum total value.
=#

using CSV, DataFrames
using JuMP
using Cbc

include("Instance.jl")
include("f_exact_DynamicProgramming.jl")
include("f_exact_jump.jl")
include("f_heuristics_greedy.jl")

#### Sepcfify the inputs 
instance_gen = 0 #if 1, generate a new instance; if 0, read the instance from the csv files
num_items = 1500  # Large number of items
num_knapsacks = 20  # Multiple knapsacks

##################################################
#1  Generate the instance
##################################################
weights, values, capacities = instance_generation(instance_gen,num_items,num_knapsacks)

##################################################
#2  Run the exact solution
##################################################

# ============= Using optimisation package =======#
# no constraints for the number of knapsack
optimal_value_jump, assignment_jump,time_jump,knapsack_jump = solve_mkp(weights, values, capacities)
println("Optimal Value for jump: ", optimal_value_jump)
println("Assignment : \n", knapsack_jump)
println("Computational Time for jump: ", time_jump)

# ============= column generation =======#


##################################################
#3  Run the heuristics
##################################################

#========== Greedy solution ===============# 
total_value_greedy, assigned_items_greedy, knapsack_greedy = knapsack_heuristic(weights, values, capacities)
time_greedy = @elapsed result = knapsack_heuristic(weights, values, capacities)
println( "Optimal Value: ", total_value_greedy)
#println("Assigned Items: ", assigned_items)
println("Computational Time: ", time_greedy)