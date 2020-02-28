function [Xud,Yvd,Nrd] = addedMassSpheroid(a,b,rho)
% computes added mass of a spheroid using method developed by Lamb and
% described by Imlay (imlay1961complete)
m = 4/3*pi*rho*a*b^2;
esqrd = 1-(b/a)^2;
e = sqrt(esqrd);
alfa0 = 2*(1-esqrd)/e^3*(0.5*log((1+e)/(1-e))-e);
beta0 = 1/esqrd-(1-esqrd)/(2*e^3)*log((1+e)/(1-e));
k1 = alfa0/(2-alfa0);
k2 = beta0/(2-beta0);
kp = esqrd^2*(beta0-alfa0)/((2-esqrd)*(2*esqrd-(2-esqrd)*(beta0-alfa0)));
Xud = -k1*m;
Yvd = -k2*m;
Nrd = -kp*1/5*m*(a^2+b^2);