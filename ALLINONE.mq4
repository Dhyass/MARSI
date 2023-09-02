//+------------------------------------------------------------------+
//|                                                     ALLINONE.mq4 |
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
#include <Controls\Button.mqh>

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
  double riskLots  = NormalizeDouble( riskAmount / ( tickValue * riskPoints ), 2); // la taille du lot
// 

 double tralingprice=TrailingStop*SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT); // valeur du stop suiveur
 
 double lotSize= riskLots;
 
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
   StoplossSuiveur();
   AutoSlTP();
   closeTradesOnProfitTarget();
   BuyBotun();
   SellButun();
   CloseButun();
   
  }
//+------------------------------------------------------------------+


// Define OnTrade function

void OnTrade()
   {
    // Close last trade if it's not closed yet
    if (lastTrade > 0 && OrderSelect(lastTrade, SELECT_BY_TICKET) && !OrderCloseTime())
    {
        bool verifyClose =OrderClose(lastTrade, OrderLots(), Bid, 3);
    }
    }
// Fonction pour compter le nombre total de trades ouverts
int CountOpenTradesTotal()
{
    int count = 0;
    
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            count++;
        }
    }
    
    return count;
}


void closeTradesOnProfitTarget() {
   
   double dailyProfit =  AccountInfoDouble(ACCOUNT_PROFIT);
   if (dailyProfit >= 0.08*AccountBalance()|| dailyProfit <= -0.03*AccountBalance()) {
      for (int i = 0; i < OrdersTotal(); i++) {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            bool ordre = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3, CLR_NONE);
         }
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
   
   void  AutoSlTP()
  {
//
  datetime checkTime = TimeCurrent()-30;      // only looking at trading time in last 30 secondes
   int NbreTrads= OrdersTotal();   // nombes total de trades en cours
      for(int i=NbreTrads-1; i>=0; i--){
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         // automatique stoploss
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
  
  
   
  void BuyBotun()
  {
//---
    ObjectCreate(
    Symbol(),      // Current chart
   "BUYBOTTON" ,   // object name
   OBJ_BUTTON,   // object type
   0,             // in main window
   0,             // no datetime
   0              // no price
   );
   
   
   // set distance frome border
ObjectSetInteger(Symbol(), "BUYBOTTON", OBJPROP_XDISTANCE,155);
// set width
ObjectSetInteger(Symbol(), "BUYBOTTON", OBJPROP_XSIZE,100);
// set distance frome border
ObjectSetInteger(Symbol(), "BUYBOTTON", OBJPROP_YDISTANCE,50);
// set height
ObjectSetInteger(Symbol(), "BUYBOTTON", OBJPROP_YSIZE,30);
// set button text
ObjectSetString(Symbol(), "BUYBOTTON", OBJPROP_TEXT,"BUY Max : " + riskLots);
// set button background color to blue
   ObjectSetInteger(Symbol(), "BUYBOTTON", OBJPROP_COLOR, clrBlue);
  }

// event handling

void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
  {
  //if an object was clicked
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
     // if buy button was pressed
      if(sparam=="BUYBOTTON")
        {
        //open buy order
        openTrade(Symbol(), OP_BUY);
         // cart out put
         Comment(sparam+ " was pressede");
         // Change button background color to green when pressed
            ObjectSetInteger(Symbol(), "BUYBOTTON", OBJPROP_COLOR, clrGreen);
        }else if(sparam=="SELLBOTTON")
           {
           openTrade(Symbol(), OP_SELL);
            // cart out put
         Comment(sparam+ " was pressede");
        
        // bool der= OrderSend(Symbol(), OP_SELL, 0.1, Ask,3,0,NULL,NULL,0,0,Green);
         
          // Change button background color to yellow when pressed
            ObjectSetInteger(Symbol(), "SELLBOTTON", OBJPROP_COLOR, clrYellow);
           }else if(sparam=="CLOSEBOTTON")
           {
            // cart out put
         Comment(sparam+ " was pressede");
         //open buy order
         for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrRed);
        }
    }
         
          // Change button background color to yellow when pressed
            ObjectSetInteger(Symbol(), "CLOSEBOTTON", OBJPROP_COLOR, clrYellow);
           }
     }
     
     // If an object was hovered over
    else if (id == CHARTEVENT_MOUSE_MOVE)
    {
        // If buy button is being hovered over
        if (sparam == "BUYBOTTON")
        {
            // Change button background color to light green when hovered over
            ObjectSetInteger(Symbol(), "BUYBOTTON", OBJPROP_COLOR, clrLightGreen);
        }
        // If sell button is being hovered over
        else if (sparam == "SELLBOTTON")
        {
            // Change button background color to light yellow when hovered over
            ObjectSetInteger(Symbol(), "SELLBOTTON", OBJPROP_COLOR, clrLightYellow);
        }
    }
  }
  
  void SellButun()
  {
//---
    ObjectCreate(
    Symbol(),      // Current chart
   "SELLBOTTON" ,   // object name
   OBJ_BUTTON,   // object type
   0,             // in main window
   0,             // no datetime
   0              // no price
   );
   
   
   // set distance frome border
ObjectSetInteger(Symbol(), "SELLBOTTON", OBJPROP_XDISTANCE,50);
// set width
ObjectSetInteger(Symbol(), "SELLBOTTON", OBJPROP_XSIZE,100);
// set distance frome border
ObjectSetInteger(Symbol(), "SELLBOTTON", OBJPROP_YDISTANCE,50);
// set height
ObjectSetInteger(Symbol(), "SELLBOTTON", OBJPROP_YSIZE,30);
// set button text
ObjectSetString(Symbol(), "SELLBOTTON", OBJPROP_TEXT,"SELL Max " + riskLots);

// set button background color to red
 ObjectSetInteger(Symbol(), "SELLBOTTON", OBJPROP_COLOR, clrRed);
  }

 void CloseButun()
  {
//---
    ObjectCreate(
    Symbol(),      // Current chart
   "CLOSEBOTTON" ,   // object name
   OBJ_BUTTON,   // object type
   0,             // in main window
   0,             // no datetime
   0              // no price
   );
   
   
   // set distance frome border
ObjectSetInteger(Symbol(), "CLOSEBOTTON", OBJPROP_XDISTANCE,50);
// set width
ObjectSetInteger(Symbol(), "CLOSEBOTTON", OBJPROP_XSIZE,205);
// set distance frome border
ObjectSetInteger(Symbol(), "CLOSEBOTTON", OBJPROP_YDISTANCE,85);
// set height
ObjectSetInteger(Symbol(), "CLOSEBOTTON", OBJPROP_YSIZE,30);
// set button text
ObjectSetString(Symbol(), "CLOSEBOTTON", OBJPROP_TEXT,"CLOSE ALL : " + AccountInfoDouble(ACCOUNT_PROFIT));
//ObjectSetString(Symbol(), "CLOSEBOTTON", OBJPROP_BGCOLOR, clrAzure);

// set button background color to red
if(AccountInfoDouble(ACCOUNT_PROFIT)<0)
  {
   ObjectSetInteger(Symbol(), "CLOSEBOTTON", OBJPROP_COLOR, clrRed);
  }else if(AccountInfoDouble(ACCOUNT_PROFIT)>0)
          {
        ObjectSetInteger(Symbol(), "CLOSEBOTTON", OBJPROP_COLOR, clrBlue);   
          }else
             {
              ObjectSetInteger(Symbol(), "CLOSEBOTTON", OBJPROP_COLOR, clrGray); 
             }
 
  }
  
  
 
 // Fonction d'ouverture de position
void openTrade(string symbol, int tradeType)
{
    // Calculer le stop loss et le take profit
    double stopLossLevel =0, takeProfitLevel=0;
    if (tradeType == OP_BUY)
    {
         stopLossLevel = currencyPrice-stoploss;
         takeProfitLevel = currencyPrice+takeprofit;
      
    }
    else if (tradeType == OP_SELL)
    {
         stopLossLevel = currencyPrice+stoploss;
         takeProfitLevel = currencyPrice-takeprofit;
    }
     stopLossLevel = NormalizeDouble(stopLossLevel,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
     takeProfitLevel= NormalizeDouble(takeProfitLevel,(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
    // Ouvrir la position
   string text = "GOOD LUCK ";
    int ticket = OrderSend(symbol, tradeType, lotSize, currencyPrice, 0, stopLossLevel, takeProfitLevel, text , clrAliceBlue);
    
    // Activer le stop loss suiveur
    
    if (OrdersTotal() > 0)
    {
        bool trailingStopActivated = false;
        
       
    }
    
}

