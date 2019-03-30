%blocks inspector 2
function blockInspector2()
    global inspectorTwoBlocked clock verbose I2IdleStartTimes
    
    inspectorTwoBlocked = true;
    if verbose
        fprintf('inspector 2 blocked\n');
    end
    I2IdleStartTimes = [I2IdleStartTimes clock];
end