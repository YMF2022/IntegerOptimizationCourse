#=
MKP for Tai-Yu's course
Determine the optimal assignment of items to knapsacks as well as the maximum total value.
=#

using CSV, DataFrames, DelimitedFiles
using JuMP, Gurobi
using Coluna,BlockDecomposition,MathOptInterface
using Random, Cbc

include("f_instance_generation.jl")
include("f_exact_jump.jl")
include("f_heuristics_greedy.jl")
include("f_columngen.jl")

#### Sepcfify the inputs 
instance_gen = 1 #if 1, generate a new instance; if 0, read the instance from the csv files
num_items = 1500  # Large number of items
num_knapsacks = 2 # Multiple knapsacks
folder_instance = pwd() * "/MKP/instances/"
folder_result = pwd() * "/MKP/result/"


function run_mul(knap_list::Vector)
    #1  Rdad the instance
    Random.seed!(num_knapsacks)
    results = DataFrame(num_knapsacks = [], gurobi_obj = [], gurobi_soltime = [], greedy_obj=[], greedy_soltime=[])

    for num_knapsacks in knap_list 
        weights, values, capacities = instance_generation(instance_gen, num_items, num_knapsacks, folder_instance)

        # ============= Using optimisation package =======#
        # no constraints for the number of knapsack
        optimal_value_jump, assignment_jump,time_jump, knapsack_jump, status = solve_mkp(weights, values, capacities)
        println("Optimal Value for jump: ", optimal_value_jump)
        println("Assignment : \n", knapsack_jump)
        println("Computational Time for jump: ", time_jump)
    
    
        #========== Greedy solution ===============# 
        total_value_greedy, assigned_items_greedy, knapsack_greedy = knapsack_heuristic(weights, values, capacities)
        time_greedy = @elapsed result = knapsack_heuristic(weights, values, capacities)
        println( "Optimal Value Greedy: ", total_value_greedy)
        #println("Assigned Items: ", assigned_items)
        println("Computational Time: ", time_greedy)

        push!(results, [num_knapsacks, optimal_value_jump, time_jump, total_value_greedy, time_greedy])
    end
    return results
end

results = run_mul([10, 20, 30, 40, 50, 60, 70, 80, 90, 100])
CSV.write(folder_result * "1500items.csv", results)
