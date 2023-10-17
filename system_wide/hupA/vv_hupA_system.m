% v vulnificus model - system

% to execute an initial conditions sweep, use hupAsystem_run.m
% contains code to solve system of odes and make plots
% parameters called from separate file hupA_params


%% Run Options
% plot and file title
temp_title = 'tcsRep02 region3';    % not used if doing an ics sweep

% set sv=1 to save png of outputted plots
sv=0;

% simulation overall time interval
t0=0; tfinal=500;

temp_ics = [0 0 0 0 0 0]; % ics 01  % not used if doing a sweep

% determines value of some variable parameter in simulation
% in this model, use k1 = rate of R* formation / phosphorylation
opt_b3=0;
opt_rbc=0;

% opt = 0 constant value for k1
temp_b3_constant=20;
temp_rbc_constant=1;

% opt = 1 sudden change(s)

% opt = 2 smooth changes (one direction)
    % init->final changes happen according to hyperbolic tangent
    % w/midpoint at time halfway between initial and final
    % set min and max k1 as well as steepness of change (stp)

   % initial / final k1
    b3_init=1; b3_final=10;    % starting and ending k values
    rbc_init=2; rbc_final=1;   % used for both opt 1 and 2
    t_half=(t0+tfinal)/2;       % midpoint of time interval
    stp=0.01;                   % determines steepness of tanh (opt2 only)

% opt = 3 smooth changes (init to final to init)
    t_mid1=t_half/2;
    t_mid2=t_half+t_mid1;




%% Set Variable Parameters

% Single Run Stuff

if ics_sweep == 0
% certain values need to be set if not doing an ics sweep that will be
% dealt with iteratively otherwise

% initial conditions
% dvdt = [a r rs fs pa p0];
v0 = temp_ics;
title = temp_title;
b3constant=temp_b3_constant;
rbcconstant=temp_rbc_constant;
end

if opt_rbc == 0
    var_rbc = @(t) rbcconstant;
elseif opt_rbc == 1
    var_rbc = @(t) rbc_init.*(t<t_half)+rbc_final*(t>t_half);
elseif opt_rbc == 2
     var_rbc= @(t) ((rbc_final-rbc_init)/2*tanh(stp*(t-t_half))+(abs(rbc_final-rbc_init)/2+min(rbc_final,rbc_init)));
elseif opt_rbc == 3
    var_rbc = @(t) ((rbc_final-rbc_init)/2*tanh(stp*(t-t_mid1))+(abs(rbc_final-rbc_init)/2+min(rbc_final,rbc_init))).*(t<t_half) ...
                  + ((rbc_final-rbc_init)/2*tanh(-stp*(t-t_mid2))+(abs(rbc_final-rbc_init)/2+min(rbc_final,rbc_init))).*(t>=t_half);
end


if opt_b3 == 0
    var_b3 = @(t) b3constant;
elseif opt_b3 == 1
    var_b3=@(t) b3_init.*(t<t_half)+ b3_final* (t>=t_half);
elseif opt_b3 == 2
    var_b3= @(t) (b3_final-b3_init)/2*tanh(stp*(t-t_half))+(abs(b3_final-b3_init)/2 + min(b3_final,b3_init));
elseif opt_b3 == 3
    var_b3 = @(t) ((b3_final-b3_init)/2*tanh(stp*(t-t_mid1))+(abs(b3_final-b3_init)/2+min(b3_final,b3_init))).*(t<t_half) ...
                  +((b3_final-b3_init)/2*tanh(-stp*(t-t_mid2))+(abs(b3_final-b3_init)/2+min(b3_final,b3_init))).*(t>=t_half);
end



%% Runs
% run ode solver
tic

% note: use 15s for stiffness
Optdb = odeset('Events',@event);
[t,v] = ode15s(@(t,v)vvsys(t,v,a,b,p,k,extFe(t),RBC(t),b3(t)),t0:0.01:tfinal,v0,Optdb);
toc



%% Plots

tic

figh = figure();
pos = get(figh,'position');
set(figh,'position',[pos(1:2)/4 pos(3:4)*2])

subplot(2,3,2)
% plot heme iron etc
hold on
plot(t,v(:,1),'linewidth',2)
plot(t,v(:,5),'linewidth',2)
plot(t,v(:,6),'linewidth',2)
hold off
legend('HupA','Hi','Fe')

subplot(2,3,1)
% plots operon
hold on
plot(t,v(:,7),'linewidth',2)
plot(t,v(:,8),'linewidth',2)
P0 = ones(length(v(:,7)),1) - v(:,7) - v(:,8);
plot(t,P0,'linewidth',2)
hold off
legend('Pa','Pr','P0')

subplot(2,3,4)
% plots proteins
hold on
plot(t,v(:,2),'linewidth',2)
plot(t,v(:,3),'linewidth',2)
P0 = ones(length(v(:,7)),1) - v(:,7) - v(:,8);
plot(t,v(:,4),'linewidth',2)
if opt == 1
    xline(th_1,'--','iron off')
    xline(th_2,'--','iron on')
end
hold off
legend('F','R','Rs')

subplot(2,3,3)
% plots parameters
hold on
% bifurcation parameter: whats it doing
plot1=plot(tplot,var_b3(tplot),'.','color',"#0072BD");
plot2=plot(tplot,var_rbc(tplot),'.','color',"#D95319");
ylim([0,21])
legend([plot1(1),plot2(1)],{'k1','a1'})
hold off



subplot(2,3,6)
% debug check (plots all vars)
hold on
plot1=plot(t,v(:,1:6),'color',"#0072BD",'linewidth',1);
plot2=plot(t,v(:,7:8),'color',"#D95319",'linewidth',1);
hold off
ylim([-0.1,1.1])
legend([plot1(1),plot2(1)],{'conc.','prob.'})

sgtitle(title)



% save plot as png
if sv == 1
    saveas(gcf, title, 'png')
end

toc 


%% Functions
function [value, isterminal, direction] = event(t,v)
% debugging check
    % v = [a f r rs hi fe pa pr]
    value = v(4);   % Want to know if value crosses 0
    isterminal = 1;             % halt integration when = 1
    direction = 0;              % zero can be approached from either direction (if = 0)
    
end

function dvdt = vvsys(t,v,a,b,p,k,varFe,varRBC)

RBC = varRBC(t);
extFe = varFe(t);

% equations
da = a(1) * (v(7) - v(1));
df = (1-v(2)) - b(1)*v(2)*v(6);
dr = a(2)*v(8) - a(3)*v(3) + 2*b(2)*v(4) - 2*b(3)*v(5)^2*v(3);
drs = b(3)*v(5)^2*v(3) - b(2)*v(4);
dhi = p(1)*varRBC/(1+varRBC)*v(1) - p(2)*v(5)/(1+v(5)) - 2*b(4)*v(5)^2*v(3) + 2*b(5)*v(4) - a(4)*v(5);
dfe = p(3)*v(5)/(1+v(5)) - b(6)*v(2)*v(6) + b(7)*(1-v(2)) - a(5)*v(6) ...
      +(p(4)*varFe/(1+varFe) - p(5)*v(6)/(1+v(6)))*1/(1+k(3)*(1-v(2)));
dpa = k(1)*v(8)*v(4) - k(4)*v(7) + k(6)*v(8);
dpr = k(2)*(1-v(7)-v(8)) - k(5)*v(8) + k(4)*v(7) - k(1)*v(8)*v(4) - k(6)*v(8);

dvdt = [da df dr drs dhi dfe dpa dpr]';
end
