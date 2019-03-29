%Main control flow for one replication of the queuing system simulation.

%callFromCommandWindow: a boolean value to indicate wether a simulation is
%                       ran as a part of many replications, or once through 
%                       the command window. This is need because there are 
%                       certain initializations that should not be reperformed
%                       if doing many replications (eg. random number
%                       streams).
%outputFileName: the filename/path for a simulation output
function Sim(callFromCommandWindow, outputFileName)
    %variables which affect program control flow
    global alternativeStrategy alternativePriority maxSimulationTime seed verbose readInFilesMode;
    %---------------------------------------------
    %               Contol Variables
    %---------------------------------------------
    maxSimulationTime = 1000; %change to set the length of time the simulation runs
    alternativeStrategy = false; %set true to use alternative round-robin C1 scheduling
    alternativePriority = false; %set true to use alternative C1 queue priorities
    verbose = false; %set true to have information on the status of the program displayed in the console window
    if callFromCommandWindow %only set the seed here if doing one replication
        seed = 5437; %change to set the seed used in random number generation
    end
    readInFilesMode = true; %set true if we have existing .dat files that we want to read in
    %---------------------------------------------
    %            End of Contol Variables
    %---------------------------------------------
    
    %initialize model
    if verbose
        fprintf('initailizing variables...\n');
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
    %integer values indicating the number of each component that has been inspected
    global C1Inspected C2Inspected C3Inspected;
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
    %six integers representing start/stop times for each inspector being idle
    global idleStartI1 idleEndI1 idleStartI2 idleEndI2; 
    %boolean value which indicates if clock has reached max simulation time
    global timeToEndSim;
    %independent random number streams for each of the 6 distriutions plus 1
    %for deciding to inspect C2 or C3 next
    global rngC1 rngC2 rngC3 rngW1 rngW2 rngW3 rand0to1
    %arrays for storing the number of items in a queue each iteration
    global arrayC1W1 arrayC1W2 arrayC2W2 arrayC1W3 arrayC3W3 timesQueueSizeCaptured;
    %arrays to capture times events occur at - used to determine length of
    %initialization phase.
    global C1ReadyTimes C2ReadyTimes C3ReadyTimes P1BuiltTimes P2BuiltTimes P3BuiltTimes
    
    if readInFilesMode
        %arrays for storing the read-in distributions from the .dat files
        global arrayReadI1C1 arrayReadI2C2 arrayReadI2C3 arrayReadW1 arrayReadW2 arrayReadW3;
        initializeReadInValues();
    end    
    initializeGlobals();
    if callFromCommandWindow
        initializeRandomNumberStreams(seed);
        initializeDistributions();
    end
    initializeFEL();

    %main program loop - while FEL not empty, process the next event
    if verbose
        fprintf('begining main program loop...\n');
    end
    while FEL.listSize > 0 && ~timeToEndSim
        if verbose
            fprintf('\n');
            FEL.printList();
        end
       [nextEvent, FEL] = FEL.getNextEvent();
        processEvent(nextEvent);
        if verbose
            fprintf('inspector 2 holding component %d\n', lastComponentInspector2Held);
            fprintf('queue C1W1: %d components\n', queueC1W1);
            fprintf('queue C1W2: %d components\n', queueC1W2);
            fprintf('queue C1W3: %d components\n', queueC1W3);
            fprintf('queue C2W2: %d components\n', queueC2W2);
            fprintf('queue C3W3: %d components\n', queueC3W3);
        end
        % Store the number of items in each queue into an array so that we
        % can later average them to find the average number of items in a
        % given queue.
        arrayC1W1 = [arrayC1W1 queueC1W1];
        arrayC1W2 = [arrayC1W2 queueC1W2];
        arrayC2W2 = [arrayC2W2 queueC2W2];
        arrayC1W3 = [arrayC1W3 queueC1W3];
        arrayC3W3 = [arrayC3W3 queueC3W3];
        timesQueueSizeCaptured = [timesQueueSizeCaptured clock];
    end
    %processed all events - write statistics to file
    updateIdleTimes();
    plotEventTimes(5);
    if verbose
        fprintf('\n');
        fprintf('printing results...\n');
    end
    fd = fopen(outputFileName, 'w');
    fprintf(fd, 'Total simulation time: %f seconds\n\n', clock);
    fprintf(fd, 'Number of product 1 produced: %d\n', P1Produced);
    fprintf(fd, 'Number of product 2 produced: %d\n', P2Produced);
    fprintf(fd, 'Number of product 3 produced: %d\n', P3Produced);
    fprintf(fd, 'Total products produced: %d\n\n', P1Produced + P2Produced + P3Produced);
    fprintf(fd, 'Total number of component 1 used in production: %d\n', P1Produced + P2Produced + P3Produced);
    fprintf(fd, 'Total number of component 2 used in production: %d\n', P2Produced);
    fprintf(fd, 'Total number of component 3 used in production: %d\n\n', P3Produced);
    fprintf(fd, 'Total number of component 1 used in production or in queues at end of simulation: %d\n', P1Produced + P2Produced + P3Produced + queueC1W1 + queueC1W2 + queueC1W3 + P1InProduction);
    fprintf(fd, 'Total number of component 2 used in production or in queues at end of simulation: %d\n', P2Produced + queueC2W2 + P2InProduction);
    fprintf(fd, 'Total number of component 3 used in production or in queues at end of simulation: %d\n\n', P3Produced + queueC3W3 + P3InProduction);
    fprintf(fd, 'Number of component 1 inspected: %d\n', C1Inspected);
    fprintf(fd, 'Number of component 2 inspected: %d\n', C2Inspected);
    fprintf(fd, 'Number of component 3 inspected: %d\n\n', C3Inspected);
    fprintf(fd, 'Time inspector one spent idle: %f minutes\n', Inspector1IdleTime);
    fprintf(fd, 'Time inspector two spent idle: %f minutes\n', Inspector2IdleTime);
    fprintf(fd, 'Time workstation one spent idle: %f minutes\n', Workstation1IdleTime);
    fprintf(fd, 'Time workstation two spent idle: %f minutes\n', Workstation2IdleTime);
    fprintf(fd, 'Time workstation three spent idle: %f minutes\n\n', Workstation3IdleTime);
    fprintf(fd, 'Average number of component 1 in queue for workstation 1: %f components\n', mean(arrayC1W1));
    fprintf(fd, 'Average number of component 1 in queue for workstation 2: %f components\n', mean(arrayC1W2));
    fprintf(fd, 'Average number of component 1 in queue for workstation 3: %f components\n', mean(arrayC1W3));
    fprintf(fd, 'Average number of component 2 in queue for workstation 2: %f components\n', mean(arrayC2W2));
    fprintf(fd, 'Average number of component 3 in queue for workstation 3: %f components\n', mean(arrayC3W3));
    fclose(fd);
    if verbose
        fprintf('simulation complete!\n');
    end
    %END OF MAIN CONTROL FLOW
end

%initializes the FEL with the first events for the simulation
function initializeFEL()
    global FEL verbose maxSimulationTime;
    %create first ready event for Inspector 1
    e1 = getNextInspector1Event();
    %create first ready event for Inspector 2
    e2 = getNextInspector2Event();
    %create FEL
    FEL = FutureEventList(e1);
    FEL = FEL.addEvent(e2);
    FEL = FEL.addEvent(Event(maxSimulationTime, EventType.endOfSimulation));
    if verbose
        fprintf('initial ');
        FEL.printList();
    end
end

%initializes each global to starting values
function initializeGlobals()
    global clock Inspector1IdleTime Inspector2IdleTime timeToEndSim;
    global Workstation1IdleTime Workstation2IdleTime Workstation3IdleTime;
    global P1Produced P2Produced P3Produced;
    global C1Inspected C2Inspected C3Inspected
    global P1InProduction P2InProduction P3InProduction;
    global lastQueueC1PlacedIn;
    global queueC1W1 queueC1W2 queueC1W3 queueC2W2 queueC3W3;
    global inspectorOneBlocked inspectorTwoBlocked;
    global workstationOneIdle workstationTwoIdle workstationThreeIdle;
    global idleStartW1 idleEndW1 idleStartW2 idleEndW2 idleStartW3 idleEndW3;
    global idleStartI1 idleEndI1 idleStartI2 idleEndI2;
    global arrayC1W1 arrayC1W2 arrayC2W2 arrayC1W3 arrayC3W3 timesQueueSizeCaptured;
    global C1ReadyTimes C2ReadyTimes C3ReadyTimes P1BuiltTimes P2BuiltTimes P3BuiltTimes
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
    %time starts at zero, so idle times start at 0
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
    %at begining of simulation we have not finished inspecting any components yet
    C1Inspected = 0;
    C2Inspected = 0;
    C3Inspected = 0;
    %workstations start as idle since they at time 0 they are not producing
    workstationOneIdle = true;
    workstationTwoIdle = true;
    workstationThreeIdle = true;
    %at time zero, all idle times start at zero
    idleStartW1 = 0;
    idleEndW1 = 0;
    idleStartW2 = 0;
    idleEndW2 = 0;
    idleStartW3 = 0;
    idleEndW3 = 0;
    idleStartI2 = 0;
    idleEndI2 = 0;
    idleStartI1 = 0;
    idleEndI1 = 0;
    timeToEndSim = false;
    %all arrays should be empty as there is no queue information to add
    arrayC1W1 = [];
    arrayC1W2 = [];
    arrayC2W2 = [];
    arrayC1W3 = [];
    arrayC3W3 = [];
    C1ReadyTimes = [];
    C2ReadyTimes = [];
    C3ReadyTimes = [];
    P1BuiltTimes = [];
    P2BuiltTimes = [];
    P3BuiltTimes = [];
    timesQueueSizeCaptured = [];
end

%after processing events we need to update the total idle times of each
%entity. This is only updated elsewhere when an entity stops being idle, so
%if the simulation ends with an entity idle its idle time value will be
%inaccurate.
function updateIdleTimes()
    global clock;
    global inspectorOneBlocked Inspector1IdleTime idleStartI1;
    global inspectorTwoBlocked Inspector2IdleTime idleStartI2;
    global workstationOneIdle Workstation1IdleTime idleStartW1;
    global workstationTwoIdle Workstation2IdleTime idleStartW2;
    global workstationThreeIdle Workstation3IdleTime idleStartW3;
    
    if inspectorOneBlocked
        Inspector1IdleTime = Inspector1IdleTime + clock - idleStartI1;
    end
    if inspectorTwoBlocked
        Inspector2IdleTime = Inspector2IdleTime + clock - idleStartI2;
    end
    if workstationOneIdle
        Workstation1IdleTime = Workstation1IdleTime + clock - idleStartW1;
    end
    if workstationTwoIdle
        Workstation2IdleTime = Workstation2IdleTime + clock - idleStartW2;
    end
    if workstationThreeIdle
        Workstation3IdleTime = Workstation3IdleTime + clock - idleStartW3;
    end
end

%performs some action in the simulation depending on the type of the event
function processEvent(e)
    global clock verbose timeToEndSim;
    global queueC1W1 queueC1W2 queueC1W3 queueC2W2 queueC3W3;
    global C1ReadyTimes C2ReadyTimes C3ReadyTimes P1BuiltTimes P2BuiltTimes P3BuiltTimes
    
    if(clock > e.time) %each program moves forward in time only
        error('next event occurs before current simulation time.');
    end  
    %ensure all queues are between [0, 2]
    checkBoundries(queueC1W1, 'queueC1W1');
    checkBoundries(queueC1W2, 'queueC2W1');
    checkBoundries(queueC1W3, 'queueC3W1');
    checkBoundries(queueC2W2, 'queueC2W2');
    checkBoundries(queueC3W3, 'queueC3W3');
    
    clock = e.time;

    if verbose
        fprintf('clock time: %f\n', clock);
        fprintf('processing %s event\n', e.type);
    end
    if e.type == EventType.C1Ready
        C1ReadyTimes = [C1ReadyTimes clock];
        component1Ready();
    elseif e.type == EventType.C2Ready
        C2ReadyTimes = [C2ReadyTimes clock];
        component2Ready();
    elseif e.type == EventType.C3Ready
        C3ReadyTimes = [C3ReadyTimes clock];
        component3Ready();
    elseif e.type == EventType.P1Built
        P1BuiltTimes = [P1BuiltTimes clock];
        productOneBuilt();
    elseif e.type == EventType.P2Built
        P2BuiltTimes = [P2BuiltTimes clock];
        productTwoBuilt();
    elseif e.type == EventType.P3Built
        P3BuiltTimes = [P3BuiltTimes clock];
        productThreeBuilt();
    elseif e.type == EventType.endOfSimulation
        timeToEndSim = true;
    else
        error('Invalid event type');
    end
end

function checkBoundries(queue, name)
    if(queue < 0) || (queue > 2)
        error('queue %s is out of acceptable range [0, 2]', name);
    end
end

%plot the event times to visualize where we enter steady state
function plotEventTimes(batchTime)
    global C1ReadyTimes C2ReadyTimes C3ReadyTimes P1BuiltTimes P2BuiltTimes P3BuiltTimes;
    global arrayC1W1 arrayC1W2 arrayC2W2 arrayC1W3 arrayC3W3;
    
    plotTitle = strcat('Number of C1Ready Events Every ', num2str(batchTime), ' minutes');
    batchAndPlot(C1ReadyTimes, batchTime, plotTitle, 'Number of C1Ready events', 'C1ReadyFrequency');
    plotTitle = strcat('Number of C2Ready Events Every ', num2str(batchTime), ' minutes');
    batchAndPlot(C2ReadyTimes, batchTime, plotTitle, 'Number of C2Ready events', 'C2ReadyFrequency');
    plotTitle = strcat('Number of C3Ready Events Every ', num2str(batchTime), ' minutes');
    batchAndPlot(C3ReadyTimes, batchTime, plotTitle, 'Number of C3Ready events', 'C3ReadyFrequency');
    plotTitle = strcat('Number of P1Built Events Every ', num2str(batchTime), ' minutes');
    batchAndPlot(P1BuiltTimes, batchTime, plotTitle, 'Number of P1Built events', 'P1BuiltFrequency');
    plotTitle = strcat('Number of P2Built Events Every ', num2str(batchTime), ' minutes');
    batchAndPlot(P2BuiltTimes, batchTime, plotTitle, 'Number of P2Built events', 'P2BuiltFrequency');
    plotTitle = strcat('Number of P3Built Events Every ', num2str(batchTime), ' minutes');
    batchAndPlot(P3BuiltTimes, batchTime, plotTitle, 'Number of P3Built events', 'P3BuiltFrequency');
       
    title = 'Size of worstation 1 component 1 queue';
    plotQueueSize(arrayC1W1, title, title, 'C1W1size'); 
    title = 'Size of worstation 2 component 1 queue';
    plotQueueSize(arrayC1W2, title, title, 'C1W2size');
    title = 'Size of worstation 3 component 1 queue';
    plotQueueSize(arrayC1W3, title, title, 'C1W3size');
    title = 'Size of worstation 2 component 2 queue';
    plotQueueSize(arrayC2W2, title, title, 'C2W2size');
    title = 'Size of worstation 3 component 3 queue';
    plotQueueSize(arrayC3W3, title, title, 'C3W3size');
end

function plotQueueSize(data, plotTitle, yTitle, filename)
    global timesQueueSizeCaptured;

    fig = figure('visible', 'off');
    plot(timesQueueSizeCaptured, data);
    xlabel('Simulation Time');
    ylabel(yTitle);
    title(plotTitle);
    pbaspect([4 1 1]);
    refline(0, mean(data));
    print(fig, '-djpeg', strcat('sim plots/', filename));
    
    %plot moving averages (average every 3 points together)
    averages = zeros(1, ceil(length(data) / 3));
    for i = 1:length(data)
         averages(ceil(i / 3)) = averages(mod(i, 3) + 1) + data(i);
     end
     averages = averages / 3;
     fig = figure('visible', 'off');
     plot(timesQueueSizeCaptured(3:3:end), averages(1:end));
     print(fig, '-djpeg', strcat('sim plots/average', filename));
end

function batchAndPlot(data, interval, plotTitle, ytitle, filename)
    global maxSimulationTime

    %create directory for figure
    if ~exist('sim plots', 'dir')
        mkdir('sim plots');
    end
    
    %count the number of events in each interval
    batches = zeros(1, ceil(maxSimulationTime/interval));
    for i = 1:length(data)
        index = ceil(data(i)/interval);
        batches(index) = batches(index) + 1;
    end
    %plot batches
    fig = figure('visible', 'off');
    plot(interval:interval:maxSimulationTime, batches);
    xlabel('Simulation Time');
    ylabel(ytitle);
    title(plotTitle);
    pbaspect([4 1 1]);
    print(fig, '-djpeg', strcat('sim plots/', filename));
    
    %plot moving averages (average every 3 points together)
     averages = zeros(1, ceil(length(batches) / 3));
     for i = 1:length(batches)
         averages(ceil(i / 3)) = averages(mod(i, 3) + 1) + batches(i);
     end
     averages = averages / 3;
     fig = figure('visible', 'off');
     plot(3*interval:3*interval:3*interval*length(averages), averages);
    xlabel('Simulation Time');
    ylabel(ytitle);
    title(strcat('average', plotTitle));
     print(fig, '-djpeg', strcat('sim plots/average', filename));
end

%reads in and stores the values from a .dat file into an array to be used 
%in place of randomly generated values
function initializeReadInValues()
    global arrayReadI1C1 arrayReadI2C2 arrayReadI2C3 arrayReadW1 arrayReadW2 arrayReadW3;
    arrayReadI1C1 = [];
    arrayReadI2C2 = [];
    arrayReadI2C3 = [];
    arrayReadW1 = [];
    arrayReadW2 = [];
    arrayReadW3 = [];
    
    file = fopen('input data\servinsp1.dat');
    line = fgetl(file);
    while ischar(line)
       arrayReadI1C1 = [arrayReadI1C1 sscanf(line, '%f')];
       line = fgetl(file);
    end
    fclose(file);
    
    file = fopen('input data\servinsp22.dat');
    line = fgetl(file);
    while ischar(line)
       arrayReadI2C2 = [arrayReadI2C2 sscanf(line, '%f')];
       line = fgetl(file);
    end
    fclose(file);
    
    file = fopen('input data\servinsp23.dat');
    line = fgetl(file);
    while ischar(line)
       arrayReadI2C3 = [arrayReadI2C3 sscanf(line, '%f')];
       line = fgetl(file);
    end
    fclose(file);
    
    file = fopen('input data\ws1.dat');
    line = fgetl(file);
    while ischar(line)
       arrayReadW1 = [arrayReadW1 sscanf(line, '%f')];
       line = fgetl(file);
    end
    fclose(file);
    
    file = fopen('input data\ws2.dat');
    line = fgetl(file);
    while ischar(line)
       arrayReadW2 = [arrayReadW2 sscanf(line, '%f')];
       line = fgetl(file);
    end
    fclose(file);
    
    file = fopen('input data\ws3.dat');
    line = fgetl(file);
    while ischar(line)
       arrayReadW3 = [arrayReadW3 sscanf(line, '%f')];
       line = fgetl(file);
    end
    fclose(file);
end