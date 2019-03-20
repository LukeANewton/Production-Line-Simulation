% Product 1
function productOneBuilt()
    global queueC1W1; 
    global inspectorOneBlocked;
    global W1Dist FEL clock P1Produced P1InProduction;
    global workstationOneIdle idleStartW1; 
    global idleStartI1 idleEndI1 Inspector1IdleTime;
    
    P1Produced = P1Produced + 1;
    P1InProduction = false;
    
    if isQueueEmpty(queueC1W1)
       workstationOneIdle = true;
       % Read the CURRENT time for when the workstation starts being idle
       idleStartW1 = clock;
    else
        queueC1W1 = queueC1W1 - 1;
        if inspectorOneBlocked == true
            inspectorOneBlocked = false;
            idleEndI1 = clock;
            difference = idleEndI1 - idleStartI1;
            Inspector1IdleTime = Inspector1IdleTime + difference;
            
            % Generates C1Ready event AT CURRENT TIME
            % This causes the inspector to try to place it's component again
            eC1 = Event(clock, EventType.C1Ready);
            FEL = FEL.addEvent(eC1);
        end
         % Generate next P1Build Event and add it to FEL
         P1InProduction = true;
         eP1 = Event(clock + random(W1Dist), EventType.P1Built);
         FEL = FEL.addEvent(eP1);
    end  
end
