function [farmList, transactionList] = makeTrades(farmList)
%makeTrades uses the knapsack algorithm to maximize benefits from trade in
%a market where willingness-to-pay and willingness-to-accept may be lumpy
%
%  farmList = makeTrades(farmList)
%       
%       farmList    :   A 1xN array of FARM objects, each with stored
%                       attributes of:
%
%                            marketID - scalar, market in which farm sells
%                            wealth - scalar, farm capital
%                            tradedCommodity - scalar, farm-owned commodity
%                            bids - Mx3 list of bids {ID, size, value}
%                            offers - Mx3 list of offers {ID, size, value}
%                           
%
%   Developed 2015 by Andrew Bell

%initialize record list
transactionList = zeros(0,5); % (buyer, seller, amount, wtp, wta)

%identify the different markets available (groups of farms that are able to
%trade)
markets = unique([farmList.marketID]);

%order the farms by id, so that we can use id and their index
%interchangeably
[~,idSortedIndex] = sort([farmList.id]);
sortedFarms = farmList(idSortedIndex);

%loop through each market separately
for indexI = 1:length(markets);
    
    %identify all the different buyers and sellers, what they want, and
    %what they will pay
    currentMarket = farmList([farmList.marketID] == markets(indexI));
    buyerList = cat(1,currentMarket.bids);
    buyerID = buyerList(:,1);
    buyerSizeList = buyerList(:,2);
    buyerPriceList = buyerList(:,3);
    sellerList = cat(1,currentMarket.offers);
    sellerID = sellerList(:,1);
    sellerSizeList = sellerList(:,2);
    sellerPriceList = sellerList(:,3);
    
    %determine the marginal vlues (i.e., total price / amount)
    buyerAvePriceList = buyerPriceList ./ buyerSizeList;
    sellerAvePriceList = sellerPriceList ./ sellerSizeList;
    
    %now sort these lists by highest marginal price
    [buyerAvePriceList,buyerIndex] = sort(buyerAvePriceList,'descend');
    [sellerAvePriceList,sellerIndex] = sort(sellerAvePriceList,'ascend');
        
    buyerID = buyerID(buyerIndex);
    sellerID = sellerID(sellerIndex);
    buyerSizeList = buyerSizeList(buyerIndex);
    sellerSizeList = sellerSizeList(sellerIndex);
    buyerPriceList = buyerPriceList(buyerIndex);
    sellerPriceList = sellerPriceList(sellerIndex);
    
    %while there are still un-evaluated possible trades, loop through
    %possible buyers from highest-valued trade to lowest
    while(~isempty(buyerID) && ~isempty(sellerID))
        
        %use the knapsack algorithm (included, by Petter Strandmark) to identify the best possible package
        %to satisfy the buyer at position 1 in the list.  the 'weight' is
        %the size of the purchase, and the 'value' is [max(price) - price];
        %that is, *lower* priced items have the greatest value
        
        %NOTE:  this will identify a set of offers that cumulatively
        %provide the SIZE demanded below the overall WTP.  individually,
        %some sellers may be asking for more than the buyer's WTP.  More
        %detailed modeling of final prices can be inserted at (A)
        [~, soldPieces] = knapsack(sellerSizeList,max(sellerPriceList)-sellerPriceList,buyerSizeList(1));
        soldPieces = boolean(soldPieces);
        
        %double check that this sale is the right size, is under the
        %buyer WTP, and does not include the buyer selling to him/herself
        if(sum(sellerSizeList(soldPieces)) == buyerSizeList(1) && ...
                sum(sellerPriceList(soldPieces)) < buyerPriceList(1) && ...
                sum(sellerID(soldPieces) == buyerID(1)) == 0)
                        
            %a sale is made
            
            %identify who the sellers are and what they are selling
            currentSaleID = sellerID(soldPieces);
            currentSaleSize = sellerSizeList(soldPieces);
            currentSaleAveSellerPrice = sellerAvePriceList(soldPieces);
            
            %all participants in this transaction will leave the market
            %after this trade
            exitingSellers = boolean(zeros(size(sellerID)));
            exitingBuyers = boolean(zeros(size(buyerID)));
            
            %for each unit that is being sold
            for indexS = 1:sum(soldPieces)
                
                %set the price as the average of the buyer's
                %willingness-to-pay and the seller's willingness-to-accept.
                %this is really a placeholder.  
                %(A) IF YOU WISH TO ADD IN SOME NOTION OF BARGAINING POWER,
                %ETC., DO IT HERE
                price = mean([currentSaleAveSellerPrice(indexS),buyerAvePriceList(1)]);
                fullPrice = price*currentSaleSize(indexS);
                
                %buying farmer pays selling farmer
                sortedFarms(buyerID(1)).wealth = sortedFarms(buyerID(1)).wealth - fullPrice;
                sortedFarms(currentSaleID(indexS)).wealth = sortedFarms(currentSaleID(indexS)).wealth + fullPrice;

                %goods are transferred
                sortedFarms(buyerID(1)).tradedCommodity = sortedFarms(buyerID(1)).tradedCommodity + currentSaleSize(indexS);
                sortedFarms(currentSaleID(indexS)).tradedCommodity = sortedFarms(currentSaleID(indexS)).tradedCommodity - currentSaleSize(indexS);
                
                %add farmers to list of entries being removed from market
                %after this trade
                exitingSellers(sellerID == currentSaleID(indexS)) = 1;
                exitingBuyers(buyerID == currentSaleID(indexS)) = 1;
                
                %store information about this trade
                transactionList(end+1,:) = [buyerID(1) currentSaleID(indexS) currentSaleSize(indexS) buyerAvePriceList(1) currentSaleAveSellerPrice(indexS)];
            end
            
            %remove farmers that have participated in trade
            exitingSellers(sellerID == buyerID(1)) = 1;
            exitingBuyers(buyerID == buyerID(1)) = 1;
            
            buyerSizeList(exitingBuyers) = [];
            buyerPriceList(exitingBuyers) = [];
            buyerAvePriceList(exitingBuyers) = [];
            buyerID(exitingBuyers) = [];
            
            sellerSizeList(exitingSellers) = [];
            sellerPriceList(exitingSellers) = [];
            sellerAvePriceList(exitingSellers) = [];
            sellerID(exitingSellers) = [];
        else
            
            %a sale is not made - cut this possible trade from the list and
            %move on
            buyerSizeList(1) = [];
            buyerPriceList(1) = [];
            buyerAvePriceList(1) = [];
            buyerID(1) = [];
            
        end
        
    end
end
