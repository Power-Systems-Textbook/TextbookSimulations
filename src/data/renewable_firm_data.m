function mpc = renewable_firm_data
%PROJECT  Power flow data representing a system with renewables and a firm source.

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%    bus_i    type    Pd    Qd    Gs    Bs    area    Vm    Va    baseKV    zone    Vmax    Vmin
mpc.bus = [
    1    3   0       0     0   0   1   1.02       0   230   1   1.10   0.90;
    2    2   10      2   0   0   1   1.015   0   230   1   1.10   0.90;
    3    2   10      2   0   0   1   1.015   0   230   1   1.10   0.90;
    4    2   12.5    2.5   0   0   1   1.0   0   230   1   1.10   0.90;
    5    1   190     30    0   0   1   1       0   230   1   1.10   0.90;

];

%% generator data
%    bus    Pg    Qg    Qmax    Qmin    Vg    mBase    status    Pmax    Pmin    Pc1    Pc2    Qc1min    Qc1max    Qc2min    Qc2max    ramp_agc    ramp_10    ramp_30    ramp_q    apf
mpc.gen = [
    1    0     0   500   -500   1.02      100   1   500   0   0   0   0   0   0   0   0   0   0   0   0;
    2    50    0   500   -500   1.015   100   1   500   0   0   0   0   0   0   0   0   0   0   0   0;
    3    50    0   500   -500   1.015   100   1   500   0   0   0   0   0   0   0   0   0   0   0   0;
    4    70    0   500   -500   1.0   100   1   500   0   0   0   0   0   0   0   0   0   0   0   0;
    
];

%% branch data
%    fbus    tbus    r    x    b    rateA    rateB    rateC    ratio    angle    status    angmin    angmax
mpc.branch = [
    1    2    0.01938   0.3917   0.0288   0   0   0   0   0   1   -60   60;
    1    3    0.03403   0.304   0.0392   0   0   0   0   0   1   -60   60;
    1    5    0.03699   0.3791   0.0338   0   0   0   0   0   1   -60   60;
    1    4    0.02699   0.3397   0.0342   0   0   0   0   0   1   -60   60;
    2    3    0.02567   0.2632   0.024    0   0   0   0   0   1   -60   60;
    2    5    0.03695   0.2388   0.0246   0   0   0   0   0   1   -60   60;
    3    5    0.0301    0.2103   0.0128   0   0   0   0   0   1   -60   60;
    4    5    0.01335   0.3211   0.031    0   0   0   0   0   1   -60   60;
];

%%-----  OPF Data  -----%%
%% generator cost data
%    1    startup    shutdown    n    x1    y1    ...    xn    yn
%    2    startup    shutdown    n    c(n-1)    ...    c0
mpc.gencost = [
    2   0   0   3   0   0   0;
    2   0   0   3   0   0   0;
    2   0   0   3   0   0   0;
    2   0   0   3   0   0   0;
];
