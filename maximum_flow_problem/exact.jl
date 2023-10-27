using DelimitedFiles
using JuMP, Gurobi

function get_arcs_capacity(capacity_matrix::Matrix)
    arcs_capacity = Dict{Tuple, Float64}() # keys are arcs, values are capacity
    num_rows, num_cols = size(capacity_matrix)
    for row in 1:num_rows
        for col in 1:num_cols
            if capacity_matrix[row, col] != 0
                arcs_capacity[(row, col)] = capacity_matrix[row, col]
            end
        end
    end

    return arcs_capacity
end

function get_nodes_inout(arcs::Vector, s::Int64, t::Int64)
    nodes_inout = Dict(i => [[],[]] for i in s:t)
    for arc in arcs
        push!(nodes_inout[arc[1]][2], arc[2]) # add arc[2] as the out node of arc[1]
        push!(nodes_inout[arc[2]][1], arc[1]) # add arc[1] as the in node of arc[2]
    end
    return nodes_inout
end

function build_model(arcs_capacity::Dict, s::Int64, t::Int64)
    # get all the arcs
    arcs = collect(keys(arcs_capacity))
    nodes_inout = get_nodes_inout(arcs, s, t) # get all the outgoing and ingoing nodes for each node

    # set up a Model
    m = Model(Gurobi.Optimizer)
    
    @variable(m, f[arc in arcs] >= 0)
    @constraint(m, [arc in arcs], f[arc] <= arcs_capacity[arc]) # capacity constraints
    @constraint(m, [u in s+1:t-1], sum(f[(u,v)] for v in nodes_inout[u][2]) - sum(f[(v,u)] for v in nodes_inout[u][1]) == 0)

    @objective(m, Max, sum(f[(s,i)] for i in nodes_inout[s][2]))

    return m
end

function get_results(m::Model, arcs_capacity::Dict)
    # get all the arcs
    arcs = collect(keys(arcs_capacity))
    flow_result = Dict{Tuple, Float64}()
    for arc in arcs
        flow_result[arc] = value(m[:f][arc])
    end 
    return flow_result
end

function exact_solve(datafile::String)
    # read the data
    capacity_matrix, _ = readdlm(datafile, ',', header=true)
    capacity_matrix = capacity_matrix[:,2:end]
    capacity_matrix = convert(Matrix{Float64}, capacity_matrix) 
    # setup the netwrok
    source, sink = 1, size(capacity_matrix)[1]
    arcs_capacity = get_arcs_capacity(capacity_matrix) 
    # build and run the model
    m = build_model(arcs_capacity, source, sink)
    optimize!(m)
    # print the objective values
    @info "The maximum flow is: ", objective_value(m)
    # output the flow at each arc
    flow_result = get_results(m, arcs_capacity)
    open("maximum_flow_problem/exact_results.txt", "w") do f
        for (k,v) in flow_result
            write(f, "$k => $v\n")
        end
    end

    return flow_result
end

flow_result = exact_solve("maximum_flow_problem/netwrok.csv")