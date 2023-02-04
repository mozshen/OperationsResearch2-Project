* Phase 2 of OR2 Prject
* Author: Mohsen Hosseini

* first we define the indices
sets
t years /0, 1, 2, 3/
s skills /Unskilled, Semi-skilled, Skilled/;

Parameter demand_table(t,s);
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=demand_table rng=D!B2:E6 rdim=1 cdim=1
$gdxin Pahse2_Data_OR2.gdx
$load demand_table

variables
x(t, s) it is equal to parameters for testing
z sum of x values;

Equations
equalconts(t, s) just make those two equal
test test_variables;



test.. z=e=sum((t, s), x(t, s));
equalconts(t, s).. x(t, s)=e= demand_table(t, s)


model testmodel /all/;
solve testmodel using lp minimizing z;
display x.l;


