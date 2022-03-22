import vnquant.DataLoader as dl
import pandas as pd
import numpy as np
from datetime import timedelta
from datetime import datetime as dt

class ReformatFinanceReport:
    def __init__(self, symbol: str, start: str, end: str):
        self.stock_code = symbol
        self.start = start
        self.end = end

        self.finance_df = self.load_data()

    def load_data(self):
        '''
        Given the params, load the dataset in as a pandas dataframe
        '''
        loader = dl.FinanceLoader(symbol = self.stock_code,
                                  start = self.start,
                                  end = self.end)
        data_finance = loader.get_finan_report()
        return data_finance.T

#unit testing
finance_test = ReformatFinanceReport('VND', '2019-06-02','2021-12-31')
df = finance_test.finance_df
print(list(df.columns))

