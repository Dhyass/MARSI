//+------------------------------------------------------------------+
//|                                                        MARSI.mq4 |
//|                                               NONZOOU MAGNOUDEWA |
//|                                                 https://magn.com |
//+------------------------------------------------------------------+
#property copyright "NONZOOU MAGNOUDEWA"
#property link      "https://magn.com"
#property version   "1.00"
#property strict
#property show_inputs
#property script_show_inputs
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

/*
enum Rispourcent 
  {
   a=0.005,     // 0.5%
   b=0.008,     // 0.8%
   c=0.01,     // 1.0%
   d=0.015,     // 1.5%
   e=0.018,    // 1.8%
   f=0.02,    // 2.0%
   g= 0.025,    // 2.5%
  };
//--- input parameters
input Rispourcent double RiskRatio=f; //valeur par defaut de perte max stoploss
*/
int order;

input double RiskRatio=0.02; //valeur par defaut de perte max stoploss
input double RiskReward=1.5;// valeur 

input int Inpstoploss= 500; // risque en pips pour le Stoploss
input int TrailingStop= 250;


bool res;
int i;

// les moyennes mobiles
double movingAverage_21 = iMA(NULL,PERIOD_H4,21,0, MODE_SMA,PRICE_OPEN,0);
double movingAverage_50 = iMA(NULL,PERIOD_H4,50,0, MODE_SMA,PRICE_CLOSE,0);

// le RSI

 double rsi_21=iRSI(NULL,PERIOD_H4,21,PRICE_CLOSE,0);

// infos du marches

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  niveau_Sell= SymbolInfoDouble(Symbol(),SYMBOL_BID); // Bid - best sell offer
double  niveau_Buy= SymbolInfoDouble(Symbol(),SYMBOL_ASK);
// les varibles generales
double currencyPrice = Open[0];
double LastPrice=Open[1];
double stoploss= Inpstoploss*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
double takeprofit= 2.5*stoploss;
double StopLossPrice=0;
double TakeProfitPrice=0;

// calcul de la tail de lots
  double riskPoints= Inpstoploss;
  double tickValue     = MarketInfo(Symbol(), MODE_TICKVALUE); // exemple EURUSD avec balance en GBP, on convertie usd en gbp
  double riskAmount =RiskRatio*AccountBalance(); // risque en argent RiskRatio en pourcetage
  double riskLots  = riskAmount / ( tickValue * riskPoints ); // la taille du lot


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
  //
 double LotSize= riskLots;
 Trading();
  
if(OrdersTotal()==0){
   if(movingAverage_21<movingAverage_50 && (currencyPrice>movingAverage_21)&& (currencyPrice< LastPrice))
     {
     // if(rsi_21<45&& rsi_21>=40)
       // {
          StopLossPrice = currencyPrice+stoploss;
          TakeProfitPrice = currencyPrice-takeprofit;
          //sell
            for(int j=0; j<1; j++){
           order= OrderSend(Symbol(), OP_SELL, LotSize, currencyPrice,0,StopLossPrice,TakeProfitPrice,NULL,0,0,NULL);
           }
    
     }
     else if(movingAverage_50<movingAverage_21 && currencyPrice<movingAverage_21 && (currencyPrice> LastPrice)){
      //if(rsi_21>55 && rsi_21<=60){
         StopLossPrice = currencyPrice-stoploss;
         TakeProfitPrice = currencyPrice+takeprofit;
       //buy
            for(int j=0; j<1; j++){
           order= OrderSend(Symbol(), OP_BUY, LotSize, currencyPrice,0,StopLossPrice,TakeProfitPrice,NULL,0,0,NULL);
           }
        }
      StopLossPrice = NormalizeDouble(StopLossPrice,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
      TakeProfitPrice= NormalizeDouble(TakeProfitPrice,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
     }else if(OrdersTotal()<3){
   if(movingAverage_21<movingAverage_50 && (currencyPrice>movingAverage_21)&& (currencyPrice< LastPrice))
     {
     // if(rsi_21<45&& rsi_21>=40)
       // {
          StopLossPrice = currencyPrice+stoploss;
          TakeProfitPrice = currencyPrice-takeprofit;
          //sell
         for(i= OrdersTotal()-1; i>=0; i--)
      {
       if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true && OrderSymbol()!=Symbol()){
       
           for(int j=0; j<1; j++){
           order= OrderSend(Symbol(), OP_SELL, LotSize, currencyPrice,0,StopLossPrice,TakeProfitPrice,NULL,0,0,NULL);
           }
          }

       }
     }
     else if(movingAverage_50<movingAverage_21 && currencyPrice<movingAverage_21 && (currencyPrice> LastPrice)){
      //if(rsi_21>55 && rsi_21<=60){
         StopLossPrice = currencyPrice-stoploss;
         TakeProfitPrice = currencyPrice+takeprofit;
       //buy
      for(i= OrdersTotal()-1; i>=0; i--)
      {
       if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true && OrderSymbol()!=Symbol()){
       
             for(int j=0; j<1; j++){
           order= OrderSend(Symbol(), OP_BUY, LotSize, currencyPrice,0,StopLossPrice,TakeProfitPrice,NULL,0,0,NULL);
           }
          }
     // }
         }
        }
      StopLossPrice = NormalizeDouble(StopLossPrice,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
      TakeProfitPrice= NormalizeDouble(TakeProfitPrice,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
     }
  }
  
  
//+------------------------------------------------------------------+


 void Trading()
  {
//---
if(OrdersTotal()<3){
  double movingAverage = iMA(NULL,0,15,0, MODE_EMA,PRICE_MEDIAN,0);
  //double currencyPrice = Open[0];
  //double LastPrice=Open[1];
  
  if ((currencyPrice> movingAverage) && (currencyPrice< LastPrice)){
   //sell
      StopLossPrice = currencyPrice+stoploss;
      TakeProfitPrice = currencyPrice-takeprofit;
     for(int j=0; j<1; j++){
      order= OrderSend(Symbol(), OP_SELL, riskLots, currencyPrice,0,StopLossPrice,TakeProfitPrice,NULL,0,0,NULL);
      }
  }else if((currencyPrice< movingAverage) && (currencyPrice> LastPrice)){
  //buy
         StopLossPrice = currencyPrice-stoploss;
         TakeProfitPrice = currencyPrice+takeprofit;
      for(int j=0; j<1; j++){
           order= OrderSend(Symbol(), OP_BUY, riskLots, currencyPrice,0,StopLossPrice,TakeProfitPrice,NULL,0,0,NULL);
           }
  }
   //Alert("Last Price "+ LastPrice + " curency Price " + movingAverage);
  }
}
