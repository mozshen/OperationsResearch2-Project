* Phase 2 of OR2 Prject
* Author: Mohsen Hosseini

* first we define the indices
sets
t years /0, 1, 2, 3/
d(t) years that the workforce is not given /1, 2, 3/
g(t) first year /0/

s skills /Unskilled, Semi-skilled, Skilled/
e experience level /New, Experienced/
param indice for the fixed values /fixed/

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

Parameter training_limit(param)
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=training_limit rng=T!D4 cdim=1
$gdxin Pahse2_Data_OR2.gdx
$load training_limit
;

Parameter training_theshold(param)
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=training_theshold rng=T!D7 cdim=1
$gdxin Pahse2_Data_OR2.gdx
$load training_theshold
;

Parameter layoff_cost(s)
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=layoff_cost rng=L!C2:E3 cdim=1
$gdxin Pahse2_Data_OR2.gdx
$load layoff_cost
;

Parameter over_hiring_cost(s)
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=over_hiring_cost rng=O!C2:E3 cdim=1
$gdxin Pahse2_Data_OR2.gdx
$load over_hiring_cost
;

Parameter overhiring_limit(param)
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=overhiring_limit rng=O!B5 cdim=1
$gdxin Pahse2_Data_OR2.gdx
$load overhiring_limit
;

Parameter parttime_cost(s)
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=parttime_cost rng=S!C2:E3 cdim=1
$gdxin Pahse2_Data_OR2.gdx
$load parttime_cost
;

Parameter parttime_limit(param)
$call gdxxrw.exe Pahse2_Data_OR2.xlsx par=parttime_limit rng=S!B5 cdim=1
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

trainincost cost for training
parttimecost cost for assigning workers to parttime work
layoffcost cost for laying off
overhiringcost cost hire more than limit
Z_second total cost
;

integer variable H;
integer variable P;
integer variable L;
integer variable O;

integer variable Train;
integer variable Demote;

integer variable W;

Positive Variable trainincost;
Positive Variable parttimecost;
Positive Variable layoffcost;
Positive Variable overhiringcost;

Equations

Workforce_constraint(t, s) limit for workforce for skill s at year t (1.4.1)
Workforce_given(t, s) limit for given workforce for skill s at year 0 (1.4.1)

State_variable_unskilled(t, s) state of workforce for skill s at year t (1.4.2)
State_variable_semiskilled(t, s) state of workforce for skill s at year t (1.4.2)
State_variable_skilled(t, s) state of workforce for skill s at year t (1.4.2)

Hiring_constraint_normal(t, s) limit for hiring for skill s at year t (1.4.3)
Hiring_constraint_over(t) limit for pver hiring at year t (1.4.3)
Hiring_constraint_part(t) limit for part time hiring at year t (1.4.3)

layoff_constraint(t, s) limit for layoff for skill s at year t (1.4.4)

training_constraint_unskilled_limit(t, s, s) training limit for training from unslikked to semi-skilled at year t (1.4.5)
training_constraint_unskilled_workforce(t, s, s) workforce limit for training from unslikked to semi-skilled at year t (1.4.5)

training_constraint_semiskilled_limit(t, s, s) training limit for training from semiskilled to skilled at year t (1.4.5)
training_constraint_semiskilled_workforce(t, s, s) workforce limit for training from semiskilled to skilled at year t (1.4.5)

demote_constraint_semiskilled(t, s, s) limit for demote from semiskikk at year t (1.4.6)
demote_constraint_skilled(t, s, s) limit for demote from skilled at year t (1.4.6)

training_costs cost of training
parttime_costs cost of parttime
layoff_costs cost of layoff
overhire_costs cost of overhire

layoff objective function of the first part
Cost objective function of the second part
;

* workforce
* for years 1 to 3 we should have the requested workforce
Workforce_constraint(t, s) .. W(t, s)- 0.5* P(t, s) =g= demand_table(t, s)$(d(t));

* for year 0 the workforce is given so we use the equal
Workforce_given(t, s) .. W('0', s) =e= demand_table('0', s);


* state variebles
* we need to define these for t>0
*unskilled workers
State_variable_unskilled(t, 'Unskilled')$(d(t)).. W(t, 'Unskilled')=e=
    (
    W(t-1, 'Unskilled')+ [H(t-1, 'Unskilled')+ O(t-1, 'Unskilled')]
    -[L(t-1, 'Unskilled')+ 0.01* churn_table('New', 'Unskilled')* (H(t-1, 'Unskilled')+ O(t-1, 'Unskilled'))+ 0.01* churn_table('Experienced', 'Unskilled')* (W(t-1, 'Unskilled'))]
    +[0.5*Demote(t-1, 'Semi-skilled', 'Unskilled')+ 0.5*Demote(t-1, 'Skilled', 'Unskilled')- Train(t-1, 'Unskilled', 'Semi-skilled')]
    )
;

* semiskilled workers
State_variable_semiskilled(t, 'Semi-skilled')$(d(t)).. W(t, 'Semi-skilled')=e=
    (
    W(t-1, 'Semi-skilled')+ [H(t-1, 'Semi-skilled')+ O(t-1, 'Semi-skilled')]
    -[L(t-1, 'Semi-skilled')+ 0.01* churn_table('New', 'Semi-skilled')* (H(t-1, 'Semi-skilled')+ O(t-1, 'Semi-skilled'))+ 0.01* churn_table('Experienced', 'Semi-skilled')* (W(t-1, 'Semi-skilled'))]
    +[0.5*Demote(t-1, 'Skilled', 'Semi-skilled')- Demote(t-1, 'Semi-skilled', 'Unskilled')+ Train(t-1, 'Unskilled', 'Semi-skilled')- Train(t-1, 'Semi-skilled', 'Skilled')]
    )
;

* skilled workers
State_variable_skilled(t, 'Skilled').. W(t, 'Skilled')$(d(t))=e=
    (
    W(t-1, 'Skilled')+ [H(t-1, 'Skilled')+ O(t-1, 'Skilled')]
    -[L(t-1, 'Skilled')+ 0.01* churn_table('New', 'Skilled')* (H(t-1, 'Skilled')+ O(t-1, 'Skilled'))+ 0.01* churn_table('Experienced', 'Skilled')* (W(t-1, 'Skilled'))]
    +[-Demote(t-1, 'Skilled', 'Semi-skilled')- Demote(t-1, 'Skilled', 'Unskilled')+ Train(t-1, 'Semi-skilled', 'Skilled')]
    )
;

* hiring constraint
* normal
Hiring_constraint_normal(t, s).. H(t, s)=l= hiring_limit(s);

* over
Hiring_constraint_over(t).. sum(s, O(t, s))=l= overhiring_limit('fixed');

* part
Hiring_constraint_part(t).. sum(s, P(t, s))=l= parttime_limit('fixed');

* lay off constraint
layoff_constraint(t, s).. L(t, s)=l= W(t, s);



* Training constraints
training_constraint_unskilled_limit(t, s, s).. Train(t, 'Unskilled', 'Semi-skilled')=l= training_limit('fixed');
training_constraint_unskilled_workforce(t, s, s).. Train(t, 'Unskilled', 'Semi-skilled')=l= W(t, 'Unskilled');

training_constraint_semiskilled_limit(t, s, s).. Train(t, 'Semi-skilled', 'Skilled')=l= training_theshold('fixed')* W(t, 'Skilled');
training_constraint_semiskilled_workforce(t, s, s).. Train(t, 'Semi-skilled', 'Skilled')=l= W(t, 'Semi-skilled')+ Train(t, 'Unskilled', 'Semi-skilled');

* demotion constraints
demote_constraint_semiskilled(t, s, s).. Demote(t, 'Semi-skilled', 'Unskilled')=l= W(t, 'Semi-skilled');
demote_constraint_skilled(t, s, s).. Demote(t, 'Skilled', 'Semi-skilled')+ Demote(t, 'Skilled', 'Unskilled')=l= W(t, 'Skilled');

* defining costs
* training
training_costs.. trainincost=e= sum(t, Train(t, 'Unskilled', 'Semi-skilled'));

*parttime
parttime_costs.. parttimecost=e= sum((t, s), parttime_cost(s)* P(t, s));

* layoff
layoff_costs.. layoffcost=e= sum((t, s), layoff_cost(s)* L(t, s));

* overhire
overhire_costs.. overhiringcost=e= sum(t, Train(t, 'Unskilled', 'Semi-skilled'));

* lay off objective for the first part
layoff.. Z_first=e= sum((t, s), L(t, s));

* total cost
cost.. z_second=e= trainincost+ parttimecost+ layoffcost+ overhiringcost

model testmodel /
    
    Workforce_given,
    Workforce_constraint,

    State_variable_unskilled,
    State_variable_semiskilled,
    State_variable_skilled,
    
    demote_constraint_semiskilled,
    demote_constraint_skilled,
    training_constraint_semiskilled_limit,
    training_constraint_semiskilled_workforce,
    training_constraint_unskilled_limit,
    training_constraint_unskilled_workforce,
    
    Hiring_constraint_normal,
    Hiring_constraint_part,
    Hiring_constraint_over,
    layoff_constraint,
       
    layoff
    
/
;

solve testmodel using mip minimizing Z_first;

display demand_table;
display churn_table;

display hiring_limit;

display training_limit;
display training_theshold;

display overhiring_limit;
display parttime_limit;

display over_hiring_cost;
display parttime_cost;


W.l(t, s)$ (W.l(t, s) eq 0)= eps;
display W.l;

H.l(t, s)$ (H.l(t, s) eq 0)= eps;
display H.l;

O.l(t, s)$ (O.l(t, s) eq 0)= eps;
display O.l;

L.l(t, s)$ (L.l(t, s) eq 0)= eps
display L.l;

Train.l(t, s, s)$ (Train.l(t, s, s) eq 0)= eps;
display Train.l;

Demote.l(t, s, s)$ (Demote.l(t, s, s) eq 0)= eps;
display Demote.l;

P.l(t, s)$ (P.l(t, s) eq 0)= eps;
display P.l;

trainincost$ (trainincost eq 0)= eps;
display trainincost

parttimecost$ (parttimecost eq 0)= eps;
display parttimecost

layoffcost$ (layoffcost eq 0)= eps;
display layoffcost

overhiringcost$ (overhiringcost eq 0)= eps;
display overhiringcost

execute_unload "Pahse2_Data_OR2.gdx" W.l, H.l, p.l, L.l, O.l, Train.l, Demote.l;
execute 'gdxxrw.exe Pahse2_Data_OR2.gdx var=W.l rng=Results!B2';
execute 'gdxxrw.exe Pahse2_Data_OR2.gdx var=H.l rng=Results!B8';
execute 'gdxxrw.exe Pahse2_Data_OR2.gdx var=p.l rng=Results!B14';
execute 'gdxxrw.exe Pahse2_Data_OR2.gdx var=L.l rng=Results!B20';
execute 'gdxxrw.exe Pahse2_Data_OR2.gdx var=O.l rng=Results!B26';
execute 'gdxxrw.exe Pahse2_Data_OR2.gdx var=Train.l rng=Results!B32';
execute 'gdxxrw.exe Pahse2_Data_OR2.gdx var=Demote.l rng=Results!B50';




