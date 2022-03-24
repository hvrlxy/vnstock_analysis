from merge_data import *
import pandas as pd
from ta import add_all_ta_features
from ta.utils import dropna


stock_list = ['HPG', 'MSR', 'DIG', 'FOX', 'ORS', 'PVS', 'GAS', 'GEX', 'MBB'] #'ACV'
start_date = '2017-01-01'
end_date = '2028-02-01'

final_df = pd.DataFrame()
for stock_code in stock_list:
    print(stock_code)
    stock_df = MergeData(stock_code, start_date, end_date).simple_price_df
    final_df = final_df.append(stock_df, ignore_index=True)
    break

mom_data = add_all_ta_features(final_df, open="open",
                               high="high", low="low", close="close", volume="volume")


mom_data.to_csv('../results/csvs/simplified_df.csv')
mom_data.to_excel('../results/excels/simplified_df.xlsx')
