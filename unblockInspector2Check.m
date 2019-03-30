%call this when you want to unblock inspector 2
function unblockInspector2Check(component)
        global inspectorTwoBlocked lastComponentInspector2Held
        global clock
        global verbose FEL
        global I2IdleEndTimes
        
        if inspectorTwoBlocked == true && lastComponentInspector2Held == component% blocked and only if he is holding a C2!
            inspectorTwoBlocked = false;
            I2IdleEndTimes = [I2IdleEndTimes clock];
            % Generates C2Ready event AT CURRENT TIME
            % This causes the inspector to try to place it's component again
            if component == 2
                e = Event(clock, EventType.C2Ready);
            elseif component == 3
                e = Event(clock, EventType.C3Ready);
            end
            FEL = FEL.addEvent(e);
            if verbose
                fprintf('inspector 2 unblocked\n');
            end
        end  
end