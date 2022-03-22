import vnquant.DataLoader as web
loader = web.DataLoader('VND', '2018-02-02','2018-04-02')
data = loader.download()
print(data.head())