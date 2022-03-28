#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(lubridate)
library(tidyr)
library(tidyverse)
library(dygraphs)
library(ggplot2)
library(xts)
library(forecast)
library(Metrics)
library(xgboost)
library(keras)
library(randomForest)
library(devtools)
library(modelr)
library(dplyr)
library(broom)

price_df <- read_csv('../../results/csvs/simplified_df.csv') %>% as_tibble()
#input_stock <- 'FPT'
#stock_df <- price_df %>% filter(stock_code == input_stock)
stock_df <- stock_df %>% filter(date >= as.Date('2017-01-01'))

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Interactive Stock Analysis"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            selectInput(inputId = 'stock_code',
                        label = "Stock Symbol",
                        choices = c('DIG', 'ORS', 'PVS', 'GAS', 'GEX', 'MBB', 'HPG', 'FPT')
            ),
            dateInput(inputId = 'start_date',
                      label = 'start date',
                      value = '2022-01-01'),
            dateInput(inputId = 'end_date',
                      label = 'end date',
                      value = '2022-02-01'),
            selectInput(inputId = 'algorithms',
                        label = "Fitting Algorithms",
                        choices = c("ARIMA", 'Linear Regression', 
                                    'Stepwise Regression', 'Random Forest')
            ),
            checkboxGroupInput(inputId = 'indicators',
                               label = 'Indicators',
                               choices = c('SMMA')),
            checkboxInput(inputId = 'SMA',
                          label = 'SMA'),
            checkboxInput(inputId = 'EMA',
                          label = 'EMA'),
            checkboxInput(inputId = 'WMA',
                          label = 'WMA'),
            checkboxInput(inputId = 'RSI',
                          label = 'RSI'),
            checkboxInput(inputId = 'MACD',
                          label = 'MACD'),
            checkboxInput(inputId = 'ATR',
                          label = 'ATR'),
            checkboxInput(inputId = 'BB',
                          label = 'BB'),
            checkboxInput(inputId = 'HULL',
                          label = 'HULL'),
            checkboxInput(inputId = 'ICHIMOKU',
                          label = 'ICHIMOKU'),
            checkboxInput(inputId = 'LSMA',
                          label = 'LSMA'),
            checkboxInput(inputId = 'momentum_oscillator',
                          label = 'momentum_oscillator'),
            checkboxInput(inputId = 'AO',
                          label = 'awsome_oscillator'),
            checkboxInput(inputId = 'momentum',
                          label = 'momentum'),
            checkboxInput(inputId = 'coppock',
                          label = 'coppock')
        ),

        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(
                tabPanel("Stock Price Overview", dygraphOutput("candlePlot")), 
                tabPanel("Model Predictions", plotOutput("predPlot")), 
                tabPanel("Model Performance", dygraphOutput("rmsePlot"), tableOutput("rmseTable")), 
                tabPanel("Indicators Comparison", tableOutput('indicatorTable')) #,
                #tabPanel("Debugging", textOutput("debug"))
            )
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    #filter the dataset according to the stock ID
    stock_df <- reactive({
        price_df$date <- as.Date(price_df$date, format = "%Y-%m-%d")
        price_df %>% filter(stock_code == input$stock_code)
    })
    
    train_date <- reactive({ input$start_date - months(6) })
    
    #create training and testing sets
    train1_df <- reactive({
        stock_df() %>% filter(stock_df()$date >= as.Date('2021-06-01') &
                   stock_df()$date <= as.Date('2021-12-31')) %>%
            select(-open, -changes, -adjust, -...1, 
                   -date, -stock_code, -low, -high)
    }) 

    test1_df <- reactive({
        #start_date <- as.Date(input$date_range[1])
        stock_df() %>%
            filter(stock_df()$date >= input$start_date &
                       stock_df()$date < input$end_date) %>%
            select(-open, -changes, -adjust, -...1,
                   -date, -stock_code, -low, -high) }) 
    
    date <- reactive({ 
        date_df <- stock_df() %>%
            filter(stock_df()$date >= input$start_date &
                       stock_df()$date < input$end_date)
        date_df$date
    })
    
    #fit ARIMA
    arima <- reactive({ auto.arima(train1_df()$close) })
    arima.pred <- reactive({ as.list(predict(arima(),length(test1_df()$close))) })
    arima.rmse <- reactive({rmse(arima(), test1_df()$close)})
    
    #fit Linear Regression
    #filter out the unchosen indicators
    all_time_stock <- reactive({
        input_stock <- stock_df() %>% filter(stock_code == input$stock_code)
        result.df <- stock_df() %>% select(date, close, volume)

        if (is.null(input$indicators) ){
        }
        else if (input$indicators == 'SMMA'){
            result.df <- result.df %>% mutate(smma = input_stock$smma)
        }
        if (input$SMA == TRUE){
            result.df <- result.df %>% mutate(sma = input_stock$sma)
        }
        if (input$EMA == TRUE){
            result.df <- result.df %>% mutate(ema = input_stock$ema)
        }
        if (input$WMA == TRUE){
            result.df <- result.df %>% mutate(wma = input_stock$wma)
        }
        if (input$RSI == TRUE){
            result.df <- result.df %>% mutate(rsi = input_stock$rsi)
        }
        if (input$MACD == TRUE){
            result.df <- result.df %>% mutate(macd = input_stock$macd)
        }
        if (input$ATR == TRUE){
            result.df <- result.df %>% mutate(atr = input_stock$atr)
        }
        if (input$BB == TRUE){
            result.df <- result.df %>% mutate(bandwidth = input_stock$bandwidth)
        }
        if (input$HULL == TRUE){
            result.df <- result.df %>% mutate(hull = input_stock$hull)
        }
        if (input$ICHIMOKU == TRUE){
            result.df <- result.df %>% mutate(ichimoku_cline = input_stock$ichimoku_cline)
            result.df <- result.df %>% mutate(ichimoku_bline = input_stock$ichimoku_bline)
            result.df <- result.df %>% mutate(ichimoku_lsa = input_stock$ichimoku_lsa)
            result.df <- result.df %>% mutate(ichimoku_lsb = input_stock$ichimoku_lsb)
            result.df <- result.df %>% mutate(ichimoku_lgp = input_stock$ichimoku_lgp)
        }
        if (input$LSMA == TRUE){
            result.df <- result.df %>% mutate(lsma = input_stock$lsma)
        }
        if (input$AO == TRUE){
            result.df <- result.df %>% mutate(ao = input_stock$ao)
        }
        if (input$momentum_oscillator == TRUE){
            result.df <- result.df %>% mutate(mom_osc = input_stock$mom_osc)
        }
        if (input$momentum == TRUE){
            result.df <- result.df %>% mutate(momemtum = input_stock$momemtum)
        }
        if (input$coppock == TRUE){
            result.df <- result.df %>% mutate(coppock = input_stock$coppock)
        }
        
        result.df
    })
    
    lm_stock <-reactive({all_time_stock() %>% 
            filter(all_time_stock()$date >= train_date() &
                       all_time_stock()$date < input$start_date) %>%
            select(-date)})

    lr <- reactive({ 
        lm(formula = close ~ ., data = lm_stock()) 
        })
    lm.pred <- reactive({ predict(lr(), test1_df()) })
    lm.rmse <- reactive({ rmse(lr(), test1_df()) })
    
    #fit stepwise regression model
    intercept_only <- reactive({lm(close ~ 1, data=train1_df())})
    all <- reactive({lm(close ~ ., data=train1_df())})
    backward <- reactive({ step(all(), direction='backward', scope=formula(all()), trace=0) })
    backward.pred <- reactive({predict(backward(), test1_df())})
    backward.rmse <- reactive({rmse(backward(), test1_df())})
    
    #fit random forest model
    rf <- reactive({randomForest(close ~ ., data=lm_stock())})
    rf.pred <- reactive({predict(rf(), test1_df())})
    rf.rmse <- reactive({rmse(rf(), test1_df())})
    
    #creating 10 train/test sets
    train_per_1 <- reactive({ all_time_stock() %>% filter(date >= as.Date('2017-01-01') & date <= as.Date('2017-06-01')) })
    test_per_1 <- reactive({ all_time_stock() %>% filter(date >= as.Date('2017-06-01') & date <= as.Date('2017-07-01')) })
    all_var_1 <- reactive({ stock_df() %>% filter(date >= as.Date('2017-01-01') & date <= as.Date('2017-06-01')) %>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high)})
    all_var_test_1 <- reactive({ stock_df() %>% filter(date >= as.Date('2017-06-01') & date <= as.Date('2017-07-01')) %>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })

    train_per_2 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2017-06-01'), as.Date('2017-12-31'))) })
    test_per_2 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2018-01-01'), as.Date('2018-02-01'))) })
    all_var_2 <- reactive({ stock_df() %>% filter(date >= as.Date('2017-06-01') & date <= as.Date('2017-12-31'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    all_var_test_2 <- reactive({ stock_df() %>% filter(date >= as.Date('2018-01-01') & date <= as.Date('2018-02-01'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    
    train_per_3 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2018-01-01'), as.Date('2018-06-01'))) })
    test_per_3 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2018-06-01'), as.Date('2018-07-01'))) })
    all_var_3 <- reactive({ stock_df() %>% filter(date >= as.Date('2018-01-01') & date <= as.Date('2018-06-01'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    all_var_test_3 <- reactive({ stock_df() %>% filter(date >= as.Date('2018-06-01') & date <= as.Date('2018-07-01'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    
    train_per_4 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2018-06-01'), as.Date('2018-12-31'))) })
    test_per_4 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2019-01-01'), as.Date('2019-02-01'))) })
    all_var_4 <- reactive({ stock_df() %>% filter(date >= as.Date('2018-06-01') & date <= as.Date('2018-12-31'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    all_var_test_4 <- reactive({ stock_df() %>% filter(date >= as.Date('2019-01-01') & date <= as.Date('2019-02-01'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    
    train_per_5 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2019-01-01'), as.Date('2019-06-01'))) })
    test_per_5 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2019-06-01'), as.Date('2019-07-01'))) })
    all_var_5 <- reactive({ stock_df() %>% filter(date >= as.Date('2019-01-01') & date <= as.Date('2019-06-01'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    all_var_test_5 <- reactive({ stock_df() %>% filter(date >= as.Date('2019-06-01') & date <= as.Date('2019-07-01'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    
    train_per_6 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2019-06-01'), as.Date('2019-12-31'))) })
    test_per_6 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2020-01-01'), as.Date('2020-02-01'))) })
    all_var_6 <- reactive({ stock_df() %>% filter(date >= as.Date('2019-06-01') & date <= as.Date('2019-12-31'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    all_var_test_6 <- reactive({ stock_df() %>% filter(date >= as.Date('2020-01-01') & date <= as.Date('2020-02-01'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    
    train_per_7 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2020-01-01'), as.Date('2020-06-01'))) })
    test_per_7 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2020-06-01'), as.Date('2020-07-01'))) })
    all_var_7 <- reactive({ stock_df() %>% filter(date >= as.Date('2020-01-01') & date <= as.Date('2020-06-01'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    all_var_test_7 <- reactive({ stock_df() %>% filter(date >= as.Date('2020-06-01') & date <= as.Date('2020-07-01'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    
    train_per_8 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2020-06-01'), as.Date('2020-12-31'))) })
    test_per_8 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2021-01-01'), as.Date('2021-02-01'))) })
    all_var_8 <- reactive({ stock_df() %>% filter(date >= as.Date('2020-06-01') & date <= as.Date('2020-12-31'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    all_var_test_8 <- reactive({ stock_df() %>% filter(date >= as.Date('2021-01-01') & date <= as.Date('2021-02-01'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    
    train_per_9 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2021-01-01'), as.Date('2021-06-01'))) })
    test_per_9 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2021-06-01'), as.Date('2021-07-01'))) })
    all_var_9 <- reactive({ stock_df() %>% filter(date >= as.Date('2021-01-01') & date <= as.Date('2021-06-01'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    all_var_test_9 <- reactive({ stock_df() %>% filter(date >= as.Date('2021-06-01') & date <= as.Date('2021-07-01'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    
    train_per_10 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2021-06-01'), as.Date('2021-12-31'))) })
    test_per_10 <- reactive({ all_time_stock() %>% filter(between(date, as.Date('2022-01-01'), as.Date('2022-02-01'))) })
    all_var_10 <- reactive({ stock_df() %>% filter(date >= as.Date('2021-06-01') & date <= as.Date('2021-12-31'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    all_var_test_10 <- reactive({ stock_df() %>% filter(date >= as.Date('2022-01-01') & date <= as.Date('2022-02-01'))%>%
            select(-open, -changes, -adjust, -...1,
                  -date, -stock_code, -low, -high) })
    
    #run ARIMA on train/test
    arima1 <- reactive({ auto.arima(train_per_1()$close) })
    arima2 <- reactive({ auto.arima(train_per_2()$close) })
    arima3 <- reactive({ auto.arima(train_per_3()$close) })
    arima4 <- reactive({ auto.arima(train_per_4()$close) })
    arima5 <- reactive({ auto.arima(train_per_5()$close) })
    arima6 <- reactive({ auto.arima(train_per_6()$close) })
    arima7 <- reactive({ auto.arima(train_per_7()$close) })
    arima8 <- reactive({ auto.arima(train_per_8()$close) })
    arima9 <- reactive({ auto.arima(train_per_9()$close) })
    arima10 <- reactive({ auto.arima(train_per_10()$close) })
    
    arima_pred_1 <- reactive({as.list(forecast(arima1(), length(test_per_1()$close))) })
    arima_pred_2 <- reactive({as.list(forecast(arima2(), length(test_per_2()$close))) })
    arima_pred_3 <- reactive({ as.list(forecast(arima3(), length(test_per_3()$close)))})
    arima_pred_4 <- reactive({as.list(forecast(arima4(), length(test_per_4()$close))) })
    arima_pred_5 <- reactive({as.list(forecast(arima5(), length(test_per_5()$close))) })
    arima_pred_6 <- reactive({as.list(forecast(arima6(), length(test_per_6()$close))) })
    arima_pred_7 <- reactive({as.list(forecast(arima7(), length(test_per_7()$close))) })
    arima_pred_8 <- reactive({as.list(forecast(arima8(), length(test_per_8()$close))) })
    arima_pred_9 <- reactive({as.list(forecast(arima9(), length(test_per_9()$close))) })
    arima_pred_10 <- reactive({as.list(forecast(arima10(), length(test_per_10()$close))) })
    
    arima.rmse.lst <- reactive({ c(rmsle(test_per_1()$close, arima_pred_1()$mean), 
                                   rmsle(test_per_2()$close, arima_pred_2()$mean),
                                   rmsle(test_per_3()$close, arima_pred_3()$mean),
                                   rmsle(test_per_4()$close, arima_pred_4()$mean),
                                   rmsle(test_per_5()$close, arima_pred_5()$mean),
                                   rmsle(test_per_6()$close, arima_pred_6()$mean),
                                   rmsle(test_per_7()$close, arima_pred_7()$mean),
                                   rmsle(test_per_8()$close, arima_pred_8()$mean),
                                   rmsle(test_per_9()$close, arima_pred_9()$mean),
                                   rmsle(test_per_10()$close, arima_pred_10()$mean)) })
    
    #fit linear regression into train/test sets
    lr1 <- reactive({ lm(formula = close ~ ., data = train_per_1()) })
    lr2 <- reactive({ lm(formula = close ~ ., data = train_per_2()) })
    lr3 <- reactive({ lm(formula = close ~ ., data = train_per_3()) })
    lr4 <- reactive({ lm(formula = close ~ ., data = train_per_4()) })
    lr5 <- reactive({ lm(formula = close ~ ., data = train_per_5()) })
    lr6 <- reactive({ lm(formula = close ~ ., data = train_per_6()) })
    lr7 <- reactive({ lm(formula = close ~ ., data = train_per_7()) })
    lr8 <- reactive({ lm(formula = close ~ ., data = train_per_8()) })
    lr9 <- reactive({ lm(formula = close ~ ., data = train_per_9()) })
    lr10 <- reactive({ lm(formula = close ~ ., data = train_per_10()) })
    
    lr_pred_1 <- reactive({as.numeric(predict(lr1(), test_per_1())) })
    lr_pred_2 <- reactive({as.numeric(predict(lr2(), test_per_2())) })
    lr_pred_3 <- reactive({as.numeric(predict(lr3(), test_per_3())) })
    lr_pred_4 <- reactive({as.numeric(predict(lr4(), test_per_4())) })
    lr_pred_5 <- reactive({as.numeric(predict(lr5(), test_per_5())) })
    lr_pred_6 <- reactive({as.numeric(predict(lr6(), test_per_6())) })
    lr_pred_7 <- reactive({as.numeric(predict(lr7(), test_per_7())) })
    lr_pred_8 <- reactive({as.numeric(predict(lr8(), test_per_8())) })
    lr_pred_9 <- reactive({as.numeric(predict(lr9(), test_per_9())) })
    lr_pred_10 <- reactive({as.numeric(predict(lr10(), test_per_10())) })
    
    lm.rmse.lst <- reactive({ c(rmsle(lr_pred_1(), test_per_1()$close),
                                rmsle(lr_pred_2(), test_per_2()$close),
                                rmsle(lr_pred_3(), test_per_3()$close),
                                rmsle(lr_pred_4(), test_per_4()$close),
                                rmsle(lr_pred_5(), test_per_5()$close),
                                rmsle(lr_pred_6(), test_per_6()$close),
                                rmsle(lr_pred_7(), test_per_7()$close),
                                rmsle(lr_pred_8(), test_per_8()$close),
                                rmsle(lr_pred_9(), test_per_9()$close),
                                rmsle(lr_pred_10(), test_per_10()$close)) })
    
    #fit backward regession to train/test set
    br1 <- reactive({ 
        intercept_only <- lm(close ~ 1, data=all_var_1())
        all <- lm(close ~ ., data=all_var_1())
        step(all(), direction='backward', scope=formula(all()), trace=0)
    })
    
    br2 <- reactive({ 
        intercept_only <- lm(close ~ 1, data=all_var_2())
        all <- lm(close ~ ., data=all_var_2())
        step(all(), direction='backward', scope=formula(all()), trace=0)
    })
    
    br3 <- reactive({ 
        intercept_only <- lm(close ~ 1, data=all_var_3())
        all <- lm(close ~ ., data=all_var_3())
        step(all(), direction='backward', scope=formula(all()), trace=0)
    })
    
    br4 <- reactive({ 
        intercept_only <- lm(close ~ 1, data=all_var_4())
        all <- lm(close ~ ., data=all_var_4())
        step(all(), direction='backward', scope=formula(all()), trace=0)
    })
    
    br5 <- reactive({ 
        intercept_only <- lm(close ~ 1, data=all_var_5())
        all <- lm(close ~ ., data=all_var_5())
        backward <- step(all(), direction='backward', scope=formula(all()), trace=0)
    })
    
    br6 <- reactive({ 
        intercept_only <- lm(close ~ 1, data=all_var_6())
        all <- lm(close ~ ., data=all_var_6())
        step(all(), direction='backward', scope=formula(all()), trace=0)
    })
    
    br7 <- reactive({ 
        intercept_only <- lm(close ~ 1, data=all_var_7())
        all <- lm(close ~ ., data=all_var_7())
        step(all(), direction='backward', scope=formula(all()), trace=0)
    })
    
    br8 <- reactive({ 
        intercept_only <- lm(close ~ 1, data=all_var_8())
        all <- lm(close ~ ., data=all_var_8())
        step(all(), direction='backward', scope=formula(all()), trace=0)
    })
    
    br9 <- reactive({ 
        intercept_only <- lm(close ~ 1, data=all_var_9())
        all <- lm(close ~ ., data=all_var_9())
        step(all(), direction='backward', scope=formula(all()), trace=0)
    })
    
    br10 <- reactive({ 
        intercept_only <- lm(close ~ 1, data=all_var_10())
        all <- lm(close ~ ., data=all_var_10())
        step(all(), direction='backward', scope=formula(all()), trace=0)
    })
    
    br_pred_1 <- reactive({as.numeric(predict(br1(), all_var_test_1())) })
    br_pred_2 <- reactive({as.numeric(predict(br2(), all_var_test_2())) })
    br_pred_3 <- reactive({as.numeric(predict(br3(), all_var_test_3())) })
    br_pred_4 <- reactive({as.numeric(predict(br4(), all_var_test_4())) })
    br_pred_5 <- reactive({as.numeric(predict(br5(), all_var_test_5())) })
    br_pred_6 <- reactive({as.numeric(predict(br6(), all_var_test_6())) })
    br_pred_7 <- reactive({as.numeric(predict(br7(), all_var_test_7())) })
    br_pred_8 <- reactive({as.numeric(predict(br8(), all_var_test_8())) })
    br_pred_9 <- reactive({as.numeric(predict(br9(), all_var_test_9())) })
    br_pred_10 <- reactive({as.numeric(predict(br10(), all_var_test_10())) })
    
    bm.rmse.lst <- reactive({ c(rmsle(br_pred_1(), all_var_test_1()$close),
                                rmsle(br_pred_2(), all_var_test_2()$close),
                                rmsle(br_pred_3(), all_var_test_3()$close),
                                rmsle(br_pred_4(), all_var_test_4()$close),
                                rmsle(br_pred_5(), all_var_test_5()$close),
                                rmsle(br_pred_6(), all_var_test_6()$close),
                                rmsle(br_pred_7(), all_var_test_7()$close),
                                rmsle(br_pred_8(), all_var_test_8()$close),
                                rmsle(br_pred_9(), all_var_test_9()$close),
                                rmsle(br_pred_10(), all_var_test_10()$close)) })
    
    #fit random forest to the train/test dataset
    rf1 <- reactive({ randomForest(formula = close ~ ., data = train_per_1()) })
    rf2 <- reactive({ randomForest(formula = close ~ ., data = train_per_2()) })
    rf3 <- reactive({ randomForest(formula = close ~ ., data = train_per_3()) })
    rf4 <- reactive({ randomForest(formula = close ~ ., data = train_per_4()) })
    rf5 <- reactive({ randomForest(formula = close ~ ., data = train_per_5()) })
    rf6 <- reactive({ randomForest(formula = close ~ ., data = train_per_6()) })
    rf7 <- reactive({ randomForest(formula = close ~ ., data = train_per_7()) })
    rf8 <- reactive({ randomForest(formula = close ~ ., data = train_per_8()) })
    rf9 <- reactive({ randomForest(formula = close ~ ., data = train_per_9()) })
    rf10 <- reactive({ randomForest(formula = close ~ ., data = train_per_10()) })
    
    rf_pred_1 <- reactive({as.numeric(predict(rf1(), test_per_1())) })
    rf_pred_2 <- reactive({as.numeric(predict(rf2(), test_per_2())) })
    rf_pred_3 <- reactive({as.numeric(predict(rf3(), test_per_3())) })
    rf_pred_4 <- reactive({as.numeric(predict(rf4(), test_per_4())) })
    rf_pred_5 <- reactive({as.numeric(predict(rf5(), test_per_5())) })
    rf_pred_6 <- reactive({as.numeric(predict(rf6(), test_per_6())) })
    rf_pred_7 <- reactive({as.numeric(predict(rf7(), test_per_7())) })
    rf_pred_8 <- reactive({as.numeric(predict(rf8(), test_per_8())) })
    rf_pred_9 <- reactive({as.numeric(predict(rf9(), test_per_9())) })
    rf_pred_10 <- reactive({as.numeric(predict(rf10(), test_per_10())) })
    
    rf.rmse.lst <- reactive({ c(rmsle(rf_pred_1(), test_per_1()$close),
                                rmsle(rf_pred_2(), test_per_2()$close),
                                rmsle(rf_pred_3(), test_per_3()$close),
                                rmsle(rf_pred_4(), test_per_4()$close),
                                rmsle(rf_pred_5(), test_per_5()$close),
                                rmsle(rf_pred_6(), test_per_6()$close),
                                rmsle(rf_pred_7(), test_per_7()$close),
                                rmsle(rf_pred_8(), test_per_8()$close),
                                rmsle(rf_pred_9(), test_per_9()$close),
                                rmsle(rf_pred_10(), test_per_10()$close)) })

    output$candlePlot <- renderDygraph({
        # generate bins based on input$bins from ui.R
        data <- data.frame(
            time= stock_df()$date, 
            open=stock_df()$open, 
            high=stock_df()$high, 
            low=stock_df()$low, 
            close=stock_df()$close 
        )
        
        # switch to xts format
        data <- xts(x = data[,-1], order.by = data$time)
        
        # Plot it
        dygraph(data) %>% dyCandlestick()
    })
    
    output$predPlot <- renderPlot({
        colors <- c("Real Closing Price" = "blue", "Predicted Closing Price" = 'red')
        if (input$algorithms == 'ARIMA'){
            p <- ggplot(test1_df(), aes(x = date())) + 
                geom_line(aes(y = close, color = "Real Closing Price"), size = 0.5) +
                geom_line(aes(y = arima.pred()$pred, color = "Predicted Closing Price"), size = 0.5) +
                labs(x = "Date",
                     y = "closing prices",
                     color = "Legend") +
                scale_color_manual(values = colors) +
                title("Comparison Between Predicted and Real Closing Price")
            
            p
        }
        else if (input$algorithms == 'Linear Regression'){
            ggplot(test1_df(), aes(x = date())) + 
                geom_line(aes(y = close, color = "Real Closing Price"), size = 0.5) +
                geom_line(aes(y = lm.pred(), color = "Predicted Closing Price"), size = 0.5) +
                labs(x = "Date",
                     y = "closing prices",
                     color = "Legend") +
                scale_color_manual(values = colors)
        }
        else if (input$algorithms == 'Stepwise Regression'){
            ggplot(test1_df(), aes(x = date())) + 
                geom_line(aes(y = close, color = "Real Closing Price"), size = 0.5) +
                geom_line(aes(y = backward.pred(), color = "Predicted Closing Price"), size = 0.5) +
                labs(x = "Date",
                     y = "closing prices",
                     color = "Legend") +
                scale_color_manual(values = colors)
        }
        else{
            ggplot(test1_df(), aes(x = date())) + 
                geom_line(aes(y = close, color = "Real Closing Price"), size = 0.5) +
                geom_line(aes(y = rf.pred(), color = "Predicted Closing Price"), size = 0.5) +
                labs(x = "Date",
                     y = "closing prices",
                     color = "Legend") +
                scale_color_manual(values = colors)
        }
    })
    
    output$rmsePlot <- renderDygraph({
        colors <- c("ARIMA's RMSE" = "royalblue2", "LR's RMSE" = "red", "BR's RMSE" = "orange", "RF's RMSE"='violet')
        
        rmse.date <- c(as.Date('2017-06-01'),
                       as.Date('2018-01-01'),
                       as.Date('2018-06-01'),
                       as.Date('2019-01-01'),
                       as.Date('2019-06-01'),
                       as.Date('2020-01-01'),
                       as.Date('2020-06-01'),
                       as.Date('2021-01-01'),
                       as.Date('2021-06-01'),
                       as.Date('2022-01-01'))
        rmse.df <- data.frame(rmse.date, arima.rmse.lst(), lm.rmse.lst(), bm.rmse.lst(), rf.rmse.lst())
        colnames(rmse.df) <- c('date', 'ARIMA (baseline)', 'LR', 'BR', 'RF')
        data <- xts(x = rmse.df[,-1], order.by = rmse.df$date)
        dygraph(data, main = "Model Comparison By RMSLE")
    })
    
    output$rmseTable <- renderTable({
        rmse.date <- c(as.Date('2017-06-01'),
                       as.Date('2018-01-01'),
                       as.Date('2018-06-01'),
                       as.Date('2019-01-01'),
                       as.Date('2019-06-01'),
                       as.Date('2020-01-01'),
                       as.Date('2020-06-01'),
                       as.Date('2021-01-01'),
                       as.Date('2021-06-01'),
                       as.Date('2022-01-01'))
        rmse.df <- data.frame(as.character(rmse.date), arima.rmse.lst(), lm.rmse.lst(), bm.rmse.lst(), rf.rmse.lst())
        colnames(rmse.df) <- c('Date', 'ARIMA (baseline)', 'Linear Regression', 'Stepwise Regression', 'Random Forest')
        rmse.df
    })
    
    output$indicatorTable <- renderTable({
        all.lm <- lm(close ~ ., data = train1_df())
        train1_df() %>% 
            do(tidy(all.lm <- lm(close ~ ., data = train1_df()))) %>% 
            select(term, estimate, std.error, t_stat = statistic, p_value = p.value)
    })
    

    output$debug <-renderText({
        as.character(
            
            colnames(all_var_test_1())
            )
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
