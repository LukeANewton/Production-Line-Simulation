%generates the next C1Ready event for insepctor 1
function e = getNextInspector1Event()
    global C1Dist clock;
    e = Event(clock + random(C1Dist), EventType.C1Ready);
end

