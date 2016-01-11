facts("VariationalBayes collect inbound type tests") do
    context("VariationalBayes should collect the proper inbound types as dependent on the factorization") do
        # Mean field factorized Gaussian node
        initializeGaussianNode(Dict(    n(:node).i[:mean].edge => GaussianDistribution,
                                        n(:node).i[:precision].edge => GammaDistribution,
                                        n(:node).i[:mean].edge => GaussianDistribution))
        algo = VariationalBayes()
        @fact algo.factorization.factors[1].internal_schedule[2].inbound_types --> [GaussianDistribution, GammaDistribution, Void]
        @fact algo.factorization.factors[2].internal_schedule[2].inbound_types --> [GaussianDistribution, Void, GaussianDistribution]
        @fact algo.factorization.factors[3].internal_schedule[2].inbound_types --> [Void, GammaDistribution, GaussianDistribution]

        # Structurally factorized
        initializeGaussianNode()
        algo = VariationalBayes(Set([n(:node).i[:out].edge])) # Split off extensions of these groups into separate subgraphs
        @fact algo.factorization.factors[2].internal_schedule[2].inbound_types --> [NormalGammaDistribution, NormalGammaDistribution, Void]
    end
end