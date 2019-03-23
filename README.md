This submission for the second deliverable of Group 18's SYSC4005 project contains 16 files:

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

----------------------------------------------------------------------------------------------------------------------------------
TODO:
1. create different random number stream for each distribution
2. implement mode of operation to pull service times from empirical data
3. implement waiting time collection to do Little's Law calculations
4. (optional) complete verbose mode
5. write report section for deliverable 3
