% Product 1
function productOneBuilt()
    global queueC1W1; 
    global inspectorOneBlocked;
    global W1Dist FEL clock P1Produced;

    if isQueueEmpty(queueC1W1)
       %TO DO: Set W1 to idle
    else
        queueC1W1 = queueC1W1 - 1;
        if inspectorOneBlocked == true
            inspectorOneBlocked = false;
            % Generates C1Ready event AT CURRENT TIME
            % This causes the inspector to try to place it's component again
            eC1 = Event(clock, EventType.C1Ready);
            FEL.addEvent(eC1);
        end
         % Generate next P1Build Event and add it to FEL
         timeToAssemble = random(W1Dist);
         eP1 = Event(clock + timeToAssemble, EventType.P1Built);
         FEL.addEvent(eP1);
         P1Produced = P1Produced + 1;
    end  
end
