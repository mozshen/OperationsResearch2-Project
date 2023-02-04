* Phase 2 of OR2 Prject
* Author: Mohsen Hosseini

* first we define the indices
sets
t years /0, 1, 2, 3/
d(t) years that the workforce is not given /1, 2, 3/
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

Workforce_constraint(t, s) limit for workforce for skill s at year t (1.4.1)
Workforce_given(t, s) limit for given workforce for skill s at year 0 (1.4.1)

State_variable_unskilled(t, s) state of workforce for skill s at year t (1.4.2)
State_variable_semiskilled(t, s) state of workforce for skill s at year t (1.4.2)
State_variable_skilled(t, s) state of workforce for skill s at year t (1.4.2)

Hiring_constraint(t, s) limit for hiring for skill s at year t (1.4.3)
layoff_constraint(t, s) limit for layoff for skill s at year t (1.4.4)
training_constraint(t, s, s) limit for training between skills at year t (1.4.5)
demote_constraint(t, s, s) limit for demote between skills at year t (1.4.6)

layoff objective function of the first part
Cost objective function of the second part
;

* workforce
* for years 1 to 3 we should have the requested workforce
Workforce_constraint(t, s) .. W(t, s) =g= demand_table(t, s)$(d(t));

* for year 0 the workforce is given so we use the equal
Workforce_given(t, s) .. W(t, s) =e= demand_table(t, s)$(not d(t));


* state variebles
* maybe we need to define these for t>0
*unskilled workers
State_variable_unskilled(t, 'Unskilled').. W(t, 'Unskilled')=e=
    W(t-1, 'Unskilled')+ [H(t-1, 'Unskilled')+ O(t-1, 'Unskilled')]
    -[L(t-1, 'Unskilled')+ churn_table('New', 'Unskilled')* (H(t-1, 'Unskilled')+ O(t-1, 'Unskilled'))+ churn_table('Experienced', 'Unskilled')* (W(t-1, 'Unskilled')- H(t-1, 'Unskilled')- L(t-1, 'Unskilled')- O(t-1, 'Unskilled'))]
    +[0.5*Demote(t-1, 'Semi-skilled', 'Unskilled')+ 0.5*Demote(t-1, 'Skilled', 'Unskilled')- Train(t-1, 'Unskilled', 'Semi-skilled')]
;

* semiskilled workers
State_variable_semiskilled(t, 'Semi-skilled').. W(t, 'Semi-skilled')=e=
    W(t-1, 'Semi-skilled')+ [H(t-1, 'Semi-skilled')+ O(t-1, 'Semi-skilled')]
    -[L(t-1, 'Semi-skilled')+ churn_table('New', 'Unskilled')* (H(t-1, 'Semi-skilled')+ O(t-1, 'Semi-skilled'))+ churn_table('Experienced', 'Semi-skilled')* (W(t-1, 'Semi-skilled')- H(t-1, 'Semi-skilled')- L(t-1, 'Semi-skilled')- O(t-1, 'Semi-skilled'))]
    +[0.5*Demote(t-1, 'Skilled', 'Semi-skilled')- Demote(t-1, 'Semi-skilled', 'Unskilled')+ Train(t-1, 'Unskilled', 'Semi-skilled')- Train(t-1, 'Semi-skilled', 'Skilled')]
    
;

* skilled workers
State_variable_skilled(t, 'Skilled').. W(t, 'Skilled')=e=
    W(t-1, 'Skilled')+ [H(t-1, 'Skilled')+ O(t-1, 'Skilled')]
    -[L(t-1, 'Skilled')+ churn_table('New', 'Unskilled')* (H(t-1, 'Skilled')+ O(t-1, 'Skilled'))+ churn_table('Experienced', 'Skilled')* (W(t-1, 'Skilled')- H(t-1, 'Skilled')- L(t-1, 'Skilled')- O(t-1, 'Skilled'))]
    +[0.5*Demote(t-1, 'Skilled', 'Semi-skilled')- Demote(t-1, 'Skilled', 'Unskilled')+ Train(t-1, 'Semi-skilled', 'Skilled')]
    
;


* layoff .. Z_first=e= 10;

model testmodel /all/;
solve testmodel using lp minimizing Z_first;


