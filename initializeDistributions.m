%creates the 6 distribution functions with parameters determined through 
%input modelling in deliverable 1
function initializeDistributions()
    global C1Dist C2Dist C3Dist W1Dist W2Dist W3Dist;
    C1Dist = makedist('Exponential', 'mu', 10.35791);
    C2Dist = makedist('Exponential', 'mu', 15.537);
    C3Dist = makedist('Exponential', 'mu', 20.63276);
    W1Dist = makedist('Exponential', 'mu', 4.604417);
    W2Dist = makedist('Exponential', 'mu', 11.093);
    W3Dist = makedist('Exponential', 'mu', 8.79558);
end