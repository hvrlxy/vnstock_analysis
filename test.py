import vnquant.DataLoader as web
import datetime as dt
loader = web.DataLoader('VND', '2018-01-01', '2019-01-01')
data = loader.download()
def median(data, l=0):
    l = (l) if l > 0 else len(data); pl = []; med = [];
    for i in range(len(data)):
        pl.append(data[i]);
        if (len(pl)) >= l:
            tmp = pl[:];
            tmp.sort(reverse=True);
            med.append(tmp[int(round((len(tmp)) / 2))]);
            pl = pl[1:];
    return med;
def rsi(data, l=14): #14 is typical period of data, changed by users
    pl = []; rs = [];
    for i in range(1, len(data)):
        pl.append(data[i] - data[i - 1]);
        if (len(pl)) >= l-1:
            gain = 0.0; loss = 0.0;
            for a in range(len(pl)):
                if pl[a] > 0: gain += float(pl[a]);
                if pl[a] < 0: loss += abs(float(pl[a]));
            gain /= l; loss /= l;
            try:
                f = 100.0 - 100.0 / (1.0 + (gain/loss));
            except:
                f = 100.0
            rs.append(f);
            pl = pl[1:];
    return rs;
def macd(data, l1=12, l2=26):
    if l1 > l2: [l1, l2] = [l2, l1];
    em1 = ema(data[:], l1); em2 = ema(data[:], l2);
    em1 = em1[-(len(em2) - len(em1)):]; emf = [];
    for i in range(len(em1)):
        emf.append(em1[i] - em2[i]);
    return emf;
def ichimoku(data, l1=9, l2=26, l3=52, l4=26):
    cloud = []; place = []; pl = [];
    for i in range(len(data)):
        pl.append(data[i]);
        if(len(pl) >= l3):
            highs = []; lows = [];
            for a in range(len(pl)):
                highs.append(float(pl[a][0]));
                lows.append(float(pl[a][2]));
            tsen = (max(highs[len(highs)-l1:len(highs)]) + (min(lows[len(lows)-l1:len(lows)]))) / 2.0;
            ksen = (max(highs[len(highs)-l2:len(highs)]) + (min(lows[len(lows)-l2:len(lows)]))) / 2.0;
            senka = float(data[i][1]) + ksen;
            senkb = (max(highs[len(highs)-l3:len(highs)]) + (min(lows[len(lows)-l2:len(lows)]))) / 2.0;
            chik = float(data[i][1]);
            place.append([tsen, ksen, senka, senkb, chik]);
            pl = pl[1:];
    for i in range(l4, len(place)-l4):
        cloud.append([place[i][0], place[i][1], place[i+l4][2], place[i+l4][3], place[i-l4][4]]);
    return cloud;
def bands(data, l1=14, l2=1):
    pl = []; deviation = []; boll = [];
    sm = sma(data[:], l1);
    for i in range(len(data)):
        pl.append(data[i]);
        if (len(pl)) >= l1:
            devi = std(pl[:], l1);
            deviation.append(devi);
            pl = pl[1:];
    for i in range(len(sm)):
        boll.append([sm[i] + deviation[i] * l2, sm[i], sm[i] - deviation[i] * l2]);
    return boll;
def ema(data, l=12):
    pl = []; em = []; weight = 2 / (float(l) + 1);
    for i in range(len(data)):
        pl.append(float(data[i]));
        if (len(pl)) >= l:
            f = sum(pl) / l if len(em) <= 0 else (data[i] - em[len(em) - 1]) * weight + em[len(em) - 1]
            em.append(f);
            pl = pl[1:];
    return em;
def tsi(data, long=25, short=13, sig=13):
    mo = []; ab = []; ts = []; tsi = [];
    for i in range(1, len(data)):
        mo.append(data[i] - data[i - 1]);
        ab.append(abs(data[i] - data[i - 1]));
    sma1 = ema(mo, long); sma2 = ema(ab, long);
    ema1 = ema(sma1, short); ema2 = ema(sma2, short);
    for i in range(len(ema1)):
        ts.append(ema1[i] / ema2[i]);
    tma = ema(ts, sig);
    ts = ts[(len(ts)-len(tma)):];
    for i in range(len(tma)):
        tsi.append([tma[i], ts[i]]);
    return tsi;
