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

numberOfReplications = 10; %the number of times to run the simulation
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

%collect final statistics:
%average number of prodcts produced, components insepected, queue sizes
%proportion of inspector and workstation times spent idle
%variances for each value
AverageP1Produced = mean(P1Productions);
AverageP2Produced = mean(P2Productions);
AverageP3Produced = mean(P3Productions);
AverageTotalProduced = mean(totalProductions);
AverageC1Inspections = mean(C1Inspections);
AverageC2Inspections = mean(C2Inspections);
AverageC3Inspections = mean(C3Inspections);
AverageC1W1Size = mean(avgC1W1Sizes);
AverageC1W2Size = mean(avgC1W2Sizes);
AverageC1W3Size = mean(avgC1W3Sizes);
AverageC2W2Size = mean(avgC2W2Sizes);
AverageC3W3Size = mean(avgC3W3Sizes);
AverageI1IdlePercent = mean(I1IdleTimes) / maxSimulationTime;
AverageI2IdlePercent = mean(I2IdleTimes) / maxSimulationTime;
AverageW1IdlePercent = mean(W1IdleTimes) / maxSimulationTime;
AverageW2IdlePercent = mean(W2IdleTimes) / maxSimulationTime;
AverageW3IdlePercent = mean(W3IdleTimes) / maxSimulationTime;

VarianceP1Produced = var(P1Productions);
VarianceP2Produced = var(P2Productions);
VarianceP3Produced = var(P3Productions);
VarianceTotalProduced = var(totalProductions);
VarianceC1Inspections = var(C1Inspections);
VarianceC2Inspections = var(C2Inspections);
VarianceC3Inspections = var(C3Inspections);
VarianceC1W1Size = var(avgC1W1Sizes);
VarianceC1W2Size = var(avgC1W2Sizes);
VarianceC1W3Size = var(avgC1W3Sizes);
VarianceC2W2Size = var(avgC2W2Sizes);
VarianceC3W3Size = var(avgC3W3Sizes);
VarienceI1IdlePercent = var(I1IdleTimes/maxSimulationTime);
VarienceI2IdlePercent = var(I2IdleTimes/maxSimulationTime);
VarienceW1IdlePercent = var(W1IdleTimes/maxSimulationTime);
VarienceW2IdlePercent = var(W2IdleTimes/maxSimulationTime);
VarienceW3IdlePercent = var(W3IdleTimes/maxSimulationTime);

%print final statistics to file
fd = fopen('output/finalresults.txt', 'w');
fprintf(fd, formatStatisticOutput('P1 Produced', AverageP1Produced, VarianceP1Produced));
fprintf(fd, formatStatisticOutput('P2 Produced', AverageP2Produced, VarianceP2Produced));
fprintf(fd, formatStatisticOutput('P3 Produced', AverageP3Produced, VarianceP3Produced));
fprintf(fd, formatStatisticOutput('Total Produced', AverageTotalProduced, VarianceTotalProduced));
fprintf(fd, formatStatisticOutput('C1 Inspected', AverageC1Inspections, VarianceC1Inspections));
fprintf(fd, formatStatisticOutput('C2 Inspected', AverageC2Inspections, VarianceC2Inspections));
fprintf(fd, formatStatisticOutput('C3 Inspected', AverageC3Inspections, VarianceC3Inspections));
fprintf(fd, formatStatisticOutput('Workstation 1 C1 queue size', AverageC1W1Size, VarianceC1W1Size));
fprintf(fd, formatStatisticOutput('Workstation 1 C2 queue size', AverageC1W2Size, VarianceC1W2Size));
fprintf(fd, formatStatisticOutput('Workstation 1 C3 queue size', AverageC1W3Size, VarianceC1W3Size));
fprintf(fd, formatStatisticOutput('Workstation 2 C2 queue size', AverageC2W2Size, VarianceC2W2Size));
fprintf(fd, formatStatisticOutput('Workstation 3 C3 queue size', AverageC3W3Size, VarianceC3W3Size));
fprintf(fd, formatStatisticOutput('Proportion of time Inspector 1 idle', AverageI1IdlePercent, VarienceI1IdlePercent));
fprintf(fd, formatStatisticOutput('Proportion of time Inspector 2 idle', AverageI2IdlePercent, VarienceI2IdlePercent));
fprintf(fd, formatStatisticOutput('Proportion of time Workstation 1 idle', AverageW1IdlePercent, VarienceW1IdlePercent));
fprintf(fd, formatStatisticOutput('Proportion of time Workstation 2 idle', AverageW2IdlePercent, VarienceW2IdlePercent));
fprintf(fd, formatStatisticOutput('Proportion of time Workstation 3 idle', AverageW3IdlePercent, VarienceW3IdlePercent));

%function to output a statistic's mean and variance in a readable format
function outputString = formatStatisticOutput(name, mean, variance)
    outputString = strcat('---------------------------------------\n');
    outputString = strcat(outputString, name, '\n\n');
    outputString = strcat(outputString, 'average:\t', num2str(mean), '\n');
    outputString = strcat(outputString, 'variance:\t', num2str(variance), '\n\n');
    
end
