#=
if you have not had those packages installed
using Pkg
Pkg.add("JuMP")
Pkg.add("Cbc")
=#


function solve_mkp(weights, values, capacities)
    num_items = length(weights)
    num_knapsacks = length(capacities)

    # Create a new model with the CBC solver
    model = Model(Cbc.Optimizer)
    set_optimizer_attribute(model, "seconds", 30 * 60)  # 600 seconds = 10 minutes


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
        computational_time = @elapsed optimize!(model)
        # Initialize an empty vector for each knapsack
        knapsack_assignments = [Int[] for _ in 1:num_knapsacks]

        # Iterate over each item and knapsack
        for i in 1:num_items
            for k in 1:num_knapsacks
                # Check if item i is assigned to knapsack k
                if value(x[i, k]) > 0.5  # Assuming binary decision variables
                    push!(knapsack_assignments[k], i)
                end
            end
        end

        return optimal_value, assignment, computational_time, knapsack_assignments
    else
        error("No optimal solution found!")
    end

end
