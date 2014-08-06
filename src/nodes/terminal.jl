############################################
# TerminalNode
############################################
# Description:
#   Simple node with just 1 interface.
#   Always sends out a predefined message.
#
#           out
#   [value]----->
#
#   out = value
#
# One can pass the value to the constructor, and
# modify the value directly later.
#
# Example:
#   TerminalNode(GaussianDistribution(), name="myterminal")
#
# Interface ids, (names) and supported message types:
#   1. (out):
#       Message{Any}
############################################

export TerminalNode

type TerminalNode <: Node
    value::Any
    interfaces::Array{Interface,1}
    name::ASCIIString
    out::Interface

    function TerminalNode(value=1.0; name="unnamed")
        if typeof(value) <: Message || typeof(value) == DataType
            error("TerminalNode $(name) can not hold value of type $(typeof(value)).")
        end
        self = new(deepcopy(value), Array(Interface, 1), name)
        # Create interface
        self.interfaces[1] = Interface(self)
        # Init named interface handle
        self.out = self.interfaces[1]
        return self
    end
end

# Overload firstFreeInterface since EqualityNode is symmetrical in its interfaces
firstFreeInterface(node::TerminalNode) = (node.out.partner==nothing) ? node.out : error("No free interface on $(typeof(node)) $(node.name)")

function updateNodeMessage!(node::TerminalNode,
                            outbound_interface_id::Int,
                            outbound_message_payload_type::DataType,
                            ::Any)
    # Calculate an outbound message. The TerminalNode does not accept incoming messages.
    # This function is not exported, and is only meant for internal use.
    (typeof(node.value) <: outbound_message_payload_type) || error("TerminalNode cannot produce a message with payload type $(outbound_message_value_type) since the node value is of type $(typeof(node.value))")
    return node.out.message = Message(node.value)
end