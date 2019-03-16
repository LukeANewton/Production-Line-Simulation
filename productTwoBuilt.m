% Product 2
function productTwoBuilt()
    global queueC1W2 queueC2W2;
    global inspectorOneBlocked inspectorTwoBlocked;
    global W2Dist FEL clock P2Produced;
    global lastComponentInspector2Held;
    
    if isQueueEmpty(queueC1W2) && isQueueEmpty(queueC2W2)
       %TO DO: Set W2 to idle
    else
        queueC1W2 = queueC1W2 - 1;
        queueC2W2 = queueC2W2 - 1;
        if inspectorOneBlocked
            inspectorOneBlocked = false;
            % Generates C1Ready event AT CURRENT TIME
            % This causes the inspector to try to place it's component again
            eC1 = Event(clock, EventType.C1Ready);
            FEL.addEvent(eC1);
        end
        if inspectorTwoBlocked == true && lastComponentInspector2Held == 2% blocked and only if he is holding a C2!
            inspectorTwoBlocked = false;
            % Generates C2Ready event AT CURRENT TIME
            % This causes the inspector to try to place it's component again
            eC2 = Event(clock, EventType.C2Ready);
            FEL.addEvent(eC2);
        end  
        % Generate next P2Build Event and add it to FEL
         timeToAssemble = random(W2Dist);
         eP2 = Event(clock + timeToAssemble, EventType.P2Built);
         FEL.addEvent(eP2);
         P2Produced = P2Produced + 1;
    end 
end

