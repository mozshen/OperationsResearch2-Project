* Phase 2 of OR2 Prject
* Author: Mohsen Hosseini

* first we define the indices
sets
t years /0, 1, 2, 3/
s skills /Unskilled, Semi-skilled, Skilled/
e experience level /New, Experienced/
;


Parameter demand_table(t,s)
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=demand_table rng=D!B2:E6 rdim=1 cdim=1
$gdxin Pahse2_Data_OR2.gdx
$load demand_table
;

Parameter churn_table(e,s)
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=churn_table rng=W!B2:E4 rdim=1 cdim=1
$gdxin Pahse2_Data_OR2.gdx
$load churn_table
;


Parameter hiring_limit(s)
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=hiring_limit rng=R!C2:E3 cdim=1
$gdxin Pahse2_Data_OR2.gdx
$load hiring_limit
;

Parameter training_limit
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=training_limit rng=T!E5
$gdxin Pahse2_Data_OR2.gdx
$load training_limit
;

Parameter training_theshold
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=training_theshold rng=T!E6
$gdxin Pahse2_Data_OR2.gdx
$load training_theshold
;

Parameter over_hiring_cost(s)
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=over_hiring_cost rng=O!C2:E3 cdim=1
$gdxin Pahse2_Data_OR2.gdx
$load over_hiring_cost
;

Parameter overhiring_limit
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=overhiring_limit rng=O!C6
$gdxin Pahse2_Data_OR2.gdx
$load overhiring_limit
;

Parameter parttime_cost(s)
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=parttime_cost rng=S!C2:E3 cdim=1
$gdxin Pahse2_Data_OR2.gdx
$load parttime_cost
;

Parameter parttime_limit
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=parttime_limit rng=O!C6
$gdxin Pahse2_Data_OR2.gdx
$load parttime_limit
;

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


