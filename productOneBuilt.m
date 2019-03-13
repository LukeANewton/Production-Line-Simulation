% Product 1
function productOneBuilt()
    global queueC1W1 inspectorOneBlocked;

    % Check if queue is empty
    if (isQueueEmpty(queueC1W1))
       %TO DO: Set W1 to idle
       return
    % Not empty, so decrement queue size
    else
        queueC1W1 = queueC1W1 - 1;
        % Is inspector 1 blocked
        if (inspectorOneBlocked)
            inspectorOneBlocked = false;
        end      
    end
    %TO DO: Generate next P1Build Event  
end
