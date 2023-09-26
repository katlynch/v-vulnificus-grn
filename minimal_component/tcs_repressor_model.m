%% tcs system with repressor

% runs full model simulation for four variable two component system 
% (i.e.hup A and hup R)
% outputs graphs for each run; optionally saves as png


%% RUN OPTIONS

% plot and file title
% title = 'tcsRep02 region3';

% set sv=1 to save png of outputted plots
sv=0;

% simulation overall time interval
t0=0; tfinal=500;

% determines value of some variable parameter in simulation
% in this model, use k1 = rate of R* formation / phosphorylation
opt_k=0;
opt_a=0;

% opt = 0 constant value for k1
    % k1constant=20;
    % a1constant=1;

% opt = 1 sudden change(s)

% opt = 2 smooth changes (one direction)
    % init->final changes happen according to hyperbolic tangent
    % w/midpoint at time halfway between initial and final
    % set min and max k1 as well as steepness of change (stp)

   % initial / final k1
    k1_init=1; k1_final=10;    % starting and ending k values
    a1_init=2; a1_final=1;   % used for both opt 1 and 2
    t_half=(t0+tfinal)/2;       % midpoint of time interval
    stp=0.01;                   % determines steepness of tanh (opt2 only)

% opt = 3 smooth changes (init to final to init)
    t_mid1=t_half/2;
    t_mid2=t_half+t_mid1;


% initial conditions
% dvdt = [a r rs fs pa p0];
% v0 = [0 0 0 0 0 0]; % ics 01

% v0=[1 1 2 0.5 0.7 0.1];  % ics 02


%% Parameters 
if opt_a == 0
    var_a1 = @(t) a1constant;
elseif opt_a == 1
    var_a1 = @(t) a1_init.*(t<t_half)+a1_final*(t>t_half);
elseif opt_a == 2
     var_a1= @(t) ((a1_final-a1_init)/2*tanh(stp*(t-t_half))+(abs(a1_final-a1_init)/2+min(a1_final,a1_init)));
elseif opt_a == 3
    var_a1 = @(t) ((a1_final-a1_init)/2*tanh(stp*(t-t_mid1))+(abs(a1_final-a1_init)/2+min(a1_final,a1_init))).*(t<t_half) ...
                  + ((a1_final-a1_init)/2*tanh(-stp*(t-t_mid2))+(abs(a1_final-a1_init)/2+min(a1_final,a1_init))).*(t>=t_half);
end


if opt_k == 0
    var_k1 = @(t) k1constant;
elseif opt_k == 1
    var_k1=@(t) k1_init.*(t<t_half)+ k1_final* (t>=t_half);
elseif opt_k == 2
    var_k1= @(t) (k1_final-k1_init)/2*tanh(stp*(t-t_half))+(abs(k1_final-k1_init)/2 + min(k1_final,k1_init));
elseif opt_k == 3
    var_k1 = @(t) ((k1_final-k1_init)/2*tanh(stp*(t-t_mid1))+(abs(k1_final-k1_init)/2+min(k1_final,k1_init))).*(t<t_half) ...
                  +((k1_final-k1_init)/2*tanh(-stp*(t-t_mid2))+(abs(k1_final-k1_init)/2+min(k1_final,k1_init))).*(t>=t_half);
end

% constant parameters
% a1=1; % not really used but need the placeholder from prev
a2=1; 
d1=1; d2=1;

b1=1; b2=1;
b3=1; b4=1;
k2=1;
k1m=1; 
k2m=1;
eps=1/100;

params=[0 a2 d1 d2 b1 b2 b3 b4 k1m k2m k2 eps];



%% SET VARIABLE PARAMETERS AND RUN ODES

tic
[t,v] = ode15s(@(t,v)tcs_sys(t,v,params,var_k1,var_a1),t0:0.01:tfinal,v0);
toc

tic

%% PLOTS
% make some plots babeee
figh = figure();
pos = get(figh,'position');
set(figh,'position',[pos(1:2)/4 pos(3:4)*2])


tplot = t0:0.1:tfinal;
subplot(2,2,3)
hold on
% bifurcation parameter: whats it doing
plot1=plot(tplot,var_k1(tplot),'.','color',"#0072BD");
plot2=plot(tplot,var_a1(tplot),'.','color',"#D95319");
ylim([0,21])
legend([plot1(1),plot2(1)],{'k1','a1'})
hold off


subplot(2,2,1)
% operons
hold on
plot(t,1-v(:,5)-v(:,6),'linewidth',2)
plot(t,v(:,5),'linewidth',2)
plot(t,v(:,6),'linewidth',3)
legend('Pr','Pa','P0')
ylim([0,1])
hold off

subplot(2,2,2)
% proteins
hold on
plot(t,v(:,1),'linewidth',2)
plot(t,v(:,2),'linewidth',2)
plot(t,v(:,3),'linewidth',2)
plot(t,v(:,4),'linewidth',2)
ylim([0,4])
% xline(t_mid1)
% xline(t_mid2)
legend('A','R','R*','F*')
hold off


subplot(2,2,4)
% sanity check (i.e. see that nothing is negative or prob>1)
hold on
plot1=plot(t,v(:,1:4),'color',"#0072BD",'linewidth',1);
plot2=plot(t,v(:,5:6),'color',"#D95319",'linewidth',1);
hold off
ylim([-0.1,1.1])
legend([plot1(1),plot2(1)],{'conc.','prob.'})

sgtitle(title)



if sv == 1
    saveas(gcf, title, 'png')
end

toc

%% FUNCTIONS

function [value, isterminal, direction] = event(t,v)
% debugging check
    value = v(4);   % Want to know if value crosses 0
    isterminal = 1;             % halt integration when = 1
    direction = 0;              % zero can be approached from either direction (if = 0)
    
end


function dvdt = tcs_sys(t,v,params,var_k1,var_a1)

    k1 = var_k1(t);
    a1= var_a1(t);

    % params=[1 a1  2 a2  3 d1  4 d2  5 b1  6 b2  7 b3  8 b4  9 k1m  10 k2m eps];

    % equations
    dadt = a1*v(5) - params(3)*v(1) + 2*params(9)*v(3) - 2*k1*v(2)*v(1)^2 - params(11)*(1-v(4))*v(1) + params(10)*v(4);
    drdt = params(2)*(1-v(5)-v(6))-params(4)*v(2)+params(9)*v(3)-k1*v(2)*v(1)^2;
    drsdt = -params(9)*v(3)+k1*v(2)*v(1)^2;
    dfsdt = params(11)*(1-v(4))*v(1) - params(10)*v(4);
    dpadt = params(5)*(1-v(5)-v(6))*v(3) - params(6)*v(5)+params(12)*(1-v(5));
    dp0dt = params(7)*(1-v(5)-v(6))*v(4) - params(8)*v(6);

    
    dvdt = [dadt drdt drsdt dfsdt dpadt dp0dt]';
end


