import vnquant.DataLoader as web
import pandas as pd
import numpy as np
from datetime import timedelta
from datetime import datetime as dt

class ReformatPrice:
    def __init__(self, stock_code: str, start: str, end: str, minimal = True, data_source = 'cafe'):
        # read in the input variables
        self.stock_code = stock_code
        self.start = start
        self.end = end
        self.minimal = minimal
        self.data_source = data_source

        # round up and down the start and end date
        self.first_monday = self.first_monday()
        self.last_friday = self.last_friday()

        #check if last friday is after first monday
        if self.first_monday > self.last_friday:
            print('Invalid input period. Please enter a period > than 1 week')

        self.dataloaded = self.load_data()

        #generate the final pricing dataframe in pandas
        self.price_df = pd.DataFrame()
        self.price_df['date'] = self.generate_date()
        self.price_df['open'] = self.generate_open_price()
        self.price_df['close'] = self.generate_close_price()
        self.price_df['low'] = self.generate_low_price()
        self.price_df['high'] = self.generate_high_price()
        self.price_df['adjust'] = self.generate_adjust_price()
        self.price_df['volume'] = self.generate_volume_price()

    def first_monday(self):
        '''
        Return the first Monday after the input start date
        '''
        current_date = dt.strptime(self.start, '%Y-%m-%d')
        current_weekday = current_date.weekday()
        while(current_weekday != 0):
            current_date = current_date + timedelta(days=1)
            current_weekday = current_date.weekday()
        return current_date

    def last_friday(self):
        '''
        Return the last Friday before the input end date
        '''
        current_date = dt.strptime(self.end, '%Y-%m-%d')
        current_weekday = current_date.weekday()
        while(current_weekday != 4):
            current_date = current_date - timedelta(days=1)
            current_weekday = current_date.weekday()
        return current_date

    def load_data(self):
        '''
        Given the stock code and the start/end date, generate the price dataframe with open
        and closing price of the period.
        '''
        start_date = self.first_monday.strftime("%Y-%m-%d")
        end_date = self.last_friday.strftime("%Y-%m-%d")
        loader = web.DataLoader(self.stock_code, start = self.start,end =  self.end,
                                minimal = self.minimal, data_source = self.data_source)
        data = loader.download()
        return data

    def generate_close_price(self):
        '''
        Generate a list of closing price per day (5 days)
        '''
        return list(self.dataloaded['close'][self.stock_code])

    def generate_open_price(self):
        '''
        Generate a list of opening price per day (5 days)
        '''
        return list(self.dataloaded['open'][self.stock_code])

    def generate_high_price(self):
        '''
        Generate a list of closing price per day (5 days)
        '''
        return list(self.dataloaded['high'][self.stock_code])

    def generate_low_price(self):
        '''
        Generate a list of opening price per day (5 days)
        '''
        return list(self.dataloaded['low'][self.stock_code])

    def generate_adjust_price(self):
        '''
        Generate a list of opening price per day (5 days)
        '''
        return list(self.dataloaded['adjust'][self.stock_code])

    def generate_volume_price(self):
        '''
        Generate a list of opening price per day (5 days)
        '''
        return list(self.dataloaded['volume'][self.stock_code])

    def generate_date(self):
        '''
        Generate a list of date in the period
        '''
        return list(self.dataloaded.index)

    def print_data(self):
        '''
        Print the dataframe for unit testing
        '''
        print(self.load_data().columns)

#unit testing
# test_class = ReformatPrice('VND', '2018-02-02', '2018-04-02')
# print(test_class.price_df.head(5))

