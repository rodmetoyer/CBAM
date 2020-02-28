% addedMassTool.m
% This tool may be used to compute the added mass coefficients for a body
% composed of one or more slender bodies.
% The tool uses strip theory to compute the added mass coefficients of
% sections and then sums the section loads to get equivalent body loads,
% and finally the partial of each equivalent load with respect to the body
% frame accelerations is taken to compute the coefficient values.

clearvars; close all; clc;

addpath('src');

%% Working with the section class and section objects
% Here is the fastest way to create a section. The hydrodynamic mass
% coefficients will be for water with a density of 1000 kg/m^3
sec = section('ellipse',2,4);
% If you want to compute the coefficients for a different medium, use the
% computeCoeff method on the section object like this:
fluidDensity = 500;
sec.computeCoeffs(fluidDensity);
% Also, the computeAddedMass method in the section class is static, so you
% can use it to compute added mass for supported sections without
% instantiating an object if you want to for some reason.
[ma22, ma33, ma44] = section.computeAddedMass(fluidDensity,'ellipse',2,4);
% Notice that ma22,... are the same as sec.MA22,...
% Finally, you can visually check the section that you just made using
% the showme method.
hfig_ell = sec.showme;

% Try a rectangle
% NOTE that the way I am doing this I am overwriting the section object.
sec = section('rectangle',1,2);
hfig_rec = sec.showme;

% and a diamond
sec = section('diamond',2,1);
hfig_dia = sec.showme;

% and finally a flat plat, which is an ellipse of zero in one dimension.
% NOTE: USE ELLIPSE TO MAKE A PLATE SECTION - DO NOT USE ANOTHER SHAPE!!!
sec = section('ellipse',0,2);
hfig_plt = sec.showme;
pause
%% Build a mass matrix from sections
clearvars; close all;
% Right now this is all on the user.
% Let's do a cylinder with body frame at the center made up of 100 sections
% Same section so we only need one
s = section('ellipse',0.1,0.1,0.1); % Circle radius of 0.15 diffl 0.2
s.showme;
% location is at center of diffl
MA = zeros(6); % Initialize added mass matrix
% start with the negative x sections
for sNum = 1:1:50
    loc = [-(sNum-1)*s.diffl-s.diffl/2;0;0]; % x,y,z coordinates of centroid
    ornt = [0;0;0]; % Orientation angles following 3-2-1 sequence
    % getDiffMij is obsolete. Make a vehicle and then use the getAddedMass
    % method in the vehicle class.
    % Todo remove getDiffMij and use a vehicle here.
    dMA = getDiffMij(s,loc,ornt);
    MA = MA + dMA;
end
% add positive x sections
for sNum = 1:1:50
    loc = [(sNum-1)*s.diffl+s.diffl/2;0;0]; % x,y,z coordinates of centroid
    ornt = [0;0;0]; % Orientation angles following 3-2-1 sequence
    dMA = getDiffMij(s,loc,ornt);
    MA = MA + dMA;
end
MA
%% FUTURE FUNCTIONALITY: Working with the slenderbody class
% Not sure this is necessary. I may remove the class and just work with
% vehicles.

%% Working with the vehicle class and vehicle objects
% A vehicle has bodies, body locations, body orientations, and the computed
% hydrodynamic mass coefficients
% An example is coming. See fullSizeKite for now.