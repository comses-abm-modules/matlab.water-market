%make a list of farms with random attributes
clear all;
close all;

farmList(1) = Farm(1, 1);
farmList(1) = [];


numMarkets = 3;
numFarms = 30;
maxBids = 4;

farmID = 0;

for indexI = 1:numFarms

    farmID = farmID + 1;

    currentFarm = Farm(farmID, rand());
    currentFarm.marketID = ceil(rand()*numMarkets);
    
    %generate a random set of bids
    bids = zeros(0,3);
    bidAmt = 0;
    bidSize = 0;
    numBids = ceil(rand()*maxBids);
    for indexJ = 1:numBids
        bids(end+1,:) = [farmID bidSize + ceil(rand()*3) bidAmt + rand()];
    end
    currentFarm.bids = bids;
    
    %generate a random set of offers
    bids = zeros(0,3);
    bidAmt = 0;
    bidSize = 0;
    numBids = ceil(rand()*maxBids);
    for indexJ = 1:numBids
        bids(end+1,:) = [farmID bidSize + ceil(rand()*3) bidAmt + rand()];
    end
    currentFarm.offers = bids;
    
    farmList(end+1) = currentFarm;

end

%run the market algorithm and observe which trades took place
[farmList, transactionList] = makeTrades(farmList);

