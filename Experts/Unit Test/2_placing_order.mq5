#include <Trade\Trade.mqh>
CTrade trade;
int MagicNumber=5652534;
int slippage=10;
string pairs [7] = {"AUDUSD","USDCAD","USDCHF","EURUSD","GBPUSD","USDJPY","NZDUSD"};




int OnInit(){
   EventSetTimer(3);
   //--- set MagicNumber for your orders identification   
   trade.SetExpertMagicNumber(MagicNumber);
//--- set available slippage in points when buying/selling   
   trade.SetDeviationInPoints(slippage);
//--- order filling mode, the mode allowed by the server should be used
   trade.SetTypeFilling(ORDER_FILLING_RETURN);
//--- logging mode: it would be better not to declare this method at all, the class will set the best mode on its own
   trade.LogLevel(1); 
//--- what function is to be used for trading: true - OrderSendAsync(), false - OrderSend()
   trade.SetAsyncMode(true);
//---
   return(0);
}

void OnTimer(){OnTick();}


void OnTick()
  {
      double ask, bid, point_size, balance, equity ;
      string text;
      
      for(int i=0;i<=6; i++){        
         ask = SymbolInfoDouble(pairs[i],SYMBOL_ASK);
         bid = SymbolInfoDouble(pairs[i],SYMBOL_BID);
         point_size = SymbolInfoDouble(pairs[i], SYMBOL_POINT ); 
         
         balance = AccountInfoDouble(ACCOUNT_BALANCE);
         equity = AccountInfoDouble(ACCOUNT_EQUITY);  
         
         text = text + "\n" + pairs[i] + "/"+ask+"/"+bid+"/"+point_size+"/"+balance +"/"+equity ; 
         //comment_this_text(text) ;    
         placing_order();

      } 
}

void comment_this_text(string text){   
   Print(text);
   Comment(text);   
}

void placing_order(){
   double volume=0.1;         // specify a trade operation volume
   string symbol="GBPUSD";    //specify the symbol, for which the operation is performed
   int    digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS); // number of decimal places
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);         // point 0.00001
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);             // current price for closing LONG
   double SL=bid-1000*point;                                   // unnormalized SL value .01
   SL=NormalizeDouble(SL,digits);                              // normalizing Stop Loss
   double TP=bid+1000*point;                                   // unnormalized TP value
   TP=NormalizeDouble(TP,digits);                              // normalizing Take Profit
//--- receive the current open price for LONG positions
   double open_price=SymbolInfoDouble(symbol,SYMBOL_ASK);
   string comment=StringFormat("Buy %s %G lots at %s, SL=%s TP=%s",
                               symbol,volume,
                               DoubleToString(open_price,digits),
                               DoubleToString(SL,digits),
                               DoubleToString(TP,digits));   
   comment_this_text(comment);  
}

void placing_buy_order(){
double volume=0.1;         // specify a trade operation volume
   string symbol="GBPUSD";    //specify the symbol, for which the operation is performed
   int    digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS); // number of decimal places
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);         // point
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);             // current price for closing LONG
   double SL=bid-1000*point;                                   // unnormalized SL value
   SL=NormalizeDouble(SL,digits);                              // normalizing Stop Loss
   double TP=bid+1000*point;                                   // unnormalized TP value
   TP=NormalizeDouble(TP,digits);                              // normalizing Take Profit
//--- receive the current open price for LONG positions
   double open_price=SymbolInfoDouble(symbol,SYMBOL_ASK);
   string comment=StringFormat("Buy %s %G lots at %s, SL=%s TP=%s",
                               symbol,volume,
                               DoubleToString(open_price,digits),
                               DoubleToString(SL,digits),
                               DoubleToString(TP,digits));
   if(!trade.Buy(volume,symbol,open_price,SL,TP,comment))
     {
      //--- failure message
      Print("Buy() method failed. Return code=",trade.ResultRetcode(),
            ". Code description: ",trade.ResultRetcodeDescription());
     }
   else
     {
      Print("Buy() method executed successfully. Return code=",trade.ResultRetcode(),
            " (",trade.ResultRetcodeDescription(),")");
     }
}

void modifying_order(){}





