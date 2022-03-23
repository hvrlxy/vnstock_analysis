from merge_data import *
import pandas as pd

stock_list = ['VND', 'MBB']
start_date = '2017-01-01'
end_date = '2022-02-01'

final_df = pd.DataFrame()
for stock_code in stock_list:
    stock_df = MergeData(stock_code, start_date, end_date).simple_price_df
    final_df = final_df.append(stock_df, ignore_index=True)

# final_df.to_csv('../results/csvs/simplifies_df.csv')
final_df.to_excel('../results/excels/simplifies_df.xlsx')
