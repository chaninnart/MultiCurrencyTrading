#include <Trade\Trade.mqh>
CTrade trade;
string pairs [7] = {"AUDUSD","USDCAD","USDCHF","EURUSD","GBPUSD","USDJPY","NZDUSD"};




void OnInit(){
   EventSetTimer(3);
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
         comment_this_text(text) ;    
         

      } 
}

void comment_this_text(string text){   
   Print(text);
   Comment(text);   
}






