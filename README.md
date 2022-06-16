#  Stock Simulation and Analysis

This repository contains the code for crawling stock pricing and volume data from the Vietnamese stock market, and a website to visualize the price overtime and different statistics models to predict the price movement. The crawling and cleaning data process is done in Python, and we use R to train the models and design the layout of the webpage. We use 10 different stock code that have been around for at least 5 years, and calculate up to 20 different basic technical indicators in order to predict price movement. Users can use the website to test the efficiency of different models and technical indicators, and economists can look at the charts andp-value to determine which model works best for which stock code.

## Stock Code
We use 10 different stock code from different industries: energy industry (GAS, PVS), tech industry (FPT), banking industry (MBB), and real estate industry (HPG). Except for the energy, none of the other stock code data display a pattern for seasonality.

## Statistical Models 
We present 4 different well-known models that are heavily use to analyze time series:
- ARIMA
- Weighted Logistics Regression
- Stepwise Regression
- Random Forest Regression

## Technical Indicators
We calculate 20 different basic technical indicators for users to choose from. All the indicators fall within one of the following three class of indicators:
- Trend Indicator measure the direction and strength of trend by using price averaging. Indicator selected: SMMA, SMA, EMA, WMA, MACD, LSMA), Hull Moving Average
- Momentum Indicator identify the speed of price movement by comparing prices over time or comparing the current closing price to previous closing price. Indicator selected: Relative Strength Index (RSI), Ichimoku, Awesome Oscillator,
Coppock
- Volatility Indicator measure the rate of price movement, regardless of direction, based on a change in the highest and lowest historical prices. Indicator selected: Bollinger Bands (BB), Average True Range (ATR), Momentum Oscillator, Momentum

## Analysis
The third and fourth panel in the website is provided to the users for further analysis. We provide the charts for RSME over the 10 test cases. For testing, we employed **Blocked Cross-Validation**, where we divide 5-year dataset into 10 different blocks of 6-month train sets. Train the model on each of the train sets and test the model on the following 1-month test sets. The RSME of the model over the test case is graphed for user to see the efficiency of each model compared with each other. The fourth panel provide the p-value of each technical indicator trained on logistic regression model, to view the efficiency of different technical indicator on price movements.
