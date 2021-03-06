export Dirichlet

"""
Description:
    Dirichlet factor node

    Real vector
    a .> 0

    Multivariate:
    f(out, a) = Dir(out|a)
              = Γ(Σ_i a_i)/(Π_i Γ(a_i)) Π_i out_i^{a_i}

    Matrix variate with independent rows:
    f(out, a) = Π_j Dir(out|a_j.)
              = Π_j Γ(Σ_k a_jk)/(Π_k Γ(a_jk)) Π_k out_jk^{a_jk}

Interfaces:
    1. out
    2. a

Construction:
    Dirichlet(id=:some_id)
"""
mutable struct Dirichlet <: SoftFactor
    id::Symbol
    interfaces::Vector{Interface}
    i::Dict{Symbol,Interface}

    function Dirichlet(out, a; id=generateId(Dirichlet))
        @ensureVariables(out, a)
        self = new(id, Array{Interface}(2), Dict{Symbol,Interface}())
        addNode!(currentGraph(), self)
        self.i[:out] = self.interfaces[1] = associate!(Interface(self), out)
        self.i[:a] = self.interfaces[2] = associate!(Interface(self), a)

        return self
    end
end

slug(::Type{Dirichlet}) = "Dir"

format{V<:VariateType}(dist::ProbabilityDistribution{V, Dirichlet}) = "$(slug(Dirichlet))(a=$(format(dist.params[:a])))"

ProbabilityDistribution(::Type{MatrixVariate}, ::Type{Dirichlet}; a=ones(3,3)) = ProbabilityDistribution{MatrixVariate, Dirichlet}(Dict(:a=>a))
ProbabilityDistribution(::Type{Multivariate}, ::Type{Dirichlet}; a=ones(3)) = ProbabilityDistribution{Multivariate, Dirichlet}(Dict(:a=>a))
ProbabilityDistribution(::Type{Dirichlet}; a=ones(3)) = ProbabilityDistribution{Multivariate, Dirichlet}(Dict(:a=>a))

dims(dist::ProbabilityDistribution{Multivariate, Dirichlet}) = length(dist.params[:a])
dims(dist::ProbabilityDistribution{MatrixVariate, Dirichlet}) = size(dist.params[:a])

vague(::Type{Dirichlet}, dims::Int64) = ProbabilityDistribution(Multivariate, Dirichlet, a=ones(dims))
vague(::Type{Dirichlet}, dims::Tuple{Int64, Int64}) = ProbabilityDistribution(MatrixVariate, Dirichlet, a=ones(dims))

isProper{V<:VariateType}(dist::ProbabilityDistribution{V, Dirichlet}) = all(dist.params[:a] .> 0.0)

unsafeMean(dist::ProbabilityDistribution{Multivariate, Dirichlet}) = dist.params[:a]./sum(dist.params[:a])
unsafeMean(dist::ProbabilityDistribution{MatrixVariate, Dirichlet}) = dist.params[:a]./sum(dist.params[:a],2)

unsafeLogMean(dist::ProbabilityDistribution{Multivariate, Dirichlet}) = digamma.(dist.params[:a]) - digamma.(sum(dist.params[:a]))
unsafeLogMean(dist::ProbabilityDistribution{MatrixVariate, Dirichlet}) = digamma.(dist.params[:a]) .- digamma.(sum(dist.params[:a],2))

function unsafeVar(dist::ProbabilityDistribution{Multivariate, Dirichlet})
    a_sum = sum(dist.params[:a])
    return dist.params[:a].*(a_sum - dist.params[:a])./(a_sum^2*(a_sum + 1.0))
end

function prod!{V<:VariateType}( x::ProbabilityDistribution{V, Dirichlet},
                                y::ProbabilityDistribution{V, Dirichlet},
                                z::ProbabilityDistribution{V, Dirichlet}=ProbabilityDistribution(V, Dirichlet, a=ones(dims(x))))

    z.params[:a] = x.params[:a] + y.params[:a] - 1.0

    return z
end

@symmetrical function prod!(x::ProbabilityDistribution{Multivariate, Dirichlet},
                            y::ProbabilityDistribution{Multivariate, PointMass},
                            z::ProbabilityDistribution{Multivariate, PointMass}=ProbabilityDistribution(Multivariate, PointMass, m=[NaN]))

    all(0.0 .<= y.params[:m] .<= 1.0) || error("PointMass location entries $(y.params[:m]) should all be between 0 and 1")
    isapprox(sum(y.params[:m]), 1.0) || error("Pointmass location entries $(y.params[:m]) should sum to one")
    z.params[:m] = deepcopy(y.params[:m])

    return z
end

@symmetrical function prod!(x::ProbabilityDistribution{MatrixVariate, Dirichlet},
                            y::ProbabilityDistribution{MatrixVariate, PointMass},
                            z::ProbabilityDistribution{MatrixVariate, PointMass}=ProbabilityDistribution(MatrixVariate, PointMass, m=mat(NaN)))

    all(0.0 .<= y.params[:m] .<= 1.0) || error("PointMass location entries $(y.params[:m]) should all be between 0 and 1")
    for j = 1:dims(y)[1]
        isapprox(sum(y.params[:m][j,:]), 1.0) || error("Pointmass location entries $(y.params[:m][j,:]) of row $j should sum to one")
    end

    z.params[:m] = deepcopy(y.params[:m])

    return z
end

# Entropy functional
function differentialEntropy(dist::ProbabilityDistribution{Multivariate, Dirichlet})
    a_sum = sum(dist.params[:a])

    -sum( (dist.params[:a] - 1.0).*(digamma.(dist.params[:a]) - digamma.(a_sum)) ) -
    lgamma(a_sum) +
    sum( lgamma.(dist.params[:a]) )
end

function differentialEntropy(dist::ProbabilityDistribution{MatrixVariate, Dirichlet})
    H = 0.0
    for j = 1:dims(dist)[1]
        a_sum = sum(dist.params[:a][j,:])

        H += -sum( (dist.params[:a][j,:] - 1.0).*(digamma.(dist.params[:a][j,:]) - digamma.(a_sum)) ) -
        lgamma(a_sum) +
        sum( lgamma.(dist.params[:a][j,:]) )
    end

    return H
end

# Average energy functional
function averageEnergy(::Type{Dirichlet}, marg_out::ProbabilityDistribution{Multivariate}, marg_a::ProbabilityDistribution{Multivariate, PointMass})
    a_sum = sum(marg_a.params[:m])

    -lgamma(a_sum) +
    sum( lgamma.(marg_a.params[:m]) ) -
    sum( (marg_a.params[:m] - 1.0).*unsafeLogMean(marg_out) )
end

function averageEnergy(::Type{Dirichlet}, marg_out::ProbabilityDistribution{MatrixVariate}, marg_a::ProbabilityDistribution{MatrixVariate, PointMass})
    (dims(marg_out) == dims(marg_a)) || error("Distribution dimensions must agree")

    log_mean_marg_out = unsafeLogMean(marg_out)

    H = 0.0
    for j = 1:dims(marg_out)[1]
        a_sum = sum(marg_a.params[:m][j,:])

        H += -lgamma(a_sum) +
        sum( lgamma.(marg_a.params[:m][j,:]) ) -
        sum( (marg_a.params[:m][j,:] - 1.0).*log_mean_marg_out[j,:] )
    end

    return H
end
