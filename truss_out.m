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

%% MEMBER LENGTH
lens = zeros(1,M);
dX = zeros(1,M);
dY = zeros(1,M);
for i=[1:M]
    tempvec=C(:,i); % In C, the row represents the joint number and the column represents the member number, so isolate the member
    cxns = find(tempvec); % Since each member is connected to exactly 2 joints, find those two joint indices. CXN is shorthand for connection
    dX(i) = abs(X(cxns(1)) - X(cxns(2)));
    dY(i) = abs(Y(cxns(1)) - Y(cxns(2)));
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
for i=[1:J]
    for k=[1:M]
        if C(i,k)==1
            A(i,k)=dX(k)/lens(k);
        else 
            A(i,k)=0;
        end
    end
end

% Forces in Y direction
for i=[J+1:2*J]
    for k=[1:M]
        if C(i-J,k)==1
            A(i,k)=dY(k)/lens(k);
        else 
            A(i,k)=0;
        end
    end
end

T = zeros((M+3),1); % Tensions in each member
T = (A^-1)*L;

%% LIVE LOAD
R=zeros(1,M);
trussload = L(find(L)); % only 1 index of L should have a value, which is the load

% R sub m = T sub m / Weight Force
for i=[1:M]
        if T(i)~=0
            R(i)=T(i)/trussload;
        end
end

%% CRITICAL MEMBER AND MAXIMUM LOAD
% Pcrit equation taken from Section-wide Buckling Lab Data Analysis done by
% TAs and GSTs
Pcrit=zeros(1,M);
Wfail=zeros(1,M);

for i=[1:M]
    Pcrit(1,i)=3908.184*(lens(1,i)^2.211)-4.1;
end

for i=[1:M]
    Wfail(i)=-1*Pcrit(i)/R(i);
end

%Load/Cost Ratio
LCRat=zeros(1,M)

for i=[1:M]
    LCrat(i) = Wfail(i)/cost;
end

%% OUTPUT
fprintf("EK301 A3: Al Levine, Marina Lyons, Rajiv Ramroop \n")
fprintf("Load: %d oz \n",trussload)
fprintf("Member forces in oz:\n")
for i=[1:M]
    fprintf("\tM%d:\t%.3f\t",i,abs(T(i)))
    if T(i) == abs(T(i))
        fprintf("(T)\n")
    else
        fprintf("(C)\n")
    end
end
fprintf("Reaction forces in oz:\n")
fprintf("\tSx1:\t%.3f\n",T(M+1))
fprintf("\tSy1:\t%.3f\n",T(M+2))
fprintf("\tSy2:\t%.3f\n",T(end))
fprintf("Cost of Truss: $%d\n",cost)
fprintf("Theoretical max load/cost ratio in oz/$: %.3f\n",LCRat)

%% FUNCTIONS
function out = pythag(x,y)
out = sqrt((x^2)+(y^2));
end
