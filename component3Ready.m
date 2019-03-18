%Contains the method for processing a C3Ready event, 
%which occurs when inspector two finishes inspecting a component three. 
%The component needs to be placed in the queue, we must check if we can now 
%make any products, and we must start inspecting the next component 2 or 3.
function component3Ready()
    global queueC1W3 queueC3W3 inspectorTwoBlocked FEL;
    global P3InProduction verbose;
    global W3Dist clock P3Produced;
    global workstationThreeIdle Workstation3IdleTime idleStartW3 idleEndW3;
    
    if queueC3W3 == 2%cannot place component in queue if queue is full
        inspectorTwoBlocked = true;
        if verbose
            fprintf("inspector 2 blocked\n");
        end
    else %there is space to place the component
        if ~isQueueEmpty(queueC1W3) && ~P3InProduction 
            %start building a product if we have other components and a product
            %is not currently being produced
            queueC1W3 = queueC1W3 - 1;
            P3InProduction = true;
            if verbose
                fprintf("product 3 production started\n");
            end
            
            %clear workstation idle bit and increment workstation idle time
            workstationThreeIdle = false;
            idleEndW3 = clock;            
            difference = idleEndW3 - idleStartW3;
            Workstation3IdleTime = Workstation3IdleTime + difference;
            %safety measure to make sure we don't accidently add idle time
            idleStartW3 = 0;
            idleEndW3 = 0;
            
            %generate P3BuiltEvent
            timeToAssemble = random(W3Dist);
            eP3 = Event(clock + timeToAssemble, EventType.P3Built);
            FEL = FEL.addEvent(eP3);
        else
            queueC3W3 = queueC3W3 + 1;
        end  
        e = getNextInspector2Event();
        FEL = FEL.addEvent(e);
    end
end