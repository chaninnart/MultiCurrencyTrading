#include <Trade\Trade.mqh>
CTrade trade;
string currency [8] = {"AUD","CAD","CHF","EUR","GBP","USD","JPY","NZD"};
string pairs[28] = {"AUDCAD#","AUDCHF#","AUDJPY#","AUDNZD#","AUDUSD#","CADCHF#","CADJPY#","CHFJPY#","EURAUD#","EURCAD#","EURCHF#","EURGBP#","EURJPY#","EURNZD#","EURUSD#","GBPAUD#","GBPCAD#","GBPCHF#","GBPJPY#","GBPNZD#","GBPUSD#","NZDCAD#","NZDCHF#","NZDJPY#","NZDUSD#","USDCAD#","USDCHF#","USDJPY#"};
string pairs2[28] = {"AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY","EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF","GBPJPY","GBPNZD","GBPUSD","NZDCAD","NZDCHF","NZDJPY","NZDUSD","USDCAD","USDCHF","USDJPY"};

void OnTimer(){OnTick();}
void OnInit(){
   init_handle();
   EventSetTimer(3);
}
//Initialization Process ***************************************************************************
int handle_hull[28];    //hull global variable handler
int handle_rsi[28];
int handle_ccs;

void init_handle(){
      for(int i=0; i< ArraySize(pairs); i++){         //handle hull
         handle_hull[i] = iCustom(pairs[i],PERIOD_M15,"HullAverage2"); 
         handle_rsi [i] = iRSI(pairs[i],PERIOD_M15,14,PRICE_CLOSE);
      } 
      handle_ccs = iCustom(NULL,PERIOD_H4,"FlukeMultiCurrencyIndex"); 
      
}
//-----------------------------------------------------------------------------


void OnTick(){
   getAllParameters();
   printInfo();      
}

void getAllParameters(){
      for(int i=0; i< ArraySize(pairs); i++){
            getMarketSummary_report(i);            
            getHull_report(i);
            getRSI_report(i);
      }              
      getCCS_report();
          
}

double report_rsi [28];
void getRSI_report(int i){
   double buffer[];
   ArraySetAsSeries(buffer,true);
   CopyBuffer(handle_rsi[i],0,0,5,buffer);   
   report_rsi[i] = buffer[0] ; 
}



double report_ccs_h4 [8];
string bestpair;
bool invert_pair;
void getCCS_report(){
   double buffer0 [],buffer1[],buffer2[],buffer3[],buffer4[],buffer5[],buffer6[],buffer7[];

   ArraySetAsSeries(buffer0,true);ArraySetAsSeries(buffer1,true);ArraySetAsSeries(buffer2,true);ArraySetAsSeries(buffer3,true);
   ArraySetAsSeries(buffer4,true);ArraySetAsSeries(buffer5,true);ArraySetAsSeries(buffer6,true);ArraySetAsSeries(buffer7,true);
   CopyBuffer(handle_ccs,0,0,10,buffer0);
   CopyBuffer(handle_ccs,1,0,10,buffer1);
   CopyBuffer(handle_ccs,2,0,10,buffer2);
   CopyBuffer(handle_ccs,3,0,10,buffer3);
   CopyBuffer(handle_ccs,4,0,10,buffer4);
   CopyBuffer(handle_ccs,5,0,10,buffer5);
   CopyBuffer(handle_ccs,6,0,10,buffer6);
   CopyBuffer(handle_ccs,7,0,10,buffer7);      
 
   report_ccs_h4[0] = buffer0[0];
   report_ccs_h4[1] = buffer1[0];
   report_ccs_h4[2] = buffer2[0];
   report_ccs_h4[3] = buffer3[0];
   report_ccs_h4[4] = buffer4[0];
   report_ccs_h4[5] = buffer5[0];
   report_ccs_h4[6] = buffer6[0]; 
   report_ccs_h4[7] = buffer7[0]; 

   bestpair = currency[ArrayMaximum(report_ccs_h4)] +currency[ArrayMinimum(report_ccs_h4)] ;
   
   bool found_pair = false; invert_pair = false;
      for(int i=0; i< ArraySize(pairs2); i++){
         if (bestpair == pairs2[i]){found_pair = true;}
      } 
      if (found_pair != true){bestpair = currency[ArrayMinimum(report_ccs_h4)]+ currency[ArrayMaximum(report_ccs_h4)];invert_pair=true;}
   bestpair = bestpair + "#";   
//Comment("Max/Min: "+ currency[ArrayMaximum(report_ccs_h4)]+ currency[ArrayMinimum(report_ccs_h4)]+"\n"+ report_ccs_h4[0] +"\n"+ report_ccs_h4[1]+"\n"+ report_ccs_h4[2]+"\n"+ report_ccs_h4[3]+"\n"+ report_ccs_h4[4]+"\n"+ report_ccs_h4[5]+"\n"+ report_ccs_h4[6]+"\n"+ report_ccs_h4[7]);
}

//HULL ***************************************************************************
string report_hull_m15 [28];
void getHull_report(int i){     
   double buffer1[];
   ArraySetAsSeries(buffer1,true);
   CopyBuffer(handle_hull[i],1,0,5,buffer1);   
   report_hull_m15[i] = "-"; 
   if (buffer1[1] == 1.0 && buffer1[2] == 2.0){report_hull_m15[i] = "b";} //1.0 = green / 2.0 = red
   if (buffer1[1] == 2.0 && buffer1[2] == 1.0){report_hull_m15[i] = "s";}
};
//-----------------------------------------------------------





//Show Output On Screen------------------------------------------------------------------------------------------
string text[30]; //Array of String store custom texts on screen
void printInfo()
{ 
   for (int i = 0; i < ArraySize(pairs); i++) {    
      text[i] = "";
         if (i<10) {text[i] = "0"+text [i];}    //arrange the text 00-09
      text[i] = text[i] + i + ". " +  pairs[i]+ " : ";
      text[i] = text[i] + "   *   HULL(15M) = ";
      text[i] = text[i] + report_hull_m15 [i];
      text[i] = text[i] + "   *    RSI(15M) = ";
      text[i] = text[i] + DoubleToString(report_rsi [i],1);
         
   }
   
   text[28] = "The Strongest/Weakest (4Hrs) = "+ bestpair +" (Invert Pair: " + invert_pair + ")";
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




