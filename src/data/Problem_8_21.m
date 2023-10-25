function mpc = Twelve_Bus_Example
%Base Case

%% MATPOWER Case Format : Version 2
mpc.version = '2';

%%-----  Power Flow Data  -----%%

%% System MVA base
mpc.baseMVA = 100;

%% Bus data
%% Bus types:3 = slack, 1: PV, 2: PQ
%% Only the active power load (Pd) and the reactive power load (Qd) are used in the power flow computations.
%bus_i type  Pd     Qd    Gs  Bs area  Vm      Va baseKV zone Vmax  Vmin
mpc.bus = [
    1    3   25     10     0   0   1   1       0   230   1   1.05   0.95;
    2    1   40     15     0   0   1   1       0   230   1   1.05   0.95;
    3    2   45     16     0   0   1   1       0   230   1   1.05   0.95;
    4    1    0	     0     0   0   1   1       0   230   1   1.05   0.95;
    5    1    0      0     0   0   1   1       0   230   1   1.05   0.95;
    6    1   20      7     0   0   1   1       0    33   1   1.05   0.95;
    7    1   33     10     0   0   1   1       0    33   1   1.05   0.95;
    8    1   20      8     0   0   1   1       0    33   1   1.05   0.95;
    9    1   15      6     0   0   1   1       0    33   1   1.05   0.95;
    10   2    5      2     0   0   1   1       0    33   1   1.05   0.95;
    11   1   60     15     0   0   1   1       0    33   1   1.05   0.95;
    12   2   15      5     0   0   1   1       0    33   1   1.05   0.95;
];

%% Generator data
%% Only the active power generation (Pg) and the generator terminal voltage (Vg) are used in the power flow computations.
% Changing the status of a generator from 1 to 0 takes it out of service.
%  bus   Pg   Qg  Qmax   Qmin  Vg     mBase status Pmax    Pmin    Pc1    Pc2    Qc1min    Qc1max    Qc2min    Qc2max    ramp_agc    ramp_10    ramp_30    ramp_q    apf
mpc.gen = [
    1    0    0   500   -500   1.02    100   1   500   0   0   0   0   0   0   0   0   0   0   0   0;
    3    42   0   500   -500   1.02    100   1   500   0   0   0   0   0   0   0   0   0   0   0   0;
    10   27   0   500   -500   1.02    100   1   500   0   0   0   0   0   0   0   0   0   0   0   0;
    12   33   0   500   -500   1.02    100   1   500   0   0   0   0   0   0   0   0   0   0   0   0;
];

%% Branch data
% Only the resistance (r), reactance (x), susceptance (b), transformer tap ration (rat), transformer phase shift (ang), and status of each branch are used in the power flow computations.
% Changing the status of a line from 1 to 0 takes it out of service.
% Adjusting rat changes the transformer tap ratio away from nominal
% Adjusting ang introduces a phase angle shift in a transformer.
% from  to     r        x         b        A   B   C  rat ang status angmin  angmax
mpc.branch = [
    1    2    0.03876   0.11834   0.0264   0   0   0   0   0   1   -60   60;
    1    2    0.03876   0.11834   0.0264   0   0   0   0   0   1   -60   60;
    1    5    0.05203   0.20304   0.0492   0   0   0   0   0   1   -60   60;
    2    3    0.04699   0.19797   0.0438   0   0   0   0   0   1   -60   60;
    2    4    0.05811   0.17632   0.034    0   0   0   0   0   1   -60   60;
    2    5    0.05695   0.07388   0.0346   0   0   0   0   0   1   -60   60;
    3    4    0.06701   0.17103   0.0128   0   0   0   0   0   1   -60   60;
    4    5    0.01335   0.04211   0.0391   0   0   0   0   0   1   -60   60;
    4    7    0         0.55618   0        0   0   0   0   0   1   -60   60;
    5    6    0         0.55618   0        0   0   0   0   0   1   -60   60;
    6    9    0.09498   0.1989    0.0176   0   0   0   0   0   1   -60   60;
    6    10   0.12291   0.25581   0.0267   0   0   0   0   0   1   -60   60;
    6    11   0.06615   0.13027   0.031    0   0   0   0   0   1   -60   60;
    7    8    0.03181   0.0845    0.041    0   0   0   0   0   1   -60   60;
    7    12   0.12711   0.27038   0.0323   0   0   0   0   0   1   -60   60;
    8    9    0.08205   0.19207   0.026    0   0   0   0   0   1   -60   60;
    10   11   0.12092   0.19988   0.019    0   0   0   0   0   1   -60   60;
    11   12   0.17093   0.34802   0.036    0   0   0   0   0   1   -60   60;
];
