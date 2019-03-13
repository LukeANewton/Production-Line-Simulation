% Product 2
function productTwoBuilt()
    global queueC1W2 queueC2W2 inspectorOneBlocked inspectorTwoBlocked
    % Check if queues are empty
    if (isQueueEmpty(queueC1W2) && isQueueEmpty(queueC2W2))
       % TO DO: Set W2 to idle     
    % Not empty, so decrement queue size
    else
        queueC1W2 = queueC1W2 - 1;
        queueC2W2 = queueC2W2 - 1;
        % Is inspector 1 blocked
        if (inspectorOneBlocked)
            inspectorOneBlocked = false;
        end
        % Is inspector 2 blocked
        if (inspectorTwoBlocked)
            inspectorTwoBlocked = false;
        end       
    end
    %TO DO: Generate next P2Build Event 
end

