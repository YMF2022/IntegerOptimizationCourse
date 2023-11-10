function knapsack_heuristic(weights, values, capacities)
    n = length(weights)
    m = length(capacities)
    ratio = values ./ weights
    indices = sortperm(ratio, rev=true)
    assignment = zeros(Int, n)
    knapsack_weights = zeros(Int, m)

    for i in indices
        for k in 1:m
            if knapsack_weights[k] + weights[i] <= capacities[k]
                assignment[i] = k
                knapsack_weights[k] += weights[i]
                break
            end
        end
    end

    total_value = sum([assignment[i] > 0 ? values[i] : 0 for i in 1:n])
    assigned_items = [(i, assignment[i]) for i in 1:n if assignment[i] > 0]

    return total_value, assigned_items
end
