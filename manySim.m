%Script to run many replications of the simulation and gather results. The
%Script creates a folder called 'output' and stores a txt for the output of
%each replication, as well as a file called 'finalresults.txt' which
%contains the estimated values and 95% confidence intervals from the
%combined replications output data. 
%
%If you want to run a single replication, you can set numberOfReplications 
%to 1, but your finalresults.txt will show confidence intervals as NaN 
%(becuase you have 0 variance, resulting in a divide by 0). You can also 
%run a single simulation by directly running Sim.m
function manySim()
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
    %arrays used to store statistics about each replication
    global I1IdleTimes I2IdleTimes W1IdleTimes W2IdleTimes W3IdleTimes
    global P1Productions P2Productions P3Productions totalProductions
    global C1Inspections C2Inspections C3Inspections
    global avgC1W1Sizes avgC1W2Sizes avgC1W3Sizes avgC2W2Sizes avgC3W3Sizes

    %---------------------------------------------
    %               Contol Variables
    %---------------------------------------------
    global numberOfReplications compareAlternateDesigns;
    global alternativeStrategy alternativePriority calculateReplicationsRequired;
    %Set calculateReplicationsRequired to true to have the program determine
    %how many replications are needed to get confidence intervals for
    %statistics of a width within 20% of the estimated value. If set to true,
    %the following numberOfReplications variable is ignored. The program will
    %always run at least 10 replications before determining if additional
    %replications are needed to shrink the confidence interval size
    calculateReplicationsRequired = false; 
    %set numberOfReplications to the number of desired replications of the
    %simulation
    numberOfReplications = 10; 
    %seed to used for random number generation in the simulation. If you set a
    %seed value here and run manySim, the control variable for the seed in Sim
    %is ignored
    seed = 5437; 
    %set alternativeStrategy to true to use alternative round-robin C1
    %scheduling, false will pick the shortest queue (regular system behaviour)
    alternativeStrategy = false; 
    %set alternativePriority to true to use alternative C1 queue priorities
    %for when 2 C1 queues are the same length. The alternative prioirty is
    %W3 highest, W1 lowest. This value set to false uses the normal
    %priority of W1 highest, W3 lowest
    alternativePriority = false;
    %set compareAlternateDesigns to true to run the the script 3 times, once
    %for each alternative design, and then produce an output file containing
    %the comparison results. set to false to run multiple replications for one
    %system design which is spcified by the above two values.
    compareAlternateDesigns = true;
    %---------------------------------------------
    %            End of Contol Variables
    %---------------------------------------------

    %start of main script
    %create directory for output files
    if ~exist('output', 'dir')
        mkdir('output');
    end

    %delete old output files
    oldOutput = dir('output');
    for i = 1:size(oldOutput)
        if(regexp(oldOutput(i).name, 'Replication\d+.txt'))
             delete(strcat('output/', oldOutput(i).name));
        elseif(regexp(oldOutput(i).name, 'FinalResults.txt'))
            delete(strcat('output/', oldOutput(i).name));
        elseif(regexp(oldOutput(i).name, 'AlternativeComparison.txt'))
            delete(strcat('output/', oldOutput(i).name));
        end
    end
     
    if ~calculateReplicationsRequired
        %can only initialize these if we know for sure how many replications
        if ~compareAlternateDesigns
            arraySize = 1;
        else
            arraySize = 3;
        end
        I1IdleTimes = zeros(arraySize, numberOfReplications);
        I2IdleTimes = zeros(arraySize, numberOfReplications);
        W1IdleTimes = zeros(arraySize, numberOfReplications);
        W2IdleTimes = zeros(arraySize, numberOfReplications);
        W3IdleTimes = zeros(arraySize, numberOfReplications);
        P1Productions = zeros(arraySize, numberOfReplications);
        P2Productions = zeros(arraySize, numberOfReplications);
        P3Productions = zeros(arraySize, numberOfReplications);
        totalProductions = zeros(arraySize, numberOfReplications);
        C1Inspections = zeros(arraySize, numberOfReplications);
        C2Inspections = zeros(arraySize, numberOfReplications);
        C3Inspections = zeros(arraySize, numberOfReplications);
        avgC1W1Sizes = zeros(arraySize, numberOfReplications);
        avgC1W2Sizes = zeros(arraySize, numberOfReplications);
        avgC1W3Sizes = zeros(arraySize, numberOfReplications);
        avgC2W2Sizes = zeros(arraySize, numberOfReplications);
        avgC3W3Sizes = zeros(arraySize, numberOfReplications); 
    else
       %when calculating how many replications we need, always do at least 10
       numberOfReplications = 10; 
    end
    
    if ~compareAlternateDesigns
         runManyReplications(); %run once with chosen design
    else %run once with each design and compare values
        alternativePriority = false;
        alternativeStrategy = false; 
        runManyReplications('DefaultDesign', 1);
        alternativePriority = true;
        alternativeStrategy = false;
        runManyReplications('AltPriorityDesign', 2);
        alternativePriority = false;
        alternativeStrategy = true;
        runManyReplications('AltStrategyDesign', 3);
        compareDesigns();
    end
end

function compareDesigns()
    global I1IdleTimes I2IdleTimes W1IdleTimes W2IdleTimes W3IdleTimes
    global P1Productions P2Productions P3Productions totalProductions
    global C1Inspections C2Inspections C3Inspections
    global avgC1W1Sizes avgC1W2Sizes avgC1W3Sizes avgC2W2Sizes avgC3W3Sizes
    global maxSimulationTime

    fd = fopen('output/AlternativeComparison.txt', 'w');
    %compare designs 1 and 2
    fprintf(fd, '------------------------------------------------------------\n');
    fprintf(fd, 'Comparing Default Design with Alternative Priority Design\n\n'); 
    fprintf(fd, 'a negative value indicates that the value for alternative\n');
    fprintf(fd, 'priority is higher, while positive means the default design\n');
    fprintf(fd, 'value is higher\n');
    printComparison(fd, P1Productions(1,:), P1Productions(2,:), 'P1 Prodcuction');
    printComparison(fd, P2Productions(1,:), P2Productions(2,:), 'P2 Prodcuction');
    printComparison(fd, P3Productions(1,:), P3Productions(2,:), 'P3 Prodcuction');
    printComparison(fd, totalProductions(1,:), totalProductions(2,:), 'Total Products Made');
    printComparison(fd, C1Inspections(1,:), C1Inspections(2,:), 'C1 Inspected');
    printComparison(fd, C2Inspections(1,:), C2Inspections(2,:), 'C2 Inspected');
    printComparison(fd, C3Inspections(1,:), C3Inspections(2,:), 'C3 Inspected');
    printComparison(fd, avgC1W1Sizes(1,:), avgC1W1Sizes(2,:), 'Workstation 1 C1 queue size');
    printComparison(fd, avgC1W2Sizes(1,:), avgC1W2Sizes(2,:), 'Workstation 2 C1 queue size');
    printComparison(fd, avgC2W2Sizes(1,:), avgC2W2Sizes(2,:), 'Workstation 2 C2 queue size');
    printComparison(fd, avgC1W3Sizes(1,:), avgC1W3Sizes(2,:), 'Workstation 3 C1 queue size');
    printComparison(fd, avgC3W3Sizes(1,:), avgC3W3Sizes(2,:), 'Workstation 3 C3 queue size');
    printComparison(fd, I1IdleTimes(1,:)/maxSimulationTime, I1IdleTimes(2,:)/maxSimulationTime, 'Proportion of time Inspector 1 idle');
    printComparison(fd, I2IdleTimes(1,:)/maxSimulationTime, I2IdleTimes(2,:)/maxSimulationTime, 'Proportion of time Inspector 2 idle');
    printComparison(fd, W1IdleTimes(1,:)/maxSimulationTime, W1IdleTimes(2,:)/maxSimulationTime, 'Proportion of time Workstation 1 idle');
    printComparison(fd, W2IdleTimes(1,:)/maxSimulationTime, W2IdleTimes(2,:)/maxSimulationTime, 'Proportion of time Workstation 2 idle');
    printComparison(fd, W3IdleTimes(1,:)/maxSimulationTime, W3IdleTimes(2,:)/maxSimulationTime, 'Proportion of time Workstation 3 idle');
    %compare designs 1 and 3
    fprintf(fd, '------------------------------------------------------------\n');
    fprintf(fd, 'Comparing Default Design with Alternative Strategy Design\n\n'); 
    fprintf(fd, 'a negative value indicates that the value for alternative\n');
    fprintf(fd, 'strtategy is higher, while positive means the default design\n');
    fprintf(fd, 'value is higher\n');
    printComparison(fd, P1Productions(1,:), P1Productions(3,:), 'P1 Prodcuction');
    printComparison(fd, P2Productions(1,:), P2Productions(3,:), 'P2 Prodcuction');
    printComparison(fd, P3Productions(1,:), P3Productions(3,:), 'P3 Prodcuction');
    printComparison(fd, totalProductions(1,:), totalProductions(3,:), 'Total Products Made');
    printComparison(fd, C1Inspections(1,:), C1Inspections(3,:), 'C1 Inspected');
    printComparison(fd, C2Inspections(1,:), C2Inspections(3,:), 'C2 Inspected');
    printComparison(fd, C3Inspections(1,:), C3Inspections(3,:), 'C3 Inspected');
    printComparison(fd, avgC1W1Sizes(1,:), avgC1W1Sizes(3,:), 'Workstation 1 C1 queue size');
    printComparison(fd, avgC1W2Sizes(1,:), avgC1W2Sizes(3,:), 'Workstation 2 C1 queue size');
    printComparison(fd, avgC2W2Sizes(1,:), avgC2W2Sizes(3,:), 'Workstation 2 C2 queue size');
    printComparison(fd, avgC1W3Sizes(1,:), avgC1W3Sizes(3,:), 'Workstation 3 C1 queue size');
    printComparison(fd, avgC3W3Sizes(1,:), avgC3W3Sizes(3,:), 'Workstation 3 C3 queue size');
    printComparison(fd, I1IdleTimes(1,:)/maxSimulationTime, I1IdleTimes(3,:)/maxSimulationTime, 'Proportion of time Inspector 1 idle');
    printComparison(fd, I2IdleTimes(1,:)/maxSimulationTime, I2IdleTimes(3,:)/maxSimulationTime, 'Proportion of time Inspector 2 idle');
    printComparison(fd, W1IdleTimes(1,:)/maxSimulationTime, W1IdleTimes(3,:)/maxSimulationTime, 'Proportion of time Workstation 1 idle');
    printComparison(fd, W2IdleTimes(1,:)/maxSimulationTime, W2IdleTimes(3,:)/maxSimulationTime, 'Proportion of time Workstation 2 idle');
    printComparison(fd, W3IdleTimes(1,:)/maxSimulationTime, W3IdleTimes(3,:)/maxSimulationTime, 'Proportion of time Workstation 3 idle');
    fclose(fd);
end

function printComparison(fd, data1, data2, name)
    [avg, CI] = compareData(data1, data2);
    
    fprintf(fd, '------------------------------------------------------------\n');
    fprintf(fd, '%s\n\n', name);
    fprintf(fd, 'average:\t%f\n', avg);
    fprintf(fd, '95%% confidence interval:\t[%f %f]\n\n', CI(1), CI(2));
end

function [avg, CI] = compareData(data1,data2)
    global numberOfReplications;
    
    diff = data1-data2;
    avg = sum(diff)/numberOfReplications;
    var = sum((diff-avg).^2)/(numberOfReplications-1);
    
    CI = createCI(avg, var);
end

function runManyReplications(filePrefix, statArrayIndex)
    global compareAlternateDesigns
    if ~compareAlternateDesigns
        statArrayIndex = 1;
    end

    global numberOfReplications
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
    %arrays used to store statistics about each replication
    global I1IdleTimes I2IdleTimes W1IdleTimes W2IdleTimes W3IdleTimes
    global P1Productions P2Productions P3Productions totalProductions
    global C1Inspections C2Inspections C3Inspections
    global avgC1W1Sizes avgC1W2Sizes avgC1W3Sizes avgC2W2Sizes avgC3W3Sizes
    
    initializeRandomNumberStreams(seed);
    initializeDistributions();
    
    %run trials for specified number of times and collect statistics
    for i = 1:numberOfReplications
        %do one replication
        if ~compareAlternateDesigns
            outputFile = strcat('output/Replication', num2str(i) , '.txt');
        else
            outputFile = strcat('output/',filePrefix,'Replication', num2str(i) , '.txt');
        end
        Sim(false, outputFile);
        %collect statistics from single replication
        I1IdleTimes(statArrayIndex,i) = Inspector1IdleTime;
        I2IdleTimes(statArrayIndex,i) = Inspector2IdleTime;
        W1IdleTimes(statArrayIndex,i) = Workstation1IdleTime;
        W2IdleTimes(statArrayIndex,i) = Workstation2IdleTime;
        W3IdleTimes(statArrayIndex,i) = Workstation3IdleTime;
        P1Productions(statArrayIndex,i) = P1Produced;
        P2Productions(statArrayIndex,i) = P2Produced;
        P3Productions(statArrayIndex,i) = P3Produced;
        totalProductions(statArrayIndex,i) = P1Produced + P2Produced + P3Produced;
        C1Inspections(statArrayIndex,i) = C1Inspected;
        C2Inspections(statArrayIndex,i) = C2Inspected;
        C3Inspections(statArrayIndex,i) = C3Inspected;
        avgC1W1Sizes(statArrayIndex,i) = mean(arrayC1W1);
        avgC1W2Sizes(statArrayIndex,i) = mean(arrayC1W2);
        avgC1W3Sizes(statArrayIndex,i) = mean(arrayC1W3);
        avgC2W2Sizes(statArrayIndex,i) = mean(arrayC2W2);
        avgC3W3Sizes(statArrayIndex,i) = mean(arrayC3W3);

        %check if we need to do another - are CIs width < 20% of mean?
        if i >= 10 %we want to do at least 10 replications
            if ~compareAlternateDesigns
                if isCIWidthOver20Percent(P1Productions)||isCIWidthOver20Percent(P2Productions)||isCIWidthOver20Percent(P3Productions)||isCIWidthOver20Percent(C1Inspections)||isCIWidthOver20Percent(C2Inspections)||isCIWidthOver20Percent(C3Inspections)||isCIWidthOver20Percent(I1IdleTimes)||isCIWidthOver20Percent(I2IdleTimes)||isCIWidthOver20Percent(W1IdleTimes)||isCIWidthOver20Percent(W2IdleTimes)||isCIWidthOver20Percent(W3IdleTimes)||isCIWidthOver20Percent(avgC1W1Sizes)||isCIWidthOver20Percent(avgC1W2Sizes)||isCIWidthOver20Percent(avgC1W3Sizes)||isCIWidthOver20Percent(avgC2W2Sizes)||isCIWidthOver20Percent(avgC3W3Sizes)
                    %if any CI too large, do another replication
                    numberOfReplications = numberOfReplications + 1;
                end
            else
                if isCIWidthOver20Percent(P1Productions(statArrayIndex))||isCIWidthOver20Percent(P2Productions(statArrayIndex))||isCIWidthOver20Percent(P3Productions(statArrayIndex))||isCIWidthOver20Percent(C1Inspections(statArrayIndex))||isCIWidthOver20Percent(C2Inspections(statArrayIndex))||isCIWidthOver20Percent(C3Inspections(statArrayIndex))||isCIWidthOver20Percent(I1IdleTimes(statArrayIndex))||isCIWidthOver20Percent(I2IdleTimes(statArrayIndex))||isCIWidthOver20Percent(W1IdleTimes(statArrayIndex))||isCIWidthOver20Percent(W2IdleTimes(statArrayIndex))||isCIWidthOver20Percent(W3IdleTimes(statArrayIndex))||isCIWidthOver20Percent(avgC1W1Sizes(statArrayIndex))||isCIWidthOver20Percent(avgC1W2Sizes(statArrayIndex))||isCIWidthOver20Percent(avgC1W3Sizes(statArrayIndex))||isCIWidthOver20Percent(avgC2W2Sizes(statArrayIndex))||isCIWidthOver20Percent(avgC3W3Sizes(statArrayIndex))
                    %if any CI too large, do another replication
                    numberOfReplications = numberOfReplications + 1;
                end
            end          
        end
    end

    %print final statistics to file
    %average number of prodcts produced, components insepected, queue sizes
    %proportion of inspector and workstation times spent idle
    %variances and CIs for each value
    if ~compareAlternateDesigns
        fd = fopen('output/FinalResults.txt', 'w');
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
        printStatistic(fd, 'Proportion of time Inspector 2 idle', I2IdleTimes/maxSimulationTime);
        printStatistic(fd, 'Proportion of time Workstation 1 idle', W1IdleTimes/maxSimulationTime);
        printStatistic(fd, 'Proportion of time Workstation 2 idle', W2IdleTimes/maxSimulationTime);
        printStatistic(fd, 'Proportion of time Workstation 3 idle', W3IdleTimes/maxSimulationTime);
    else
        fd = fopen(strcat('output/',filePrefix,'FinalResults.txt'), 'w');
        printStatistic(fd, 'P1 Produced', P1Productions(statArrayIndex,:));
        printStatistic(fd, 'P2 Produced', P2Productions(statArrayIndex,:));
        printStatistic(fd, 'P3 Produced', P3Productions(statArrayIndex,:));
        printStatistic(fd, 'Total Produced', totalProductions(statArrayIndex,:));
        printStatistic(fd, 'C1 Inspected', C1Inspections(statArrayIndex,:));
        printStatistic(fd, 'C2 Inspected', C2Inspections(statArrayIndex,:));
        printStatistic(fd, 'C3 Inspected', C3Inspections(statArrayIndex,:));
        printStatistic(fd, 'Workstation 1 C1 queue size', avgC1W1Sizes(statArrayIndex,:));
        printStatistic(fd, 'Workstation 2 C1 queue size', avgC1W2Sizes(statArrayIndex,:));
        printStatistic(fd, 'Workstation 2 C2 queue size', avgC2W2Sizes(statArrayIndex,:));
        printStatistic(fd, 'Workstation 3 C1 queue size', avgC1W3Sizes(statArrayIndex,:));
        printStatistic(fd, 'Workstation 3 C3 queue size', avgC3W3Sizes(statArrayIndex,:));
        printStatistic(fd, 'Proportion of time Inspector 1 idle', I1IdleTimes(statArrayIndex,:)/maxSimulationTime);
        printStatistic(fd, 'Proportion of time Inspector 2 idle', I2IdleTimes(statArrayIndex,:)/maxSimulationTime);
        printStatistic(fd, 'Proportion of time Workstation 1 idle', W1IdleTimes(statArrayIndex,:)/maxSimulationTime);
        printStatistic(fd, 'Proportion of time Workstation 2 idle', W2IdleTimes(statArrayIndex,:)/maxSimulationTime);
        printStatistic(fd, 'Proportion of time Workstation 3 idle', W3IdleTimes(statArrayIndex,:)/maxSimulationTime);
    end
    fclose(fd);
end

%function to output a statistic's mean and variance in a readable format
function  printStatistic(fd, name, data)
    avg = mean(data);
    variance = var(data);
    CI = createCI(avg, variance);
    
    fprintf(fd, '-------------------------------------------------------\n');
    fprintf(fd, '%s\n\n', name);
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

%function to determine if the width of a CI is over 20% of the mean value
%(a specification of the project)
function doAnotherReplication = isCIWidthOver20Percent(data)
    CI = createCI(mean(data), var(data));
    doAnotherReplication = abs(CI(1) - CI(2)) > 0.20*mean(data);
end