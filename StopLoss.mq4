//+------------------------------------------------------------------+
//|                                                     StopLoss.mq4 |
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
   datetime checkTime = TimeCurrent()-30;      // only looking at trading time in last 30 secondes
   int NbreTrads= OrdersTotal();   // nombes total de trades en cours
      for(int i=NbreTrads-1; i>=0; i--){
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
            if(OrderMagicNumber()==0 && OrderStopLoss()==0 &&(OrderType()==ORDER_TYPE_SELL ||OrderType()==ORDER_TYPE_BUY)){
            // magic 0 = manual entry SL 0 means no set
               if(OrderOpenTime()>checkTime){   // lets you override after 30 seconds
                 double stoploss= Inpstoptloss*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
                 double takeprofit= 4*Inpstoptloss*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
                 double StopLossPrice = (OrderType()==ORDER_TYPE_BUY)?
                                         OrderOpenPrice()-stoploss:
                                         OrderOpenPrice()+stoploss;
                                         
                 StopLossPrice = NormalizeDouble(StopLossPrice,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS)); 
                OrderModify(OrderTicket(),OrderOpenPrice(), StopLossPrice, OrderTakeProfit(), OrderExpiration(), clrYellowGreen);  
                                       
               }
               
               if(OrderMagicNumber()==0 && OrderTakeProfit()==0 &&(OrderType()==ORDER_TYPE_SELL ||OrderType()==ORDER_TYPE_BUY)){
            // magic 0 = manual entry SL 0 means no set
               if(OrderOpenTime()>checkTime){   // lets you override after 30 seconds
                 double takeprofit= 2*Inpstoptloss*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
                 double takeprofitprice = (OrderType()==ORDER_TYPE_BUY)?
                                         OrderOpenPrice()+takeprofit:
                                         OrderOpenPrice()-takeprofit;
                 
            
                takeprofitprice = NormalizeDouble(takeprofitprice,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS)); 
                OrderModify(OrderTicket(),OrderOpenPrice(), OrderStopLoss(), takeprofitprice,OrderExpiration(), clrYellowGreen);  
                                       
               }
               
            }
      
         }
      }   
  }
  }
  
//+------------------------------------------------------------------+
