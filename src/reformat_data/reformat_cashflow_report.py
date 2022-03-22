import vnquant.DataLoader as dl

class ReformatCashflowReport:
    def __init__(self, symbol: str, start: str, end: str, data_source = 'cafe', minimal = True):
        self.stock_code = symbol
        self.start = start
        self.end = end
        self.data_source = data_source
        self.minimal = minimal

        self.cash_df = self.load_data()

    def load_data(self):
        loader = dl.FinanceLoader(symbol = self.stock_code,
                                  start = self.start,
                                  end = self.end,
                                  data_source = self.data_source,
                                  minimal = self.minimal)
        data_cash = loader.get_cashflow_report()
        return data_cash.T

    def export_to_excel(self):
        file_path = '../../results/excels/'
        self.cash_df.to_excel(self.stock_code + ".xlsx")

#unit testing
# cash_test = ReformatYearlyIndex('VND', '2019-06-02','2021-12-31')
# df = cash_test.cash_df
# cash_test.export_to_excel()
# print(df.head(5))
# cols = list(df.columns)
# print(cols)
