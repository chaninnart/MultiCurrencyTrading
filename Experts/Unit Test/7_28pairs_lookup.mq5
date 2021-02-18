#include <Trade\Trade.mqh>
CTrade trade;
string pairs [7] = {"AUDUSD","USDCAD","USDCHF","EURUSD","GBPUSD","USDJPY","NZDUSD"};




void OnInit(){
   EventSetTimer(3);
}

void OnTimer(){OnTick();}


void OnTick()
  {
   MqlRates rates[];
   int copiedRates=CopyRates(NULL,PERIOD_CURRENT,0,10,rates); //symbol,timeframe,start,end,mqlrate array
   
   MqlTick Latest_Price; // Structure to get the latest prices      
   int copiedTick = SymbolInfoTick(Symbol() ,Latest_Price); // Assign current prices to structure 
   double spread_current = (Latest_Price.ask - Latest_Price.bid)*MathPow(10,_Digits);
   
   if(copiedRates<=0)
      Comment("Error copying price data ",GetLastError());
      
   else Comment(Latest_Price.bid+"/" +Latest_Price.ask+"/"+ rates[0].spread +"/"+ spread_current+"/"+SymbolExist("EURUSD",));//Comment("Copied ",ArraySize(rates)," bars");
}

void comment_this_text(string text){   
   Print(text);
   Comment(text);   
}






