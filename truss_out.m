%% Information

% BOSTON UNIVERISITY ENG-EK301 SECTION A3
% AL LEVINE, MARINA LYONS, RAJIV RAMROOP
%
% THIS PROGRAM READS A PARAMETER FILE FOR A SIMPLE PLANAR TRUSS
% CONFIGURATION. IT THEN ANALYZES THE TRUSS FOR TENSION AND COMPRESSION
% FORCES IN EACH MEMBER.
%
% THE ASSIGNMENT PARAMTERS MAKE SEVERAL ASSUMPTIONS
% 1) The structure is well modelled as a pin-jointed and 2-dimensional truss
% 2) The strength of the truss members in tension is practically infinite
% 3) The strength of the joints is practically infinite
% 4) The dominant failure mechanism is buckling of individual members
% THE MATERIAL USED FOR THIS ASSIGNMENT IS ACRYLIC SHEET. BASED ON A FIT
% CURVE DETERMINED VIA EXPERIMENTATION, THE CRITICAL BUCKLING STRENGTH OF
% EACH MEMBER WILL BE COMPARED TO THE TENSION/COMPRESSION FORCES.

%% READ IN PARAMETER FILE
clearvars % clean up the workspace first
filename = input("Enter the name of the parameter file: ",'s');
load(filename,'-mat','C','sX','sY','X','Y','L')
J = size(C,1);
M = size(C,2);

%% MISC ANONYMOUS FUNCTIONS
oz2lb = @(x) x./16; % ounce to pound converter
lb2oz = @(x) x.*16; % pound to ounce converter

%% MEMBER LENGTH
lens = zeros(1,M);
dX = zeros(1,M);
dY = zeros(1,M);
for i=1:M
    tempvec=C(:,i); % In C, the row represents the joint number and the column represents the member number, so isolate the member
    cxns = find(tempvec); % Since each member is connected to exactly 2 joints, find those two joint indices. CXN is shorthand for connection
    dX(i) = X(cxns(2)) - X(cxns(1));
    dY(i) = Y(cxns(2)) - Y(cxns(1));
    lens(i) = pythag(dX(i),dY(i));
end
lenTot = sum(lens);

%% COST CALCULATOR
cost = (10*J) + ceil(1*lenTot);

%% TENSION MATRIX
A = zeros((2*J),(M+3)); %A is the coeffcients of the force for the respective member tension at each joint
% starting with the forces along the x axis for rows 1 to j, and finishing with the forces along the y axis for rows j + 1 to 2j.

A(1,(M+1))=1; % the last three columns are the Sx and Sy matrices
A((J+1),(M+2))=1;
A((2*J),(M+3))=1;

% Forces in X direction
for i=1:J
    for k=1:M
        if C(i,k)==1
            cxns = find(C(:,k));
            locale = cxns==i;
            x1 = X(i);
            x2 = X(cxns(find(~locale)));
            A(i,k)=(x2-x1)/lens(k);
        else
            A(i,k)=0;
        end
    end
end

% Forces in Y direction
for i=J+1:2*J
    for k=1:M
        if C(i-J,k)==1
            cxns = find(C(:,k));
            locale = cxns==(i-J);
            y1 = Y(i-J);
            y2 = Y(cxns(find(~locale)));
            A(i,k)=(y2-y1)/lens(k);
        else
            A(i,k)=0;
        end
    end
end

T = inv(A)*L; % Tensions in each member

%% LIVE LOAD, CRITICAL MEMBER, AND MAXIMUM LOAD
Lind = find(L);
trussload = L(Lind); % only 1 index of L should have a value, which is the load

% Pcrit equation taken from Section-wide Buckling Lab Data Analysis done by
% TAs and GSTs
Pcrit = ((3908.184).*(transpose(lens).^(-2.211)))-(4.1);
inds = find(T(1:M)<0); % indices of compression members
% crit_mem = find(min(Pcrit(T<0)));

R = T(1:M)./trussload; % proportion of tension in each member to the load
Wfail_all = (-1*Pcrit)./R;
Wfail = min(Wfail_all(inds)) % lowest value among compression members

proportion = (abs(T(1:M)))./(Pcrit); % proportion of load to buckling value (only useful for compression member)

%% L/C RATIO
LCrat = Wfail/cost;

%% OUTPUT
fprintf("\n---------------\n\nEK301 A3: Al Levine, Marina Lyons, Rajiv Ramroop \n")
disp(filename)
fprintf("Load (oz): %d\n",trussload)
fprintf("Member Lengths (in):\n")
for i=1:M
    if i<10
        fprintf("\tM0%d:\t%.3f\t",i,lens(i))
    else
        fprintf("\tM%d:\t%.3f\t",i,lens(i))
    end
    fprintf("\n");
end
fprintf("Member Forces (oz):\n")
for i=1:M
    if i<10
        fprintf("\tM0%d:\t%.3f\t",i,abs(T(i)))
    else
        fprintf("\tM%d:\t%.3f\t",i,abs(T(i)))
    end
    if T(i) == abs(T(i))
        fprintf("(T)")
    else
        fprintf("(C)\tPcrit: %.3f\tLoading: %.2f%%",Pcrit(i),proportion(i)*100)
        if Pcrit(i)<abs(T(i))
            fprintf("\tBUCKLED!")
        end
    end
    fprintf("\n");
end
fprintf("Reaction Forces (oz):\n")
fprintf("\tSx1:\t%.3f\n",T(M+1))
fprintf("\tSy1:\t%.3f\n",T(M+2))
fprintf("\tSy2:\t%.3f\n",T(end))
fprintf("Cost of Truss: $%d\n",cost)
fprintf("Theoretical Maximum Load (oz): %.3f\n",Wfail)
fprintf("Theoretical Load/Cost Ratio (oz/$): %.3f\n\n---------------\n\n",LCrat)

%% FUNCTIONS
function out = pythag(x,y)
out = sqrt((x^2)+(y^2));
end
