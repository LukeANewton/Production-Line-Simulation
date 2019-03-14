%Generates the next C1Ready event for insepctor 1.
function e = getNextInspector1Event()
    global C1Dist clock;
    timeToInspect = random(C1Dist);
    e = Event(clock + timeToInspect, EventType.C1Ready);
end

