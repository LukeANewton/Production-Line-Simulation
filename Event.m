%Defines a class for the events in the future event list. 
%An event consists of the time the event occurs and the type of event.
classdef Event
    properties
        %the time the event occurs at
        time
        %the type of event
        type
    end
    methods
        %Constructor
        function obj = Event(eventTime, eventType)
            global maxSimulationTime;
            if maxSimulationTime > eventTime %only create valid event if time is before end of simulation
                obj.time = eventTime;
                obj.type = eventType;
            else
                obj.type = EventType.invalid;
            end
        end 
        %prints and event in a readable format
        function printEvent(self)
            fprintf("(%f, %s)", self.time, self.type);
        end
    end
end