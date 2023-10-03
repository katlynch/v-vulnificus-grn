% v vulnificus - runner
% note: calls vvsystem.m and full_params.m; place all in same directory

% runs full model simulation from vv simulation
    % HupA model F23
% outputs graphs for each run; optionally saves

% includes initial condition and params of interest below


% require minor edits to simulate change in params w/i simulation
% see take2 model for basic structure




%% RUN OPTIONS

run_no = 0;             % run number
sv = 0;                 % s = 1 --> save as png named "title".png (see below)


t0 = 0; tfinal = 200;   % time interval

opt = 1;     % experiment options
% changes to external Fe, Heme/RBC availability, and temperature
% according to various schema
% opt = 0: constant values as set below 

% opt = 1: changes at times
tf_1 = 60; tf_2 = 120;
th_1 = 60; th_2 = 120;





%% Initial Conditions and Parameter

% set variable parameters
% iron and heme conditions
    % 1 - no heme all iron
    % 2 - all heme no iron
    % 3 - both heme and iron

input(1).fe = 1;
input(2).fe = 0;
input(1).rbc = 0.0001;
input(2).rbc = 1;
input(3).fe=1;
input(3).rbc= 1;

input(1).b3 = 1;

% set initial conditions

% Run 1: everything "off" (operons in "default", 0 protein/Fe levels)
% --> how does full system "turn on" for differing external Fe/He levels?
ics(1).a = 0;
ics(1).f = 1;
ics(1).r = 0; 
ics(1).rs = 0;
ics(1).hi = 0;
ics(1).fe = 0;
ics(1).pa = 0;
ics(1).pr = 1;




% load non-variable parameters / constants
hupA_params

%% Runs 
for i=1:1                              % iterate over ics
    v0 = [ics(i).a ics(i).f ics(i).r ics(i).rs ics(i).hi ics(i).fe ics(i).pa ics(i).pr];

    if opt == 0
        
        for j = 1:3        % iterate over params    
            extFe = input(j).fe;
            RBC = input(j).rbc;
            b3 = input(j).b2;
    
            title = sprintf("r%02d FullSys ics%02d fe%02d rbc%02d",run_no,i,extFe,floor(RBC)); % plot title / save title
    
            vvsystem            % solves ode system and plots
    
        end

    elseif opt == 1
        % iron on off on
        % heme all on
        extFe = @(t) input(1).fe.*(t<tf_1) + input(2).fe.* (t>=tf_1 & t<tf_2) + input(3).fe.* (t>=tf_2);   % (1)
        RBC = @(t) input(3).rbc.*(t<th_1)+ input(2).rbc.* (t>=th_1 & t<th_2) + input(3).rbc.* (t>=th_2);   % (2) 
    
         title = sprintf("r%02d FullSys opt1",run_no); % plot title / save title
    
         vv_hupA_system 
    end
end







%% optional lol

% load handel
% sound(y,Fs)
