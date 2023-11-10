function mkp(weights, values, capacities)
    num_items = length(weights)
    num_knapsacks = length(capacities)
    dp = zeros(Int, num_items+1, capacities[1]+1, capacities[2]+1, capacities[3]+1)

    for i in 1:num_items
        for c1 in 0:capacities[1]
            for c2 in 0:capacities[2]
                for c3 in 0:capacities[3]
                    dp[i+1, c1+1, c2+1, c3+1] = dp[i, c1+1, c2+1, c3+1]

                    if weights[i] <= c1
                        dp[i+1, c1+1, c2+1, c3+1] = max(dp[i+1, c1+1, c2+1, c3+1], dp[i, c1-weights[i]+1, c2+1, c3+1] + values[i])
                    end

                    if weights[i] <= c2
                        dp[i+1, c1+1, c2+1, c3+1] = max(dp[i+1, c1+1, c2+1, c3+1], dp[i, c1+1, c2-weights[i]+1, c3+1] + values[i])
                    end

                    if weights[i] <= c3
                        dp[i+1, c1+1, c2+1, c3+1] = max(dp[i+1, c1+1, c2+1, c3+1], dp[i, c1+1, c2+1, c3-weights[i]+1] + values[i])
                    end
                end
            end
        end
    end

    # Backtracking to find the optimal assignment
    assignment = fill(0, num_items)
    c1, c2, c3 = capacities
    for i in num_items:-1:1
        if dp[i+1, c1+1, c2+1, c3+1] != dp[i, c1+1, c2+1, c3+1]
            if c1 >= weights[i] && dp[i+1, c1+1, c2+1, c3+1] == dp[i, c1-weights[i]+1, c2+1, c3+1] + values[i]
                assignment[i] = 1
                c1 -= weights[i]
            elseif c2 >= weights[i] && dp[i+1, c1+1, c2+1, c3+1] == dp[i, c1+1, c2-weights[i]+1, c3+1] + values[i]
                assignment[i] = 2
                c2 -= weights[i]
            elseif c3 >= weights[i]
                assignment[i] = 3
                c3 -= weights[i]
            end
        end
    end

    return dp[num_items+1, capacities[1]+1, capacities[2]+1, capacities[3]+1], assignment
end

# Example usage
weights = [2, 3, 4, 5, 6]
values = [3, 4, 5, 8, 10]
capacities = [10, 12, 15]
max_value, assignment = mkp(weights, values, capacities)
println("Max Value: ", max_value)
println("Item Assignment: ", assignment)
