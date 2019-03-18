% Product 3
function productThreeBuilt()
    global queueC1W3 queueC3W3;
    global inspectorOneBlocked inspectorTwoBlocked;
    global W3Dist FEL clock P3Produced;
    global lastComponentInspector2Held;
    global workstationThreeIdle idleStartW3;
    
    P3Produced = P3Produced + 1;
    
    if isQueueEmpty(queueC1W3) && isQueueEmpty(queueC3W3)
       workstationThreeIdle = true;
       % Read the CURRENT time for when the workstation starts being idle
       idleStartW3 = clock; 
    else 
        queueC1W3 = queueC1W3 - 1;
        queueC3W3 = queueC3W3 - 1;
        if inspectorOneBlocked == true
            inspectorOneBlocked = false;
            % Generates C1Ready event AT CURRENT TIME
            % This causes the inspector to try to place it's component again
            eC1 = Event(clock, EventType.C1Ready);
            FEL = FEL.addEvent(eC1);
        end
        if inspectorTwoBlocked == true && lastComponentInspector2Held == 3% blocked and only if he is holding a C3!
            inspectorTwoBlocked = false;
            % Generates C3Ready event AT CURRENT TIME
            % This causes the inspector to try to place it's component again
            eC3 = Event(clock, EventType.C3Ready);
            FEL = FEL.addEvent(eC3);
        end  
        % Generate next P3Build Event and add it to FEL
         timeToAssemble = random(W3Dist);
         eP3 = Event(clock + timeToAssemble, EventType.P3Built);
         FEL = FEL.addEvent(eP3);
    end 
end