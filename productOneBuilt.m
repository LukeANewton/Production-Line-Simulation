% Product 1
function productOneBuilt()
    global queueC1W1; 
    global inspectorOneBlocked;
    global W1Dist FEL clock P1Produced;
    global workstationOneIdle idleStartW1; 

    P1Produced = P1Produced + 1;
    
    if isQueueEmpty(queueC1W1)
       workstationOneIdle = true;
       % Read the CURRENT time for when the workstation starts being idle
       idleStartW1 = clock;
    else
        queueC1W1 = queueC1W1 - 1;
        if inspectorOneBlocked == true
            inspectorOneBlocked = false;
            % Generates C1Ready event AT CURRENT TIME
            % This causes the inspector to try to place it's component again
            eC1 = Event(clock, EventType.C1Ready);
            FEL = FEL.addEvent(eC1);
        end
         % Generate next P1Build Event and add it to FEL
         timeToAssemble = random(W1Dist);
         eP1 = Event(clock + timeToAssemble, EventType.P1Built);
         FEL = FEL.addEvent(eP1);
    end  
end
