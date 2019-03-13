%generates the next C2Ready/C3Ready event for inspector 2
%TO DO: inspector 2 should only randomly pick a component if
%both C2 and C3 queues are not full. If one of the queues is full,
%the inspector should inspect a component of the other type next
function e = getNextInspector2Event()
    global C2Dist C3Dist queueC2W2 queueC3W3 clock;
    
    if queueC2W2 == 2 %if there is no space to place a C2, pick a C3 to inspect next
        e = Event(clock + random(C2Dist), EventType.C2Ready);
    elseif queueC3W3 == 2 %if there is no space to place a C3, pick a C2 to inspect next
        e = Event(clock + random(C3Dist), EventType.C3Ready);
    else %neither queue is full so randomly pick a C2 or C3 to inspect next
     bernoulli = rand();
     bernoulli = bernoulli > 0.5;
     if bernoulli == 1
         e = Event(clock + random(C2Dist), EventType.C2Ready);
     else
         e = Event(clock + random(C3Dist), EventType.C3Ready);
     end
    end
end 