%Contains the method for processing a C2Ready event, 
%which occurs when inspector two finishes inspecting a component two. The 
%component needs to be placed in the queue, we must check if we can now 
%make any products, and we must start inspecting the next component 2 or 3.
function component2Ready()
    global queueC1W2 queueC2W2 inspectorTwoBlocked FEL;
    global P2InProduction verbose;
    global W2Dist clock P2Produced;
    global workstationTwoIdle Workstation2IdleTime idleStartW2 idleEndW2;
    
    if queueC2W2 == 2%cannot place component in queue if queue is full
        inspectorTwoBlocked = true;
        if verbose
            fprintf("inspector 2 blocked\n");
        end
    else %there is space to place the component
        if ~isQueueEmpty(queueC1W2) && ~P2InProduction 
            %start building a product if we have other components and a product
            %is not currently being produced
            queueC1W2 = queueC1W2 - 1;
            P2InProduction = true;
            if verbose
                fprintf("product 2 production started\n");
            end
            
            %clear workstation idle bit and increment workstation idle time
            workstationTwoIdle = false;
            idleEndW2 = clock;            
            difference = idleEndW2 - idleStartW2;
            Workstation2IdleTime = Workstation2IdleTime + difference;
            %safety measure to make sure we don't accidently add idle time
            idleStartW2 = 0;
            idleEndW2 = 0;
            
            %generate P2BuiltEvent
            timeToAssemble = random(W2Dist);
            eP2 = Event(clock + timeToAssemble, EventType.P2Built);
            FEL.addEvent(eP2);
            P2Produced = P2Produced + 1;
        else
            queueC2W2 = queueC2W2 + 1;
        end  
        e = getNextInspector2Event();
        FEL = FEL.addEvent(e);
    end
end