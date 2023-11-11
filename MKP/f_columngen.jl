
#const MOI = MathOptInterface

function solve_mkp_with_coluna(weights, values, capacities)
    num_items = length(weights)
    num_knapsacks = length(capacities)
    # ... (continue with additional setup)

    # Create the model
    model = BlockModel(Coluna.Optimizer())

    #### ---- Master problem ----#
    master = BlockModel(Coluna.Optimizer())

    # Decision variables: y[j, k] is 1 if combination j is in knapsack k
    # Initially, we can start with a small set of combinations or even none
    @variable(master, y[j=1:num_items, k=1:num_knapsacks], Bin)

    # Objective: Maximize the total value
    # Assuming value_combinations[j] is the value of combination j
    @objective(master, Max, sum(y[j, k] * value_combinations[j] for j in 1:num_items for k in 1:num_knapsacks))

    # Constraints
    # Each item can be in at most one knapsack
    for i in 1:num_items
        @constraint(master, sum(y[j, k] for k in 1:num_knapsacks for j in 1:num_items if item_in_combination(i, j)) <= 1)
    end

    # The total weight in each knapsack must not exceed its capacity
    for k in 1:num_knapsacks
        @constraint(master, sum(y[j, k] * weight_combinations[j] for j in 1:num_items) <= capacities[k])
    end
    # ... end of master problem ... #

    ### ---- Subproblem for each knapsack ----###
    for k in 1:num_knapsacks
        subproblem = BlockModel(Coluna.Optimizer())
        # Decision variables: x[i] is 1 if item i is selected
        @variable(subproblem, 0 <= x[1:num_items] <= 1, Bin)

        # Reduced cost objective: Maximize the value minus the dual cost
        @objective(subproblem, Max, sum((values[i] - dual_values[i]) * x[i] for i in 1:num_items))

        # Constraint: The total weight must not exceed the knapsack's capacity
        @constraint(subproblem, sum(weights[i] * x[i] for i in 1:num_items) <= capacity)

        # Link subproblem with master
        link!(model, subproblem, y[k])
    end

    #Select the algorithm 
    algorithm = Coluna.Algorithm.TreeSearchAlgorithm()  # Or another suitable algorithm

    optimize!(model, algorithm)

    # Check if a solution was found and extract it
    if termination_status(model) == MOI.OPTIMAL
        # ... (extract the solution)
        #optimal_value, assignment, computational_time, knapsack_assignments
    else
        error("No optimal solution found!")
    end
    return optimal_value, assignment, computational_time, knapsack_assignments
end