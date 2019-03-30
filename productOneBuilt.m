% Product 1
function productOneBuilt()
    global queueC1W1 verbose; 
    global inspectorOneBlocked;
    global W1Dist rngW1 FEL clock P1Produced P1InProduction;
    global workstationOneIdle; 
    global W1IdleStartTimes I1IdleEndTimes;
    
    P1Produced = P1Produced + 1;
    P1InProduction = false;
    
    if isQueueEmpty(queueC1W1)
       workstationOneIdle = true;
       % Read the CURRENT time for when the workstation starts being idle
       W1IdleStartTimes = [W1IdleStartTimes clock];
    else
        queueC1W1 = queueC1W1 - 1;
        if inspectorOneBlocked == true
            if verbose
                fprintf('inspector 1 unblocked\n');
            end
            
            inspectorOneBlocked = false;
            I1IdleEndTimes = [I1IdleEndTimes clock];
            
            % Generates C1Ready event AT CURRENT TIME
            % This causes the inspector to try to place it's component again
            eC1 = Event(clock, EventType.C1Ready);
            FEL = FEL.addEvent(eC1);
        end
         % Generate next P1Build Event and add it to FEL
         P1InProduction = true;
         
         %get the inspection time from entering a random numer [0, 1] into
         %inverse cdf
         timeToAssemble = W1Dist.icdf(rand(rngW1));
         eP1 = Event(clock + timeToAssemble, EventType.P1Built);
         FEL = FEL.addEvent(eP1);
         if verbose
                fprintf('assembling another P1\n');
         end
    end  
end
