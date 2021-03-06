export
ruleSPCategoricalOutVP,
ruleVBCategoricalOut,
ruleVBCategoricalIn1

ruleSPCategoricalOutVP(msg_out::Void, msg_p::Message{PointMass, Multivariate}) = Message(Univariate, Categorical, p=deepcopy(msg_p.dist.params[:m]))

function ruleVBCategoricalOut(marg_out::Any, marg_p::ProbabilityDistribution{Multivariate})
    rho = clamp.(exp.(unsafeLogMean(marg_p)), tiny, huge)
    
    Message(Univariate, Categorical, p=rho./sum(rho))
end

ruleVBCategoricalIn1(marg_out::ProbabilityDistribution, marg_p::Any) = Message(Multivariate, Dirichlet, a=unsafeMeanVector(marg_out) + 1.0)