from merge_data import *
import pandas as pd
from indicators import *

stock_list = ['VND', 'VNM', 'DIG', 'ORS', 'PVS', 'GAS', 'GEX', 'MBB', 'HPG', 'FPT'] #, 'SSA', 'MWG' 'ACV', 'MSR'
start_date = '2016-10-01'
end_date = '2026-02-01'

final_df = pd.DataFrame()
for stock_code in stock_list:
    print(stock_code)
    stock_df = MergeData(stock_code, start_date, end_date, simplified = False).price_df
    stock_df = AddIndicator(stock_df).stock_df

    #calculate the change in closing price
    prices = list(stock_df['close'])
    changes = [0]
    for i in range(len(prices) - 1):
        changes.append((prices[i + 1] - prices[i]) / prices[i])
    stock_df['changes'] = changes
    final_df = final_df.append(stock_df, ignore_index=True)

    final_df.to_csv('../results/csvs/full_df.csv')
    final_df.to_excel('../results/excels/full_df.xlsx')
