function [] = paramete_IES()
global Power_Load Hot_Load p_invest k_c k_Power c_buy price_sell...
       k_gas c_0 c_1 c_2 c_3 c_4 c_5 cm M_coal M_gas k_ic_CHP k_fix_CHP k_var_CHP L_CHP W_CHP M_v_ch4 M_q_co2 H_0 H_max P_max P_min cv_1 cv_2 K S_sc T_on_min T_off_min P_up_CHP P_down_CHP P_on_CHP P_off_CHP...
       k_ic_PEM k_fix_PEM k_var_PEM L_PEMFC W_PEMFC v_H2_max M_Hydro...
       k_ic_AWE k_fix_AWE k_var_AWE L_AWE W_AWE...
       k_ic_P2G k_fix_P2G k_var_P2G L_P2G yita_P2G lamda_me Mv_CH4...
       k_ic_TES k_fix_TES k_var_TES L_TES Tau_TES gama_TES W_TES...
       k_ic_THS k_fix_THS k_var_THS L_THS Tau_THS yita_THS gama_THS W_THS R_g_air T_compre p_compre p_THS k_air G_H2...
       k_ic_SHS k_fix_SHS k_var_SHS L_SHS Tau_SHS yita_SHS gama_SHS W_SHS p_SHS...
       Power_output_PV_unit k_ic_PV k_fix_PV k_var_PV L_PV...
       Power_output_WT_unit k_ic_WT k_fix_WT k_var_WT L_WT...
       k_ic_TTS k_fix_TTS k_var_TTS L_TTS Tau_TTS yita_TTS gama_TTS W_TTS A_TTS T_max_TTS T_min_TTS h_TTS cof_save_TTS...
       k_ic_STS k_fix_STS k_var_STS L_STS Tau_STS yita_STS gama_STS T_ae_TS W_STS A_STS T_max_STS T_min_STS h_STS...
       Day_number td th
%% 文章参数设置
Day_number = 4; %每个典型日所含的日数
td = ceil(366/Day_number);
th = Day_number * 24;
Power_Load_D1 = xlsread( 'Load.xlsx','O3:O26'); %典型日1电需求
Power_Load_D2 = xlsread( 'Load.xlsx','P3:P26'); %典型日2电需求
Power_Load_D3 = xlsread( 'Load.xlsx','Q3:Q26'); %典型日2电需求
Power_Load_D4 = xlsread( 'Load.xlsx','R3:R26'); %典型日2电需求

Hot_Load_D1 = xlsread( 'Load.xlsx','T3:T26');   %典型日1热需求
Hot_Load_D2 = xlsread( 'Load.xlsx','U3:U26');   %典型日2热需求
Hot_Load_D3 = xlsread( 'Load.xlsx','V3:V26');   %典型日2热需求
Hot_Load_D4 = xlsread( 'Load.xlsx','W3:W26');   %典型日2热需求
Power_Load = [Power_Load_D1;Power_Load_D2;Power_Load_D3;Power_Load_D4];
Hot_Load = [Hot_Load_D1;Hot_Load_D2;Hot_Load_D3;Hot_Load_D4];

k_Power = xlsread( 'Load.xlsx','C30:C53')*1000/6.36; % 分时电价 $/MWh
c_buy =0.5810 ;%外电网碳排放因子，t/Mwh  %《企业温室气体排放核算方法与报告指南 发电设施》（环办气候〔2021〕9号）
k_c = 11/6.36; %碳税 11/6.36$/吨
p_invest = 0.08; %利率为8%
price_sell = xlsread( 'Load.xlsx','D30:D30')'*1000/6.36; % 分时电价 $/MWh

% CHP系统
k_gas = 3.23 / 6.36; %3.23/6.36$每立方米天然气
c_0 = 11.537;   %燃气轮机煤耗标准系数,t/h
c_1 = 0.2705;   %燃气轮机煤耗标准系数,t/(MW*h)
c_2 = 4.1 * power(10,-2); %燃气轮机煤耗标准系数,t/(MW*h)
c_3 = 1.71 * power(10,-4); %燃气轮机煤耗标准系数,t/(MW^2*h)
c_4 = 5.13 * power(10,-5); %燃气轮机煤耗标准系数,t/(MW^2*h)
c_5 = 3.85 * power(10,-6); %燃气轮机煤耗标准系数,t/(MW^2*h)
M_coal = 29.3076 * (10^3); %煤低热值,MJ/t
M_gas  = 35.88;  %天然气低热值，MJ/m3
cm = 0.448;     %背压运行时的电功率和热功率的弹性系数
cv_1  = 0.23;
cv_2  = 0;
K = 81.01;
k_ic_CHP = 2067.1 * (10^3); % CHP投资成本 $/MW
k_fix_CHP = 20 * (10^3); % CHP年固定成本 $/MW年
k_var_CHP = 30; % CHP年单位运营可变成本 $/Mwh
L_CHP = 20; %寿命 20年
W_CHP = 357; %一台CHP的额定容量为357MW
M_v_ch4 = 22.4 * power(10,-3); %CH4的摩尔体积，m3/mol
M_q_co2 = 44 * power(10,-6); %CO2的摩尔质量 t/mol
H_max = 323; %CHP热出力最大值
H_0 = 154;%CHP背压热出力最小值
P_min = 150; %CHP电出力最小值
P_max = 357; %CHP电出力最大值
S_sc = 22.3 * M_coal / M_gas * k_gas; %启停成本 $,应耗22.3吨煤，转换为天然气，再转换为价格
T_on_min = 7; %CHP最少运行时间7小时
T_off_min = 7; %CHP最少停机时间7小时
P_up_CHP = 80; %CHP爬坡速率
P_down_CHP = 80; %CHP退坡速率
P_on_CHP = 150; %CHP启动时增加的爬坡速率
P_off_CHP = 501.7040; %CHP停机的功率下降速率
% PEMFC系统
i_L = 1.6;               %极限电流密度               A/cm2
A = 200;                 %质子交换膜的有效面积       单位为cm2
N = 900;                  %堆内串联的燃料电池数量    单位为片
G_H2 = 2.02 * power(10,-3);%氢气的摩尔质量          单位为Kg/mol
F = 96485;               %法拉第常数，              单位位C/mol    1C=1A*1s
v_H2_max = ( i_L * A * (N * G_H2) / ( 2 * F) ) * ( 3.6 * 22.4 / G_H2 ) * 0.99999 ; %最大耗氢速率 m3/h        √
M_Hydro = 10.779; %MJ/m3 氢气低热值
k_ic_PEM = 100 * (10^3); %PEMFC投资成本 $/MW
k_fix_PEM = 5  * (10^3); %PEMFC年固定成本 $/MW年
k_var_PEM = 0; %PEMFC年运行可变单位成本$/MWh
L_PEMFC = 10 ; %PEMFC寿命 10年               
W_PEMFC = 0.206586451721958; %每个PEMFC的额定容量 0.206586451721958MW  

% AWE系统
k_ic_AWE = 1490.3 * ( 10 ^ 3 ); %AWE投资成本 $/MW
k_fix_AWE = 0;                 %AWE年固定成本 $/MW年
k_var_AWE = 0.01  * ( 10 ^ 3 ); % AWE年运行可变单位成本 $/MWh
L_AWE = 30;  %AWE寿命30年
W_AWE = 0.176889402889443; %每个AWE的额定容量为 0.176889402889443 MW

% P2G系统
k_ic_P2G = 1750 * ( 10 ^ 3 ); %P2G投资成本 $/MW
k_fix_P2G = 10 * ( 10 ^ 3); %P2G年固定成本 $/MW年
k_var_P2G = 0; %P2G年运行可变单位成本 $/MWh
L_P2G = 25; %P2G寿命25年
yita_P2G = 0.7; %电制气效率
lamda_me = 4.6 * power( 10, -5 ); %甲烷化反应放热系数, MWh/mol
Mv_CH4 = 22.4; %天然气的摩尔体积,L/mol

%TES系统
k_ic_TES = 52.16 * 10^3; %SHS投资成本 $/MW
k_fix_TES = 0;
k_var_TES = 0.01 * ( 10 ^ 3 );
L_TES = 10;
Tau_TES = 0.1;
gama_TES = 0.04/100;
W_TES = 1.536/1000; % 单个锂电池1.536kwh

% TTS
k_ic_TTS = 26.08 * ( 10 ^ 3 ); %TTS投资成本 $/MW
k_fix_TTS = 0; %TTS年固定成本 $/MW年
k_var_TTS = 0.01 * ( 10 ^ 3 ); %TTS年运行可变单位成本 $/MWh
L_TTS = 25; %TTS寿命25年
Tau_TTS = 0.2;   %TTS供热最大速率系数
yita_TTS = 0.8;  %TTS输入输出热效率系数
gama_TTS = 0.08/100; %TTS的热量自然损耗系数
% 短期储热罐物理参数
ro = 971.8 ; %储能介质流体密度（水密度） kg/m3
c = 1.167 / 1000 ; %水定容比热容 Kwh/(kg K)
R = 0.45; %罐体底圆半径 m
H = 1.1846; %罐体高 m
A_TTS = 2 * pi * R * H; % 罐身侧面积 m^2
T_max_TTS = 95 + 273.15; %罐体最高温度 95°C， K
T_min_TTS = 65 + 273.15; %罐体最低温度 65°C， K
h_TTS = 2.688; %罐体外表面总对流换热系数 W/(m2 K)
V_TTS = pi * R^2 * H; %罐体积 m3
cof_save_TTS = 0.95; %保温层保温效率
W_TTS = ro * c * V_TTS * (T_max_TTS - T_min_TTS) /1000; %最大储热量 Mwh
T_ae_TS = 20 + 273.15; % 热储(包括TTS和STS)的环境温度 K

%THS系统
k_ic_THS = 15 * ( 10 ^ 3 ); %THS投资成本 $/MW
k_fix_THS = 0; %THS年固定成本 $/MW年
k_var_THS = 0.01 * ( 10 ^ 3 ); %THS年运行可变单位成本 $/MWh
L_THS = 25; %THS寿命25年
Tau_THS = 0.2;   %THS供氢最大速率系数
yita_THS = 0.95;  %THS输入输出氢气效率系数
gama_THS = 0.001/100; %THS的自然损耗系数
%临时性储氢罐物理参数
k_air = 1.4; %空气绝热系数
V_THS = 1; %储氢罐体积 m3
R_g_hyd = 8.314;  %氢气mol气体常量 J/(mol K)
p_THS=98*10^6; %设计压力 pa  98Mpa
T_in = 25 + 273.15; %储氢罐内部温度 K
W_THS = p_THS*V_THS/(R_g_hyd*T_in) * 22.4 /1000 / ( 1000 * 3.6 /M_Hydro); %单个临时储氢罐额定容量 MW
R_g_air = 287.1; %空气气体常数 J/(kg K)
T_compre = 20 + 273.15 ; %空气压缩机进口温度 K
p_compre = 101.325 * 1000 ; %进口压力 Pa
%Q_m = 1; % 1kg/h
%w = k_air * Q_m / (k_air-1) * R_g_air * T_compre * ( (P'/p_compre).^((k_air-1)/k_air) -1 )/3600 /10^6; % Mw

%SHS系统
k_ic_SHS = 0.91 * (10 ^ 3); %SHS投资成本 $/MW
k_fix_SHS = 0;  %SHS年固定成本 $/MW年
k_var_SHS = 0.01 * (10 ^ 3); %SHS运行可变单位成本 $/MWh
L_SHS = 20; %SHS寿命20年
Tau_SHS = 0.1; %SHS供氢最大速率系数
yita_SHS = 0.99;  %SHS输入输出氢气效率系数
gama_SHS = 0.0001/100; %SHS的自然损耗系数
% 季节性储氢罐的物理参数
p_SHS=22*10^6; %设计压力22Mpa
V_SHS=15; % 容积 15m3
W_SHS = p_SHS*V_SHS/(R_g_hyd*T_in) * 22.4 /1000 / ( 1000 * 3.6 /M_Hydro); %额定容量 MW

%STS系统
k_ic_STS = 0.53 * ( 10 ^ 3 ); %STS投资成本 $/MW
k_fix_STS = 0; %STS年固定成本 $/MW年 
k_var_STS = 0.0053 * ( 10 ^ 3 ); %STS年运行可变单位成本 $/MWh
L_STS = 25; %STS寿命25年
Tau_STS = 0.2;   %STS供热最大速率系数
yita_STS = 0.9557;  %STS输入输出热效率系数
gama_STS = 0.001/100; %STS的热量自然损耗系数
% 季节性储热罐参数
R = 13; %罐体底圆半径 m
H = 44; %罐体高 m
A_STS = 2 * pi * R * H; % 罐身侧面积 m^2
T_max_STS = 90 + 273.15; %罐体最高温度 90°C， K
T_min_STS = 35 + 273.15; %罐体最低温度 35°C， K
h_STS = 0.3; %对流换热系数 W/(m2 K)
V_STS = pi * R^2 * H; %罐体积 m3
W_STS = ro * c * V_STS * (T_max_STS - T_min_STS) /1000; %最大储热量 Mwh

% PV
Power_output_PV_unit_D1 = xlsread( 'Load.xlsx','I3:I26');  %1MW 光伏出力，单位MW
Power_output_PV_unit_D2 = xlsread( 'Load.xlsx','J3:J26');  %1MW 光伏出力，单位MW
Power_output_PV_unit_D3 = xlsread( 'Load.xlsx','K3:K26');  %1MW 光伏出力，单位MW
Power_output_PV_unit_D4 = xlsread( 'Load.xlsx','L3:L26');  %1MW 光伏出力，单位MW
Power_output_PV_unit = [Power_output_PV_unit_D1;Power_output_PV_unit_D2;Power_output_PV_unit_D3;Power_output_PV_unit_D4];
k_ic_PV = 7.1 * ( 10 ^ 5 );  %PV投资成本 $/MW 
k_fix_PV = 2.956 * ( 10 ^ 4);    %PV年固定成本 $/MW年
k_var_PV = 0.012;  %PV运行可变单位成本 $/MWh
L_PV = 25; % PV寿命25年

% WT
Power_output_WT_unit_D1 = xlsread( 'Load.xlsx','C3:C26');  %1MW 风机出力，单位MW
Power_output_WT_unit_D2 = xlsread( 'Load.xlsx','D3:D26');  %1MW 风机出力，单位MW
Power_output_WT_unit_D3 = xlsread( 'Load.xlsx','E3:E26');  %1MW 风机出力，单位MW
Power_output_WT_unit_D4 = xlsread( 'Load.xlsx','F3:F26');  %1MW 风机出力，单位MW
Power_output_WT_unit = [Power_output_WT_unit_D1;Power_output_WT_unit_D2;Power_output_WT_unit_D3;Power_output_WT_unit_D4];
k_ic_WT = 1.4 * ( 10 ^ 6 );  %WT投资成本 $/MW 
k_fix_WT = 4 * ( 10 ^ 4);    %WT年固定成本 $/MW年
k_var_WT = 0.017;  %WT运行可变单位成本 $/MWh
L_WT = 25; % WT寿命25年

end

