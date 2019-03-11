classdef FutureEventList
    properties
        list
        listSize
    end 
    methods
        %Constructor
        function FEL = FutureEventList(firstEvent)
            FEL.list = firstEvent;
            FEL.listSize = 1;
        end 
        
        %adds newEvent into list in correct chronological position
        function self = addEvent(self, newEvent)
            added = 0;
            for i = 1:self.listSize
                if self.list(i).time > newEvent.time
                    self.list = [self.list(1:(i-1)), newEvent, self.list(i:self.listSize)];
                    added = 1;
                    break
                end
            end
            if added == 0
                self.list = [self.list, newEvent];
            end
            self.listSize = self.listSize + 1;
        end
        
        %returns and removes the event at the front of the FEL
        function [nextEvent, self] = getNextEvent(self)
            if self.listSize >= 1
                nextEvent = self.list(1);
                self.list = self.list(2:self.listSize);
                self.listSize = self.listSize - 1;
            end
        end
        
        function printList(self)
            for i = 1:self.listSize
                self.list(i)
            end 
        end
    end
end
