%Contains the method for processing a C2Ready event, 
%which occurs when inspector two finishes inspecting a component two. The 
%component needs to be placed in the queue, we must check if we can now 
%make any products, and we must start inspecting the next component 2 or 3.
function component2Ready()
    global queueC1W2 queueC2W2 queueC3W3 inspectorTwoBlocked FEL;
    global P2InProduction verbose;
    global W2Dist rngW2 clock;
    global workstationTwoIdle Workstation2IdleTime idleStartW2 idleEndW2;
    global idleStartI2 C2Inspected;
    
    if isQueueFull(queueC2W2)%cannot place component in queue if queue is full
        inspectorTwoBlocked = true;
        if verbose
            fprintf('inspector 2 blocked\n');
        end
        idleStartI2 = clock;
    else %there is space to place the component
         queueC2W2 = queueC2W2 + 1;
         C2Inspected = C2Inspected + 1;
         if verbose
            fprintf('component two placed in workstation 2 queue\n');
        end
        if ~isQueueEmpty(queueC1W2) && ~isQueueEmpty(queueC2W2) && ~P2InProduction 
            %start building a product if we have other components and a product
            %is not currently being produced
            queueC1W2 = queueC1W2 - 1;
            queueC2W2 = queueC2W2 - 1;
            P2InProduction = true;
            if verbose
                fprintf('product 2 production started\n');
            end
            
            %clear workstation idle bit and increment workstation idle time
            workstationTwoIdle = false;
            idleEndW2 = clock;            
            difference = idleEndW2 - idleStartW2;
            Workstation2IdleTime = Workstation2IdleTime + difference;
            
            %generate P2BuiltEvent
            %get the inspection time from entering a random numer [0, 1] into
            %inverse cdf
            timeToAssemble = W2Dist.icdf(rand(rngW2));
            eP2 = Event(clock + timeToAssemble, EventType.P2Built);
            FEL = FEL.addEvent(eP2); 
        end  
        if ~isQueueFull(queueC3W3) || ~isQueueFull(queueC2W2)
            e = getNextInspector2Event();
            FEL = FEL.addEvent(e);
        end
    end
end