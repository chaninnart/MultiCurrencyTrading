#include <Trade\Trade.mqh>
CTrade trade;
string pairs [7] = {"AUDUSD","USDCAD","USDCHF","EURUSD","GBPUSD","USDJPY","NZDUSD"};
string currency [8] = {"AUD","CAD","CHF","EUR","GBP","USD","JPY","NZD"};



void OnTimer(){OnTick();}


void OnInit(){
   EventSetTimer(3);
   handle_init();
   
}

void OnTick(){
   Print(handle_hull()+"*******************");
}

int handle_for_hull[7];          // handle icustom *** global variable
void handle_init(){           // all the icustom init here
     
      for(int i=0; i< ArraySize(handle_for_hull); i++){
         handle_for_hull[i] = iCustom(pairs[i],PERIOD_M15,"HullAverage2");         
      }            
      
}

string handle_hull(){  
   double buffer0_AUDUSD [],buffer1_AUDUSD[];
   ArraySetAsSeries(buffer0_AUDUSD,true);
   ArraySetAsSeries(buffer1_AUDUSD,true);

   CopyBuffer(handle_for_hull[0],0,0,5,buffer0_AUDUSD);
   CopyBuffer(handle_for_hull[0],1,0,5,buffer1_AUDUSD);
  
   if (buffer1_AUDUSD[1] == 1.0 && buffer1_AUDUSD[2] == 2.0){return "buy";} //1.0 = green / 2.0 = red
   if (buffer1_AUDUSD[1] == 2.0 && buffer1_AUDUSD[2] == 1.0){return "sell";}
//Comment(buffer0_AUDUSD[0] +"\n"+ buffer1_AUDUSD[0]+"\n"+buffer0_AUDUSD[1] +"\n"+ buffer1_AUDUSD[1]+"\n"+buffer0_AUDUSD[2] +"\n"+ buffer1_AUDUSD[2]+"\n");

return("NONE");
}
      






