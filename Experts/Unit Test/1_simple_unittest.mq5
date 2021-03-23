#include <Trade\Trade.mqh>
CTrade trade;
string currency[7] = {"AUDUSD","USDCAD","USDCHF","EURUSD","GBPUSD","USDJPY","NZDUSD"};
string pairs[28] = {"AUDCAD#","AUDCHF#","AUDJPY#","AUDNZD#","AUDUSD#","CADCHF#","CADJPY#","CHFJPY#","EURAUD#","EURCAD#","EURCHF#","EURGBP#","EURJPY#","EURNZD#","EURUSD#","GBPAUD#","GBPCAD#","GBPCHF#","GBPJPY#","GBPNZD#","GBPUSD#","NZDCAD#","NZDCHF#","NZDJPY#","NZDUSD#","USDCAD#","USDCHF#","USDJPY#"};



void OnInit(){
   EventSetTimer(3);
}



void OnTimer(){OnTick();}


void OnTick(){
   printInfo();      
}


//Show Output On Screen------------------------------------------------------------------------------------------
string text[30]; //Array of String store custom texts on screen
void printInfo()
{ 
   for (int i = 0; i < ArraySize(pairs); i++) {    
      text[i] = "";
         if (i<10) {text[i] = "0"+text [i];}    //arrange the text 00-09
      text[i] = text[i] + i + ". " +  pairs[i]+ " : ";
         
   }
   
   text[28] = "The Strongest/Weakest (4Hrs) = ";
   text[29] = "-------Fluke--------";

   int i=0, k=20;
   while (i<30)
   {
      string object_name = DoubleToString(i, 0);
      ObjectCreate(0,object_name, OBJ_LABEL,0,0,0);
      ObjectSetString(0,object_name,OBJPROP_FONT,"Arial");
      ObjectGetInteger(0,object_name,OBJPROP_FONTSIZE,8);
      ObjectSetInteger(0,object_name,OBJPROP_COLOR,clrOrange);
       
      ObjectSetInteger(0,object_name,OBJPROP_XDISTANCE,5);
      ObjectSetInteger(0,object_name,OBJPROP_YDISTANCE,k);       

      ObjectSetString(0,object_name,OBJPROP_TEXT,text[i]);
      i++;
      k=k+16;
   } 
}
//-----------------------------------------------------------------------------




