%blocks inspector 2
function blockInspector2()
    global inspectorTwoBlocked idleStartI2 clock verbose
    
    inspectorTwoBlocked = true;
    if verbose
        fprintf('inspector 2 blocked\n');
    end
    idleStartI2 = clock;
end