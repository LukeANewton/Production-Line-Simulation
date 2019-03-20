%Generates the next C2Ready/C3Ready event for inspector 2.
function e = getNextInspector2Event()
    global C2Dist C3Dist queueC2W2 queueC3W3 clock lastComponentInspector2Held;
    
    if isQueueFull(queueC2W2) %if there is no space to place a C2, pick a C3 to inspect next
        e = Event(clock + random(C3Dist), EventType.C3Ready);
        lastComponentInspector2Held = 3;
    elseif isQueueFull(queueC3W3) %if there is no space to place a C3, pick a C2 to inspect next
        e = Event(clock + random(C2Dist), EventType.C2Ready);
        lastComponentInspector2Held = 2;
    else %neither queue is full so randomly pick a C2 or C3 to inspect next
        bernoulli = rand();
        bernoulli = bernoulli > 0.5;
        if bernoulli == 1
            e = Event(clock + random(C2Dist), EventType.C2Ready);
            lastComponentInspector2Held = 2;
        else
            e = Event(clock + random(C3Dist), EventType.C3Ready);
            lastComponentInspector2Held = 3;
        end
    end
end 