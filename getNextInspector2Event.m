%Generates the next C2Ready/C3Ready event for inspector 2.
function e = getNextInspector2Event()
    global C2Dist C3Dist rngC2 rngC3 verbose;
    global queueC2W2 queueC3W3 clock lastComponentInspector2Held;
    if isQueueFull(queueC2W2) %if there is no space to place a C2, pick a C3 to inspect next
        lastComponentInspector2Held = 3;
    elseif isQueueFull(queueC3W3) %if there is no space to place a C3, pick a C2 to inspect next
        lastComponentInspector2Held = 2;
    else %neither queue is full so randomly pick a C2 or C3 to inspect next
        bernoulli = rand();
        bernoulli = bernoulli > 0.5;
        if bernoulli == 1
            lastComponentInspector2Held = 2;
        else
            lastComponentInspector2Held = 3;
        end
    end
    if lastComponentInspector2Held == 2
        %get the inspection time from entering a random numer [0, 1] into
        %inverse cdf
        inspectionTime = C2Dist.icdf(rand(rngC2));
        e = Event(clock + inspectionTime, EventType.C2Ready);
    elseif lastComponentInspector2Held == 3
        inspectionTime = C3Dist.icdf(rand(rngC3));
        e = Event(clock + inspectionTime, EventType.C3Ready);
    end
    if verbose
        fprintf('inspector 2 inspecting component %d next\n', lastComponentInspector2Held);
    end
end 