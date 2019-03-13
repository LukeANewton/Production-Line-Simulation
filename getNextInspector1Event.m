%Generates the next C1Ready event for insepctor 1.
function e = getNextInspector1Event()
    global C1Dist clock maxSimulationTime;
    timeToInspect = random(C1Dist);
    if maxSimulationTime > clock + timeToInspect %only generate another event if before simualtion end time
        e = Event(clock + timeToInspect, EventType.C1Ready);
    end
end

