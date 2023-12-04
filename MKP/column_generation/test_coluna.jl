using BlockDecomposition, Coluna
using Gurobi, JuMP
using CSV, DataFrames

# Read the CSV files
df_items = CSV.read("MKP/instances/mkp_items.csv", DataFrame)
df_knapsacks = CSV.read("MKP/instances/mkp_knapsacks_2.csv", DataFrame)

# Extract data from the DataFrames
weights = df_items.Weight
values = df_items.Value
capacities = df_knapsacks.Capacity

num_items = length(weights)
num_knapsacks = length(capacities)

coluna = optimizer_with_attributes(
    Coluna.Optimizer,
    "params" => Coluna.Params(
        solver = Coluna.Algorithm.TreeSearchAlgorithm() # default branch-cut-and-price
    ),
    "default_optimizer" => Gurobi.Optimizer # GLPK for the master & the subproblems
);


model = BlockModel(coluna)
@axis(K_axis, 1:num_knapsacks)

@variable(model, x[k in K_axis, i in 1:num_items], Bin)
@constraint(model, setcov[i in 1:num_items], sum(x[k,i] for k in K_axis) <= 1)
@constraint(model, cap[k in K_axis], sum(weights[i] * x[k,i] for i in 1:num_items) <= capacities[k])
@objective(model, Max, sum(values[i] * x[k,i] for k in K_axis for i in 1:num_items))

@dantzig_wolfe_decomposition(model, decomposition, K_axis)
master = getmaster(decomposition) # master problem
subproblems = getsubproblems(decomposition) # sub problem
specify!.(subproblems, lower_multiplicity = 0, upper_multiplicity = 1) # each knapsack used once

getsubproblems(decomposition)
optimize!(model)