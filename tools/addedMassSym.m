% addedMassSym.m
% symnbolic math for added mass stuff

clearvars; close all; clc;
% The verification of this method is for the general case. If you assume
% symmetric sections then some terms will be zero and you will see
% verification failures.
symmetricSections = false;
writeToFile = false;

%% Define symbols
% Added mass matrix
Ma = sym('Ma%d%d',[6 6]);
syms u v w p q r ud vd wd pd qd rd X Y Z K M N xg yg zg m
% NOTE: B velocity/acceleration means the B derivative of the
% position/velocity vector
BaBO_B = [ud;vd;wd]; % B acceleration of B w.r.t. O expressed in the B frame
OvBO_B = [u;v;w]; % B velocity of B w.r.t. O expressed in the B frame
OomgB_B = [p;q;r]; % Angular velocity of B w.r.t O expressed in the B frame
OalfB_B = [pd;qd;rd]; % Angular acceleration of B w.r.t O expressed in the B frame
rCB_B = [xg;yg;zg]; % position to C from B expressed in the B frame
IB_B = sym('IB_B%d%d',[3 3]); % Inertia tensor about B expressed in the B frame
sumF_B = [X;Y;Z]; % sum of the forces on the body expressed in the B frame
sumTau_B = [K;M;N]; % moments about B expressed in the B frame
rhs1 = m*(BaBO_B + cross(OalfB_B,rCB_B) + cross(OomgB_B,OvBO_B) + cross(OomgB_B,cross(OomgB_B,rCB_B)));
rhs2 = IB_B*OalfB_B + cross(OomgB_B,IB_B*OomgB_B) + m*cross(rCB_B,BaBO_B) + m*cross(rCB_B,cross(OomgB_B,OvBO_B));
eqn1 = sumTau_B == rhs1;
eqn2 = sumTau_B == rhs2;

% section acceleration as function of body accelerations exprssed in B
% frame
syms xa ya za
raB_B = [xa;ya;za];
OaaO_B = BaBO_B + cross(OomgB_B,OvBO_B) + cross(OalfB_B,raB_B) + cross(OomgB_B,cross(OomgB_B,raB_B));

syms phi theta psi;
Rx_phi = ...
    [1 0 0;...
    0 cos(phi) sin(phi);...
    0 -sin(phi) cos(phi)];    
Ry_theta =...
    [cos(theta) 0 -sin(theta);...
    0 1 0;...
    sin(theta) 0 cos(theta)];
Rz_psi = ...
    [cos(psi) sin(psi) 0;...
    -sin(psi) cos(psi) 0;...
    0 0 1];
B_C_a = Rx_phi*Ry_theta*Rz_psi;
a_C_B = transpose(B_C_a);    
    
syms a22 a23 a24 a32 a33 a34 a42 a43 a44
aa_a = sym(zeros(6));
aa_a(2,2) = a22; aa_a(3,3) = a33; aa_a(4,4) = a44;
if ~symmetricSections
aa_a(2,3) = a23; aa_a(2,4) = a24;
aa_a(3,2) = a32; aa_a(3,4) = a34;
aa_a(4,2) = a42; aa_a(4,3) = a43;
end

aa_a11 = aa_a(1:3,1:3); aa_a12 = aa_a(1:3,4:6);
aa_a21 = aa_a(4:6,1:3); aa_a22 = aa_a(4:6,4:6);

RBa = [B_C_a sym(zeros(3)); sym(zeros(3)) B_C_a];
OaaO_a = a_C_B*OaaO_B;

% The contribution to the total B frame force of any one section is
syms dl
FAa_B = B_C_a*aa_a11*a_C_B*OaaO_B*dl + B_C_a*aa_a12*a_C_B*OalfB_B*dl;
% then the added mass elements are
m11 = diff(FAa_B(1),ud); m21 = diff(FAa_B(2),ud); m31 = diff(FAa_B(3),ud);
m12 = diff(FAa_B(1),vd); m22 = diff(FAa_B(2),vd); m32 = diff(FAa_B(3),vd);
m13 = diff(FAa_B(1),wd); m23 = diff(FAa_B(2),wd); m33 = diff(FAa_B(3),wd);
m14 = diff(FAa_B(1),pd); m24 = diff(FAa_B(2),pd); m34 = diff(FAa_B(3),pd);
m15 = diff(FAa_B(1),qd); m25 = diff(FAa_B(2),qd); m35 = diff(FAa_B(3),qd);
m16 = diff(FAa_B(1),rd); m26 = diff(FAa_B(2),rd); m36 = diff(FAa_B(3),rd);

% And the moments
TAa_B = B_C_a*aa_a21*a_C_B*OaaO_B*dl + B_C_a*aa_a22*a_C_B*OalfB_B*dl + ...
    cross(raB_B,B_C_a*aa_a11*a_C_B*OaaO_B)*dl + cross(raB_B,B_C_a*aa_a12*a_C_B*OalfB_B)*dl;
m41 = diff(TAa_B(1),ud); m51 = diff(TAa_B(2),ud); m61 = diff(TAa_B(3),ud);
m42 = diff(TAa_B(1),vd); m52 = diff(TAa_B(2),vd); m62 = diff(TAa_B(3),vd);
m43 = diff(TAa_B(1),wd); m53 = diff(TAa_B(2),wd); m63 = diff(TAa_B(3),wd);
m44 = diff(TAa_B(1),pd); m54 = diff(TAa_B(2),pd); m64 = diff(TAa_B(3),pd);
m45 = diff(TAa_B(1),qd); m55 = diff(TAa_B(2),qd); m65 = diff(TAa_B(3),qd);
m46 = diff(TAa_B(1),rd); m56 = diff(TAa_B(2),rd); m66 = diff(TAa_B(3),rd);

m11 = simplify(m11)
m12 = simplify(m12)
m13 = simplify(m13)
m14 = simplify(m14)
m15 = simplify(m15)
m16 = simplify(m16)
m22 = simplify(m22)
m23 = simplify(m23)
m24 = simplify(m24)
m25 = simplify(m25)
m26 = simplify(m26)
m33 = simplify(m33)
m34 = simplify(m34)
m35 = simplify(m35)
m36 = simplify(m36)
m44 = simplify(m44)
m45 = simplify(m45)
m46 = simplify(m46)
m55 = simplify(m55)
m56 = simplify(m56)
m66 = simplify(m66)
MA = [string(m11) string(m12) string(m13) string(m14) string(m15) string(m16) string(m22) string(m23) string(m24) string(m25) string(m26)...
    string(m33) string(m34) string(m35) string(m36) string(m44) string(m45) string(m46) string(m55) string(m56) string(m66)];
% Let's make sure that we get back what we would expect for when the axes
% are coincident. Use the table in the MIT OCW 2.20 (13.021) lecture 14 
% or in Principles of Naval Architecture Vol. 3 pg. 56
% Diagonals
check_m22 = subs(m22,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be a22*dl
if strcmp(char(check_m22),'a22*dl')
    disp('m22 pass');
else
    disp('m22 fail');
end
check_m33 = subs(m33,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be a33*dl
if strcmp(char(check_m33),'a33*dl')
    disp('m33 pass');
else
    disp('m33 fail');
end
check_m44 = subs(m44,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be a44
if strcmp(char(check_m44),'a44*dl')
    disp('m44 pass');
else
    disp('m44 fail');
end
check_m55 = subs(m55,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be a33*dl*x^2
if strcmp(char(check_m55),'a33*dl*xa^2')
    disp('m55 pass');
else
    disp('m55 fail');
end
check_m66 = subs(m66,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be a22*dl*xa^2
if strcmp(char(check_m66),'a22*dl*xa^2')
    disp('m66 pass');
else
    disp('m66 fail');
end
% Off-dialgonals
check_m23 = subs(m23,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be a23*dl
if strcmp(char(check_m23),'a23*dl')
    disp('m23 pass');
else
    disp('m23 fail');
end
check_m24 = subs(m24,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be a24*dl
if strcmp(char(check_m24),'a24*dl')
    disp('m24 pass');
else
    disp('m24 fail');
end
check_m25 = subs(m25,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be -a23*dl*x
if strcmp(char(check_m25),'-a23*dl*xa')
    disp('m25 pass');
else
    disp('m25 fail');
end
check_m26 = subs(m26,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be a22*dl*x
if strcmp(char(check_m26),'a22*dl*xa')
    disp('m26 pass');
else
    disp('m26 fail');
end
check_m34 = subs(m34,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be a24*dl
if strcmp(char(check_m34),'a34*dl')
    disp('m34 pass');
else
    disp('m34 fail');
end
check_m35 = subs(m35,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be -a33*dl*x
if strcmp(char(check_m35),'-a33*dl*xa')
    disp('m35 pass');
else
    disp('m35 fail');
end
check_m36 = subs(m36,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be a32*dl*x
if strcmp(char(check_m36),'a32*dl*xa')
    disp('m36 pass');
else
    disp('m36 fail');
end
check_m45 = subs(m45,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be -a43*dl*x
if strcmp(char(check_m45),'-a43*dl*xa')
    disp('m45 pass');
else
    disp('m45 fail');
end
check_m46 = subs(m46,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be a42*dl*x
if strcmp(char(check_m46),'a42*dl*xa')
    disp('m46 pass');
else
    disp('m46 fail');
end
check_m56 = subs(m56,[phi, psi, theta, ya, za],[0, 0, 0, 0, 0]); % should be -a32*dl*x^2
if strcmp(char(check_m56),'-a32*dl*xa^2')
    disp('m56 pass');
else
    disp('m56 fail');
end
if symmetricSections
    disp('Symmetric sections is TRUE. Off diagonals will fail (they are 0) except m26 and m35.');
end
% write to file
if writeToFile
    fid = fopen('addedMassExpressions.txt','w');
    fprintf(fid,'%s\n',MA);
%     for i=1:1:length(MA)
%         fprintf(fid,'%s\n', char(MA(i)));
%     end
    fclose(fid);
end