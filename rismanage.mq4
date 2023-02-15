//+------------------------------------------------------------------+
//|                                                    rismanage.mq4 |
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
  PrintFormat( "Base currency is %s", AccountInfoString( ACCOUNT_CURRENCY ) );
   PrintFormat( "Testing for symbol %s", Symbol() );

  double  niveau_Sell= SymbolInfoDouble(Symbol(),SYMBOL_BID); // Bid - best sell offer
double  niveau_Buy= SymbolInfoDouble(Symbol(),SYMBOL_ASK);
// les varibles generales
double currencyPrice = Open[0];
double LastPrice=Open[1];
double riskPoints =500;
//double stoploss= Inpstoploss*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
double stoploss= riskPoints*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
double takeprofit= 2.5*stoploss;
double StopLossPrice=0;
double TakeProfitPrice=0;

   

   

   double tickSize      = SymbolInfoDouble( Symbol(), SYMBOL_TRADE_TICK_SIZE );
   double tickValue     = MarketInfo(Symbol(), MODE_TICKVALUE);
   double point=MarketInfo(Symbol(),MODE_POINT);
   double ticksPerPoint = tickSize / point;
   double pointValue    = tickValue / ticksPerPoint;

  PrintFormat( "tickSize=%f, tickValue=%f, point=%f, ticksPerPoint=%f, pointValue=%f",
                tickSize, tickValue, point, ticksPerPoint, pointValue );
               
   double riskAmount =0.01*AccountBalance();
   double riskLots   = riskAmount / ( tickValue * riskPoints );
  
   PrintFormat( "Risk lots for %s value %f and stop loss at %f points is %f",
                Symbol(), riskAmount, riskPoints, riskLots );
                
          StopLossPrice = currencyPrice+stoploss;
          TakeProfitPrice = currencyPrice-takeprofit;
          //sell
            for(int j=0; j<1; j++){
           double order= OrderSend(Symbol(), OP_SELL, riskLots , currencyPrice,0,StopLossPrice,TakeProfitPrice,NULL,0,0,NULL);
           }
  
  
  Comment("TICKVALUE = " + MarketInfo(Symbol(), MODE_TICKVALUE) + ", 1 / Bid = " + (1 / Bid));

  }
//+------------------------------------------------------------------+
