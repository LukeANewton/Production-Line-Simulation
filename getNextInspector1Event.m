%Generates the next C1Ready event for insepctor 1.
function e = getNextInspector1Event()
    global C1Dist clock rngC1;
    %get the inspection time from entering a random numer [0, 1] into
    %inverse cdf
    inspectionTime = C1Dist.icdf(rand(rngC1));
    e = Event(clock + inspectionTime, EventType.C1Ready);
end

