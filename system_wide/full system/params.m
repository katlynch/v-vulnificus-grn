% parameters for non-dimensional vibrio system

% contains non-variable parameters only

% reaction rates (protein binding/unbinding)
% note: F* --> Fe + F parameter scaled to 1
b1=10; b7=10; % Fe + F->- F*
b2=1;         % Fe + I --> I*
b3=1; b8=1;   % I* --> I + Fe  
b4=10;         % R + Hi --> R*
b5=1; b6=1;   % R* --> Hi +


% creation rates 
% transcription/translation (protein created from operon)
% or external source (RBC, Fe)
a1 = 1;     % --> HupA
a2 = 1;     % --> PilD
a3 = 1;     % --> IscR
a4 = 1;     % --> HupR
a5 = 1;     % --> VvhA (interior)
a6 = 1;   % --> RBC (Ve-> He)
a7 = 1; % --> Fe
   

% destruction/use rates
n1 = 1;     % I --> 
n2 = 1;     % I* -->
n3 = 1;     % R --> 
n4 = 1;     % R* -->
n5 = 1;     % Vi -->
n6 = 1;     % Ve -->
n7 = 1;     % He -->
n8 = 1;     % Hi -->
n9 = 1;     % Fe -->

% iron acquisition
p1 = 10;              % Vi --> Ve
p2 = 1;              % He --> Hi 
p3 = 1; p4 = 4;      % Hi --> Fe
p5 = 10; p6 = 1;      % Fe ext <--> Fe int

% operon binding/unbinding rates
k1 = 1; k1m = 10;    % Pr <--> Pa
k2 = 10; k2m = 1;    % P0 <--> Pr
k3 = 1; k3m = 1;    % Pd <--> Pd0
k4 = 1; k4m = 1;    % Pi <--> Pi0
k5 = 1; k5m = 1;    % Pvi <--> Pv
k6 = 10; k6m = 1;    % Pv <--> Pvn  % note high temp -| N (i.e. k6 dec or k6m inc)
k7 = 10; k7m = 1;    % Pvf <--> Pv
k8 = 1;             % Fe intake repressed by Fur (Px in qss) (k8-/k8)


% vectorized parameters (to be passed to ODEs)
a = [a1 a2 a3 a4 a5 a6 a7];
b = [b1 b2 b3 b4 b5 b6 b7 b8];
p = [p1 p2 p3 p4 p5 p6];
k = [k1 k2 k3 k4 k5 k6 k7 k8];
km = [k1m k2m k3m k4m k5m k6m k7m];
n = [n1 n2 n3 n4 n5 n6 n7 n8 n9];
