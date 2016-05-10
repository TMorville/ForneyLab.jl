#####################
# Unit tests
#####################

facts("Subgraph unit tests") do
    context("Subgraph() should initialize a subgraph") do
        sg = ForneyLab.Subgraph()
        @fact typeof(sg) --> ForneyLab.Subgraph
        @fact typeof(sg.internal_edges) --> Set{Edge}
        @fact typeof(sg.internal_schedule) --> Schedule
        @fact typeof(sg.external_schedule) --> Array{Node, 1}
    end
end

facts("Nodes and edges overloadings for Subgraph") do
    context("nodes() called on a subgraph should return all internal nodes of the subgraph") do
        initializeFactoringGraphWithoutLoop()

        f = ForneyLab.factorize(Dict(
            eg(:q_mean) => Gaussian,
            eg(:q_var) => InverseGamma,
            eg(:q_out) => Gaussian))

        sg = f.factors[3]
        @fact nodes(sg) --> Set{Node}(Node[n(:g1), n(:t2)])
    end

    context("edges() called on a subgraph should return all internal edges (optionally external as well) of the subgraph") do
        initializeFactoringGraphWithoutLoop()
        f = ForneyLab.factorize(Dict(
            eg(:q_mean) => Gaussian,
            eg(:q_var) => InverseGamma,
            eg(:q_out) => Gaussian))
        sg = f.factors[3]
        @fact edges(sg, include_external=false) --> Set{Edge}(Edge[n(:g1).i[:variance].edge])
        @fact edges(sg) --> Set{Edge}(Edge[n(:g1).i[:variance].edge, n(:g1).i[:out].edge, n(:g1).i[:mean].edge])
    end
end

#####################
# Integration tests
#####################

facts("Subgraph integration tests") do
    context("externalEdges() should return all external edges") do
        data = [1.0, 1.0, 1.0]

        # MF case
        initializeGaussianNodeChain(data)
        n_sections = length(data)

        f = ForneyLab.factorize(Dict(
            eg(:q_m*(1:3)) => Gaussian,
            eg(:q_gam*(1:3)) => Gamma,
            eg(:q_y*(1:3)) => Gaussian))

        m_subgraph = f.edge_to_subgraph[n(:g1).i[:mean].edge]
        @fact ForneyLab.externalEdges(m_subgraph) --> Set(Edge[n(:g1).i[:out].edge, n(:g2).i[:out].edge, n(:g3).i[:out].edge, n(:g1).i[:precision].edge, n(:g2).i[:precision].edge, n(:g3).i[:precision].edge])

        # Structured case
        initializeGaussianNodeChain(data)
        n_sections = length(data)

        f = ForneyLab.factorize(Dict(
            [eg(:q_m1) eg(:q_gam1);
             eg(:q_m2) eg(:q_gam2);
             eg(:q_m3) eg(:q_gam3)] => NormalGamma,
            eg(:q_y1) => Gaussian))

        m_gam_subgraph = f.edge_to_subgraph[n(:g1).i[:mean].edge]
        @fact ForneyLab.externalEdges(m_gam_subgraph) --> Set(Edge[n(:g1).i[:out].edge, n(:g2).i[:out].edge, n(:g3).i[:out].edge])
    end

    context("nodesConnectedToExternalEdges() should return all nodes (g) connected to external edges") do
        data = [1.0, 1.0, 1.0]

        # MF case
        initializeGaussianNodeChain(data)
        n_sections = length(data)
        f = ForneyLab.factorize(Dict(
            eg(:q_m*(1:3)) => Gaussian,
            eg(:q_gam*(1:3)) => Gamma,
            eg(:q_y*(1:3)) => Gaussian))

        m_subgraph = f.edge_to_subgraph[n(:g1).i[:mean].edge]
        @fact ForneyLab.nodesConnectedToExternalEdges(m_subgraph) --> Set{Node}([n(:g1), n(:g2), n(:g3)])

        # Structured case
        initializeGaussianNodeChain(data)
        n_sections = length(data)

        f = ForneyLab.factorize(Dict(
            [eg(:q_m1) eg(:q_gam1);
             eg(:q_m2) eg(:q_gam2);
             eg(:q_m3) eg(:q_gam3)] => NormalGamma,
            eg(:q_y1) => Gaussian))

        m_gam_subgraph = f.edge_to_subgraph[n(:g1).i[:mean].edge]
        @fact ForneyLab.nodesConnectedToExternalEdges(m_gam_subgraph) --> Set{Node}([n(:g1), n(:g2), n(:g3)])
    end
end
