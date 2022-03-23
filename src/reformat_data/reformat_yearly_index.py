import vnquant.DataLoader as dl

class ReformatYearlyIndex:
    def __init__(self, symbol, start, end, data_source = 'cafe', minimal = True):
        """

        @rtype: object
        """
        self.stock_code = symbol
        self.start = start
        self.end = end
        self.data_source = data_source
        self.minimal = minimal

        self.basic_df = self.load_data()

    def load_data(self):
        loader = dl.FinanceLoader(symbol = self.stock_code,
                                  start = self.start,
                                  end = self.end,
                                  data_source = self.data_source,
                                  minimal = self.minimal)
        data_basic = loader.get_basic_index()
        return data_basic.T

    def export_to_excel(self):
        file_path = '../../results/excels/'
        self.basic_df.to_excel(self.stock_code + ".xlsx")

#unit testing
basic_test = ReformatYearlyIndex('VND', '2019-06-02', '2021-12-31')
df = basic_test.basic_df
# cash_test.export_to_excel()
# print(df.head(5))
cols = list(df.columns)
# print(cols)
