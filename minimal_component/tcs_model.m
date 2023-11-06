%% simple tcs system

% runs full model simulation for four variable two component system 
% (i.e.hup A and hup R)
% outputs graphs for each run; optionally saves as png


%% RUN OPTIONS

% plot and file title
title = 'ode solver test';

% set sv=1 to save png of outputted plots
sv=0;

% simulation overall time interval
t0=0; tfinal= 200;

% determines value of some variable parameter in simulation
% in this model, use k1 = rate of R* formation / phosphorylation
opt_k=0;
opt_a=0;

% opt = 0 constant value for k1
    k1constant=10;
    a1constant=2;

% opt =/= 0 variable params 
    k1_init=10; k1_final=1;
    a1_init=1; a1_final=1;

% opt = 1 sudden changes

% opt = 2 smooth changes
    % init->final changes happen according to hyperbolic tangent
    % w/midpoint at time halfway between initial and final
    % set min and max k1 as well as steepness of change (stp)

    % initial / final k1
    t_half=(t0+tfinal)/2;   % midpoint of time interval
    stp=0.005;               % determines steepness of tanh

% opt = 3 smooth changes (up then down)
    t_mid1=t_half/2;
    t_mid2=t_half+t_mid1;

% initial conditions
% v0 = [a r rs pa]
% v0 = [0 0 0 1];
 v0 = [0 1 0 0];



%% Parameters
% set variable parameters
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

if opt_a == 0
    var_a1 = @(t) a1constant;
elseif opt_a == 1
    var_a1=@(t) a1_init.*(t<t_half)+ a1_final* (t>=t_half);
elseif opt_a == 2
    var_a1= @(t) (a1_final-a1_init)/2*tanh(stp*(t-t_half))+(abs(a1_final-a1_init)/2 + min(a1_final,a1_init));
elseif opt_a == 3
    var_a1 = @(t) ((a1_final-a1_init)/2*tanh(stp*(t-t_mid1))+(abs(a1_final-a1_init)/2+min(a1_final,a1_init))).*(t<t_half) ...
                  +((a1_final-a1_init)/2*tanh(-stp*(t-t_mid2))+(abs(a1_final-a1_init)/2+min(a1_final,a1_init))).*(t>=t_half);
end

% constant parameters
a1=1; a2=1; 
d1=1; d2=1;

b1=1; b2=1;
k1m=1; 
eps=1/100;

params=[a1 a2 d1 d2 b1 b2 k1m eps];



%% RUN ODES

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
subplot(2,2,2)
hold on
% bifurcation parameter: whats it doing
plot1=plot(tplot,var_k1(tplot),'.','color',"#0072BD");
plot2=plot(tplot,var_a1(tplot),'.','color',"#D95319");
legend([plot1(1),plot2(1)],{'k1','a1'})
hold off


subplot(2,2,1)
% r and r*
hold on
plot(t,1-v(:,4),'linewidth',2)
plot(t,v(:,2),'linewidth',2)
plot(t,v(:,3),'linewidth',2)
legend('Pr','R','R*')
hold off

subplot(2,2,3)
% pa and a
hold on
plot(t,v(:,4),'linewidth',2)
plot(t,v(:,1),'linewidth',2)
legend('Pa','A')
hold off


subplot(2,2,4)
% sanity check (i.e. see that nothing is negative or prob>1)
hold on
plot1=plot(t,v(:,1:3),'color',"#0072BD",'linewidth',1);
plot2=plot(t,v(:,4),'color',"#D95319",'linewidth',1);
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


function dvdt = tcs_sys(t,v,params,k1,a1)

    k1 = k1(t);
    a1 = a1(t);

    % equations
    dadt = a1*v(4) - params(3)*v(1) + 2*params(7)*v(3) - 2*k1*v(2)*v(1)^2;
    drdt = params(2)*(1-v(4))-params(4)*v(2)+params(7)*v(3)-k1*v(2)*v(1)^2;
    drsdt = -params(7)*v(3)+k1*v(2)*v(1)^2;
    dpadt = params(5)*(1-v(4))*v(3) - params(6)*v(4)+eps*(1-v(4));
    
    dvdt = [dadt drdt drsdt dpadt]';
end



    

