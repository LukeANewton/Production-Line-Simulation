% Product 2
function productTwoBuilt()
    global queueC1W2 queueC2W2 verbose;
    global inspectorOneBlocked;
    global W2Dist rngW2 FEL clock P2Produced P2InProduction;
    global workstationTwoIdle idleStartW2;
    global W2IdleStartTimes I1IdleEndTimes;
    
    P2Produced = P2Produced + 1;
    P2InProduction = false;
    
    if isQueueEmpty(queueC1W2) || isQueueEmpty(queueC2W2)
       workstationTwoIdle = true;
       % Read the CURRENT time for when the workstation starts being idle
       idleStartW2 = clock;
       W2IdleStartTimes = [W2IdleStartTimes clock];
    else
        queueC1W2 = queueC1W2 - 1;
        queueC2W2 = queueC2W2 - 1;
        if inspectorOneBlocked == true
            inspectorOneBlocked = false;
            I1IdleEndTimes = [I1IdleEndTimes clock];
            
            % Generates C1Ready event AT CURRENT TIME
            % This causes the inspector to try to place it's component again
            eC1 = Event(clock, EventType.C1Ready);
            FEL = FEL.addEvent(eC1);
        end
        unblockInspector2Check(2);
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

