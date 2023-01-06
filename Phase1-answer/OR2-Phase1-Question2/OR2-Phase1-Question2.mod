/*********************************************
 * OPL 22.1.0.0 Model
 * Author: Mohsen
 * Creation Date: Jan 6, 2023 at 9:28:16 PM
 *********************************************/

 /* indices*/
 
 {int} veg= ...;
 {int} oil= ...;
 {int} month= ...;
 
 
 /* parameters*/
 
 float vegprice[veg][month]= ...;
 float oilprice[oil][month]= ...;
 
 float charveg[veg]= ...;
 float charoil[oil]= ...;
 
 float prodprice= ...;
 float startinventory= ...;
 
 /*decision variebles*/
 
 dvar float+ BX[veg][month];
 dvar float+ RX[veg][month];
 dvar float+ BY[oil][month];
 dvar float+ RY[oil][month];
 
 dvar float+ IX[veg][month];
 dvar float+ IY[oil][month];
 
 /*opjective*/
 
 maximize prodprice* sum(i in veg, t in month) RX[i][t]+
			prodprice* sum(i in oil, t in month) RY[i][t]-
			sum(i in veg, t in month) vegprice[i][t]* BX[i][t]-
			sum(i in oil, t in month) oilprice[i][t]* BY[i][t]-
			5* sum(i in veg, t in month) IX[i][t]- 
			5* sum(i in oil, t in month) IY[i][t];
			
/*constraints*/

subject to {
  
  /*capacity limit*/
  forall (t in month)
    sum(i in veg) RX[i][t]<= 200;
 
  forall (t in month)
    sum(i in oil) RY[i][t]<= 200;
  
  /*charachtristic limit*/
  forall (t in month)
  	sum(i in veg) charveg[i]* RX[i][t]+ sum(i in oil) charoil[i]* RY[i][t]-
  	6* (sum(i in veg) RX[i][t]+ sum(i in oil) RY[i][t])<= 0;
  	
  forall (t in month)
  	sum(i in veg) charveg[i]* RX[i][t]+ sum(i in oil) charoil[i]* RY[i][t]-
  	3* (sum(i in veg) RX[i][t]+ sum(i in oil) RY[i][t])>= 0;
  
  /*inventory*/
  	
  forall (i in veg)
	IX[i][1]== startinventory+ BX[i][1]- RX[i][1];    
  
  forall (i in oil)
	IY[i][1]== startinventory+ BY[i][1]- RY[i][1];    
  
  
  forall (t in month, i in veg)
    if (t> 1)
		IX[i][t]== IX[i][t-1]+ BX[i][t]- RX[i][t];    
    
  forall (t in month, i in oil)
    if (t> 1)
		IY[i][t]== IY[i][t-1]+ BY[i][t]- RY[i][t];    
    
  forall (t in month, i in veg)
  	IX[i][t]<=1000;
  	
  forall (t in month, i in oil)
  	IY[i][t]<=1000;
  
  forall (t in month, i in veg)
  	RX[i][t]<=IX[i][t];
  
  forall (t in month, i in oil)
  	RY[i][t]<=IY[i][t];
  
  }
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 