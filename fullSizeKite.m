% fullSizeKite.m
% This tool may be used to compute the added mass coefficients for the full
% sized kite.
clearvars; close all; clc;

addpath('src');

% set-up
fuselageLength_m = 9;
fuselageRadius_m = 0.2;
lngthToTail = 5.0; % length to tail from body frame origin
halfWingLength_m = 5;
wingChord_m = 1.0;
wingThickFrac = 0.12;
wingTipOffset_m = wingChord_m/2; % puts LE at x=0
halfHorStabLength_m = 2.0;
horStabChord_m = 0.5;
vStabLength_m = 2.4375;
vStabChord_m = 0.52;

nsects = 10; % number of amsections in each slender body
runname = 'almostAyazConfiguration3';
savefigs = true;

% make a vehicle object
v = amvehicle;


% add amsections
% addSection(location,orientation)
% Fuselage
sectWidth = lngthToTail/nsects;
halfEllipse = fuselageLength_m/2;
offset = lngthToTail - halfEllipse; % 
for i=1:1:nsects % add circles in the +x direction
    x = (i-1)*sectWidth + sectWidth/2;
    r = fuselageRadius_m*sqrt(1-(x-offset)^2/halfEllipse^2);
    v.addSection(amsection('ellipse',r,r,sectWidth),[x;0;0],[0;0;0]);
end
v.showme('r');
%pause

lngthToNose = fuselageLength_m - lngthToTail; % 4 meters in -x
sectWidth = lngthToNose/nsects;
%offset = fuselageLength_m/2-lngth;
for i=1:1:nsects % add circles in the -x direction
    x = -((i-1)*sectWidth + sectWidth/2);
    r = fuselageRadius_m*sqrt(1-(x-offset)^2/halfEllipse^2);
    v.addSection(amsection('ellipse',r,r,sectWidth),[x;0;0],[0;0;0]);
end
v.showme('b');

% Wings
sectWidth = halfWingLength_m/nsects;
airfoilThickness = wingThickFrac*wingChord_m;
for i=1:1:nsects % add circles in the +y direction
    y = (i-1)*sectWidth + sectWidth/2;
    if abs(y) < fuselageRadius_m % don't need internal amsections
        continue;
    end
    v.addSection(amsection('ellipse',wingChord_m/2,airfoilThickness/2,sectWidth),[wingTipOffset_m;y;0],[90*pi/180;0;0]);
end
v.showme('r');
for i=1:1:nsects % add circles in the -y direction
    y = (i-1)*sectWidth + sectWidth/2;
    if abs(y) < fuselageRadius_m % don't need internal amsections
        continue;
    end
    v.addSection(amsection('ellipse',wingChord_m/2,airfoilThickness/2,sectWidth),[wingTipOffset_m;-y;0],[90*pi/180;0;0]);
end
v.showme('b');

% Horizontal Stabilizer
sectWidth = halfHorStabLength_m/nsects;
airfoilThickness = 0.12*horStabChord_m;
for i=1:1:nsects % add circles in the +y direction
    y = (i-1)*sectWidth + sectWidth/2;
    if abs(y) < fuselageRadius_m % don't need internal amsections - todo make this the diameter at the point... or something. Make it better.
        continue;
    end
    v.addSection(amsection('ellipse',horStabChord_m/2,airfoilThickness/2,sectWidth),[4.35+horStabChord_m/2;y;0],[90*pi/180;0;0]);
end
v.showme('r');
for i=1:1:nsects % add circles in the -y direction
    y = (i-1)*sectWidth + sectWidth/2;
    if abs(y) < fuselageRadius_m % don't need internal amsections
        continue;
    end
    v.addSection(amsection('ellipse',horStabChord_m/2,airfoilThickness/2,sectWidth),[4.35+horStabChord_m/2;-y;0],[90*pi/180;0;0]);
end
v.showme('b');

% Vertical Stabilizer
sectWidth = vStabLength_m/nsects;
airfoilThickness = 0.12*vStabChord_m;
for i=1:1:nsects % add circles in the +y direction
    z = (i-1)*sectWidth + sectWidth/2;
    if abs(z) < fuselageRadius_m % don't need internal amsections
        continue;
    end
    v.addSection(amsection('ellipse',airfoilThickness/2,vStabChord_m/2,sectWidth),[4.35+vStabChord_m/2;0;z],[0;-90*pi/180;0]);
end
hfig1 = v.showme('k');
if savefigs
    if ~exist('output\figs','dir')
        mkdir('output\figs');
    end
    hfig1.CurrentAxes.Color = 'none';
    hfig1.CurrentAxes.Title.String = ['Sections for ' runname ' in the body frame.'];
    hfig1.CurrentAxes.XLabel.String = 'x';
    hfig1.CurrentAxes.YLabel.String = 'y';
    hfig1.CurrentAxes.ZLabel.String = 'z';
    savefig(hfig1,['output\figs\' runname '.fig']);
    export_fig(['output\figs\' runname], '-png', '-transparent','-m5');
end

% OK, let's see the added mass matrix for this guy
MA = v.getAddedMass;
MA = round(MA) % round to the nearest integer to remove numerical noise