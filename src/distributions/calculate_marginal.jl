export calculateMarginal, calculateMarginal!

# Functions for calculating marginals on nodes and edges.

# Marginal calculations are in a separate file from the distribution definitions,
# because types that are needed for marginal calculations are defined after distribution definitions

# Marginal calculations on the edges are the same as the equality node rules,
# where the forward and backward messages are incoming and the marginal outcome is on the outgoing edge.

############################
# Edge marginal calculations
############################

"""
Calculates the marginal without writing back to the edge
"""
function calculateMarginal(edge::Edge)
    @assert(edge.tail.message != nothing, "Edge ($(edge.tail.node.id) --> $(edge.head.node.id)) should hold a forward message.")
    @assert(edge.head.message != nothing, "Edge ($(edge.tail.node.id) --> $(edge.head.node.id)) should hold a backward message.")
    return calculateMarginal(edge.tail.message.payload, edge.head.message.payload)
end

"""
Calculates and writes the marginal on edge
"""
function calculateMarginal!(edge::Edge)
    @assert(edge.tail.message != nothing, "Edge ($(edge.tail.node.id) --> $(edge.head.node.id)) should hold a forward message.")
    @assert(edge.head.message != nothing, "Edge ($(edge.tail.node.id) --> $(edge.head.node.id)) should hold a backward message.")
    calculateMarginal!(edge, edge.tail.message.payload, edge.head.message.payload)
    return edge.marginal
end


############################################
# GammaDistribution
############################################

function calculateMarginal(forward_dist::GammaDistribution, backward_dist::GammaDistribution)
    marg = GammaDistribution()
    return equalityRule!(marg, forward_dist, backward_dist)
end
function calculateMarginal!(edge::Edge, forward_dist::GammaDistribution, backward_dist::GammaDistribution)
    marg = ensureMarginal!(edge, GammaDistribution)
    return equalityRule!(marg, forward_dist, backward_dist)
end


############################################
# InverseGammaDistribution
############################################

function calculateMarginal(forward_dist::InverseGammaDistribution, backward_dist::InverseGammaDistribution)
    marg = InverseGammaDistribution()
    return equalityRule!(marg, forward_dist, backward_dist)
end
function calculateMarginal!(edge::Edge, forward_dist::InverseGammaDistribution, backward_dist::InverseGammaDistribution)
    marg = ensureMarginal!(edge, InverseGammaDistribution)
    return equalityRule!(marg, forward_dist, backward_dist)
end


############################################
# BetaDistribution
############################################

function calculateMarginal(forward_dist::BetaDistribution, backward_dist::BetaDistribution)
    marg = BetaDistribution()
    return equalityRule!(marg, forward_dist, backward_dist)
end
function calculateMarginal!(edge::Edge, forward_dist::BetaDistribution, backward_dist::BetaDistribution)
    marg = ensureMarginal!(edge, BetaDistribution)
    return equalityRule!(marg, forward_dist, backward_dist)
end


############################################
# LogNormalDistribution
############################################

function calculateMarginal(forward_dist::LogNormalDistribution, backward_dist::LogNormalDistribution)
    marg = LogNormalDistribution()
    return equalityRule!(marg, forward_dist, backward_dist)
end
function calculateMarginal!(edge::Edge, forward_dist::LogNormalDistribution, backward_dist::LogNormalDistribution)
    marg = ensureMarginal!(edge, LogNormalDistribution)
    return equalityRule!(marg, forward_dist, backward_dist)
end


############################################
# BernoulliDistribution
############################################

function calculateMarginal(forward_dist::BernoulliDistribution, backward_dist::BernoulliDistribution)
    marg = BernoulliDistribution()
    return equalityRule!(marg, forward_dist, backward_dist)
end
function calculateMarginal!(edge::Edge, forward_dist::BernoulliDistribution, backward_dist::BernoulliDistribution)
    marg = ensureMarginal!(edge, BernoulliDistribution)
    return equalityRule!(marg, forward_dist, backward_dist)
end


############################################
# GaussianDistribution
############################################

function calculateMarginal(forward_dist::GaussianDistribution, backward_dist::GaussianDistribution)
    marg = GaussianDistribution()
    return equalityRule!(marg, forward_dist, backward_dist)
end
function calculateMarginal!(edge::Edge, forward_dist::GaussianDistribution, backward_dist::GaussianDistribution)
    marg = ensureMarginal!(edge, GaussianDistribution)
    return equalityRule!(marg, forward_dist, backward_dist)
end


############################################
# DeltaDistribution
############################################

function calculateMarginal(forward_dist::DeltaDistribution{Float64}, backward_dist::DeltaDistribution{Float64})
    marg = DeltaDistribution()
    return equalityRule!(marg, forward_dist, backward_dist)
end
function calculateMarginal!(edge::Edge, forward_dist::DeltaDistribution{Float64}, backward_dist::DeltaDistribution{Float64})
    marg = ensureMarginal!(edge, DeltaDistribution{Float64})
    return equalityRule!(marg, forward_dist, backward_dist)
end


############################################
# MvDeltaDistribution
############################################

function calculateMarginal(forward_dist::MvDeltaDistribution{Float64}, backward_dist::MvDeltaDistribution{Float64})
    marg = MvDeltaDistribution()
    return equalityRule!(marg, forward_dist, backward_dist)
end
function calculateMarginal!(edge::Edge, forward_dist::MvDeltaDistribution{Float64}, backward_dist::MvDeltaDistribution{Float64})
    marg = ensureMarginal!(edge, MvDeltaDistribution{Float64})
    return equalityRule!(marg, forward_dist, backward_dist)
end


############################################
# MvGaussianDistribution
############################################

function calculateMarginal(forward_dist::MvGaussianDistribution, backward_dist::MvGaussianDistribution)
    marg = deepcopy(forward_dist)
    return equalityRule!(marg, forward_dist, backward_dist)
end
function calculateMarginal!(edge::Edge, forward_dist::MvGaussianDistribution, backward_dist::MvGaussianDistribution)
    marg = ensureMarginal!(edge, MvGaussianDistribution)
    return equalityRule!(marg, forward_dist, backward_dist)
end


############################################
# Gaussian-students t combination
############################################

function calculateMarginal(forward_dist::GaussianDistribution, backward_dist::StudentsTDistribution)
    marg = GaussianDistribution()
    return equalityRule!(marg, forward_dist, backward_dist)
end
calculateMarginal(forward_dist::StudentsTDistribution, backward_dist::GaussianDistribution) = calculateMarginal(backward_dist, forward_dist)
function calculateMarginal!(edge::Edge, forward_dist::GaussianDistribution, backward_dist::StudentsTDistribution)
    marg = ensureMarginal!(edge, GaussianDistribution)
    return equalityRule!(marg, forward_dist, backward_dist)
end
calculateMarginal!(edge::Edge, forward_dist::StudentsTDistribution, backward_dist::GaussianDistribution) = calculateMarginal!(edge, backward_dist, forward_dist)


############################################
# Gaussian-Delta combination
############################################

function calculateMarginal(forward_dist::GaussianDistribution, backward_dist::DeltaDistribution{Float64})
    marg = DeltaDistribution()
    return equalityRule!(marg, forward_dist, backward_dist)
end
calculateMarginal(forward_dist::DeltaDistribution{Float64}, backward_dist::GaussianDistribution) = calculateMarginal(backward_dist, forward_dist)
function calculateMarginal!(edge::Edge, forward_dist::GaussianDistribution, backward_dist::DeltaDistribution{Float64})
    marg = ensureMarginal!(edge, DeltaDistribution{Float64})
    return equalityRule!(marg, forward_dist, backward_dist)
end
calculateMarginal!(edge::Edge, forward_dist::DeltaDistribution{Float64}, backward_dist::GaussianDistribution) = calculateMarginal!(edge, backward_dist, forward_dist)


############################################
# Gamma-Delta combination
############################################

function calculateMarginal(forward_dist::GammaDistribution, backward_dist::DeltaDistribution{Float64})
    marg = DeltaDistribution()
    return equalityRule!(marg, forward_dist, backward_dist)
end
calculateMarginal(forward_dist::DeltaDistribution{Float64}, backward_dist::GammaDistribution) = calculateMarginal(backward_dist, forward_dist)
function calculateMarginal!(edge::Edge, forward_dist::GammaDistribution, backward_dist::DeltaDistribution{Float64})
    marg = ensureMarginal!(edge, DeltaDistribution{Float64})
    return equalityRule!(marg, forward_dist, backward_dist)
end
calculateMarginal!(edge::Edge, forward_dist::DeltaDistribution{Float64}, backward_dist::GammaDistribution) = calculateMarginal!(edge, backward_dist, forward_dist)


############################################
# InverseGamma-Delta combination
############################################

function calculateMarginal(forward_dist::InverseGammaDistribution, backward_dist::DeltaDistribution{Float64})
    marg = DeltaDistribution()
    return equalityRule!(marg, forward_dist, backward_dist)
end
calculateMarginal(forward_dist::DeltaDistribution{Float64}, backward_dist::InverseGammaDistribution) = calculateMarginal(backward_dist, forward_dist)
function calculateMarginal!(edge::Edge, forward_dist::InverseGammaDistribution, backward_dist::DeltaDistribution{Float64})
    marg = ensureMarginal!(edge, DeltaDistribution{Float64})
    return equalityRule!(marg, forward_dist, backward_dist)
end
calculateMarginal!(edge::Edge, forward_dist::DeltaDistribution{Float64}, backward_dist::InverseGammaDistribution) = calculateMarginal!(edge, backward_dist, forward_dist)


############################################
# LogNormal-Delta combination
############################################

function calculateMarginal(forward_dist::LogNormalDistribution, backward_dist::DeltaDistribution{Float64})
    marg = DeltaDistribution()
    return equalityRule!(marg, forward_dist, backward_dist)
end
calculateMarginal(forward_dist::DeltaDistribution{Float64}, backward_dist::LogNormalDistribution) = calculateMarginal(backward_dist, forward_dist)
function calculateMarginal!(edge::Edge, forward_dist::LogNormalDistribution, backward_dist::DeltaDistribution{Float64})
    marg = ensureMarginal!(edge, DeltaDistribution{Float64})
    return equalityRule!(marg, forward_dist, backward_dist)
end
calculateMarginal!(edge::Edge, forward_dist::DeltaDistribution{Float64}, backward_dist::LogNormalDistribution) = calculateMarginal!(edge, backward_dist, forward_dist)


############################################
# MvDeltaDistribution
############################################

function calculateMarginal(forward_dist::MvDeltaDistribution{Float64}, backward_dist::MvDeltaDistribution{Float64})
    marg = deepcopy(forward_dist) # Do not overwrite an existing distribution
    return equalityRule!(marg, forward_dist, backward_dist)
end
function calculateMarginal!(edge::Edge, forward_dist::MvDeltaDistribution{Float64}, backward_dist::MvDeltaDistribution{Float64})
    marg = ensureMarginal!(edge, MvDeltaDistribution{Float64, dimensions(forward_dist)})
    return equalityRule!(marg, forward_dist, backward_dist)
end


############################################
# MvGaussianDistribution
############################################

function calculateMarginal(forward_dist::MvGaussianDistribution, backward_dist::MvGaussianDistribution)
    marg = deepcopy(forward_dist)
    return equalityRule!(marg, forward_dist, backward_dist)
end
function calculateMarginal!(edge::Edge, forward_dist::MvGaussianDistribution, backward_dist::MvGaussianDistribution)
    marg = ensureMarginal!(edge, MvGaussianDistribution{dimensions(forward_dist)})
    return equalityRule!(marg, forward_dist, backward_dist)
end


############################################
# WishartDistribution
############################################

function calculateMarginal(forward_dist::WishartDistribution, backward_dist::WishartDistribution)
    marg = deepcopy(forward_dist)
    return equalityRule!(marg, forward_dist, backward_dist)
end
function calculateMarginal!(edge::Edge, forward_dist::WishartDistribution, backward_dist::WishartDistribution)
    marg = ensureMarginal!(edge, WishartDistribution{dimensions(forward_dist)})
    return equalityRule!(marg, forward_dist, backward_dist)
end

############################################
# PartitionedDistribution
############################################

function calculateMarginal{dtype1,dtype2,n_factors}(forward_dist::PartitionedDistribution{dtype1,n_factors}, backward_dist::PartitionedDistribution{dtype2,n_factors})
    return PartitionedDistribution([calculateMarginal(forward_dist.factors[i], backward_dist.factors[i]) for i=1:n_factors])
end
function calculateMarginal!{dtype1,dtype2,n_factors}(edge::Edge, forward_dist::PartitionedDistribution{dtype1,n_factors}, backward_dist::PartitionedDistribution{dtype2,n_factors})
    return edge.marginal = calculateMarginal(forward_dist, backward_dist)
end


############################################
# MvGaussian-MvDelta combination
############################################

function calculateMarginal(forward_dist::MvGaussianDistribution, backward_dist::MvDeltaDistribution{Float64})
    marg = deepcopy(forward_dist)
    return equalityRule!(marg, forward_dist, backward_dist)
end

calculateMarginal(forward_dist::MvGaussianDistribution, backward_dist::MvDeltaDistribution{Float64}) = calculateMarginal(backward_dist, forward_dist)

function calculateMarginal!(edge::Edge, forward_dist::MvDeltaDistribution{Float64}, backward_dist::MvGaussianDistribution)
    marg = ensureMarginal!(edge, MvDeltaDistribution{Float64, dimensions(forward_dist)})
    return equalityRule!(marg, forward_dist, backward_dist)
end
calculateMarginal!(edge::Edge, forward_dist::MvDeltaDistribution{Float64}, backward_dist::MvGaussianDistribution) = calculateMarginal!(edge, backward_dist, forward_dist)

# Wishart-MvDelta combination
function calculateMarginal(forward_dist::MvDeltaDistribution{Float64}, backward_dist::WishartDistribution)
    marg = deepcopy(forward_dist)
    return equalityRule!(marg, forward_dist, backward_dist)
end

calculateMarginal(forward_dist::WishartDistribution, backward_dist::MvDeltaDistribution{Float64}) = calculateMarginal(backward_dist, forward_dist)

function calculateMarginal!(edge::Edge, forward_dist::MvDeltaDistribution{Float64}, backward_dist::WishartDistribution)
    marg = ensureMarginal!(edge, MvDeltaDistribution{Float64, dimensions(forward_dist)})
    return equalityRule!(marg, forward_dist, backward_dist)
end

calculateMarginal!(edge::Edge, forward_dist::WishartDistribution, backward_dist::MvDeltaDistribution{Float64}) = calculateMarginal!(edge, backward_dist, forward_dist)
