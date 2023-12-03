function knapsack_heuristic(weights, values, capacities)
    n = length(weights)
    m = length(capacities)
    ratio = values ./ weights
    indices = sortperm(ratio, rev=true)
    assignment = zeros(Int, n)
    knapsack_weights = zeros(Int, m)

    # Initialize a vector for each knapsack
     knapsacks = [Int[] for _ in 1:m]

    for i in indices
        for k in 1:m
            if knapsack_weights[k] + weights[i] <= capacities[k]
                assignment[i] = k
                knapsack_weights[k] += weights[i]
                push!(knapsacks[k], i)  # Add item to the respective knapsack
                break
            end
        end
    end

    total_value = sum([assignment[i] > 0 ? values[i] : 0 for i in 1:n])
    assigned_items = [(i, assignment[i]) for i in 1:n if assignment[i] > 0] # (items, bag)
    struct_knapsacks = value_each_knapsack(knapsacks, values)
    return struct_knapsacks
end

function greedy_multiple_knapsack(capacities, weights, profits)
    num_knapsacks = length(capacities)
    num_items = length(weights)

    # Initialize empty knapsacks
    knapsacks = [[] for _ in 1:num_knapsacks]
    knapsack_weights = zeros(num_knapsacks)
    total_profit = 0

    # Calculate profit-to-weight ratios for each item
    ratios = [(i, profits[i] / weights[i]) for i in 1:num_items]

    # Sort items in descending order of profit-to-weight ratio
    sort!(ratios, by = x -> x[2], rev = true)

    # Greedy item selection
    for (item, _) in ratios
        for knapsack in 1:num_knapsacks
            if knapsack_weights[knapsack] + weights[item] <= capacities[knapsack]
                # Add the item to the knapsack
                push!(knapsacks[knapsack], item)
                knapsack_weights[knapsack] += weights[item]
                total_profit += profits[item]
                break
            end
        end
    end

    return knapsacks, total_profit
end


function value_each_knapsack(knapsacks::Vector, values::Vector)
    struct_knapsack = Vector{Knapsack}(undef, length(knapsacks))
    for (i,bag) in enumerate(knapsacks)
        value = sum(values[item] for item in bag)
        struct_knapsack[i] = Knapsack(bag, value)
    end
    return struct_knapsack
end
