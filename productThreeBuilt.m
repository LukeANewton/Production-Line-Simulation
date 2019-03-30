% Product 3
function productThreeBuilt()
    global queueC1W3 queueC3W3 verbose;
    global inspectorOneBlocked;
    global W3Dist rngW3 FEL clock P3Produced P3InProduction;
    global workstationThreeIdle;
    global W3IdleStartTimes I1IdleEndTimes;
    
    P3Produced = P3Produced + 1;
    P3InProduction = false;
    
    if isQueueEmpty(queueC1W3) || isQueueEmpty(queueC3W3)
       workstationThreeIdle = true;
       % Read the CURRENT time for when the workstation starts being idle 
       W3IdleStartTimes = [W3IdleStartTimes clock];
    else 
        queueC1W3 = queueC1W3 - 1;
        queueC3W3 = queueC3W3 - 1;
        if inspectorOneBlocked == true
            if verbose
                fprintf('inspector 2 unblocked\n');
            end
            inspectorOneBlocked = false;
            I1IdleEndTimes = [I1IdleEndTimes clock];
            
            % Generates C1Ready event AT CURRENT TIME
            % This causes the inspector to try to place it's component again
            eC1 = Event(clock, EventType.C1Ready);
            FEL = FEL.addEvent(eC1);
        end
         unblockInspector2Check(3);
        % Generate next P3Build Event and add it to FEL
        P3InProduction = false;
        %get the inspection time from entering a random numer [0, 1] into
        %inverse cdf
        timeToAssemble = W3Dist.icdf(rand(rngW3));
        eP3 = Event(clock + timeToAssemble, EventType.P3Built);
        FEL = FEL.addEvent(eP3);
        if verbose
           fprintf('assembling another P3\n');
        end
    end 
end