#####################
# Integration tests
#####################

facts("Read/write buffer integration tests") do
    context("ensureValue!() should ensure TerminalNode has a value") do
        # Used for readbuffer attachment
        FactorGraph()
        node = TerminalNode()

        @fact ForneyLab.ensureValue!(node, Float64) --> Delta()
        @fact ForneyLab.ensureValue!(node, Bernoulli) --> Bernoulli()
        @fact ForneyLab.ensureValue!(node, Delta{Float64}) --> Delta()
        @fact ForneyLab.ensureValue!(node, Bool) --> Delta(false)
        @fact ForneyLab.ensureValue!(node, Gaussian) --> vague(Gaussian)
        @fact ForneyLab.ensureValue!(node, MvDelta{Float64, 3}) --> MvDelta([0.0, 0.0, 0.0])
        @fact ForneyLab.ensureValue!(node, MatrixDelta{Float64, 2, 3}) --> MatrixDelta(zeros(2, 3))
    end

    # attachReadBuffer
    context("attachReadBuffer should register a read buffer for a TerminalNode") do
        g = initializeBufferGraph()
        read_buffer = zeros(10)
        attachReadBuffer(n(:node_t1), read_buffer)
        @fact g.read_buffers[n(:node_t1)] --> read_buffer
    end

    context("attachReadBuffer should register a mini-batch read buffer for a TerminalNode array") do
        data = [1.0, 1.0, 1.0]
        initializeGaussianNodeChain(data)
        graph = currentGraph()
        more_data = [1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 3.0, 3.0, 3.0]
        attachReadBuffer([n(:y1), n(:y2), n(:y3)], more_data, graph)
        @fact graph.read_buffers[n(:y1)] --> [1.0, 2.0, 3.0]
        @fact graph.read_buffers[n(:y2)] --> [1.0, 2.0, 3.0]
        @fact graph.read_buffers[n(:y3)] --> [1.0, 2.0, 3.0]
    end

    context("detachReadBuffer should detach a read buffer from a terminal node") do
        g = initializeBufferGraph()
        read_buffer = zeros(10)
        attachReadBuffer(n(:node_t1), read_buffer)
        detachReadBuffer(n(:node_t1))
        @fact length(g.read_buffers) --> 0
    end

    context("emptyReadBuffers should empty read buffers while retaining pointers") do
        g = initializeBufferGraph()
        read_buffer = zeros(10)
        attachReadBuffer(n(:node_t1), read_buffer)
        emptyReadBuffers(g)
        @fact g.read_buffers[n(:node_t1)] --> read_buffer
        @fact length(g.read_buffers[n(:node_t1)]) --> 0
        @fact g.current_section --> 1
    end

    # attachWriteBuffer
    context("attachWriteBuffer should register a write buffer for an Interface") do
        g = initializeBufferGraph()
        write_buffer = Array(Any, 0)
        attachWriteBuffer(n(:node_t1).i[:out], write_buffer)
        @fact g.write_buffers[n(:node_t1).i[:out]] --> write_buffer
    end
    context("attachWriteBuffer should register a write buffer for an Edge (marginal)") do
        g = initializeBufferGraph()
        write_buffer = Array(Any, 0)
        attachWriteBuffer(eg(:e), write_buffer)
        @fact g.write_buffers[eg(:e)] --> write_buffer
    end

    # detachWriteBuffer
    context("detachWriteBuffer should deregister a write buffer on an edge") do
        g = initializeBufferGraph()
        write_buffer = Array(Any, 0)
        attachWriteBuffer(eg(:e), write_buffer)
        detachWriteBuffer(eg(:e))
        @fact length(g.write_buffers) --> 0
    end
    context("detachWriteBuffer should deregister a write buffer on an interface") do
        g = initializeBufferGraph()
        write_buffer = Array(Any, 0)
        attachWriteBuffer(n(:node_t1).i[:out], write_buffer)
        detachWriteBuffer(n(:node_t1).i[:out])
        @fact length(g.write_buffers) --> 0
    end

    context("detachBuffers should deregister all read/write buffers") do
        g = initializeBufferGraph()
        write_buffer = Array(Any, 0)
        attachWriteBuffer(eg(:e), write_buffer)
        detachBuffers(g)
        @fact length(g.read_buffers) --> 0
        @fact length(g.write_buffers) --> 0
    end

    context("emptyWriteBuffers should empty write buffers while retaining pointers") do
        g = initializeBufferGraph()
        write_buffer = Array(Any, 0)
        attachWriteBuffer(n(:node_t1).i[:out], write_buffer)
        emptyWriteBuffers(g)
        @fact g.write_buffers[n(:node_t1).i[:out]] --> write_buffer
        @fact length(g.write_buffers[n(:node_t1).i[:out]]) --> 0
    end
end

facts("step integration tests") do
    context("step should perform a time step and handle read/write buffers") do
        # out = in + delta
        g = FactorGraph()
        TerminalNode(Delta(0.0), id=:in)
        AdditionNode(id=:add)
        TerminalNode(Delta(), id=:delta)
        TerminalNode(Delta(), id=:out)
        Edge(n(:in), n(:add).i[:in1])
        Edge(n(:delta), n(:add).i[:in2])
        Edge(n(:add).i[:out], n(:out))
        Wrap(n(:out), n(:in))
        deltas = [Delta(n) for n in collect(1.:10.)]
        attachReadBuffer(n(:delta), deltas)
        results = attachWriteBuffer(n(:add).i[:out])
        algo = SumProduct(g) # The timewraps and buffers tell the autoscheduler what should be computed
        prepare!(algo)
        while g.current_section <= length(deltas)
            step(algo)
        end
        @fact results --> [Delta(r) for r in cumsum(collect(1.:10.))]
    end
end

facts("run() integration tests") do
    context("run() should step() until a read buffer is exhausted") do
        # out = in + delta
        g = FactorGraph()
        TerminalNode(Delta(0.0), id=:in)
        AdditionNode(id=:add)
        TerminalNode(Delta(), id=:delta)
        TerminalNode(Delta(), id=:out)
        Edge(n(:in), n(:add).i[:in1])
        Edge(n(:delta), n(:add).i[:in2])
        Edge(n(:add).i[:out], n(:out))
        Wrap(n(:out), n(:in))
        deltas = [Delta(n) for n in collect(1.:10.)]
        attachReadBuffer(n(:delta), deltas)
        results = attachWriteBuffer(n(:add).i[:out])
        algo = SumProduct()
        run(algo)
        @fact results --> [Delta(r) for r in cumsum(collect(1.:10.))]
    end
end
