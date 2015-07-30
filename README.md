### MODULE NAME
Water Market

### PLATFORM
Matlab

### AUTHORS
- Andrew Bell
- using [knapsack.m](http://www.mathworks.com/matlabcentral/fileexchange/22783-0-1-knapsack/content/knapsack.m) written by Petter Strandmark 

### DESCRIPTION

This package solves a market for a 'lumpy' commodity such as water.  In agricultural systems, the marginal value of additional water supply may vary unevenly.  For instance, a farm with more than enough water to grow wheat but not enough water to grow sugarcane might have a low marginal value for a small additional amount of water (since they can not use it to their advantage) but a high marginal value for a larger amount of water (if it enables them to transition to sugarcane).  At the same time, they may be quite interested in selling water.  This can be a difficult market problem to resolve, as agents have the potential to participate in the market in very different ways, depending on what other offers are available.

If the willingness of each farmer to participate in a market can be evaluated at several different points, then the overall market can be solved using solvers for the [knapsack problem](https://en.wikipedia.org/wiki/Knapsack_problem), which find the most valued set of elements that add to a given weight constraint.  

### PACKAGE CONTENTS

1. testScript.m: An outer script to generate a test dataset and call the market algorithm
2. makeTrades: The main function for the solution of the market
3. Farm: An object class for farms that stores the basic properties needed to participate in the market
4. knapsack: A solver for the 0-1 knapsack problem written by Petter Strandmark and available at http://www.mathworks.com/matlabcentral/fileexchange/22783-0-1-knapsack/content/knapsack.m

### INSTRUCTIONS

To test this package, copy all files to a folder, preserving inner directory structure, and run testScript.  This script returns farmList, an array of farms that have participated in the market, and transactionList, a list of transactions in the form `[buyerID sellerID saleSize buyerWTP sellerWTA]`.

### BENCHMARKS

Verify that for all transactions in transactionList:

1. if the transaction is to a single seller, the buyer's WTP is always greater than the seller's WTA and
2. if the transaction is split across multiple sellers, the cumulative WTP `(size * WTP)` is greater than the sum of all sellers' `size * WTA`.
