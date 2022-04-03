%% Information

% BOSTON UNIVERISITY ENG-EK301 SECTION A3
% AL LEVINE, MARINA LYONS, RAJIV RAMROOP
% 
% THIS PROGRAM GENERATES A PARAMETER FILE FOR A SIMPLE PLANAR TRUSS TO BE
% ANALYZED IN A SEPARATE SCRIPT.

%% GENERAL VARIABLES
iteration = 1; % for output file-naming
loadMin = 32; % truss must support a minimum of 32 oz placed on a joint located at a horizontal distance of 20 in away from the pin support.
trussload = loadMin; % we want to start load at the minimum acceptable value and work it upward from there

%% JOINTS AND MEMBERS
J = input("Enter the number of joints: ");
M = input("Enter the number of members: ");

if M ~= (2*J-3) % Check J,M for validity. For a simple truss, Members = 2*Joints-3
    error("This is not a valid configuration for a simple truss.")
end

% Connection matrix. row index = joint #, col index = member #. 1 if connection, 0 if no connection
C = zeros(J,M); 

for k=[1:M] % gets info for C
    question = sprintf("Enter the joints that member %d is connected to separated by a space: ",k);
    inds = str2num(input(question,'s'));
    C(inds,k) = 1;
end

if any(2 ~= sum(C,1)) % Check validity of C (sum of each column should be 2, since simple truss)
    error("Connection matrix is invalid for a simple truss.")
end

% Joint locations
X = zeros(1,J);
Y = zeros(1,J);

for i=[1:J] % Get info for joint locations
    xIn = sprintf("Enter x coordinate of joint %d (inches): ",i);
    yIn = sprintf("Enter y coordinate of joint %d (inches): ",i);
    X(i) = input(xIn);
    Y(i) = input(yIn);
end

%% SUPPORT FORCES
sX = zeros(J,3); % for each unknown reaction force, put a `1' in the column that corresponds to the joint j
sY = zeros(J,3);

% The assignment parameters dictate the truss be supported by a pin and a
% roller joint.
sX(1) = 1; % We will say that the pin support is always at joint 1
sY(1,2) = 1;
sY(J,3) = 1; % We will say that the roller support is always at the last joint

%% LOAD VECTOR
L = zeros(2*J,1); % This vector has 2j elements; the first j elements correspond to loads in the x direction in order by element number, and the last j elements represent loads along the y direction

i = input("What joint is the load suspended from? ");
L(i+J) = trussload; % W = mg, except load is in oz, which is already a weight

%% OUTPUT
filename = sprintf("TrussDesign%d_A3_LevineLyonsRamroop",iteration)
save(filename, 'C','sX','sY','X','Y',"L");

fprintf("Number of joints:\t%d\nNumber of members:\t%d\n",J,M)
fprintf("Joint locations:\n")
fprintf("Joint\tX(in)\tY(in)\n")
for i=[1:J]
    fprintf("%d\t%d\t%d",i,X(i),Y(i))
end
fprintf("Connection matrix (row j, column m):\n");
disp(C);
fprintf("Load Vector:\n")
disp(L);