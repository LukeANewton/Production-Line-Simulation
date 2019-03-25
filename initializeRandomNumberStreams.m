%initializes the independent random number streams for use in simulation
function initializeRandomNumberStreams(seed)
    global rngC1 rngC2 rngC3 rngW1 rngW2 rngW3 rand0to1;

    [rngC1, rngC2, rngC3, rngW1, rngW2, rngW3, rand0to1] = RandStream.create('mrg32k3a', 'Seed', seed, 'NumStreams', 7);
end