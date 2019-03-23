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
            obj.time = eventTime;
            obj.type = eventType;
        end 
        %prints and event in a readable format
        function printEvent(self)
            fprintf('(%f, %s)', self.time, self.type);
        end
    end
end