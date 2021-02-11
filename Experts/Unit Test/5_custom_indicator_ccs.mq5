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
   handle_ccs();

}

int handle_for_ccs;         // handle icustom *** global variable
void handle_init(){     // all the icustom init here
      handle_for_ccs = iCustom(NULL,PERIOD_H4,"FlukeMultiCurrencyIndex"); 
      handle_ccs(); 
}

void handle_ccs(){  
   double buffer0 [],buffer1[],buffer2[],buffer3[],buffer4[],buffer5[],buffer6[],buffer7[];
   ArraySetAsSeries(buffer0,true);
   ArraySetAsSeries(buffer1,true);
   ArraySetAsSeries(buffer2,true);
   ArraySetAsSeries(buffer3,true);
   ArraySetAsSeries(buffer4,true);
   ArraySetAsSeries(buffer5,true);
   ArraySetAsSeries(buffer6,true);
   ArraySetAsSeries(buffer7,true);
   CopyBuffer(handle_for_ccs,0,0,10,buffer0);
   CopyBuffer(handle_for_ccs,1,0,10,buffer1);
   CopyBuffer(handle_for_ccs,2,0,10,buffer2);
   CopyBuffer(handle_for_ccs,3,0,10,buffer3);
   CopyBuffer(handle_for_ccs,4,0,10,buffer4);
   CopyBuffer(handle_for_ccs,5,0,10,buffer5);
   CopyBuffer(handle_for_ccs,6,0,10,buffer6);
   CopyBuffer(handle_for_ccs,7,0,10,buffer7);   
   
   double value_bar0[8];     //put all the value to array for sorting 
   value_bar0[0] = NormalizeDouble(buffer0[0],4);
   value_bar0[1] = NormalizeDouble(buffer1[0],4);
   value_bar0[2] = NormalizeDouble(buffer2[0],4);
   value_bar0[3] = NormalizeDouble(buffer3[0],4);
   value_bar0[4] = NormalizeDouble(buffer4[0],4);
   value_bar0[5] = NormalizeDouble(buffer5[0],4);
   value_bar0[6] = NormalizeDouble(buffer6[0],4); 
   value_bar0[7] = NormalizeDouble(buffer7[0],4); 
Comment(buffer0[0] +"\n"+ buffer1[0]+"\n"+ buffer2[0]+"\n"+ buffer3[0]+"\n"+ buffer4[0]+"\n"+ buffer5[0]+"\n"+ buffer6[0]+"\n"+ buffer7[0]);
Comment("Max/Min: "+ currency[ArrayMaximum(value_bar0)]+ currency[ArrayMinimum(value_bar0)]+"\n"+ value_bar0[0] +"\n"+ value_bar0[1]+"\n"+ value_bar0[2]+"\n"+ value_bar0[3]+"\n"+ value_bar0[4]+"\n"+ value_bar0[5]+"\n"+ value_bar0[6]+"\n"+ value_bar0[7]);

}
      

void comment_this_text(string text){   
   Print(text);
   Comment(text);   
}






