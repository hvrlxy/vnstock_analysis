import vnquant.DataLoader as dl
import pandas as pd
import numpy as np
from datetime import timedelta
from datetime import datetime as dt

class ReformatFinanceReport:
    def __init__(self, symbol, start, end):
        self.stock_code = symbol
        self.start = start
        self.end = end

        self.finance_df = self.load_data()

        self.picked_cols = ['Tài sản ngắn hạn', 'Tài sản tài chính ngắn hạn',
                            'Tiền và các khoản tương đương tiền', 'Các khoản phải thu ngắn hạn',
                            'Hàng tồn kho', 'Tài sản ngắn hạn khác', 'Tài sản dài hạn',
                            'Các khoản phải thu dài hạn', 'Tài sản cố định', 'Tài sản dở dang dài hạn',
                            'TỔNG CỘNG NGUỒN VỐN', 'Nợ phải trả', ' Vay tài sản tài chính ngắn hạn ',
                            'Nợ dài hạn', 'Vốn chủ sở hữu', 'Nguồn kinh phí và quỹ khác']
        self.col_names = ['Current_Assets','Short_term_financial_investments',
                          'Cash_and_cash_equivalents', 'Short_term_receivables',
                          'Inventories', 'other_short_term_assets',
                          'Non_current_assets', 'long_term_receivable', 'Fixed_assets',
                          'Long_term_assets_in_progress', 'Liabilities', 'Current_liabilities',
                          'Short_term_borrowing', 'Long_term_liabilities',
                          'Owners_equity', 'Other_fund']
        self.map = {self.picked_cols[i]:self.col_names[i] for i in range(len(self.picked_cols))}

        self.finance_df = self.finance_df[self.picked_cols]
        self.finance_df = self.finance_df.rename(columns=self.map)


    def load_data(self):
        '''
        Given the params, load the dataset in as a pandas dataframe
        '''
        loader = dl.FinanceLoader(symbol = self.stock_code,
                                  start = self.start,
                                  end = self.end)
        data_finance = loader.get_finan_report()
        return data_finance.T

    def export_to_excel(self):
        '''
        Export the file to excel format
        @return:
        '''
        file_path = '../../results/excels/'
        self.finance_df.to_excel(self.stock_code + ".xlsx")

#unit testing
# finance_test = ReformatFinanceReport('VND', '2019-06-02','2021-12-31')
# df = finance_test.finance_df
# finance_test.export_to_excel()
# print(df.head(5))
# print(list(df.columns))

