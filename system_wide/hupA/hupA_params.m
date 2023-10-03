% v vulnificus - parameters

% contains (nonvariable) parameters for vv_system

a1=1;   % HupA parameter
a2=1;   % --> R


% Rxns
% Reaction equations:
    % F + Fe <--> F*
    % R^2 + Hi <--> R*

b1=1;   % F --> F*
b6=1;   % Fe --> F*
b7=1;   % F* --> Fe
b2=1;   % R* --> R
placeholdb3=1;   % R --> R*  % make variable; this
b4=1;   % Hi --> R*
b5=1;   % R* --> Hi

n1=1;   % R --> 
n2=1;   % Hi -->
n3=1;   % Fe -->


p1=1;   % RBC --> Hi
p2=1;   % Hi --> Fe (hi)
p3=1;   % Hi --> Fe (fe)
p4=1;   % extFe --> Fe
p5=1;   % Fe --> extFe

% Operon Dynamics
% Equations:
    % Pa <-R*-> PR <-F*-> P0

k1=1;   % Pr + R* --> Pa
k1m=1;  % Pa --> Pr
k2=1;   % P0 --> Pr
k2m=1;  % Pr + F* --> P0
k3=1;   % F* -| Fe

eps = 1/100;

% put in vectors to pass to ODE solver
a=[a1 a2 n1 n2 n3];
b=[b1 b2 placeholdb3 b4 b5 b6 b7];
p=[p1 p2 p3 p4 p5];
k=[k1 k2 k3 k1m k2m eps];


