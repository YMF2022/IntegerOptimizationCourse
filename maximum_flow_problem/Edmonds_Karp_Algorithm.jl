#using Pkg
#Pkg.add("Graphs")
#Pkg.add("GraphsFlows")


using Graphs
using GraphsFlows

# Create a directed graph representing the flow network
n = 10  # Number of nodes
flow_graph =  Graphs.DiGraph(8)

flow_edges = [
    (1, 2, 16), (1, 3, 13),
    (2, 4, 7),(2, 5, 12),
    (3, 2, 4),(3, 6, 14),
    (4, 5, 10), 
    (5, 3, 9), (5, 8, 4),(5, 9, 20),
    (6, 5, 7), (6, 7, 7),(6, 9, 4),
    (7, 9, 15),
    (8, 5, 6), (8, 9, 9),(8, 10, 10),
    (9, 8, 5),(9, 10, 12)
]

# Create the residual graph with the same structure as the flow network graph
flow_graph =  Graphs.DiGraph(n)
# Create a matrix to store the capacities of the edges
capacity_matrix = zeros(Int, n, n)


# Iterate through the edges and capacities to create the residual graph
for (source, target, capacity) in flow_edges
    # Add the forward edge in the residual graph with the initial capacity
    Graphs.add_edge!(flow_graph, source, target)
    capacity_matrix[source, target] = capacity
end

source_node = 1
sink_node = 10
flow_value, flow_map = GraphsFlows.edmonds_karp_impl(flow_graph, source_node, sink_node,capacities_matrix)

println("The maximum flow value is: ", flow_value)