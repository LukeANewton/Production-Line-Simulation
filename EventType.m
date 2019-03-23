%Defines an enumeration of all valid event types for the simulation.
%These are:
%C1Ready: Inspector 1 has finished inspecting a C1 component
%C2Ready: Inspector 2 has finished inspecting a C2 component
%C3Ready: Inspector 2 has finished inspecting a C3 component
%P1Built: Workstation 1 has produced a P1
%P2Built: Workstation 1 has produced a P2
%P3Built: Workstation 1 has produced a P3
classdef EventType
    enumeration
        C1Ready, C2Ready, C3Ready, P1Built, P2Built, P3Built, endOfSimulation
    end
end
