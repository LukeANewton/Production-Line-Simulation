% Product 1
function productOneBuilt()
    global queueC1W1 inspectorOneBlocked W1Dist FEL clock P1Produced;

    if isQueueEmpty(queueC1W1)
       %TO DO: Set W1 to idle
    else
        % Removes a C1 component from the queue
        queueC1W1 = queueC1W1 - 1;
        if inspectorOneBlocked
            inspectorOneBlocked = false;
            % Generates C1Ready event AT CURRENT TIME
            % This causes the inspector to try to place it's component again
            e1 = Event(clock, EventType.C1Ready);
            FEL.addEvent(e1);
        end
         % Generate next P1Build Event and add it to FEL
         timeToAssemble = random(W1Dist);
         e2 = Event(clock + timeToAssemble, EventType.P1Built);
         FEL.addEvent(e2);
         P1Produced = P1Produced + 1;
    end  
end
