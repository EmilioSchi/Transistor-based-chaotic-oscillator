clc; clear all; close all

% Step size
dt = 5e-8;
% duration
seconds = 30;
% iteration
steps = floor(seconds / dt);

% Component value
Vcc = 5;
R = 226;
L1 = 150;
L2 = 68;
L3 = 15;
C = 470e-6;
C1 = 50e-6;
C2 = 1e-8;
C3 = 10e-8;

% Initial condition
Vc = 0.76;
V1 = 50e-6;
V2 = 1e-8;
V3 = 10e-8;
Il1 = 2e-4;
Il2 = -2e-4;
Il3 = 2e-4;
Vbc1 = 0;
Vbc2 = -1e-4;
Vbe1 = 0;
Vbe2 = 0.76;

% Static Allocation
save_step = 10000; count = 0; i = 0;
x  = NaN(floor(steps / save_step), 1);
y  = NaN(floor(steps / save_step), 1);
z  = NaN(floor(steps / save_step), 1);
xy = NaN(floor(steps / save_step), 1);

fprintf('[+] Start Simulation \n')
% Solve the system
for iteration = 1 : steps - 1
	% Euler Method
	Vc_new = Vc + C^(-1) * (g(Vbe2, Vbc2) - f(Vbe2, Vbc2)  + Il3) * dt;
	V1_new = V1 + C1^(-1) * (f(Vbe2, Vbc2) - g(Vbe2, Vbc2) - g(Vbe1, Vbc1) - Il1 - Il2 - Il3) * dt;
	V2_new = V2 + C2^(-1) * (f(Vbe2, Vbc2) - g(Vbe2, Vbc2) - f(Vbe1, Vbc1) - Il1) * dt;
	V3_new = V3 + C3^(-1) * ((Vcc - V3) / R - g(Vbe2, Vbc2) - Il3) * dt;
	Il1_new = Il1 + L1^(-1) * (V1 + V2) * dt;
	Il2_new = Il2 + L2^(-1) * (V1) * dt;
	Il3_new = Il3 + L3^(-1) * (V3 + V1 - Vc) * dt;

	% NPN update
	Vbe1 = V2_new;
	Vbc1 = -V1_new;
	Vbe2 = Vc_new - V1_new - V2_new;
	Vbc2 = Vc_new - V1_new - V2_new - V3_new;

	% Store
	if count == save_step
		count = 0;
		i = i + 1;
		x(i) = Vbe2 - Vbc2;
		y(i) = Vbe2;
		z(i) = Vc;
		xy(i) = Vbc1;
	end
	count = count + 1;

	% Update state
	Vc  = Vc_new;
	V1  = V1_new;
	V2  = V2_new;
	V3  = V3_new;
	Il1 = Il1_new;
	Il2 = Il2_new;
	Il3 = Il3_new;
end

fprintf('[+] End Simulation \n');
% PLOT
figure(1);
t = (1 : floor(steps / save_step)) * dt;
subplot(4, 1, 1); plot(t, x, 'k'); title('V_{dd} - V_R');
subplot(4, 1, 2); plot(t, y, 'k'); title('V_{BE2}');
subplot(4, 1, 3); plot(t, xy, 'k'); title('V_{BC1}');
subplot(4, 1, 4); plot(t, z, 'k'); title('V_{C}');
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
    figure(2); plot(z(1:end-delay,1),z(delay+1:end,1), 'k'); grid on; ylabel('v(t + \theta) [V]'); xlabel('v(t) [V]'); title('Attractor V_{C}');
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
    grid on; ylabel('v(t + \theta) [V]'); xlabel('v(t) [V]'); title('Attractor V_{BC1}');	annotation('textbox',...
        [0.17 0.2 0.15 0.05],...
        'String',{['\theta = ' num2str(delay)]},...
        'FontSize',12,...
        'FontName','Arial',...
        'BackgroundColor',[1 1 1],...
        'Color',[0 0 0]);
    pause(0.2);
end

% Nonlinear Function
function Ie = f(Vbe, Vbc)
Is = 10e-15; Vt = 0.0259; DROP = 0.1; betaF = 145.76; betaR = 0.1001;
if Vbe > 0
	Ie = (Is / betaF) * (exp((Vbe - DROP) / Vt)) + ...
		Is * (exp((Vbe - DROP) / Vt) - exp((Vbc - DROP) / Vt));
elseif Vbe <= 0
	Ie = Is * (exp((Vbe - DROP) / Vt) - exp((Vbc - DROP) / Vt));
else
	fprintf('[!] Error\n');
end
end

function Ic = g(Vbe, Vbc)
Is = 10e-15; Vt = 0.0259; DROP = 0.1; betaF = 145.76; betaR = 0.1001;
if Vbc > 0
	Ic = -(Is / betaR) * (exp((Vbc - DROP) / Vt)) + ...
		Is * (exp((Vbe - DROP) / Vt) - exp((Vbc - DROP) / Vt));
elseif Vbc <= 0
	Ic = Is * (exp((Vbe - DROP) / Vt) - exp((Vbc - DROP) / Vt));
else
	print('[!] Error\n')
end
end
