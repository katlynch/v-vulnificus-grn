% v vulnificus model - system

% to execute this, use vvruns.m
% contains code to solve system of odes and make plots

%% Runs
% run ode solver
tic

% note: using 15s to help with zeros thing

if opt == 0
Optdb = odeset('Events',@event);
[t,v] = ode15s(@(t,v)vvsys(t,v,a,b,p,k,extFe,RBC),t0:0.01:tfinal,v0,Optdb);
elseif opt == 1
Optdb = odeset('Events',@event);
[t,v] = ode15s(@(t,v)vvsys(t,v,a,b,p,k,extFe(t),RBC(t)),t0:0.01:tfinal,v0,Optdb);
end

toc



%% Plots

tic

figh = figure();
pos = get(figh,'position');
set(figh,'position',[pos(1:2)/4 pos(3:4)*2])

subplot(2,2,1)
% plot heme iron etc
hold on
plot(t,v(:,1),'linewidth',2)
plot(t,v(:,5),'linewidth',2)
plot(t,v(:,6),'linewidth',2)
if opt == 1
    xline(th_1,'--','iron off')
    xline(th_2,'--','iron on')
end
hold off
legend('HupA','Hi','Fe')

subplot(2,2,2)
% plots operon
hold on
plot(t,v(:,7),'linewidth',2)
plot(t,v(:,8),'linewidth',2)
P0 = ones(length(v(:,7)),1) - v(:,7) - v(:,8);
plot(t,P0,'linewidth',2)
if opt == 1
    xline(th_1,'--','iron off')
    xline(th_2,'--','iron on')
end
hold off
legend('Pa','Pr','P0')

subplot(2,2,3)
% plots operon
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



subplot(2,2,4)
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
