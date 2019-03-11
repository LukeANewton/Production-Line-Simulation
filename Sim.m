%initialize model
global C1Dist C2Dist C3Dist W1Dist W2Dist W3Dist FEL clock;
global Inspector1IdleTime Inspector2IdleTime;
global Workstation1IdleTime Workstation2IdleTime Workstation3IdleTime
global P1Produced P2Produced P3Produced
clock = 0;
initializeDistributions();
initializeFEL();

%main program loop - while FEL not empty, process the next event
while FEL.listSize > 0
   [nextEvent, FEL] = FEL.getNextEvent();
    processEvent(nextEvent);
end
%processed all events - write statistics to file
%TO DO: write statistics to file
%statistics are: simulation time, number of each component built,
%time spent idle for each workstation and inspector

%creates the 6 distribution functions with parameters determined through 
%input modelling in deliverable 1
function initializeDistributions()
    global C1Dist C2Dist C3Dist W1Dist W2Dist W3Dist;
    C1Dist = makedist('Exponential', 'mu', 0.096545);
    C2Dist = makedist('Exponential', 'mu', 0.0644);
    C3Dist = makedist('Exponential', 'mu', 0.048467);
    W1Dist = makedist('Exponential', 'mu', 0.217183);
    W2Dist = makedist('Exponential', 'mu', 0.0902);
    W3Dist = makedist('Exponential', 'mu', 0.113693);
end

%initializes the FEL with the first events for the simulation
function initializeFEL()
    global FEL;
    %create first ready event for Inspector 2
    e1 = getNextInspector1Event();
    %create first ready event for Inspector 2
    e2 = getNextInspector2Event();
    %create FEL
    FEL = FutureEventList(e1);
    FEL = FEL.addEvent(e2);
end

%generates the next C1Ready event for insepctor 1
function e = getNextInspector1Event()
    global C1Dist clock;
    e = Event(clock + random(C1Dist), EventType.C1Ready);
end

%generates the next C2Ready/C3Ready event for inspector 2
%TO DO: inspector 2 should only randomly pick a component if
%both C2 and C3 queues are not full. If one of the queues is full,
%the inspector should inspect a component of the other type next
function e = getNextInspector2Event()
    global C2Dist C3Dist clock;
    %generate random 1 or 0 to pick C2Ready or C3Ready
     bernoulli = rand();
     bernoulli = bernoulli > 0.5;
     if bernoulli == 1
         e = Event(clock + random(C2Dist), EventType.C2Ready);
     else
         e = Event(clock + random(C3Dist), EventType.C3Ready);
     end
end 

%performs some action in the simulation depending on the type of the event
function processEvent(e)
    global clock;
    %advance simulation time to event time
    clock = e.time;

    %TO DO:perform some action based on the type of event that is occuring
    if e.type == EventType.C1Ready
    elseif e.type == EventType.C2Ready
    elseif e.type == EventType.C3Ready
    elseif e.type == EventType.P1Built
    elseif e.type == EventType.P2Built
    elseif e.type == EventType.P3Built
    else
        error("Invalid event type");
    end
end