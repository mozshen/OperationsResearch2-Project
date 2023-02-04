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
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=parttime_limit rng=S!C5
$gdxin Pahse2_Data_OR2.gdx
$load parttime_limit
;

variables
H(t, s) hiring for skill s at year t
P(t, s) parttime for skill s at year t
L(t, s) lay off for skill s at year t
O(t, s) over-hire for skill s at year t

Train(t, s, s) training from skill s1 to skill s2 at year t
Demote(t, s, s) demoting from skill s1 to skill s2 at year t

W(t ,s) workforce for skill s at year t

Z_first total lay offs at all years for all skills
Z_second total cost
;

Equations

Workforce_limit(t, s) limit for workforce for skill s at year t (1.4.1)
State_variables(t, s) state of workforce for skill s at year t (1.4.2)
Hiring_limit(t, s) limit for hiring for skill s at year t (1.4.3)
layoff_limit(t, s) limit for layoff for skill s at year t (1.4.4)
training_limit(t, s, s) limit for training between skills at year t (1.4.5)
demote_limit(t, s, s) limit for demote between skills at year t (1.4.6)





test.. z=e=sum((t, s), x(t, s));
equalconts(t, s).. x(t, s)=e= demand_table(t, s)


model testmodel /all/;
solve testmodel using lp minimizing z;
display x.l;


