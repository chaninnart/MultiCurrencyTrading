#include <Trade\Trade.mqh>
CTrade trade;
//string pairs [7] = {"AUDUSD","USDCAD","USDCHF","EURUSD","GBPUSD","USDJPY","NZDUSD"};
string pairs[28] = {
   "AUDCAD",	"AUDCHF",	"AUDJPY",	"AUDNZD",	"AUDUSD",
   "CADCHF",	"CADJPY",
   "CHFJPY",	
   "EURAUD",	"EURCAD",	"EURCHF",	"EURGBP",	"EURJPY",   "EURNZD",	"EURUSD",	
   "GBPAUD",	"GBPCAD",	"GBPCHF",   "GBPJPY",	"GBPNZD",	"GBPUSD",	
   "NZDCAD",   "NZDCHF",	"NZDJPY",	"NZDUSD",
   "USDCAD",   "USDCHF",	"USDJPY"};

string pairs_avaiable[];



void OnInit(){
   EventSetTimer(3);
   is_pairs_exist();
   comment_pairs_info();
}

void OnTimer(){OnTick();}


void OnTick(){
      is_pairs_exist();
      comment_pairs_info();

}

void is_pairs_exist(){
      bool is_custom=false;
      for(int i=0; i< ArraySize(pairs); i++){            
         if(SymbolExist(pairs[i],is_custom)){
            //Print("PASSED: Symbol #0 (",pairs[i],") is exist");            
         }
         if(!SymbolExist(pairs[i],is_custom)){
            //Print("ERROR: Symbol #0 (",pairs[i],") not exist !!!!!"); 
               pairs[i] = pairs[i]+"#";
                  if(SymbolExist(pairs[i],is_custom)){
                     //Print("PASSED NEW: Symbol # replaced #0 (",pairs[i],")  !!!!!"); 
                  }
                  else
                    {
                     pairs[i]= "XXXXXX";
                    }
         }  
      }       
}

void comment_pairs_info(){
   MqlRates rates[];
   int copiedRates [ArraySize(pairs)];
   
   
   MqlTick Latest_Price; // Structure to get the latest prices      
   int copiedTick [ArraySize(pairs)];
   int spread_current ;
   

   int tickSize; 
   string text = "      SYMBOL   |     BID    |    ASK    | DI | Sp | SP|"+"\n" ;
    
    for(int i=0; i< ArraySize(pairs); i++){
         copiedRates [i]=CopyRates(pairs[i],PERIOD_CURRENT,0,5,rates); //symbol,timeframe,start,end,mqlrate array   
         copiedTick [i] = SymbolInfoTick(pairs[i] ,Latest_Price); // Assign current prices to structure 
         
         tickSize = SymbolInfoInteger( pairs[i], SYMBOL_DIGITS );
         spread_current = (Latest_Price.ask - Latest_Price.bid)*MathPow(10,tickSize);
         
         if(copiedRates [i]<=0)
            text = text + " :Error copying price data ";      
         else  //rates[0].spread +"/"+ spread_current);//Comment("Copied ",ArraySize(rates)," bars");         
            text = text  + i + ". "
                         + pairs[i]+ ":   " 
                         + DoubleToString(Latest_Price.bid,tickSize)+"  |  " 
                         + DoubleToString(Latest_Price.ask,tickSize) + "  |  " 
                         + tickSize +"  |  " 
                         + rates[0].spread +"  |  " 
                         + spread_current +"  |  "
                         + "\n" ;         
    
    
    }
    Comment (text);
}

