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
//#include <bouton.mqh>
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

int maxTradesPerSymbol = 1;
int maxTradesOverall = 3;
int order;

input double RiskRatio=0.010; // Risque en argent 1%*captal/100
input double RiskReward=2;// Ratio Gain/Perte, Gain=2*risque

input int Inpstoploss= 500; // risque en pips pour le Stoploss
input int TrailingStop= 200;


bool res;
//int i;

// les moyennes mobiles
double movingAverage_21 = iMA(NULL,0,21,0, MODE_SMA,PRICE_OPEN,0);
double movingAverage_50 = iMA(NULL,0,50,0, MODE_SMA,PRICE_CLOSE,0);
 double  movingAverage_200 = iMA(NULL, 0, 200, 0, MODE_SMA, PRICE_CLOSE, 0);

// le RSI

 double rsi_21=iRSI(NULL,0,21,PRICE_CLOSE,0);
 double rsi_14=iRSI(NULL,0,14,PRICE_CLOSE,0);

// infos du marches

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int lastTrade=order;

double  niveau_Sell= SymbolInfoDouble(Symbol(),SYMBOL_BID); // Bid - best sell offer
double  niveau_Buy= SymbolInfoDouble(Symbol(),SYMBOL_ASK);
// les varibles generales
double currencyPrice = Close[0];
double LastPrice=Close[1];
double stoploss= Inpstoploss*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
double takeprofit= 2*stoploss;
double StopLossPrice=0;
double TakeProfitPrice=0;

// calcul de la tail de lots
  double riskPoints= Inpstoploss;
  double tickValue     = MarketInfo(Symbol(), MODE_TICKVALUE); // exemple EURUSD avec balance en GBP, on convertie usd en gbp
  double riskAmount =RiskRatio*AccountBalance(); // risque en argent RiskRatio en pourcetage
  double riskLots  = riskAmount / ( tickValue * riskPoints ); // la taille du lot
// 

 double tralingprice=TrailingStop*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT); // valeur du stop suiveur
 
 double lotSize= riskLots;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
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
  
   //StrategieMARSI();
   Trading();
   StoplossSuiveur();
   //IsRejectOnMA200();
   closeTradesOnProfit();
   //AutoSlTP();
//---
   
  
  }
  
  
//+------------------------------------------------------------------+


 void Trading()
  {
//---
  // les sommet avec m15
  double movingAverage = iMA(NULL,0,15,0, MODE_EMA,PRICE_MEDIAN,0);
    if ((currencyPrice> movingAverage) && (currencyPrice< LastPrice)&& rsi_21>=70){
   //sell
      
      openTrade(Symbol(), OP_SELL, "Sommet vente");
      
  }else if((currencyPrice< movingAverage) && (currencyPrice> LastPrice)&& rsi_21<=30){
  //buy
         openTrade(Symbol(), OP_BUY, "Sommet Achat");
    }
    
    //  StrategieMARSI()
    
    if(movingAverage_21<movingAverage_50 && (currencyPrice>=movingAverage_21))
     {
       if(rsi_21<45&& rsi_21>=41)
        {
       if((currencyPrice< LastPrice)&& LastPrice<=movingAverage_50){
        openTrade(Symbol(), OP_SELL, "Tendance vente");
       }
       }
     }
     else if(movingAverage_50<movingAverage_21 && currencyPrice<=movingAverage_21)
     {
      if(rsi_21>55 && rsi_21<=57){
      if((currencyPrice> LastPrice)&& LastPrice>=movingAverage_50){
         openTrade(Symbol(), OP_BUY, "Tendance Achat");
         }
         }
        
        }
        
      ///////IsRejectOnMA200()
      // Fonction pour vérifier le rejet sur une moyenne mobile spécifique
      
       if(movingAverage_200>movingAverage_50 && (LastPrice >= movingAverage_200))
     {
       if( rsi_21>=70 && currencyPrice < movingAverage_200)
        {
        openTrade(Symbol(), OP_SELL, "Tendance vente MA200");
       }
     
     }
     else if(movingAverage_200<movingAverage_50 && (LastPrice <= movingAverage_200))
     {
      if(rsi_21<=30 && currencyPrice > movingAverage_200){
      
         openTrade(Symbol(), OP_BUY, "Tendance Achat ME200");
     
         }
        
        }
        
   
   }

void StoplossSuiveur()
   {
        // stop loss suiveur
  double TralStopLossPrice=0;
   
    for(int i= OrdersTotal()-1; i>=0; i--)
      {
       double Suiveur=MathAbs((OrderOpenPrice()-currencyPrice)/tralingprice);
       
      // for sell
       if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true){
       
          if(OrderType()==ORDER_TYPE_SELL && Suiveur>=1 && OrderOpenPrice()>currencyPrice){
                  TralStopLossPrice = currencyPrice+tralingprice;
               if(OrderStopLoss()>TralStopLossPrice){
                  res=OrderModify(OrderTicket(),OrderOpenPrice(),TralStopLossPrice,OrderTakeProfit(),0,Blue);
               
               }
               
             //  res=OrderModify(OrderTicket(),OrderOpenPrice(),StopLossPrice,OrderTakeProfit(),0,Blue); 
          }
          else if( OrderType()==ORDER_TYPE_BUY && Suiveur>=1 && OrderOpenPrice()<currencyPrice){
                   
                  TralStopLossPrice= currencyPrice-tralingprice; 
                  if(OrderStopLoss()<TralStopLossPrice){
                  res=OrderModify(OrderTicket(),OrderOpenPrice(),TralStopLossPrice,OrderTakeProfit(),0,Blue);
               
               }
                   
                  } 
          TralStopLossPrice = NormalizeDouble(TralStopLossPrice,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
        
           }
        } 
       }  
   


// Define OnTrade function

void OnTrade()
   {
    // Close last trade if it's not closed yet
    if (lastTrade > 0 && OrderSelect(lastTrade, SELECT_BY_TICKET) && !OrderCloseTime())
    {
        bool verifyClose =OrderClose(lastTrade, OrderLots(), Bid, 3);
    }
    }


//fermeture automatique des trades

void closeTradesOnProfit() {
   int totalTrades = OrdersTotal();
   double totalProfit = 0.0;

   for (int p = 0; p < totalTrades; p++) {
      if (OrderSelect(p, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol()) {
            double profit = OrderProfit();
               totalProfit += profit;
           
         }
      }
   }

   if (totalProfit >= 0.05*AccountBalance()|| totalProfit <= -0.02*AccountBalance()) {
      for (int p = 0; p < totalTrades; p++) {
         if (OrderSelect(p, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol()) {
             bool closed = OrderClose(OrderTicket(), OrderLots(), Bid, 3);
            }
         }
      }
   }
}


void closeTradesOnProfitTarget(double target) {
   double currentProfit = 0.0;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         currentProfit += OrderProfit();
      }
   }
   double dailyProfit = currentProfit + AccountInfoDouble(ACCOUNT_PROFIT);
   if (dailyProfit >= target) {
      for (int i = 0; i < OrdersTotal(); i++) {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            bool ordre = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3, CLR_NONE);
         }
      }
   }
}


// Fonction d'ouverture de position
void openTrade(string symbol, int tradeType, string text )
{
    int totalTrades = 0;
    int symbolTrades = 0;
    
    // Compter le nombre total de trades et le nombre de trades sur le symbole donné
    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderSymbol() == symbol)
            {
                symbolTrades++;
            }
            
            totalTrades++;
        }
    }
    
    // Vérifier les limites de trades
    if (symbolTrades >= maxTradesPerSymbol || totalTrades >= maxTradesOverall)
    {
        return; // Ne pas ouvrir de nouvelle position si les limites sont atteintes
    }
    
    
    // Calculer le stop loss et le take profit
    double stopLossLevel =0, takeProfitLevel=0;
    if (tradeType == OP_BUY)
    {
         stopLossLevel = currencyPrice-stoploss;
         takeProfitLevel = currencyPrice+takeprofit;
      
    }
    else if (tradeType == OP_SELL)
    {
         stopLossLevel = currencyPrice-stoploss;
         takeProfitLevel = currencyPrice+takeprofit;
    }
     stopLossLevel = NormalizeDouble(stopLossLevel,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
      takeProfitLevel= NormalizeDouble(takeProfitLevel,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
    // Ouvrir la position
    text = " ";
    int ticket = OrderSend(symbol, tradeType, lotSize, currencyPrice, 0, stopLossLevel, takeProfitLevel, text , clrAliceBlue);
    
    // Activer le stop loss suiveur
    
    if (OrdersTotal() > 0)
    {
        bool trailingStopActivated = false;
        
       
    }
    
}

void AutoSlTP()
  {
//---
   datetime checkTime = TimeCurrent()-30;      // only looking at trading time in last 30 secondes
   int NbreTrads= OrdersTotal();   // nombes total de trades en cours
      for(int i=NbreTrads-1; i>=0; i--){
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
            if(OrderMagicNumber()==0 && OrderStopLoss()==0 &&(OrderType()==ORDER_TYPE_SELL ||OrderType()==ORDER_TYPE_BUY)){
            // magic 0 = manual entry SL 0 means no set
               //if(OrderOpenTime()>checkTime){   // lets you override after 30 seconds
                 stoploss= Inpstoploss*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
                 StopLossPrice = (OrderType()==ORDER_TYPE_BUY)?
                                         OrderOpenPrice()-stoploss:
                                         OrderOpenPrice()+stoploss;
                                         
                 StopLossPrice = NormalizeDouble(StopLossPrice,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS)); 
                bool ft= OrderModify(OrderTicket(),OrderOpenPrice(), StopLossPrice, OrderTakeProfit(), OrderExpiration(), clrYellowGreen);  
                                       
              // }
               
            }
            
             if(OrderMagicNumber()==0 && OrderTakeProfit()==0 &&(OrderType()==ORDER_TYPE_SELL ||OrderType()==ORDER_TYPE_BUY)){
            // magic 0 = manual entry SL 0 means no set
              // if(OrderOpenTime()>checkTime){   // lets you override after 30 seconds
                 takeprofit= 2*Inpstoploss*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
                 TakeProfitPrice = (OrderType()==ORDER_TYPE_BUY)?
                                         OrderOpenPrice()+takeprofit:
                                         OrderOpenPrice()-takeprofit;
                 
            
                TakeProfitPrice = NormalizeDouble(TakeProfitPrice,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS)); 
               bool ft= OrderModify(OrderTicket(),OrderOpenPrice(), OrderStopLoss(), TakeProfitPrice,OrderExpiration(), clrYellowGreen);  
                                       
              // }
      
         }
      }   
  }
  }
