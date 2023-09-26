% initial conditions sweep

% runs full model simulation for a variety of initial conditions
% outputs graphs for each run

% graph title/save settings found in full_nondim_F.m file
% note that the variables v0, extFe, RBC turned off manually in that file


% may require minor edits to simulate change in params within the
% simulation
run_no = 0;


%% RUN OPTIONS


sv = 0;      % s = 1 --> save as png named "title".png (see below)


opt = 0;     % experiment options
% changes to external Fe, Heme/RBC availability, and temperature
% according to various schema

% time interval
t0 = 0; tfinal = 100;



% opt = 0: constant values
    % currently being set below
% RBC = 1;    % RBC --> He
% extFe = 0;     % --> Fe    

% opt = 1: step changes
% init->mid->final values with changes at times 1,2 

% opt = 2: smooth changes
% init->final changes happen according to hyperbolic tangent
% w/midpoint at time 1


% opt = 3: constant Fe, RBC
% % abs value func for k2 with midpoint at halfway entire time
 a=1;    % sets steepness of change

% experiment concentrations (nondim)
Fe_init = 1; Fe_final = 1; Fe_mid = 0;      % external Fe
He_init = 1; He_final = 1; He_mid = 1;      % RBC availability/production via VvhA
Hn_init = 1; Hn_final = 1;                  % temp change/HNS binding affinity (higher = higher temp)

% experiment times
tf_1 = 50; tf_2 = 250;   % ext. Fe
th_1 = 50; th_2 = 250;   % RBC availability/production via VvhA
tn_1 = 50; tn_2 = 100;   % temperature/HNS



%% Initial Conditions and Parameters

% set various initial conditions

% v = [1a 2d 3f 4i 5is 6r 7rs 8vi 9ve 10he 11hi 12fe 13Pa 14Pr 15Pd 16Pi 17Pv 18Pvi 19Pvf]

% everything "off" (operons in "default", 0 protein/Fe levels)
% --> how does full system "turn on" for differing external Fe/He levels?
input(1).ics = [0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 1 1 0 0];

% everything "on" 
% --> how does system shut down/self regulate under different states?
input(2).ics = [1 1 1 1 1 1 1 1 1 1 1 1 0.5 0 1 1 0 0.5 0.5];

% lots of iron
% --> again how does system shut down/regulate (but with v high initial Fe)
input(3).ics = [0 0 1 0 0 0 0 0 0 0 0 10 0 1 0 1 1 0 0];

% no initial iron; high heme / heme aquisition levels (ignoring the PilD q)
% --> how does system regulate this?
input(4).ics = [1 1 1 1 0 1 1 1 1 1 1 0 0.5 0.5 0 1 0.4 0.3 0];

% "just entered body" (high temp & med iron, heme intake "off")
% --> how does system regulate Fe to Heme transition?
input(5).ics = [0 0 0.8 0 1 1 0 0 0 0 0 2 0 0 0 0 0 0 0.5];

% unnaturally high probabilities (sums to over 1)
% --> does this break things?
input(6).ics = [0 0 1 0 0 0 0 0 0 0 0 0 10 10 10 10 10 10 10];


% set variable parameters (external iron sources and "temperature")
% iron and heme conditions
input(1).fe = 1;
input(2).fe = 0;
input(1).rbc = 0;
input(2).rbc = 1;
input(3).fe=1;
input(3).rbc= 1;

% temperature parameters
% high temp -| HNS (i.e. k6 dec; km6 held constant)
input(1).temp=1;    % 'mild (even with km6)'
input(2).temp=0.1;  % 'warm'
input(3).temp=10;   % 'cold'

% load non-variable parameters / constants
params

%% Runs 


for m1=1:1                              % iterate over ics
    v0=input(m1).ics;
    for m2 = 2:2                        % iterate over params
        extFe = input(m2).fe;           
        RBC = input(m2).rbc;

        for m3 = 1:1                    % iterate k6 values
            temp = input(m3).temp;  

            title = sprintf("r%02d FullSys ics%02d fe%02d rbc%02d temp%02d",run_no,m1,extFe,RBC,m3);

            full_nondim_sys               % runs simulation, plots, saves
        end
    end
end






%% 

% load handel
% sound(y,Fs)
