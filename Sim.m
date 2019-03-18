%Main control flow for the queuing system simulation.

%variables which affect program control flow
global alternativeStrategy alternativePriority maxSimulationTime verbose;
filename = "SimResults.txt"; %change to set the filename/path for the simulaiton output
maxSimulationTime = 100; %change to set the length of time the simulation runs
alternativeStrategy = false; %set true to use alternative round-robin C1 scheduling
alternativePriority = false; %set true to use alternative C1 queue priorities
verbose = true; %set true to have information on the status of the program displayed in the console window

%initialize model
if verbose
    fprintf("initailizing variables...\n");
end
%number value representing the amount of time passed in the simulation
global clock;
%six distributiuon objects for service times of each inspector/workstation
global C1Dist C2Dist C3Dist W1Dist W2Dist W3Dist;
%the future event list for the simulation
global FEL;
%number values representing how long each inspector/workstation has spent idle
global Inspector1IdleTime Inspector2IdleTime;
global Workstation1IdleTime Workstation2IdleTime Workstation3IdleTime;
%integer values indicating the number of each product that has been produced
global P1Produced P2Produced P3Produced;
%integer indicating the last queue a C1 was placed in
global lastQueueC1PlacedIn;
%integer (2 or 3) defining the type of component inspector 2 most recently
%insepceted/is inspecting
global lastComponentInspector2Held;
%six integers representing the size of each queue in the system
global queueC1W1 queueC1W2 queueC1W3 queueC2W2 queueC3W3;
%boolean values indicating if a product is currently in production
global P1InProduction P2InProduction P3InProduction;
%boolean values which indicate if each inpector is blocked
global inspectorOneBlocked inspectorTwoBlocked;
%boolean values which indicate if each workstation is idle
global workstationOneIdle workstationTwoIdle workstationThreeIdle;
%six integers representing start/stop times for each workstation being idle
global idleStartW1 idleEndW1 idleStartW2 idleEndW2 idleStartW3 idleEndW3; 
initializeGlobals();
initializeDistributions();
initializeFEL();
%main program loop - while FEL not empty, process the next event
if verbose
    fprintf("begining main program loop...\n");
end
while FEL.listSize > 0
    if verbose
        fprintf("\n");
        FEL.printList();
    end
   [nextEvent, FEL] = FEL.getNextEvent();
    processEvent(nextEvent);
end
%processed all events - write statistics to file
if verbose
    fprintf("\n");
    FEL.printList();
    fprintf("printing results...\n");
end
fd = fopen(filename, 'w');
fprintf(fd, "Total simulation time: %f seconds\n", clock);
fprintf(fd, "Number of product 1 produced: %d\n", P1Produced);
fprintf(fd, "Number of product 2 produced: %d\n", P2Produced);
fprintf(fd, "Number of product 3 produced: %d\n", P3Produced);
fprintf(fd, "Time inspector one spent idle: %f seconds\n", Inspector1IdleTime);
fprintf(fd, "Time inspector two spent idle: %f seconds\n", Inspector2IdleTime);
fprintf(fd, "Time workstation one spent idle: %f seconds\n", Workstation1IdleTime);
fprintf(fd, "Time workstation two spent idle: %f seconds\n", Workstation2IdleTime);
fprintf(fd, "Time workstation three spent idle: %f seconds\n", Workstation3IdleTime);
fclose(fd);
if verbose
    fprintf("simulation complete!\n");
end
%END OF MAIN CONTROL FLOW

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
    global FEL verbose;
    %create first ready event for Inspector 2
    e1 = getNextInspector1Event();
    %create first ready event for Inspector 2
    e2 = getNextInspector2Event();
    %create FEL
    FEL = FutureEventList(e1);
    FEL = FEL.addEvent(e2);
    if verbose
        fprintf("initial ");
        FEL.printList();
    end
end

%initializes each global to starting values
function initializeGlobals()
    global clock Inspector1IdleTime Inspector2IdleTime;
    global Workstation1IdleTime Workstation2IdleTime Workstation3IdleTime;
    global P1Produced P2Produced P3Produced;
    global P1InProduction P2InProduction P3InProduction;
    global lastQueueC1PlacedIn;
    global queueC1W1 queueC1W2 queueC1W3 queueC2W2 queueC3W3;
    global inspectorOneBlocked inspectorTwoBlocked;
    global workstationOneIdle workstationTwoIdle workstationThreeIdle;
    global idleStartW1 idleEndW1 idleStartW2 idleEndW2 idleStartW3 idleEndW3;
    %simulation time starts at 0
    clock = 0;
    %all queues start empty
    queueC1W1 = 0;
    queueC1W2 = 0; 
    queueC1W3 = 0; 
    queueC2W2 = 0;
    queueC3W3 = 0; 
    %at begining, have not placed at C1 yet
    lastQueueC1PlacedIn = 0;
    %time starts at zero, so idel times start at 0
    Inspector1IdleTime = 0;
    Inspector2IdleTime = 0;
    Workstation1IdleTime = 0;
    Workstation2IdleTime = 0;
    Workstation3IdleTime = 0;
    %inspectors start unblocked
    inspectorOneBlocked = false;
    inspectorTwoBlocked = false;
    %not producing anything at start of simulation
    P1InProduction = false;
    P2InProduction = false;
    P3InProduction = false;
    %at begining of simulation we have not finished producing any products yet
    P1Produced = 0;
    P2Produced = 0;
    P3Produced = 0;
    %workstations start as idle since empty
    workstationOneIdle = true;
    workstationTwoIdle = true;
    workstationThreeIdle = true;
    %at beginning, all are zero
    idleStartW1 = 0;
    idleEndW1 = 0;
    idleStartW2 = 0;
    idleEndW2 = 0;
    idleStartW3 = 0;
    idleEndW3 = 0;
end

%performs some action in the simulation depending on the type of the event
function processEvent(e)
    global clock verbose FEL;
    clock = e.time;

    if verbose
        fprintf("processing %s event\n", e.type);
    end
    if e.type == EventType.C1Ready
        component1Ready();
    elseif e.type == EventType.C2Ready
        component2Ready();
    elseif e.type == EventType.C3Ready
        component3Ready();
    elseif e.type == EventType.P1Built
        productOneBuilt();
    elseif e.type == EventType.P2Built
        productTwoBuilt();
    elseif e.type == EventType.P3Built
        productThreeBuilt();
    else
        error("Invalid event type");
    end
end