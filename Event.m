classdef Event
    properties
        time
        type
    end
    methods
        function obj = Event(eventTime, eventType)
            obj.time = eventTime;
            obj.type = eventType;
        end 
        function printEvent(self)
            fprintf("(%d, %s)", self.time, self.type);
        end
    end
end