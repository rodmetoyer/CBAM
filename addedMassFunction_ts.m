% addedMassFunction_ts.m
% test script for the added mass function

clearvars; close all; clc;
addpath('src');

% Set up the struct for the argument
cv.wing.rootChord = 1;
cv.wing.tipChord = 1; % I did this instead of AR because AR should be b^2/S, but I thought you guys might be using AR = b/c_root
cv.wing.span = 10;      % tip to tip
cv.wing.thckns = 0.12;  % as percent chord
cv.wing.LEsweep = 0;   % Note that this is not the way that sweep is typically defined in the aerospace industry
cv.wing.dihedral = 0;   % Need to think about how this is defined. Typically it is mean chamber at c/4
cv.wing.incidence = 0;
cv.wing.secshape = 'ellipse';
cv.wing.nsects = 20;
cv.hstab.rootChord = 0.5;
cv.hstab.tipChord = 0.5;
cv.hstab.span = 4;
cv.hstab.thckns = 0.12;  % as percent chord
cv.hstab.LEsweep = atan2d((cv.hstab.rootChord-cv.hstab.tipChord),cv.hstab.span);
cv.hstab.incidence = 0;
cv.hstab.dihedral = 0;
cv.hstab.secshape = 'ellipse';
cv.hstab.nsects = 20; % number of amsections for the horizontal stabilizer
cv.hstab.rootLE = [4.35;0;0];
cv.vstab.rootChord = 0.52;
cv.vstab.tipChord = 0.52;
cv.vstab.span = 2.4375;
cv.vstab.LEsweep = 0;
cv.vstab.incidence = 0;
cv.vstab.secshape = 'ellipse';
cv.vstab.nsects = 10; % number of amsections for the vertical stabilizer
cv.vstab.rootLE = [4.35;0;0];
cv.vstab.thckns = 0.12;  % as percent chord
cv.fuse.diameter = 0.4;
cv.fuse.length = 9.0;
cv.fuse.secshape = 'ellipse';
cv.fuse.shape = 'spheroid';
cv.fuse.nsects = 10; % number of amsections for the fuselage
cv.fuse.RNose_LE = [-4;0;0];

% Let's compare to the fullSizeKiteComp just to make sure I reimplemented
% correctly
runname = 'fullSizeKiteComp';
savefigs = false;
MA = addedMassKiteVehicle(cv,runname,savefigs);
MA = round(MA);
oldMA = [130           0           0           0           9           0;...
           0        1221           0        -625           0        2527;...
           0           0        9316           0       -7557           0;...
           0        -625           0       67352           0       -2879;...
           9           0       -7557           0       20442           0;...
           0        2527           0       -2879           0       14123];
diffMA = MA - oldMA;
diffFrac = diffMA./oldMA;
diffFrac(isnan(diffFrac)) = 0;
% Looks good, now we can explore a litte.

runname = 'justMoreSects';
savefigs = true;
cv.wing.nsects = 40;
cv.fuse.nsects = 40;
cv.hstab.nsects = 20;
cv.vstab.nsects = 20;
MA = addedMassKiteVehicle(cv,runname,savefigs);
MA = round(MA);
diffMA = MA - oldMA
diffFrac = diffMA./oldMA;
k = find(isnan(diffFrac));
diffFrac(k) = MA(k)/1000

% Let's look at crazy dihedral and sweep, plus some incidence
runname = 'crazyWing';
savefigs = true;
cv.wing.LEsweep = 20;
cv.wing.dihedral = 20;
cv.wing.incidence = 10;
cv.wing.nsects = 40;
cv.fuse.nsects = 40;
cv.hstab.nsects = 20;
cv.vstab.nsects = 20;
MA = addedMassKiteVehicle(cv,runname,savefigs);
MA = round(MA);
diffMA = MA - oldMA
diffFrac = diffMA./oldMA;
k = find(isnan(diffFrac));
diffFrac(k) = MA(k)/1000

% Let's look at wing incidence only
runname = 'wingIncidence';
savefigs = true;
cv.wing.LEsweep = 0;
cv.wing.dihedral = 0;
cv.wing.incidence = 30;
cv.wing.nsects = 40;
cv.fuse.nsects = 40;
cv.hstab.nsects = 20;
cv.vstab.nsects = 20;
MA = addedMassKiteVehicle(cv,runname,savefigs);
MA = round(MA);
diffMA = MA - oldMA
diffFrac = diffMA./oldMA;
k = find(isnan(diffFrac));
diffFrac(k) = MA(k)/1000

runname = 'crazyCrazy';
savefigs = true;
cv.wing.LEsweep = -20;
cv.wing.dihedral = 20;
cv.wing.incidence = 10;
cv.wing.rootChord = 2.0;
cv.wing.tipChord = 0.1;
cv.hstab.LEsweep = 15;
cv.hstab.dihedral = -10;
cv.hstab.incidence = -20;
cv.hstab.rootChord = 0.4;
cv.hstab.tipChord = 1.0;
cv.vstab.LEsweep = 30;
cv.vstab.incidence = 10;
cv.vstab.rootChord = 1.0;
cv.vstab.tipChord = 0.2;
cv.wing.nsects = 40;
cv.fuse.nsects = 40;
cv.hstab.nsects = 20;
cv.vstab.nsects = 20;
cv.fuse.diameter = 3.0;
cv.fuse.length = 7.0;
MA = addedMassKiteVehicle(cv,runname,savefigs);
MA = round(MA);
diffMA = MA - oldMA
diffFrac = diffMA./oldMA;
k = find(isnan(diffFrac));
diffFrac(k) = MA(k)/1000