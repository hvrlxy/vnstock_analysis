from reformat_data.reformat_price import *
from reformat_data.reformat_cashflow_report import *
from reformat_data.reformat_yearly_index import *
from reformat_data.reformat_finance_report import *
from reformat_data.reformat_business_report import *

class MergeData:
    def __init__(self, symbol: str, start, end, data_source = 'cafe', minimal = True, simplified = True):
        self.stock_code = symbol
        self.start = start
        self.end = end
        self.data_source = data_source
        self.minimal = minimal

        #read in all the dataframe
        self.price_df = ReformatPrice(self.stock_code, self.start, self.end).price_df
        self.price_df.insert(0,'stock_code', self.stock_code)
        self.simple_price_df = self.price_df

        if not simplified:
            self.finance_df = ReformatFinanceReport(self.stock_code, self.start, self.end).finance_df
            # self.business_df = ReformatBusinessReport(self.stock_code, self.start, self.end).business_df
            self.basic_df = ReformatYearlyIndex(self.stock_code, self.start, self.end).basic_df

            self.finance_df['quarter'] = self.finance_df.index
            self.basic_df['year'] = [x[:4] for x in self.basic_df.index]

            self.price_df['quarter'] = self.add_quarter()
            self.price_df['year'] = [str(x) for x in list(self.price_df['date'].dt.year)]

            self.price_df = pd.merge(self.price_df,self.finance_df, on='quarter', how='left')
            self.price_df = pd.merge(self.price_df,self.basic_df, on='year', how='left')
            self.price_df = self.price_df.drop(columns=['year', 'quarter'])


    def add_quarter(self):
        '''
        retrieve the quarter of datetime object
        @return: list of string
        '''
        date_list = list(self.price_df['date'].dt.quarter)
        year_list = list(self.price_df['date'].dt.year)
        quarter_list = []
        for i in range(len(date_list)):
            quart_str = '12'
            if date_list[i] == 1:
                quart_str = '03'
            elif date_list[i] == 2:
                quart_str = '06'
            elif date_list[i] == 3:
                quart_str = '09'
            year_index = year_list[i]
            quarter_list.append(str(year_index) + '-' + quart_str)
        return quarter_list

    def export_to_excel(self):
        '''
        Export the file to excel
        @return:
        '''
        file_path = "../results/excels/"
        self.price_df.to_excel(file_path + self.stock_code + ".xlsx")

    def export_to_csv(self):
        '''
        Export the file to csv
        @return:
        '''
        file_path = "../results/excels/"
        self.price_df.to_csv(file_path + self.stock_code + ".csv")

#unit testing
# merge_class = MergeData('VND', '2019-07-02', '2020-12-31')
# merge_class.export_to_excel()


