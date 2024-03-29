function mpc = uw_12_bus
%UW_12_BUS  Power flow data for an example 12-bus, 5-generator test system.
%
%   This system is based on the test system used in Power System Analysis (EE 454), a senior-level 
%   undergraduate course offered through the University of Washington's Department of Electrical and 
%   Computer Engineering.
%
%   Please see MATPOWER's CASEFORMAT (https://matpower.org/docs/ref/matpower5.0/caseformat.html) 
%   for details on the case-file format.

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%    bus_i    type    Pd    Qd    Gs    Bs    area    Vm    Va    baseKV    zone    Vmax    Vmin
mpc.bus = [
    1    3   0      0      0   0   1   1.05    0   230   1   1.10   0.90;
    2    2   23.7   15.3   0   0   1   1.045   0   230   1   1.10   0.90;
    3    2   84.2   19     0   0   1   1.01    0   230   1   1.10   0.90;
    4    1   57.8   -3.9   0   0   1   1       0   230   1   1.10   0.90;
    5    1   7.6    1.6    0   0   1   1       0   230   1   1.10   0.90;
    6    1   13.5   8.5    0   0   1   1       0   230   1   1.10   0.90;
    7    1   29.5   13.6   0   0   1   1       0   230   1   1.10   0.90;
    8    1   9      5.8    0   0   1   1       0   230   1   1.10   0.90;
    9    1   4.3    2.1    0   0   1   1       0   230   1   1.10   0.90;
    10   2   5.2    1.6    0   0   1   1.06    0   230   1   1.10   0.90;
    11   1   13.5   5.8    0   0   1   1       0   230   1   1.10   0.90;
    12   2   14.9   5      0   0   1   1.04    0   230   1   1.10   0.90;
];

%% generator data
%    bus    Pg    Qg    Qmax    Qmin    Vg    mBase    status    Pmax    Pmin    Pc1    Pc2    Qc1min    Qc1max    Qc2min    Qc2max    ramp_agc    ramp_10    ramp_30    ramp_q    apf
mpc.gen = [
    1    0    0   500   -500   1.05    100   1   500   0   0   0   0   0   0   0   0   0   0   0   0;
    2    42   0   500   -500   1.045   100   1   500   0   0   0   0   0   0   0   0   0   0   0   0;
    3    23   0   500   -500   1.01    100   1   500   0   0   0   0   0   0   0   0   0   0   0   0;
    10   33   0   500   -500   1.06    100   1   500   0   0   0   0   0   0   0   0   0   0   0   0;
    12   27   0   500   -500   1.04    100   1   500   0   0   0   0   0   0   0   0   0   0   0   0;
];

%% branch data
%    fbus    tbus    r    x    b    rateA    rateB    rateC    ratio    angle    status    angmin    angmax
mpc.branch = [
    1    2    0.01938   0.05917   0.0528   0   0   0   0   0   1   -60   60;
    1    5    0.05403   0.22304   0.0492   0   0   0   0   0   1   -60   60;
    2    3    0.04699   0.19797   0.0438   0   0   0   0   0   1   -60   60;
    2    4    0.05811   0.17632   0.034    0   0   0   0   0   1   -60   60;
    2    5    0.05695   0.17388   0.0346   0   0   0   0   0   1   -60   60;
    3    4    0.6701    0.17103   0.0128   0   0   0   0   0   1   -60   60;
    4    5    0.01335   0.04211   0        0   0   0   0   0   1   -60   60;
    4    7    0         0.55618   0        0   0   0   0   0   1   -60   60;
    5    6    0         0.25202   0        0   0   0   0   0   1   -60   60;
    6    9    0.09498   0.1989    0        0   0   0   0   0   1   -60   60;
    6    10   0.12291   0.25581   0        0   0   0   0   0   1   -60   60;
    6    11   0.06615   0.13027   0        0   0   0   0   0   1   -60   60;
    7    8    0.03181   0.0845    0        0   0   0   0   0   1   -60   60;
    7    12   0.12711   0.27038   0        0   0   0   0   0   1   -60   60;
    8    9    0.08205   0.19207   0        0   0   0   0   0   1   -60   60;
    10   11   0.22092   0.19988   0        0   0   0   0   0   1   -60   60;
    11   12   0.17093   0.34802   0        0   0   0   0   0   1   -60   60;
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
    2   0   0   3   0   0   0;
];
