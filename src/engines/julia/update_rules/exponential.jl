export
ruleSPExponentialOutVG,
ruleSPExponentialOutVP,
ruleSPExponentialIn1LV,
ruleSPExponentialIn1PV

function ruleSPExponentialOutVG{F<:Gaussian}(	msg_out::Void, 
                                				msg_in1::Message{F, Univariate})

    d_in1 = convert(ProbabilityDistribution{Univariate, GaussianMeanVariance}, msg_in1.dist)

    return Message(Univariate, LogNormal, m=d_in1.params[:m], s=d_in1.params[:v])
end

ruleSPExponentialIn1LV(msg_out::Message{LogNormal, Univariate}, msg_in1::Void) = 
	Message(Univariate, GaussianMeanVariance, m=msg_out.dist.params[:m], v=msg_out.dist.params[:s])

ruleSPExponentialOutVP(msg_out::Void, msg_in1::Message{PointMass, Univariate}) = 
	Message(Univariate, PointMass, m=exp(msg_in1.dist.params[:m]))

ruleSPExponentialIn1PV(msg_out::Message{PointMass, Univariate}, msg_in1::Void) = 
	Message(Univariate, PointMass, m=log(msg_out.dist.params[:m]))