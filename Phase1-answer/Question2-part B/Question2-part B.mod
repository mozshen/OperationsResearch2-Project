/*********************************************
 * OPL 22.1.0.0 Model
 * Author: Mohsen
 * Creation Date: Jan 7, 2023 at 12:45:05 PM
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
 float endinventory= ...;
 float inventoryunitcost= ...;
 
 float vegrefinelimit= ...;
 float oilrefinelimit= ...;
 
 float uniqueoillimit= ...;
 float minusage= ...;
 
 /*decision variebles*/
 
 dvar float+ BX[veg][month];
 dvar float+ RX[veg][month];
 
 dvar float+ BY[oil][month];
 dvar float+ RY[oil][month];
 
 dvar boolean UX[veg][month];
 dvar boolean UY[oil][month];
 
 dvar float+ IX[veg][month];
 dvar float+ IY[oil][month];
 
 /* objective variebles*/
 
 dvar float Revenue;
 dvar float MaterialCost;
 dvar float InventoryCost;
 
 dvar float Profit;
 
 /*opjective*/
 maximize Profit;
 
 /*constraints*/

subject to {
  
  /*capacity limit*/
  forall (t in month)
    sum(i in veg) RX[i][t]<= vegrefinelimit;
 
  forall (t in month)
    sum(i in oil) RY[i][t]<= oilrefinelimit;
  
  /*charachtristic limit*/
  
  /*upper limit*/
  forall (t in month)
  	sum(i in veg) charveg[i]* RX[i][t]+ sum(i in oil) charoil[i]* RY[i][t]-
  	6* (sum(i in veg) RX[i][t]+ sum(i in oil) RY[i][t])<= 0;
  
  /*lower limit*/
  forall (t in month)
  	sum(i in veg) charveg[i]* RX[i][t]+ sum(i in oil) charoil[i]* RY[i][t]-
  	3* (sum(i in veg) RX[i][t]+ sum(i in oil) RY[i][t])>= 0;
  
  /*inventory*/
  
  /*starinventory*/
  forall (i in veg)
	IX[i][1]== startinventory+ BX[i][1]- RX[i][1];    
  
  forall (i in oil)
	IY[i][1]== startinventory+ BY[i][1]- RY[i][1];    
  
  /*endinventory*/
  forall (i in veg)
	IX[i][6]== 500;    
  
  forall (i in oil)
	IY[i][6]== 500;    
  
  /*inventory relationshib with buying and refinement*/
  forall (t in month, i in veg)
    if (t> 1)
		IX[i][t]== IX[i][t-1]+ BX[i][t]- RX[i][t];    
    
  forall (t in month, i in oil)
    if (t> 1)
		IY[i][t]== IY[i][t-1]+ BY[i][t]- RY[i][t];    
   
  /*inventory limit*/  
  forall (t in month, i in veg)
  	IX[i][t]<=1000;
  	
  forall (t in month, i in oil)
  	IY[i][t]<=1000;
  
  /*refinement if we have inventory*/
  forall (t in month, i in veg)
  	RX[i][t]<=IX[i][t];
  
  forall (t in month, i in oil)
  	RY[i][t]<=IY[i][t];
  	
  	
  /*refinement if use*/
  forall (t in month, i in veg)
  	RX[i][t]<= vegrefinelimit* UX[i][t];
  
  forall (t in month, i in oil)
  	RY[i][t]<=oilrefinelimit* UY[i][t];
  	
  /*3 unique oils in each month*/
  forall (t in month)
  	sum(i in veg) UX[i][t]+ sum(i in oil) UY[i][t]<= uniqueoillimit;
  
  /*minimum usage in each month*/
  forall (t in month, i in veg)
  	RX[i][t]>= minusage* UX[i][t];
  
  forall (t in month, i in oil)
  	RY[i][t]>=minusage* UY[i][t];
  
  /*3oil, if 1, 3 of veg*/
  forall (t in month)
  	(UX[1][t]+ UX[2][t])- 1<= UY[3][t];
  
  /*final objective variebles*/
  Revenue== prodprice* sum(i in veg, t in month) RX[i][t]+
			prodprice* sum(i in oil, t in month) RY[i][t];

  MaterialCost== sum(i in veg, t in month) vegprice[i][t]* BX[i][t]+
			sum(i in oil, t in month) oilprice[i][t]* BY[i][t];

  InventoryCost== 5* sum(i in veg, t in month) IX[i][t]+
			5* sum(i in oil, t in month) IY[i][t];
  
  Profit== Revenue- MaterialCost- InventoryCost;
  
  }

 