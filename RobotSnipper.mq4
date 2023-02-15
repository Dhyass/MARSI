//+------------------------------------------------------------------+
//|                                                 RobotSnipper.mq4 |
//|                                               NONZOOU MAGNOUDEWA |
//|                                                 https://magn.com |
//+------------------------------------------------------------------+
#property copyright "NONZOOU MAGNOUDEWA"
#property link      "https://magn.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int oder; 

// stopLoss

input double risk=0.02 ; // pourcentage risque
input double RiskRatio =2 ; //rapport TP/SL
input int Inpstoptloss = 500; // le risque en point

int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   AutoStopLoss();
   AutoTakeprofit();
   Trading();
  }
//+------------------------------------------------------------------+

void Trading()
  {
//---
if(OrdersTotal()<10){
  double movingAverage = iMA(NULL,0,21,0, MODE_EMA,PRICE_MEDIAN,0);
  double currencyPrice = Open[0];
  double LastPrice=Open[1];
  
  if ((currencyPrice> movingAverage) && (currencyPrice< LastPrice)){
   //sell
   oder= OrderSend(NULL, OP_SELL, 1, currencyPrice,0,NULL,NULL,NULL,0,0,NULL);
  }else if((currencyPrice< movingAverage) && (currencyPrice> LastPrice)){
  //buy
  oder= OrderSend(NULL, OP_BUY, 1, currencyPrice,0,NULL,NULL,NULL,0,0,NULL);
  }
   //Alert("Last Price "+ LastPrice + " curency Price " + movingAverage);
  }
}

void AutoStopLoss()
  {
//---
   datetime checkTime = TimeCurrent()-30;      // only looking at trading time in last 30 secondes
   int NbreTrads= OrdersTotal();   // nombes total de trades en cours
      for(int i=NbreTrads-1; i>=0; i--){
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
            if(OrderMagicNumber()==0 && OrderStopLoss()==0 &&(OrderType()==ORDER_TYPE_SELL ||OrderType()==ORDER_TYPE_BUY)){
            // magic 0 = manual entry SL 0 means no set
               if(OrderOpenTime()>checkTime){   // lets you override after 30 seconds
                 double stoploss= Inpstoptloss*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
                // double takeprofit= 4*Inpstoptloss*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
                 double StopLossPrice = (OrderType()==ORDER_TYPE_BUY)?
                                         OrderOpenPrice()-stoploss:
                                         OrderOpenPrice()+stoploss;
                 
                StopLossPrice = NormalizeDouble(StopLossPrice,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS)); 
               // OrderModify(OrderTicket(),OrderOpenPrice(), StopLossPrice, OrderTakeProfit(), OrderExpiration(), clrYellowGreen);                           
               }
            }
      
         }
      }   
  }
  
  
  void AutoTakeprofit()
  {
//---
   datetime checkTime = TimeCurrent()-30;      // only looking at trading time in last 30 secondes
   int NbreTrads= OrdersTotal();   // nombes total de trades en cours
      for(int i=NbreTrads-1; i>=0; i--){
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
            if(OrderMagicNumber()==0 && OrderTakeProfit()==0 &&(OrderType()==ORDER_TYPE_SELL ||OrderType()==ORDER_TYPE_BUY)){
            // magic 0 = manual entry SL 0 means no set
               if(OrderOpenTime()>checkTime){   // lets you override after 30 seconds
                 double takeprofit= Inpstoptloss*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
                 double takeprofitPrice = (OrderType()==ORDER_TYPE_BUY)?
                                         OrderOpenPrice()+takeprofit:
                                         OrderOpenPrice()-takeprofit;
                 
                takeprofitPrice = NormalizeDouble(takeprofitPrice,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS)); 
               // OrderModify(OrderTicket(),OrderOpenPrice(), takeprofitPrice, OrderStopLoss(), OrderExpiration(), clrYellowGreen);                           
               }
            }
      
         }
      }   
  }