#=
if you have not had those packages installed
using Pkg
Pkg.add("JuMP")
Pkg.add("Cbc")
=#

using JuMP
using Cbc

function solve_mkp(weights, values, capacities)
    num_items = length(weights)
    num_knapsacks = length(capacities)

    # Create a new model with the CBC solver
    model = Model(Cbc.Optimizer)

    # Define variables: x[i, k] is a binary variable that is 1 if item i is in knapsack k
    @variable(model, x[1:num_items, 1:num_knapsacks], Bin)

    # Objective: Maximize the total value
    @objective(model, Max, sum(x[i, k] * values[i] for i in 1:num_items for k in 1:num_knapsacks))

    # Constraints
    # Each item can be in at most one knapsack
    for i in 1:num_items
        @constraint(model, sum(x[i, k] for k in 1:num_knapsacks) <= 1)
    end

    # The total weight in each knapsack must not exceed its capacity
    for k in 1:num_knapsacks
        @constraint(model, sum(x[i, k] * weights[i] for i in 1:num_items) <= capacities[k])
    end

    # Solve the model
    optimize!(model)

    # Check if a solution was found
    if termination_status(model) == MOI.OPTIMAL
        optimal_value = objective_value(model)
        assignment = [value(x[i, k]) for i in 1:num_items, k in 1:num_knapsacks]
        return optimal_value, assignment
    else
        error("No optimal solution found!")
    end
end

