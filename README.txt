This submission for the second deliverable of Group 18's SYSC4005 project contains 15 files:

SYSC4005_Group18_Deliverable1.pdf
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
productOneBuilt.m
productTwoBuilt.m
productThreeBuilt.m
Sim.m

SYSC4005_Group18_Deliverable1.pdf contains the report for deliverable 1, including problem formulation, 
setting of objectives and overall project plan, model conecptualization, and finally input modelling and 
data collection.

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

productOneBuilt.m contains a funciton which processes P1Built events.

productTwoBuilt.m contains a function which processes P2Built events.

productThreeBuilt.m contains a function which processes P3Built events.

Sim.m contains the main control flow for the simulation.

----------------------------------------------------------------------------------------------------------------------------------
TODO:
1. productOneBuilt.m: generate next P1Built event if the components are availble to make another
2. productOneBuilt.m: block workstation 1 if there are no parts available to make another product 1
3. productOneBuilt.m: if we're creating another product 1 imediately, unblock inspector 1 becasue there will now be space for him to place his component
4. productTwoBuilt.m: generate next P2Built event if the components are availble to make another
5. productTwoBuilt.m: block workstation 2 if there are no parts available to make another product 2
6. productTwoBuilt.m: if we're creating another product 2 imediately, unblock inspector 1 becasue there will now be space for him to place his component, only unblock inspector 2 if he is holding a component 2
7. productThreeBuilt.m: generate next P3Built event if the components are availble to make another
8. productThreeBuilt.m: block workstation 3 if there are no parts available to make another product 3
9. productThreeBuilt.m: if we're creating another product 3 imediately, unblock inspector 1 becasue there will now be space for him to place his component, only unblock inspector 3 if he is holding a component 3
10. component3Ready.m: block inspector 2 if component queue is full
11. component3Ready.m: if we now have all the components to create product 3 (and a product 3 is not in production), unblock workstation 3 and generate P3Built event
12. component2Ready.m: block inspector 2 if component queue is full
13. component2Ready.m: if we now have all the components to create product 2 (and a product 2 is not in production), unblock workstation 2 and generate P2Built event
14. component1Ready.m: block inspector 1 if all component queues are full
15. component1Ready.m: if we now have all the components to create product 1 (and a product 1 is not in production), unblock workstation 1 and generate P1Built event
16. component1Ready.m: if we now have all the components to create product 2 (and a product 2 is not in production), unblock workstation 2 and generate P2Built event
17. component1Ready.m: if we now have all the components to create product 3 (and a product 3 is not in production), unblock workstation 3 and generate P3Built event
18. write report section for deliverable 2
