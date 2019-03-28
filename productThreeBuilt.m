% Product 3
function productThreeBuilt()
    global queueC1W3 queueC3W3 verbose;
    global inspectorOneBlocked;
    global W3Dist rngW3 FEL clock P3Produced P3InProduction;
    global workstationThreeIdle idleStartW3;
    global Inspector1IdleTime idleEndI1 idleStartI1;
    global readInFilesMode arrayReadW3;
    
    P3Produced = P3Produced + 1;
    P3InProduction = false;
    
    if isQueueEmpty(queueC1W3) || isQueueEmpty(queueC3W3)
       workstationThreeIdle = true;
       % Read the CURRENT time for when the workstation starts being idle
       idleStartW3 = clock; 
    else 
        queueC1W3 = queueC1W3 - 1;
        queueC3W3 = queueC3W3 - 1;
        if inspectorOneBlocked == true
            if verbose
                fprintf('inspector 2 unblocked\n');
            end
            inspectorOneBlocked = false;
            idleEndI1 = clock;
            difference = idleEndI1 - idleStartI1;
            Inspector1IdleTime = Inspector1IdleTime + difference;
            
            % Generates C1Ready event AT CURRENT TIME
            % This causes the inspector to try to place it's component again
            eC1 = Event(clock, EventType.C1Ready);
            FEL = FEL.addEvent(eC1);
        end
        unblockInspector2Check(3);
        % Generate next P3Build Event and add it to FEL
        P3InProduction = false;
        if readInFilesMode == true
            %get the assembly time from the read in values
            timeToAssemble = getNextReadInValue(arrayReadW3);
        else
            %get the assembly time from entering a random numer [0, 1] into
            %inverse cdf
            timeToAssemble = W3Dist.icdf(rand(rngW3));
        end
        eP3 = Event(clock + timeToAssemble, EventType.P3Built);
        FEL = FEL.addEvent(eP3);
        if verbose
           fprintf('assembling another P3\n');
        end
    end 
end