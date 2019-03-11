classdef Event
    properties
        time
        type
    end
    methods
        function obj = Event(eventTime, eventType)
            obj.time = eventTime
            obj.type = eventType
        end 
    end
end