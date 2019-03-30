%Contains the method for processing a C1Ready event, 
%which occurs when inspector one finishes inspecting a component one. The 
%component needs to be placed in the appropriate queue, we must check if we 
%can now make any products, and we must start inspecting the next component
%one.
function component1Ready()
    global queueC1W1 queueC1W2 queueC1W3 queueC2W2 queueC3W3 inspectorOneBlocked FEL;
    global alternativeStrategy alternativePriority lastQueueC1PlacedIn;
    global P1InProduction P2InProduction P3InProduction;
    global verbose;
    global clock;
    global W1Dist W2Dist W3Dist rngW1 rngW2 rngW3;
    global workstationOneIdle workstationTwoIdle workstationThreeIdle;
    global W1IdleEndTimes W2IdleEndTimes W3IdleEndTimes I1IdleStartTimes;
    global readInFilesMode arrayReadW1 arrayReadW2 arrayReadW3;
    
    if isQueueFull(queueC1W1) && isQueueFull(queueC1W2) && isQueueFull(queueC1W3)
        if verbose
            fprintf('inspector 1 blocked\n');
        end
        %all queues full, block inspector one
        inspectorOneBlocked = true;
        I1IdleStartTimes = [I1IdleStartTimes clock];
    else
        %there is space for a component 1 somewhere, we must figure out
        %which queue to place the component in
        componentPlaced = false;
        %---------------------------------------------
        %         Start of an Alternative Design
        %---------------------------------------------
        if alternativeStrategy %use alternative round-robin approach
            if lastQueueC1PlacedIn == 0 || lastQueueC1PlacedIn == 3
                componentPlaced = attemptC1W1Placement(componentPlaced);
                componentPlaced = attemptC1W2Placement(componentPlaced);
                attemptC1W3Placement(componentPlaced);
            elseif lastQueueC1PlacedIn == 1
                componentPlaced = attemptC1W2Placement(componentPlaced);
                componentPlaced = attemptC1W3Placement(componentPlaced);
                attemptC1W1Placement(componentPlaced);
            elseif lastQueueC1PlacedIn == 2
                componentPlaced = attemptC1W3Placement(componentPlaced);
                componentPlaced = attemptC1W1Placement(componentPlaced);
                attemptC1W2Placement(componentPlaced);
            end
        %---------------------------------------------
        %         End of an Alternative Design
        %---------------------------------------------
        else %use original place in smallest queue approach
            if queueC1W1 < queueC1W2 && queueC1W1 < queueC1W3 %C1 queue is smallest
                attemptC1W1Placement(componentPlaced);
            elseif queueC1W2 < queueC1W1 && queueC1W2 < queueC1W3 %C2 queue is smallest
                attemptC1W2Placement(componentPlaced);
            elseif queueC1W3 < queueC1W2 && queueC1W3 < queueC1W1 %C3 queue is smallest
                attemptC1W3Placement(componentPlaced);
            else %two queue have the same size
                %---------------------------------------------
                %         Start of an Alternative Design
                %---------------------------------------------
                if alternativePriority %use alternative priority of workstations 3, then 2, then 1
                    if queueC1W1 == queueC1W2 && queueC1W1 == queueC1W3 %all queues the same size
                        attemptC1W3Placement(componentPlaced);
                    elseif queueC1W1 == queueC1W2 %workstation 1 and 2 have same queue length
                        attemptC1W2Placement(componentPlaced);
                    elseif queueC1W1 == queueC1W3 %workstation 1 and 3 have same queue length
                        attemptC1W3Placement(componentPlaced);
                    elseif queueC1W3 == queueC1W2 %workstation 3 and 2 have same queue length
                        attemptC1W3Placement(componentPlaced);
                    end
                %---------------------------------------------
                %         End of an Alternative Design
                %---------------------------------------------
                else %use original priority of workstations 1, then 2, then 3
                    if queueC1W1 == queueC1W2 && queueC1W1 == queueC1W3 %all queues the same size
                        attemptC1W1Placement(componentPlaced);
                    elseif queueC1W1 == queueC1W2 %workstation 1 and 2 have same queue length
                        attemptC1W1Placement(componentPlaced);
                    elseif queueC1W1 == queueC1W3 %workstation 1 and 3 have same queue length
                        attemptC1W1Placement(componentPlaced);
                    elseif queueC1W3 == queueC1W2 %workstation 3 and 2 have same queue length
                        attemptC1W2Placement(componentPlaced);
                    end
                end
            end
        end
        
        if verbose
            fprintf('component one placed in workstation %d queue\n', lastQueueC1PlacedIn);
        end
        
        %we know a component has been placed in a queue, can we now make a product?
        if ~isQueueEmpty(queueC1W1) && ~P1InProduction%we can make a product 1
            queueC1W1 = queueC1W1 - 1;
            P1InProduction = true;
            if verbose
                fprintf('product 1 production started\n');
            end
            
            %clear workstation idle bit and increment workstation idle time
            if workstationOneIdle
                workstationOneIdle = false;
                W1IdleEndTimes = [W1IdleEndTimes clock];
            end
            
            %generate P1BuiltEvent
            if readInFilesMode == true
                %get the assembly time from the read in values
                [timeToAssemble,arrayReadW1] = getNextReadInValue(arrayReadW1);
            else
                %get the assembly time from entering a random numer [0, 1] into
                %inverse cdf
                timeToAssemble = W1Dist.icdf(rand(rngW1));
            end
            eP1 = Event(clock + timeToAssemble, EventType.P1Built);
            FEL = FEL.addEvent(eP1);
        end
        if ~isQueueEmpty(queueC1W2) && ~isQueueEmpty(queueC2W2) && ~P2InProduction%we can make a product 2
            queueC1W2 = queueC1W2 - 1;
            queueC2W2 = queueC2W2 - 1;
            P2InProduction = true;
            if verbose
                fprintf('product 2 production started\n');
            end
            
            %clear workstation idle bit and increment workstation idle time
            if workstationTwoIdle
                workstationTwoIdle = false;
                W2IdleEndTimes = [W2IdleEndTimes clock];
            end
            unblockInspector2Check(2);
            %generate P2BuiltEvent
            if readInFilesMode == true
                [timeToAssemble,arrayReadW2] = getNextReadInValue(arrayReadW2);
            else 
                timeToAssemble = W2Dist.icdf(rand(rngW2));
            end
            eP2 = Event(clock + timeToAssemble, EventType.P2Built);
            FEL = FEL.addEvent(eP2);
        end
        if ~isQueueEmpty(queueC1W3) && ~isQueueEmpty(queueC3W3) && ~P3InProduction%we can make a product 3
            queueC1W3 = queueC1W3 - 1;
            queueC3W3 = queueC3W3 - 1;
            P3InProduction = true;
            if verbose
                fprintf('product 3 production started\n');
            end
            
            %clear workstation idle bit and increment workstation idle time
            if workstationThreeIdle
                workstationThreeIdle = false;    
                W3IdleEndTimes = [W3IdleEndTimes clock];
            end
            unblockInspector2Check(3);
            %generate P3BuiltEvent
            if readInFilesMode == true
                [timeToAssemble,arrayReadW3] = getNextReadInValue(arrayReadW3);
            else
                timeToAssemble = W3Dist.icdf(rand(rngW3));
            end
            eP3 = Event(clock + timeToAssemble, EventType.P3Built);
            FEL = FEL.addEvent(eP3);
        end 
        %at this point, we have started building any products that can be
        %built, all that is left to do is begin inspecting the next
        %component one
        e = getNextInspector1Event();
        FEL = FEL.addEvent(e);
    end
end

% function place a component one in workstation 1 queue if there is space
function componentPlaced = attemptC1W1Placement(componentPlaced) 
    global queueC1W1 lastQueueC1PlacedIn C1Inspected;
    if queueC1W1 < 2 && ~componentPlaced
        queueC1W1 = queueC1W1 + 1;
        componentPlaced = true;
        C1Inspected = C1Inspected + 1;
        lastQueueC1PlacedIn = 1;
    end
end

% function place a component one in workstation 2 queue if there is space
function componentPlaced = attemptC1W2Placement(componentPlaced) 
    global queueC1W2 lastQueueC1PlacedIn C1Inspected;
    if queueC1W2 < 2 && ~componentPlaced
        queueC1W2 = queueC1W2 + 1;
        componentPlaced = true;
        C1Inspected = C1Inspected + 1;
        lastQueueC1PlacedIn = 2;
    end
end

% function place a component one in workstation 1 queue if there is space
function componentPlaced = attemptC1W3Placement(componentPlaced) 
    global queueC1W3 lastQueueC1PlacedIn C1Inspected;
    if queueC1W3 < 2 && ~componentPlaced
        queueC1W3 = queueC1W3 + 1;
        componentPlaced = true;
        C1Inspected = C1Inspected + 1;
        lastQueueC1PlacedIn = 3;
    end
end