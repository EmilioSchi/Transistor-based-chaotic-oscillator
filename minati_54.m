clc; clear all; close all

%% Opzioni della simulazione
% Step size
dt = 5e-8;
% durata simulazione
secondi = 30;
% iterazioni
steps = secondi / dt;

%% Dimensione componenti
Vdd = 5;
R = 226;
L1 = 150;
L2 = 68;
L3 = 15;
C = 470e-6;
CPar2 = 10e-8;
CParUpp = 50e-6;
CParLow = 1e-8;

%% Condizioni iniziali
Vc = 0.76;
Vr = 4.16;
Il1 = 2e-4;
Il2 = -2e-4;
Il3 = 2e-4;
Ic = 1E-4;
Ir = 0.0195;
Ie1 = 0;
Ic1 = 0;
Ie2 = 0;
Ic2 = 0;

Vbc1 = 0;
Vbc2 = -1e-4;
Vbe1 = 0;
Vbe2 = 0.76;

%% Capacita' parassite
VcPar2 = 0.76;
VcParUpp = 0;
VcParLow = -0.01;

%% Allocazione statica
save_step = 10000; count = 0; j = 0;
x = NaN(floor(steps / save_step), 1);
y = NaN(floor(steps / save_step), 1);
z = NaN(floor(steps / save_step), 1);
xy = NaN(floor(steps / save_step), 1);

t = NaN(floor(steps / save_step), 1);
fprintf('[+] Start Simulation\n')
%% Iterazioni
for i = 1 : steps

	Vr = Vdd - VcPar2;
	Ir = Vr / R;
%	Vr = Vdd - Vl3 + Vl2 - Vc;
%	Ir = Vr / R;

	Vbc1 = -VcParUpp;
	Vbe1 = VcParLow;
	Vbc2 = -VcParLow - VcParUpp + Vc - VcPar2;
	Vbe2 = -VcParLow - VcParUpp + Vc;

	%% Nuove correnti BJT
	% Su LTspice
	% Vbe2 > 0 sempre (Vedere per credere)
	[Ie1, Ic1] = NPN(Vbe1, Vbc1);
	[Ie2, Ic2] = NPN(Vbe2, Vbc2);

	%% EQUAZIONI
	dVc_dt		= (Il3 - Ie2 + Ic2) / C;
	dVcPar2_dt	= (Ir - Ic2 - Il3) / CPar2;
	dVcParUpp_dt	= (-Il2 - Ic1 - Il1 - Ic2 + Ie2 - Il3) / CParUpp;
	dVcParLow_dt	= (-Ie1 - Il1 - Ic2 + Ie2) / CParLow;
	dIl1_dt		= (VcParUpp + VcParLow) / L1;
	dIl2_dt		= (VcParUpp) / L2;
	dIl3_dt		= (VcPar2 - Vc + VcParUpp) / L3;

	%% Aggiorno valori
	Vc		= Vc + dVc_dt * dt;
	Il1		= Il1 + dIl1_dt * dt;
	Il2		= Il2 + dIl2_dt * dt;
	Il3		= Il3 + dIl3_dt * dt;
	VcPar2		= VcPar2 + dVcPar2_dt * dt;
	VcParUpp	= VcParUpp + dVcParUpp_dt * dt;
	VcParLow	= VcParLow + dVcParLow_dt * dt;

	%% Conservo dati
	if count == save_step
		count = 0;
		j = j + 1;
		x(j) = Vdd - Vr;
		y(j) = Vbe2;
		z(j) = Vc;
        xy(j) = Vbc1;
		t(j) = i * dt;
	end
	count = count + 1;
end

%% PLOT
delay = 150;
figure(1)
subplot(6, 1, 1); plot(t, x, 'k'); title('V_{dd} - V_R');
subplot(6, 1, 2); plot(t, y, 'k'); title('V_{BE2}');
subplot(6, 1, 3); plot(t, xy, 'k'); title('V_{BC1}');
subplot(6, 1, 4); plot(t, z, 'k'); title('V_{C}');
subplot(6, 1, 5:6); plot(z(1:end-delay,1),z(delay+1:end,1), 'k');
grid on
ylabel('v(t + \theta) [V]'); xlabel('v(t) [V]'); title('Attrattore');
drawnow;


figure(3)
NFFT = 2^14; %NFFT-point DFT      
Z = fft(z, NFFT); %compute DFT using FFT        
nVals = 0 : 100 - 1; %DFT Sample points       
plot(nVals,abs(real(Z(1:100))), 'k');
grid on
axis([0 inf 0 400])
title('FFT');        
xlabel('Sample points (N-point DFT)')        
ylabel('DFT Values');

for delay = 50 : 1 : 150
    figure(2); plot(z(1:end-delay,1),z(delay+1:end,1), 'k'); grid on; ylabel('v(t + \theta) [V]'); xlabel('v(t) [V]'); title('Attrattore V_{C}');
	annotation('textbox',...
		[0.17 0.2 0.15 0.05],...
		'String',{['\theta = ' num2str(delay)]},...
		'FontSize',12,...
		'FontName','Arial',...
		'BackgroundColor',[1 1 1],...
		'Color',[0 0 0]);
    pause(0.2);
end

for delay = 50 : 1 : 100
    figure(4)
    plot(xy(1:end-delay,1),xy(delay+1:end,1), 'k');
    grid on; ylabel('v(t + \theta) [V]'); xlabel('v(t) [V]'); title('Attrattore V_{BC1}');	annotation('textbox',...
        [0.17 0.2 0.15 0.05],...
        'String',{['\theta = ' num2str(delay)]},...
        'FontSize',12,...
        'FontName','Arial',...
        'BackgroundColor',[1 1 1],...
        'Color',[0 0 0]);
    pause(0.2);
end

function [Ie, Ic] = NPN(Vbe, Vbc)
	% Saturation current
	Is = 10e-15;
	% Thermal Voltage kT/q
	Vt = 0.0259;
	VTH2 = 0.1;
	VTH1 = 0.1;

	% Gain
	betaF = 145.76; % Forward
	betaR = 0.1001; % Reverse
	alphaF = betaF / (betaF + 1);
	alphaR = betaR / (betaR + 1);

    if Vbe > 0
        Ibe = (Is / betaF) * (exp((Vbe - VTH2) / Vt));
    else
        Ibe = 0;
    end

    if Vbc > 0
        Ibc = (Is / betaR) * (exp((Vbc - VTH1) / Vt));
    else
        Ibc = 0;
    end
    Ice = Is * (exp((Vbe - VTH2) / Vt) - exp((Vbc - VTH1) / Vt));

    Ic = Ice - Ibc;
    Ie = Ibe + Ice;
    
    % Check
    if isinf(Ic) || isinf(Ie) || isnan(Ic) || isnan(Ie)
        fprintf('[!] BJT: NaN or Inf\n');
        return;
    end
end
