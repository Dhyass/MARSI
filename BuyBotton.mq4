//+------------------------------------------------------------------+
//|                                                    BuyBotton.mq4 |
//|                                               NONZOOU MAGNOUDEWA |
//|                                                 https://magn.com |
//+------------------------------------------------------------------+
#property copyright "NONZOOU MAGNOUDEWA"
#property link      "https://magn.com"
#property version   "1.00"
#property strict

#include <Controls\Button.mqh>
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
//---
   BuyBotun();
   SellButun();
   
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
ObjectSetString(Symbol(), "BUYBOTTON", OBJPROP_TEXT,"BUY");

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
         // cart out put
         Comment(sparam+ " was pressede");
         //open buy order
         bool der= OrderSend(Symbol(), OP_BUY, 0.1, Bid,3,0,NULL,NULL,0,0,Green);
         // Change button background color to green when pressed
            ObjectSetInteger(Symbol(), "BUYBOTTON", OBJPROP_COLOR, clrGreen);
        }else if(sparam=="SELLBOTTON")
           {
            // cart out put
         Comment(sparam+ " was pressede");
         //open buy order
         bool der= OrderSend(Symbol(), OP_SELL, 0.1, Ask,3,0,NULL,NULL,0,0,Green);
         
          // Change button background color to yellow when pressed
            ObjectSetInteger(Symbol(), "SELLBOTTON", OBJPROP_COLOR, clrYellow);
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
ObjectSetString(Symbol(), "SELLBOTTON", OBJPROP_TEXT,"SELL");

// set button background color to red
 ObjectSetInteger(Symbol(), "SELLBOTTON", OBJPROP_COLOR, clrRed);
  }
