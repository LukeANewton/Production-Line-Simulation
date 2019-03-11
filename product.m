% Variables

global queueC1W1 queueC1W2 queueC1W3 queueC2W2 queueC3W3;
global inspectorOneBlocked inspectorTwoBlocked;
% These are just here for now, but will be moved later
queueC1W1 = 2; % queue for component C1 at workstation 1
queueC1W2 = 2; % queue for component C1 at workstation 2
queueC1W3 = 2; % queue for component C1 at workstation 3
queueC2W2 = 2; % queue for component C2 at workstation 2
queueC3W3 = 2; % queue for component C3 at workstation 3

inspectorOneBlocked = true;
inspectorTwoBlocked = false;



% Check if a queue is full
function isEmpty = isQueueEmpty(queue)
    isEmpty = false;
    if (queue == 0)
        isEmpty = true;
    end
end

% Product 1
function productOneBuilt()
    global queueC1W1 inspectorOneBlocked;

    % Check if queue is empty
    if (isQueueEmpty(queueC1W1))
       % Set W1 to idle
       return
    % Not empty, so decrement queue size
    else
        queueC1W1 = queueC1W1 - 1;
        % Is inspector 1 blocked
        if (inspectorOneBlocked)
            inspectorOneBlocked = false;
        end      
    end
    % Generate next P1Build Event  
end

% Product 2
function productTwoBuilt()
    global queueC1W2 queueC2W2 inspectorOneBlocked inspectorTwoBlocked
    % Check if queues are empty
    if (isQueueEmpty(queueC1W2) && isQueueEmpty(queueC2W2))
       % Set W2 to idle     
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
    % Generate next P2Build Event 
end

% Product 3
function productThreeBuilt()
    global queueC1W3 queueC3W3 inspectorOneBlocked inspectorTwoBlocked
    % Check if queues are empty
    if (isQueueEmpty(queueC1W3) && isQueueEmpty(queueC3W3))
       % Set W3 to idle     
    % Not empty, so decrement queue size
    else
        queueC1W3 = queueC1W3 - 1;
        queueC3W3 = queueC3W3 - 1;
        % Is inspector 1 blocked
        if (inspectorOneBlocked)
            inspectorOneBlocked = false;
        end
        % Is inspector 2 blocked
        if (inspectorTwoBlocked)
            inspectorTwoBlocked = false;
        end       
    end
    % Generate next P3Build Event 
end