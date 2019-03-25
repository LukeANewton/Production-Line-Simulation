%script to run many replications of the simulation and gather results
global seed;
%number values representing how long each inspector/workstation has spent idle
global Inspector1IdleTime Inspector2IdleTime;
global Workstation1IdleTime Workstation2IdleTime Workstation3IdleTime;
%integer values indicating the number of each product that has been produced
global P1Produced P2Produced P3Produced;
%integer values indicating the number of each component that has been inspected
global C1Inspected C2Inspected C3Inspected;

numberOfReplications = 10; %the number of times to run the simulation
seed = 420; %seed to use for simulation

initializeRandomNumberStreams(seed);
initializeDistributions();

if ~exist('output', 'dir')
    mkdir('output');
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
C1Inspections = zeros(1, numberOfReplications);
C2Inspections = zeros(1, numberOfReplications);
C3Inspections = zeros(1, numberOfReplications);

%run trials for specified number of times and collect statistics
for i = 1:numberOfReplications
    outputFile = strcat('output/replication', num2str(i) , '.txt');
    Sim(false, outputFile);
    I1IdleTimes(i) = Inspector1IdleTime;
    I1IdleTimes(i) = Inspector2IdleTime;
    W1IdleTimes(i) = Workstation1IdleTime;
    W2IdleTimes(i) = Workstation2IdleTime;
    W3IdleTimes(i) = Workstation3IdleTime;
    P1Productions(i) = P1Produced;
    P2Productions(i) = P2Produced;
    P3Productions(i) = P3Produced;
    C1Inspections(i) = C1Inspected;
    C2Inspections(i) = C2Inspected;
    C3Inspections(i) = C3Inspected;
end

