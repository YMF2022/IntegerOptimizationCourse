
# Parameters

function instance_generation(instance_gen, num_items, num_knapsacks)
    # Parameters

    if instance_gen == 1 # Generate a new instance
        weights = rand(1:45, num_items)  # Random weights between 1 and 100
        values = rand(1:45, num_items)  # Random values between 1 and 100
        capacities = rand(50:500, num_knapsacks)  # Varying capacities for knapsacks

        # Create a DataFrame
        df_items = DataFrame(Item=1:num_items, Weight=weights, Value=values)
        df_knapsacks = DataFrame(Knapsack=1:num_knapsacks, Capacity=capacities)

        # Save to CSV
        CSV.write("mkp_items.csv", df_items)
        CSV.write("mkp_knapsacks.csv", df_knapsacks)

        println("Data saved successfully.")
    else
        # Read the CSV files
        df_items = CSV.read("mkp_items.csv", DataFrame)
        df_knapsacks = CSV.read("mkp_knapsacks.csv", DataFrame)

        # Extract data from the DataFrames
        weights = df_items.Weight
        values = df_items.Value
        capacities = df_knapsacks.Capacity

        # Now, you have your weights, values, and capacities variables ready to be used
        println("Read Data successfully")
    end
    return weights, values, capacities
end