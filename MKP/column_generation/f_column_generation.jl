using Gurobi, JuMP
using CSV, DataFrames

include("f_heuristics_greedy.jl")

struct Knapsack
    items::Vector # items assigned to this knapsack
    value::Int # total value of this knapsack
end

function column_generation()
    # Read the CSV files
    df_items = CSV.read("MKP/instances/mkp_items.csv", DataFrame)
    df_knapsacks = CSV.read("MKP/instances/mkp_knapsacks_5.csv", DataFrame)

    # Extract data from the DataFrames
    weights = df_items.Weight
    values = df_items.Value
    capacities = df_knapsacks.Capacity

    # generate initial solution by the greedy solution 
    init_knapsacks = knapsack_heuristic(weights, values, capacities)
    list_master = []
    lsit_sub = []

    # master proplem
    π1, π2, obj_m, value_x = build_master(weights, values, capacities, init_knapsacks)
    unserved = findall(x->x==0,value_x)
    unserved = getindex.(unserved, 1)
    return value_x
end

function build_sub(weights::Vector, values::Vector, capacities::Vector, unserved, π1, π2)
    model = Model(Gurobi.Optimizer)
    @variable(model, 0 <= x[i in unserved, 1:num_knapsacks] <= 1)
    @objective(model, Max, sum(value[i] * x[i,j]) - sum(weights[k]*pi[k] for k in num_knapsacks))
end

function build_master(weights::Vector, values::Vector, capacities::Vector, init_capacity::Vector{Knapsack})
    num_items = length(weights)
    # num_knapsacks = length(init_capacity) # number of columns
    num_knapsacks =  # start with one knapsack

    # Create a new model with the Gurobi solver
    model = Model(Gurobi.Optimizer)
    set_optimizer_attribute(model, "Timelimit", 30 * 60)  # 600 seconds = 10 minutes


    # Define variables: x[i, k] is a binary variable that is 1 if item i is in knapsack k
    @variable(model, 0 <= x[1:num_items, 1:num_knapsacks] <= 1)

    # Objective: Maximize the total value
    @objective(model, Max, sum(x[i, k] * values[i] for i in 1:num_items for k in 1:num_knapsacks))

    # Constraints
    # Each item can be in at most one knapsack
    @constraint(model, con1[i in 1:num_items], sum(x[i, k] for k in 1:num_knapsacks) <= 1)

    # The total weight in each knapsack must not exceed its capacity
    @constraint(model, con2[k in 1:num_knapsacks], sum(x[i, k] * weights[i] for i in 1:num_items) <= capacities[k])

    # Solve the model
    optimize!(model)
    obj_m = objective_value(model)
    π1 = dual.(con1)
    π2 = dual.(con2)
    return π1, π2, obj_m, value.(x)
end