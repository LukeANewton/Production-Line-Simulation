%Generates the next C2Ready/C3Ready event for inspector 2.
function e = getNextInspector2Event()
    global C2Dist C3Dist queueC2W2 queueC3W3 clock maxSimulationTime;
    
    if queueC2W2 == 2 %if there is no space to place a C2, pick a C3 to inspect next
        timeToInspect = random(C2Dist);
        if maxSimulationTime > clock + timeToInspect %only generate another event if before simualtion end time
            e = Event(clock + timeToInspect, EventType.C2Ready);
        end
    elseif queueC3W3 == 2 %if there is no space to place a C3, pick a C2 to inspect next
        timeToInspect = random(C3Dist);
        if maxSimulationTime > clock + timeToInspect 
            e = Event(clock + timeToInspect, EventType.C3Ready);
        end
    else %neither queue is full so randomly pick a C2 or C3 to inspect next
     bernoulli = rand();
     bernoulli = bernoulli > 0.5;
     if bernoulli == 1
         timeToInspect = random(C2Dist);
         if maxSimulationTime > clock + timeToInspect
            e = Event(clock + timeToInspect, EventType.C2Ready);
         end
     else
         timeToInspect = random(C3Dist);
         if maxSimulationTime > clock + timeToInspect
            e = Event(clock + timeToInspect, EventType.C3Ready);
         end
     end
    end
end 