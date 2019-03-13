%Defines a class for the future event list for the project. 
%A future event list consists of a collection of events in chronological 
%order, and the size of the list
classdef FutureEventList
    properties
        %collection of events
        list
        %number of events in the FEL
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
                %place the new event before the first event with a later time
                if self.list(i).time > newEvent.time
                    self.list = [self.list(1:(i-1)), newEvent, self.list(i:self.listSize)];
                    added = 1;
                    break
                end
            end
            %add to end of list if no later events yet
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
        %prints FEL in a readable format
        function printList(self)
            fprintf("FEL: (%d, %s)", self.list(1).time, self.list(1).type);
            for i = 2:self.listSize
                fprintf(", ");
                self.list(i).printEvent();
            end 
            fprintf("\n");
        end
    end
end
