import vnquant.DataLoader as dl
import pandas as pd
import numpy as np
from datetime import timedelta
from datetime import datetime as dt

class ReformatBusinessReport:
    def __init__(self, symbol: str, start: str, end: str, data_source = 'cafe', minimal = True):
        self.stock_code = symbol
        self.start = start
        self.end = end
        self.data_source = data_source
        self.minimal = minimal

        self.business_df = self.load_data()

    def load_data(self):
        loader = dl.FinanceLoader(symbol = self.stock_code,
                                  start = self.start,
                                  end = self.end,
                                  data_source = self.data_source,
                                  minimal = self.minimal)
        data_bus = loader.get_business_report()
        return data_bus.T

    def export_to_excel(self):
        file_path = '/results/excels/'
        self.business_df.to_excel(self.stock_code + ".xlsx")

#unit testing
# business_test = ReformatBusinessReport('VND', '2019-06-02','2021-12-31')
# df = business_test.business_df
# business_test.export_to_excel()
# print(df.head(5))
# cols = list(df.columns)
# keywords = ['doanh thu', 'chi phí', 'lãi', 'lợi nhuận']
# cols = [col_name.lower() for col_name in cols]
# new_cols = []
# for k in keywords:
#     for name in cols:
#         if name not in new_cols and k in name:
#             new_cols.append(name)

# print(len(set(new_cols)))
