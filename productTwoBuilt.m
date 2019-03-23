% Product 2
function productTwoBuilt()
    global queueC1W2 queueC2W2;
    global inspectorOneBlocked inspectorTwoBlocked;
    global W2Dist rngW2 FEL clock P2Produced P2InProduction;
    global lastComponentInspector2Held;
    global workstationTwoIdle idleStartW2;
    global Inspector1IdleTime idleEndI1 idleStartI1;
    global Inspector2IdleTime idleEndI2 idleStartI2;
    
    P2Produced = P2Produced + 1;
    P2InProduction = false;
    
    if isQueueEmpty(queueC1W2) || isQueueEmpty(queueC2W2)
       workstationTwoIdle = true;
       % Read the CURRENT time for when the workstation starts being idle
       idleStartW2 = clock;
    else
        queueC1W2 = queueC1W2 - 1;
        queueC2W2 = queueC2W2 - 1;
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
        if inspectorTwoBlocked == true && lastComponentInspector2Held == 2% blocked and only if he is holding a C2!
            inspectorTwoBlocked = false;
            idleEndI2 = clock;
            difference = idleEndI2 - idleStartI2;
            Inspector2IdleTime = Inspector2IdleTime + difference;
            % Generates C2Ready event AT CURRENT TIME
            % This causes the inspector to try to place it's component again
            eC2 = Event(clock, EventType.C2Ready);
            FEL = FEL.addEvent(eC2);
            if verbose
                fprintf('inspector 2 unblocked\n');
            end
        end  
        % Generate next P2Build Event and add it to FEL
        P2InProduction = true;
        %get the inspection time from entering a random numer [0, 1] into
        %inverse cdf
        timeToAssemble = W2Dist.icdf(rand(rngW2));
        eP2 = Event(clock + timeToAssemble, EventType.P2Built);
        FEL = FEL.addEvent(eP2);
        if verbose
            fprintf('assembling another P2\n');
        end
    end 
end

