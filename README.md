This submission for the second deliverable of Group 18's SYSC4005 project contains 21 files:

SYSC4005_Group18_Deliverable2.pdf

SYSC4005_Group18_Input_Modelling.xlsx

component1Ready.m

component2Ready.m

component3Ready.m

Event.m

EventType.m

FutureEventList.m

getNextInspector1Event.m

getNextInspector2Event.m

isQueueEmpty.m

isQueueFull.m

productOneBuilt.m

productTwoBuilt.m

productThreeBuilt.m

Sim.m

blockInspector2.m

unblockInspector2Check.m

initializeDistributions.m

initializeRandomNumberStreams.m

manySim.m

getNextReadInValue.m

----------------------------------------------------------------------------------------------------------------------------------

SYSC4005_Group18_Deliverable2.pdf contains the report for deliverable 2, including problem formulation, 
setting of objectives and overall project plan, model conecptualization, input modelling and 
data collection, and finally, model tranformation.

SYSC4005_Group18_Input_Modelling.xlsx is the file used to plot all histograms, q-q plots, and chi-square
tests for each of the 6 data files provided. The report includes all the important parts of this file, but this
file is also made availble to show all steps of work performed.

component1Ready.m contains a function to process C1Ready events.

component2Ready.m contains a function to process C2Ready events.

component3Ready.m contains a function to process C3Ready events.

Event.m contains a class which defines an event in the simulation, consisting of the time the event occurs and the type of event.

EventType.m contains an enumeration which defines each type of valid event for the simulation.

FutureEventList.m contains a class which defines the future event list for the simulation.

getNextInspector1Event.m contains a function which creates the next C1Ready event.

getNextInspector2Event.m contains a function which creates the next C2ready/C3Ready event.

isQueueEmpty.m contains a function which determines if a queue is empty

isQueueFull.m contains a function which determines if a queue is full

productOneBuilt.m contains a funciton which processes P1Built events.

productTwoBuilt.m contains a function which processes P2Built events.

productThreeBuilt.m contains a function which processes P3Built events.

Sim.m contains the main control flow for the simulation.

blockInspector2.m contains the function which blocks inspector 2

unblockInspector2Check.m contains a function which checks whether inspector 2 should be unblocked

initializeDistributions.m contains a function which initializes the distribution objects used for service times

initializeRandomNumberStreams.m contains a funciton which initializes independent random number streams for each distribution

manySim.m contains a script to run multiple replications of the simulation and collect statistics from each

getNextReadInValue.m contains a function that returns the first element of an array and returns the same array less the first element
