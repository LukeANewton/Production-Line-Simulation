% Product 3
function productThreeBuilt()
    global queueC1W3 queueC3W3 inspectorOneBlocked inspectorTwoBlocked
    % Check if queues are empty
    if isQueueEmpty(queueC1W3) && isQueueEmpty(queueC3W3)
       %TO DO: Set W3 to idle     
    % Not empty, so decrement queue size
    else 
        queueC1W3 = queueC1W3 - 1;
        queueC3W3 = queueC3W3 - 1;
        % Is inspector 1 blocked
        if inspectorOneBlocked
            inspectorOneBlocked = false;
            %TODO: generate C1Ready event AT CURRENT TIME, this will cause the inspector to
            %try to place it's component again
        end
        % Is inspector 2 blocked
        if inspectorTwoBlocked %TODO: and only if he is holding a C3!
            inspectorTwoBlocked = false;
            %TODO: generate C2=3Ready event AT CURRENT TIME, this will cause the inspector to
            %try to place it's component again
        end  
        %TO DO: Generate next P3Build Event
    end 
end