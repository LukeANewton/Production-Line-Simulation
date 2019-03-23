%Contains the method for processing a C3Ready event, 
%which occurs when inspector two finishes inspecting a component three. 
%The component needs to be placed in the queue, we must check if we can now 
%make any products, and we must start inspecting the next component 2 or 3.
function component3Ready()
    global queueC1W3 queueC3W3 queueC2W2 inspectorTwoBlocked FEL;
    global P3InProduction verbose;
    global W3Dist rngW3 clock;
    global workstationThreeIdle Workstation3IdleTime idleStartW3 idleEndW3;
    global idleStartI2 C3Inspected;
    
    if isQueueFull(queueC3W3)%cannot place component in queue if queue is full
        inspectorTwoBlocked = true;
        if verbose
            fprintf('inspector 2 blocked\n');
        end
        idleStartI2 = clock;
    else %there is space to place the component
         queueC3W3 = queueC3W3 + 1;
         C3Inspected = C3Inspected + 1;
         if verbose
            fprintf('component three placed in workstation 3 queue\n');
         end
        if ~isQueueEmpty(queueC1W3) && ~isQueueEmpty(queueC3W3) && ~P3InProduction 
            %start building a product if we have other components and a product
            %is not currently being produced
            queueC1W3 = queueC1W3 - 1;
            queueC3W3 = queueC3W3 - 1;
            P3InProduction = true;
            if verbose
                fprintf('product 3 production started\n');
            end
            
            %clear workstation idle bit and increment workstation idle time
            workstationThreeIdle = false;
            idleEndW3 = clock;            
            difference = idleEndW3 - idleStartW3;
            Workstation3IdleTime = Workstation3IdleTime + difference;
            
            %generate P3BuiltEvent
            %get the inspection time from entering a random numer [0, 1] into
            %inverse cdf
            timeToAssemble = W3Dist.icdf(rand(rngW3));
            eP3 = Event(clock + timeToAssemble, EventType.P3Built);
            FEL = FEL.addEvent(eP3);
        end  
        if ~isQueueFull(queueC3W3) || ~isQueueFull(queueC2W2)
            e = getNextInspector2Event();
            FEL = FEL.addEvent(e);
        end
    end
end