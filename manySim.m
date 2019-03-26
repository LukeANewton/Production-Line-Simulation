%script to run many replications of the simulation and gather results
clear; clc;

%number values representing how long each inspector/workstation has spent idle
global Inspector1IdleTime Inspector2IdleTime;
global Workstation1IdleTime Workstation2IdleTime Workstation3IdleTime;
%integer values indicating the number of each product that has been produced
global P1Produced P2Produced P3Produced;
%integer values indicating the number of each component that has been inspected
global C1Inspected C2Inspected C3Inspected;
%arrays for storing the number of items in a queue each iteration
global arrayC1W1 arrayC1W2 arrayC2W2 arrayC1W3 arrayC3W3;
%random number generator seed
global seed;
%the length of one simulation run (set in Sim.m)
global maxSimulationTime;
global numberOfReplications

numberOfReplications = 5; %the number of times to run the simulation
seed = 420; %seed to use for simulation

initializeRandomNumberStreams(seed);
initializeDistributions();

%create directory for output files
if ~exist('output', 'dir')
    mkdir('output');
end

%delete old output files
oldOutput = dir('output');
for i = 1:size(oldOutput)
    if(regexp(oldOutput(i).name, 'replication\d+.txt'))
         delete(strcat('output/', oldOutput(i).name));
    end
end

%arrays to collect statistics from each replication
I1IdleTimes = zeros(1, numberOfReplications);
I2IdleTimes = zeros(1, numberOfReplications);
W1IdleTimes = zeros(1, numberOfReplications);
W2IdleTimes = zeros(1, numberOfReplications);
W3IdleTimes = zeros(1, numberOfReplications);
P1Productions = zeros(1, numberOfReplications);
P2Productions = zeros(1, numberOfReplications);
P3Productions = zeros(1, numberOfReplications);
totalProductions = zeros(1, numberOfReplications);
C1Inspections = zeros(1, numberOfReplications);
C2Inspections = zeros(1, numberOfReplications);
C3Inspections = zeros(1, numberOfReplications);
avgC1W1Sizes = zeros(1, numberOfReplications);
avgC1W2Sizes = zeros(1, numberOfReplications);
avgC1W3Sizes = zeros(1, numberOfReplications);
avgC2W2Sizes = zeros(1, numberOfReplications);
avgC3W3Sizes = zeros(1, numberOfReplications);

%run trials for specified number of times and collect statistics
for i = 1:numberOfReplications
    outputFile = strcat('output/replication', num2str(i) , '.txt');
    Sim(false, outputFile);
    I1IdleTimes(i) = Inspector1IdleTime;
    I2IdleTimes(i) = Inspector2IdleTime;
    W1IdleTimes(i) = Workstation1IdleTime;
    W2IdleTimes(i) = Workstation2IdleTime;
    W3IdleTimes(i) = Workstation3IdleTime;
    P1Productions(i) = P1Produced;
    P2Productions(i) = P2Produced;
    P3Productions(i) = P3Produced;
    totalProductions(i) = P1Produced + P2Produced + P3Produced;
    C1Inspections(i) = C1Inspected;
    C2Inspections(i) = C2Inspected;
    C3Inspections(i) = C3Inspected;
    avgC1W1Sizes(i) = mean(arrayC1W1);
    avgC1W2Sizes(i) = mean(arrayC1W2);
    avgC1W3Sizes(i) = mean(arrayC1W3);
    avgC2W2Sizes(i) = mean(arrayC2W2);
    avgC3W3Sizes(i) = mean(arrayC3W3);
end

%print final statistics to file
%average number of prodcts produced, components insepected, queue sizes
%proportion of inspector and workstation times spent idle
%variances and CIs for each value
fd = fopen('output/finalresults.txt', 'w');
printStatistic(fd, 'P1 Produced', P1Productions);
printStatistic(fd, 'P2 Produced', P2Productions);
printStatistic(fd, 'P3 Produced', P3Productions);
printStatistic(fd, 'Total Produced', totalProductions);
printStatistic(fd, 'C1 Inspected', C1Inspections);
printStatistic(fd, 'C2 Inspected', C2Inspections);
printStatistic(fd, 'C3 Inspected', C3Inspections);
printStatistic(fd, 'Workstation 1 C1 queue size', avgC1W1Sizes);
printStatistic(fd, 'Workstation 2 C1 queue size', avgC1W2Sizes);
printStatistic(fd, 'Workstation 2 C2 queue size', avgC2W2Sizes);
printStatistic(fd, 'Workstation 3 C1 queue size', avgC1W3Sizes);
printStatistic(fd, 'Workstation 3 C3 queue size', avgC3W3Sizes);
printStatistic(fd, 'Proportion of time Inspector 1 idle', I1IdleTimes/maxSimulationTime);
printStatistic(fd, 'Proportion of time Inspector 1 idle', I2IdleTimes/maxSimulationTime);
printStatistic(fd, 'Proportion of time Workstation 1 idle', W1IdleTimes/maxSimulationTime);
printStatistic(fd, 'Proportion of time Workstation 2 idle', W2IdleTimes/maxSimulationTime);
printStatistic(fd, 'Proportion of time Workstation 3 idle', W3IdleTimes/maxSimulationTime);
fclose(fd);

%function to output a statistic's mean and variance in a readable format
function  printStatistic(fd, name, data)
    avg = mean(data);
    variance = var(data);
    CI = createCI(avg, variance);
    
    fprintf(fd, '---------------------------------------\n');
    fprintf(fd, '%s\n', name);
    fprintf(fd, 'average:\t%f\n', avg);
    fprintf(fd, 'variance:\t%f\n', variance);
    fprintf(fd, '95%% confidence interval:\t[%f %f]\n\n', CI(1), CI(2));
   end

%creates a 95% confidence interval for the input mean and varaince
function CI = createCI(mean, variance)
    global numberOfReplications

    t = abs(tinv(0.025, numberOfReplications-1));
    error = t * sqrt(variance) / sqrt(numberOfReplications);
    
    CI = [mean-error mean+error];
end

