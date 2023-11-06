% runs ics sweep
% for either tcs.m or tcs_repressor.m

opt_f = 0;
% opt = 0 calls tcs
% opt = 1 calls tcsr

% called ode solving file should NOT set initial conditions
% set other options from tcs_repressor
    % i.e. saving, parameter regions, etc.
    % currently this must be set manually



% ics 1: all "off" (i.e. start at zeros)
% ics 2: near the region 3 "on" steady state ("all on")
% ics 3: all perturbed slightly from 0
% ics 4: perturb some (TFs) but not all (A) things from 0
% ics 5: opposite of 4
% ics 6: start with A super on and TFs off
% ics 7: everything v high


% set ics
ics.a(1) = 0;
ics.a(2) = 1;
ics.a(3) = 0.1;
ics.a(4) = 0;
ics.a(5) = 0.1;
ics.a(6) = 1;
ics.a(7) = 1;

ics.r(1) = 0;
ics.r(2) = 1;
ics.r(3) = 0.1;
ics.r(4) = 0.1;
ics.r(5) = 0;
ics.r(6) = 0;
ics.r(7) = 0.1;

ics.rs(1) = 0;
ics.rs(2) = 2;
ics.rs(3) = 0.1;
ics.rs(4) = 0.1;
ics.rs(5) = 0;
ics.rs(6) = 0;
ics.rs(7) = 1;

ics.fs(1) = 0;
ics.fs(2) = 0.5;
ics.fs(3) = 0.1;
ics.fs(4) = 0.1;
ics.fs(5) = 0;
ics.fs(6) = 0;
ics.fs(7) = 2;

ics.pa(1) = 0;
ics.pa(2) = 0.7;
ics.pa(3) = 0.05;
ics.pa(4) = 0;
ics.pa(5) = 0.1;
ics.pa(6) = 1;
ics.pa(7) = 0.8;

ics.p0(1) = 0;
ics.p0(2) = 0.2;
ics.p0(3) = 0.05;
ics.p0(4) = 0.05;
ics.p0(5) = 0;
ics.p0(6) = 0;
ics.p0(7) = 0.5;


% sets parameters for different regions
a1_tcs = [2 2 2];
k1_tcs = [1 6.5 10];
a1_tcsr = [2 2 2 0.5 1 1.5];
k1_tcsr = [2 5 10 10 20 30];

start = tic;    % timing
if opt_f == 0

for j = 1:3     % iterates through region parameters
    k1constant = k1_tcs(j);
    a1constant = a1_tcs(j);
for i = 1:7     % iterate through initial conditions
    v0 = [ics.a(i) ics.r(i) ics.rs(i)  ics.pa(i)]
    title = sprintf("tcs icsSweep15s eps01 region%02d ics%02d",j,i); % plot title / save title
    %tcs_model
end
end


elseif opt_f == 1
    for j = 1:6
        k1constant = k1_tcsr(j);
        a1constant = a1_tcsr(j);
        for i = 1:7
            v0 = [ics.a(i) ics.r(i) ics.rs(i) ics.fs(i) ics.pa(i) ics.p0(i)];
            title = sprintf("tcs icsSweep region%02d ics%02d",j,i); % plot title / save title
            tcs_repressor_model
        end
    end
end


toc(start)
