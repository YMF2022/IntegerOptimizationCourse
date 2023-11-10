#=
Consider the following instance of the MKP:
- Items: I = {1, 2, 3, 4, 5} with weights w = {2, 3, 4, 5, 6} and values v = {3, 4, 5, 8, 10}.
- Knapsacks: K = {1, 2} with capacities c = {10, 12}.

Determine the optimal assignment of items to knapsacks as well as the maximum total value.

**1. Exact Algorithm**:

An exact algorithm would explore all possible assignments of items to knapsacks. Here is a code in Julia that uses a brute force approach:

=#

using Combinatorics
function mkp(weights, values, capacities)
    num_items = length(weights)
    num_knapsacks = length(capacities)
    dp = zeros(Int, num_items+1, capacities[1]+1, capacities[2]+1)

    for i in 1:num_items
        for c1 in 0:capacities[1]
            for c2 in 0:capacities[2]
                dp[i+1, c1+1, c2+1] = dp[i, c1+1, c2+1] # Case 1: item i is not included in any knapsack

                if weights[i] <= c1
                    # Case 2: item i is included in knapsack 1
                    dp[i+1, c1+1, c2+1] = max(dp[i+1, c1+1, c2+1], dp[i, c1-weights[i]+1, c2+1] + values[i])
                end

                if weights[i] <= c2
                    # Case 3: item i is included in knapsack 2
                    dp[i+1, c1+1, c2+1] = max(dp[i+1, c1+1, c2+1], dp[i, c1+1, c2-weights[i]+1] + values[i])
                end
            end
        end
    end

    # Backtracking to find the optimal assignment
    assignment = fill(0, num_items)
    c1, c2 = capacities[1], capacities[2]
    for i in num_items:-1:1
        if dp[i+1, c1+1, c2+1] != dp[i, c1+1, c2+1]
            if c1 >= weights[i] && dp[i+1, c1+1, c2+1] == dp[i, c1-weights[i]+1, c2+1] + values[i]
                assignment[i] = 1
                c1 -= weights[i]
            elseif c2 >= weights[i]
                assignment[i] = 2
                c2 -= weights[i]
            end
        end
    end

    return dp[num_items+1, capacities[1]+1, capacities[2]+1], assignment
end

# Example usage
weights = [2, 3, 4, 5, 6]
values = [3, 4, 5, 8, 10]
capacities = [10, 12]
max_value, assignment = mkp(weights, values, capacities)
println("Max Value: ", max_value)
println("Item Assignment: ", assignment)
