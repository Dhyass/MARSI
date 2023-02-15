//+------------------------------------------------------------------+
//|                                                        teset.mq4 |
//|                                               NONZOOU MAGNOUDEWA |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "NONZOOU MAGNOUDEWA"
#property link      ""
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int oder;

int Inpstoploss= 500;
int TrailingStop= 250;


 bool res;
 int i;

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
  double movingAverage = iMA(NULL,0,15,0, MODE_EMA,PRICE_MEDIAN,0);
  double currencyPrice = Open[0];
  double LastPrice=Open[1];
  double stoploss= Inpstoploss*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
  double takeprofit= 2.5*stoploss;
  double StopLossPrice=0;
  double TakeProfitPrice=0;
 if(OrdersTotal()<10){
  if ((currencyPrice> movingAverage) && (currencyPrice< LastPrice)){
  StopLossPrice = currencyPrice+stoploss;
  TakeProfitPrice = currencyPrice-takeprofit;
   //sell
   for(int j=0; j<2; j++){
      oder= OrderSend(Symbol(), OP_SELL, 1, currencyPrice,0,StopLossPrice,TakeProfitPrice,NULL,0,0,NULL);
   }
   // cloture des positions en achat
   for(i= OrdersTotal()-1; i>=0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true && OrderType()==ORDER_TYPE_BUY && OrderSymbol()==Symbol()){
        OrderClose(i,OrderLots(),currencyPrice,10,clrRosyBrown); 
      }
   }
   
  }else if((currencyPrice< movingAverage) && (currencyPrice> LastPrice)){
  StopLossPrice = currencyPrice-stoploss;
  TakeProfitPrice = currencyPrice+takeprofit;
  //buy
  for(int j=0; j<2; j++){
      oder= OrderSend(Symbol(), OP_BUY, 1, currencyPrice,0,StopLossPrice,TakeProfitPrice,NULL,0,0,NULL);
   }
  
   // cloture des positions en vente
   for(i= OrdersTotal()-1; i>=0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true && OrderType()==ORDER_TYPE_SELL && OrderSymbol()==Symbol()){
          OrderClose(i,OrderLots(),currencyPrice,10,clrBeige);  
      }
   }
  }
  StopLossPrice = NormalizeDouble(StopLossPrice,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
  TakeProfitPrice= NormalizeDouble(TakeProfitPrice,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
  
 }
  // stop loss suiveur
  
  /*
   for(i= OrdersTotal()-1; i>=0; i--)
      {
       if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true){
          if(OrderType()==ORDER_TYPE_SELL && OrderOpenPrice()-Ask>Point*TrailingStop){
             if(OrderStopLoss()>MathAbs(Ask-Point*TrailingStop)){
            res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(MathAbs(Ask-Point*TrailingStop),Digits),OrderTakeProfit(),0,Blue);
           }
          }
          else if( OrderType()==ORDER_TYPE_BUY && Bid-OrderOpenPrice()>Point*TrailingStop){
                     if(OrderStopLoss()<Bid-Point*TrailingStop){
                     res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-Point*TrailingStop,Digits),OrderTakeProfit(),0,Blue);
                     }
                  } 
         if(!res){
               Print("Error in OrderModify. Error code=",GetLastError());
            }else
               {Print("Order modified successfully.");}
           }
        }
        
      */
  }
  
//+------------------------------------------------------------------+

     
  
