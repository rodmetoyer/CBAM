% addedMass.m
% Does math for added mass and teaches karate and whatnot to kids or
% whatever.

clearvars; close all; clc;

% Make sure addedMassSpheroid works. 
% For a sphere (a=b) the added mass coefficients should be 1/2 of the mass
% of the displaced fluid. But this method doesn't work when a=b because the
% eccentricity is zero. So we need to look at when a->b.
rho = 1000;
r = 1;
massDisplacedFluid = 4/3*pi*rho*r^3;
for i=2:1:6
    diffab(i) = 2*10^-i;
    a = r+10^-i;
    b = r-10^-i;
    [Xud,Yvd,Nrd(i)] = addedMassSpheroid(a,b,rho);
    del(i) = 0.5*massDisplacedFluid + mean([Xud Yvd]);
end
% These figures show that as the difference between a and b decreases, the
% analytical method for a spheroid approaches half the mass of the
% displaced fluid. Spheroid method is the one described in
% Imlay1961complete
figure
plot(diffab,del,'*r');
set(gca, 'xdir','reverse');
set(gca,'xscale','log'); set(gca,'yscale','log');
title('Diff. mean translational added mass and 1/2 mass displaced fluid');
xlabel('Diff. a b (m)'); ylabel('Diff. added mass (kg)');
figure
plot(diffab,-Nrd,'*r');
set(gca,'xdir','reverse');
set(gca,'xscale','log'); set(gca,'yscale','log');
title('Rotation added mass');
xlabel('Diff. a b (m)'); ylabel('Added mass (kg-m)');
% The figures show that the difference between half the mass of a sphere of
% displaced fluid and the added mass coefficient approaches zero as a
% approaches b, and the rotational added mass also approached zero. So we
% good.

% Looks good, now let's verify an example from geisbert2007hydrodynamics
% pg. 39
rho = 1.9905; % slug/ft^3
a = 10.0; % ft
b = 1.0;
[Xud,Yvd,Nrd] = addedMassSpheroid(a,b,rho);
MA = zeros(6);
MA(1,1) = Xud; MA(2,2) = Yvd; MA(3,3) = Yvd;
MA(5,5) = Nrd; MA(6,6) = Nrd;

% Ok, now we can compare to strip theory
% Using strip theory on a cylinder MA(1,1) would be zero and MA(2,2)/(3,3)
% would be pi*rho*b^2*a
MA22_cyl = -pi*rho*b^2*2*a;
MA66_cyl = -pi*rho*b^2*2*a^3/3;
% For a spheroid we need to integrate the circles
dz = 0.1;
z = -a:dz:a;
rsqrd = b^2*(1-z.^2/a^2);
MA22_spheroid = 0;
MA66_spheroid = 0;
for i=1:1:length(rsqrd)
    MA22_spheroid = MA22_spheroid - pi*rho*rsqrd(i)*dz;
    MA66_spheroid = MA66_spheroid - z(i)*z(i)*pi*rho*rsqrd(i)*dz;
end
% Compare the methods
method = {'Analytical';'Strip Cyl';'Strip Sphrd'};
Yvd_value = [MA(2,2)/MA(2,2);MA22_cyl/MA(2,2);MA22_spheroid/MA(2,2)];
Nrd_value = [MA(6,6)/MA(6,6);MA66_cyl/MA(6,6);MA66_spheroid/MA(6,6)];
amTransTable = table(method,Yvd_value,Nrd_value)
format shortg
MA
%return
%% Ok, let's compute some added mass for our DOE-kite system
rho = 1029; % kg/m^3
% First the fuselage
af = 4.0; % m
b = 0.5; % m 
[Xud,Yvd,Nrd] = addedMassSpheroid(af,b,rho);
MA = zeros(6);
MA(1,1) = Xud; MA(2,2) = Yvd; MA(3,3) = Yvd;
MA(5,5) = Nrd; MA(6,6) = Nrd;
% now add the wing
aw = 5.0; % m
c = 0.05; % 10% thickness
b = 0.5;
% for the wing we need to rotate the axes, so Yvd is added to MA(1,1), etc.
flatplate = true; % make false to look at spheroid
ellipsoid = false;
if ~(flatplate || ellipsoid) % spheroid - both must be false
    [Xud,Yvd,Nrd] = addedMassSpheroid(aw,c,rho);
    MA(1,1) = MA(1,1) + Yvd; MA(2,2) = MA(2,2) + Xud; MA(3,3) = MA(3,3) + Yvd;
    MA(4,4) = MA(4,4) + Nrd; MA(5,5) = MA(5,5) + 0; MA(6,6) = MA(6,6) + Nrd;
elseif ~ellipsoid % flat plate
    Yvd = 0; Xud = 0; Zud = -pi*rho*b^2*2*aw;
    MA(1,1) = MA(1,1) + Yvd; MA(2,2) = MA(2,2) + Xud; MA(3,3) = MA(3,3) + Zud;
    MA(4,4) = MA(4,4) + -pi*rho*b^2*2*aw^3/3; MA(5,5) = MA(5,5) + 0.125*pi*rho*b^4;
    MA(6,6) = MA(6,6) + 0;
else % this is an ellipsoid
    Yvd = 0; Xud = -pi*rho*c^2*2*aw; Zud = -pi*rho*b^2*2*aw;
    MA(1,1) = MA(1,1) + Xud; MA(2,2) = MA(2,2) + Yvd; MA(3,3) = MA(3,3) + Zud;
    MA(4,4) = MA(4,4) + -pi*rho*b^2*2*aw^3/3;
    MA(5,5) = MA(5,5) + 0.125*pi*rho*(b^2-c^2)^2;
    MA(6,6) = MA(6,6) + -pi*rho*c^2*2*aw^3/3;
end
MA