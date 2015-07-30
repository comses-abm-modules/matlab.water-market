classdef Farm < handle
    
   properties 
       id
       tradedCommodity
       wealth
       bids
       offers
       marketID
   end
   
   events
      %none at the moment
   end
   
   methods 
      function A = Farm(id, amount)
         A.id = id;
         A.tradedCommodity = amount;
         A.wealth = 0;
         A.bids = zeros(0,3);
         A.offers = zeros(0,3);
      end % Farm 
               
   end % methods
   
end % classdef