import ta_py as ta;

class AddIndicator:
    def __init__(self, stock_df):
        self.stock_df = stock_df
        self.n = len(self.stock_df)

        self.add_sma()
        self.add_smma()
        self.add_ema()
        self.add_wma()

        self.add_rsi()
        self.add_macd()
        self.add_atr()
        self.add_bandwidth()

        # self.add_stoch()
        self.add_hull()
        self.add_ichimoku()
        self.add_lsma()
        self.add_mom_osch()
        self.add_ao()
        self.add_momemtum()
        self.add_coppock()
        # self.add_sim()

    def add_sma(self):
        data = list(self.stock_df['close'])
        length = 14
        sma = ta.sma(data, length)
        for i in range(self.n - len(sma)):
            sma.insert(0,0)
        self.stock_df['sma'] = sma

    def add_smma(self):
        data = list(self.stock_df['close'])
        length = 14
        smma = ta.smma(data, length)
        for i in range(self.n - len(smma)):
            smma.insert(0,0)
        self.stock_df['smma'] = smma

    def add_wma(self):
        data = list(self.stock_df['close'])
        length = 14
        wma = ta.wma(data, length)
        for i in range(self.n - len(wma)):
            wma.insert(0,0)
        self.stock_df['wma'] = wma

    def add_ema(self):
        data = list(self.stock_df['close'])
        length = 14
        ema = ta.ema(data, length)
        for i in range(self.n - len(ema)):
            ema.insert(0,0)
        self.stock_df['ema'] = ema

    def add_hull(self):
        data = list(self.stock_df['close'])
        length = 14
        hull = ta.hull(data, length)
        for i in range(self.n - len(hull)):
            hull.insert(0,0)
        self.stock_df['hull'] = hull

    def add_lsma(self):
        data = list(self.stock_df['close'])
        length = 14
        lsma = ta.lsma(data, length)
        for i in range(self.n - len(lsma)):
            lsma.insert(0,0)
        self.stock_df['lsma'] = lsma

    def add_macd(self):
        data = list(self.stock_df['close'])
        length1 = 12
        length2 = 26
        macd = ta.macd(data, length1, length2)
        for i in range(self.n - len(macd)):
            macd.insert(0,0)
        self.stock_df['macd'] = macd

    def add_rsi(self):
        data = list(self.stock_df['close'])
        length = 14
        rsi = ta.lsma(data, length)
        for i in range(self.n - len(rsi)):
            rsi.insert(0,0)
        self.stock_df['rsi'] = rsi

    def add_tsi(self):
        data = list(self.stock_df['close'])
        tsi = ta.tsi(data)
        for i in range(self.n - len(tsi)):
            tsi.insert(0,0)
        self.stock_df['tsi'] = tsi

    def add_stoch(self):
        high = self.stock_df['high']
        close = self.stock_df['close']
        low = self.stock_df['low']

        data = []
        for i in range(len(high)):
            data.append([high[i], close[i], low[i]])

        length = 14
        smoothd = 3
        smoothk = 3
        stoch = ta.stoch(data, length, smoothd, smoothk)

        for i in range(self.n - len(stoch)):
            stoch.insert([0, 0],0)

        self.stock_df['stoch_a'] = [a[0] for a in stoch]
        self.stock_df['stoch_b'] = [a[1] for a in stoch]

    def add_bandwidth(self):
        data = list(self.stock_df['close'])
        bandwidth = ta.bandwidth(data)
        for i in range(self.n - len(bandwidth)):
            bandwidth.insert(0,0)
        self.stock_df['bandwidth'] = bandwidth

    def add_ichimoku(self):
        high = self.stock_df['high']
        close = self.stock_df['close']
        low = self.stock_df['low']

        data = []
        for i in range(len(high)):
            data.append([high[i], close[i], low[i]])

        length1 = 9; # default = 9
        length2 = 26; # default = 26
        length3 = 52; # default = 52
        displacement = 26; # default = 26
        ichimoku = ta.ichimoku(data, length1, length2, length3, displacement)

        ichimoku_cline = [a[0] for a in ichimoku]
        ichimoku_bline = [a[1] for a in ichimoku]
        ichimoku_lsa = [a[2] for a in ichimoku]
        ichimoku_lsb = [a[3] for a in ichimoku]
        ichimoku_lgp = [a[4] for a in ichimoku]

        for i in range(self.n - len(ichimoku)):
            ichimoku_cline.insert(0,0)
            ichimoku_bline.insert(0,0)
            ichimoku_lsa.insert(0,0)
            ichimoku_lsb.insert(0,0)
            ichimoku_lgp.insert(0,0)

        self.stock_df['ichimoku_cline'] = ichimoku_cline
        self.stock_df['ichimoku_bline'] = ichimoku_bline
        self.stock_df['ichimoku_lsa'] = ichimoku_lsa
        self.stock_df['ichimoku_lsb'] = ichimoku_lsb
        self.stock_df['ichimoku_lgp'] = ichimoku_lgp

    def add_atr(self):
        high = self.stock_df['high']
        close = self.stock_df['close']
        low = self.stock_df['low']

        data = []
        for i in range(len(high)):
            data.append([high[i], close[i], low[i]])

        atr = ta.atr(data)

        for i in range(self.n - len(atr)):
            atr.insert(0,0)

        self.stock_df['atr'] = atr

    def add_coppock(self):
        data = list(self.stock_df['close'])
        coppock = ta.cop(data)
        for i in range(self.n - len(coppock)):
            coppock.insert(0,0)
        self.stock_df['coppock'] = coppock

    def add_momemtum(self):
        data = list(self.stock_df['close'])
        momemtum = ta.mom(data)
        for i in range(self.n - len(momemtum)):
            momemtum.insert(0,0)
        self.stock_df['momemtum'] = momemtum

    def add_mom_osch(self):
        data = list(self.stock_df['close'])
        mom_osc = ta.mom_osc(data)
        for i in range(self.n - len(mom_osc)):
            mom_osc.insert(0,0)
        self.stock_df['mom_osc'] = mom_osc

    def add_ao(self): #awesome oscillator
        high = self.stock_df['high']
        low = self.stock_df['low']

        data = []
        for i in range(len(high)):
            data.append([high[i], low[i]])

        ao = ta.ao(data)
        for i in range(self.n - len(ao)):
            ao.insert(0,0)
        self.stock_df['ao'] = ao

    # def add_sim(self): #monte carlo
    #     data = list(self.stock_df['close'])
    #     length = 2
    #     simulations = 100 # default = 1000
    #     percentile = 0.5 # default = -1 (returns all raw simulations)
    #     sim = ta.sim(data, length, simulations, percentile)
    #     for i in range(self.n - len(sim)):
    #         sim.insert(0,0)
    #     self.stock_df['sim'] = sim






















