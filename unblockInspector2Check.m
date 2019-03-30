%call this when you want to unblock inspector 2
function unblockInspector2Check(component)
        global inspectorTwoBlocked lastComponentInspector2Held
        global clock idleStartI2 idleEndI2 Inspector2IdleTime I2IdleDuringIntialization
        global verbose FEL removeInitializationBias initializationPhaseLength
        global I2IdleEndTimes
        
        if inspectorTwoBlocked == true && lastComponentInspector2Held == component% blocked and only if he is holding a C2!
            inspectorTwoBlocked = false;
            idleEndI2 = clock;
            I2IdleEndTimes = [I2IdleEndTimes clock];
            difference = idleEndI2 - idleStartI2;
            Inspector2IdleTime = Inspector2IdleTime + difference;
            if removeInitializationBias && clock < initializationPhaseLength
                I2IdleDuringIntialization = I2IdleDuringIntialization + difference;
            end
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