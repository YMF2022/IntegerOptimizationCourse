#=
Consider the following instance of the MKP:
- Items: I = {1, 2, 3, 4, 5} with weights w = {2, 3, 4, 5, 6} and values v = {3, 4, 5, 8, 10}.
- Knapsacks: K = {1, 2} with capacities c = {10, 12}.

Determine the optimal assignment of items to knapsacks as well as the maximum total value.

**1. Exact Algorithm**:

An exact algorithm would explore all possible assignments of items to knapsacks. Here is a code in Julia that uses a brute force approach:

=#
using JUMP
using Combinatorics

function knapsack_exact(weights, values, capacities)
    n = length(weights)
    m = length(capacities)
    best_value = 0
    best_assignment = []

    for k in 0:n
        for subset in combinations(1:n, k)
            for assignment in product(fill(0:m, k)...)
                valid = true
                knapsack_weights = zeros(Int, m)

                for (item, knapsack) in zip(subset, assignment)
                    if knapsack > 0
                        knapsack_weights[knapsack] += weights[item]
                        if knapsack_weights[knapsack] > capacities[knapsack]
                            valid = false
                            break
                        end
                    end
                end

                if valid
                    value = sum([knapsack > 0 ? values[item] : 0 for (item, knapsack) in zip(subset, assignment)])
                    if value > best_value
                        best_value = value
                        best_assignment = [(i, a) for (i, a) in zip(subset, assignment) if a > 0]
                    end
                end
            end
        end
    end

    return best_value, best_assignment
end

weights = [2, 3, 4, 5, 6]
values = [3, 4, 5, 8, 10]
capacities = [10, 12]

println(knapsack_exact(weights, values, capacities))

