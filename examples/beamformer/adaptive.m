% Complex Adaptive Joint Process Algorithms

% Example notation
% h_k(n, i)
% h_k = zeros(p + 2, N)' --> zeros(i-count + i-offset, n-count)'
% h_k(-1 + 3, 0 + 2) --> h_k(n-index + n-offset, i-index + i-offset)

%% JCLMS (Joint Complex Gradient Transversal Filter)

clear

% Constants (function input parameters)

SAMPLE_FREQUENCY = 1024;
SAMPLE_LENGTH = 4 * 1024;
FILTER_ORDER = 16;
ALPHA = 0.01;

% Input signal

fs = SAMPLE_FREQUENCY;
t = (0 : SAMPLE_LENGTH - 1)' / fs; % Time
s = exp(1j * 2 * pi * 50 * t); % Desired signal
noise = 0.5 * (randn(size(t)) + 1j * randn(size(t)));
x = s + noise; % Input signal
d = s; % Desired signal

p = FILTER_ORDER + 1;
N = length(x);

% Filter variables

alpha_JCLMS = ALPHA;
%mu = (2 * alpha_JCLMS) / ((p + 1) * E_e0(0));

E_e0 = 0; % Minimum forward prediction error

e_dp = []; % Error

h_k = []; % Filter coefficients
%a_ik = [] % Forward prediction (filter) coefficients
%b_ik = [] % Backward prediction (filter) coefficients

% INITIALIZATION

h_k = zeros(p, 2)';
T = conv(x(1 : p), conj(flipud(x(1 : p)))); % Autocorrelation of signal
epsilon_JCLMS = T(0 + 1);
E_e0 = epsilon_JCLMS * ones(1, 2)';
e_dp = zeros(1, 2)';
err = [];
y = [];

% TIME UPDATE

for n = 1 : 1 : N
	if n > p
		xx = x(n - p + 1 : n)';
		dd = d(n - p + 1 : n)';
	else
		xx = [zeros(p - n, 1); x(1 : n)]';
		dd = [zeros(p - n, 1); x(1 : n)]';
	end
	h_k(1 + 1, :) = h_k(0 + 1, :) - 2 * alpha_JCLMS / ((p - 1 + 1) * E_e0(0 + 1)) * e_dp(0 + 1) * conj(fliplr(xx));
	%for k = 1 : 1 : p
	%	h_k(1 + 1, k) = h_k(0 + 1, k) - 2 * alpha_JCLMS / ((p - 1 + 1) * E_e0(0 + 1)) * e_dp(0 + 1) * conj(xx(p - k + 1));
	%end
	e_dp(1 + 1) = d(n);
	for k = 1 : 1 : p
		e_dp(1 + 1) = e_dp(1 + 1) + h_k(1 + 1, k) * xx(p - k + 1);
	end
	E_e0(0 + 1) = E_e0(1 + 1);
	E_e0(1 + 1) = (1 - alpha_JCLMS) * E_e0(0 + 1) + alpha_JCLMS * abs(x(n)) ^ 2;
	h_k(0 + 1, :) = h_k(1 + 1, :);
	e_dp(0 + 1) = e_dp(1 + 1);
	err = [err; e_dp(0 + 1)];
	y = [y; -h_k(1 + 1, :) * flipud(xx')];
end

% Output

mse = mean(abs(err).^2);
fprintf('MSE = %f\n', mse);
figure_1 = figure;
plot(1 : N, abs(d), 1 : N, abs(y), 1 : N, abs(x));
legend('Desired Signal', 'Estimate', 'Input Signal');
title('JCLMS');

%% JCGL (Joint Complex Gradient Lattice)

clear

% Constants (function input parameters)

SAMPLE_FREQUENCY = 1024;
%SAMPLE_LENGTH = 1024;
SAMLE_LENGTH = 18;
FILTER_ORDER = 16;
ALPHA = 0.01;

% Input signal

fs = SAMPLE_FREQUENCY;
t = (0 : SAMPLE_LENGTH - 1)' / fs; % Time
s = exp(1j * 2 * pi * 50 * t); % Desired signal
noise = 0.5 * (randn(size(t)) + 1j * randn(size(t)));
x = s + noise; % Input signal
d = s; % Desired signal

p = FILTER_ORDER;
N = length(x);

% Filter variables

alpha_JCGL = ALPHA;

% INITIALIZATION

E_di = 0; % Minimum average squared error
E_ei = 0; % Minimum forward prediction error
E_ri = 0; % Minimum backward prediction error
delta_ei = 0; % Forward (prediction) discrepancy
delta_ri = 0; % Backward (prediction) discrepancy
K_ei = 0; % Forward weighting factor (reflection coefficient / partial correlation coefficient)
K_ri = 0; % Backward weighting factor (reflection coefficient / partial correlation coefficient)
K_di = 0; % Weighting factor

e_i = []; % i-th order forward prediction error sequence
r_i = []; % i-th ortder backward prediction error sequence
e_di = []; % Error

a_ik = []; % Forward prediction (filter) coefficients
b_ik = []; % Backward prediction (filter) coefficients

T = conv(x(1 : p), conj(flipud(x(1 : p)))); % Autocorrelation of signal
E_e0 = T;
epsilon_JCGL = E_e0(0 + 1);

%K_i = zeros(p, N + 2)';
K_i = zeros(p + 1, 2)'; % n - 1, n
%E_ri = epsilon_JCGL * ones(p, N + 2)';
E_ri = epsilon_JCGL * ones(p + 2, 3)'; % n - 2, n - 1, n
%E_ei = epsilon_JCGL * ones(p, N + 2)';
E_ei = epsilon_JCGL * ones(p + 2, 2)'; % n - 1, n
e_i = zeros(p + 2, 2)';
r_i = zeros(p + 2, 3)';
K_di = zeros(p + 1, 2)';
e_di = zeros(p + 2, 2)';
a_ik = zeros(p + 2);
b_ik = zeros(p + 2);

err = [];
y = [];

for n = 1 : 1 : N
	% TIME UPDATE
	e_i(0 + 2, 0 + 2) = x(n);
	r_i(0 + 3, 0 + 2) = x(n);
	e_di(0 + 2, -1 + 2) = d(n);
	
	% ORDER UPDATE
	for i = 0 : 1 : p
		temporary_factor = e_i(-1 + 2, i + 2) .* conj(r_i(-2 + 3, i - 1 + 2));
		temporary_factor = temporary_factor + conj(r_i(-1 + 3, i + 2)) .* e_i(-1 + 2, i - 1 + 2);
		temporary_factor = abs(temporary_factor);
		K_i(0 + 2, i + 1) = K_i(-1 + 2, i + 1) - 2 * alpha_JCGL / (E_ri(-2 + 3, i - 1 + 2) + E_ei(-1 + 2, i - 1 + 2)) * temporary_factor;
		if i ~= 0
			e_i(0 + 2, i + 2) = e_i(0 + 2, i - 1 + 2) + K_i(0 + 2, i + 1) * r_i(-1 + 3, i - 1 + 2);
			r_i(0 + 3, i + 2) = r_i(-1 + 3, i - 1 + 2) + conj(K_i(0 + 2, i + 1)) * e_i(0 + 2, i - 1 + 2);
			E_ri(-1 + 3, i - 1 + 2) = (1 - alpha_JCGL) * E_ri(-2 + 3, i - 1 + 2) + alpha_JCGL * abs(r_i(-1 + 3, i - 1 + 2))^2;
			E_ei(0 + 2, i - 1 + 2) = (1 - alpha_JCGL) * E_ei(-1 + 2, i - 1 + 2) + alpha_JCGL * abs(e_i(0 + 2, i - 1 + 2))^2;
		end
		K_di(0 + 2, i + 1) = K_di(-1 + 2, i + 1) - 2 * alpha_JCGL / (E_ri(-1 + 3, i + 2)) * e_di(-1 + 2, i + 2) * conj(r_i(-1 + 3, i - 1 + 2));
		e_di(0 + 2, i + 2) = e_di(0 + 2, i - 1 + 2) + K_di(0 + 2, i + 1) * r_i(0 + 2, i + 1);
		
		% PREDICTORS
		for k = 0 : 1 : p
			a_ik(i + 2, i + 2) = K_i(0 + 2, i + 1); % Move this outside k-loop
			if k >= 1 && k <= i - 1
				a_ik(i + 2, k + 2) = a_ik(i - 1 + 2, k + 2) + K_i(0 + 2, i + 1) * conj(a_ik(i - k + 2, i - 1 + 2));
			end
		end
		for k = 0 : 1 : p
			b_ik(i + 2, k + 2) = conj(a_ik(i + 2, p - k + 2));
		end
	end
	% Cache old values
	K_i(-1 + 2, :) = K_i(0 + 2, :);
	K_di(-1 + 2, :) = K_di(0 + 2, :);
	r_i(-2 + 3, :) = r_i(-1 + 3, :);
	r_i(-1 + 3, :) = r_i(0 + 3, :);
	e_i(-1 + 2, :) = e_i(0 + 2, :);
	e_di(-1 + 2, :) = e_di(0 + 2, :);
	E_ri(-2 + 3, :) = E_ri(-1 + 3, :);
	E_ri(-1 + 3, :) = E_ri(0 + 3, :);
	E_ei(-1 + 2, :) = E_ei(0 + 2, :);
	err = [err; e_di(0 + 2, p + 2)];
	diagonal_aik = diag(a_ik);
	y = [y; -diagonal_aik(0 + 2, p + 2)' * r_i(0 + 3, 0 + 2 : p + 2)'];
end

% Output

mse = mean(abs(err).^2);
fprintf('MSE = %f\n', mse);
figure_2 = figure;
plot(1 : N, abs(d), 1 : N, abs(y), 1 : N, abs(x));
legend('Desired Signal', 'Estimate', 'Input Signal');
title('JCGL');

%% JCLSL (Joint Complex Least Squares Lattice)

clear

% Constants (function input parameters)

SAMPLE_FREQUENCY = 1024;
SAMPLE_LENGTH = 1024;
FILTER_ORDER = 16;
ALPHA = 0.01;
EPSILON = 0.001;

% Input signal

fs = SAMPLE_FREQUENCY;
t = (0 : SAMPLE_LENGTH - 1)' / fs; % Time
s = exp(1j * 2 * pi * 50 * t); % Desired signal
noise = 0.5 * (randn(size(t)) + 1j * randn(size(t)));
x = s + noise; % Input signal
d = s; % Desired signal

p = FILTER_ORDER;
N = length(x);

% Filter variables

gamma_i = []; % Gain factor
epsilon_JCLSL = EPSILON;
alpha_JCLSL = ALPHA;

E_di = 0; % Minimum average squared error
E_ei = 0; % Minimum forward prediction error
E_ri = 0; % Minimum backward prediction error
delta_ei = 0; % Forward (prediction) discrepancy
delta_ri = 0; % Backward (prediction) discrepancy
K_ei = 0; % Forward weighting factor (reflection coefficient / partial correlation coefficient)
K_ri = 0; % Backward weighting factor (reflection coefficient / partial correlation coefficient)
K_di = 0; % Weighting factor

e_i = []; % i-th order forward prediction error sequence
r_i = []; % i-th ortder backward prediction error sequence
e_di = []; % Error

a_ik = []; % Forward prediction (filter) coefficients
b_ik = []; % Backward prediction (filter) coefficients

% Initialization

K_ei = zeros(p + 1, 1)'; % n
K_ri = zeros(p + 1, 1)'; % n
E_ri = epsilon_JCLSL * ones(p + 2, 3)'; % n - 2, n - 1, n
E_ei = epsilon_JCLSL * ones(p + 2, 2)'; % n - 1, n
e_i = zeros(p + 2, 2)';
r_i = zeros(p + 2, 3)';
K_di = zeros(p + 1, 2)';
e_di = zeros(p + 2, 2)';
a_ik = zeros(p + 2);
b_ik = zeros(p + 2);
gamma_i = zeros(p + 2, 2)';
Delta_i = zeros(p + 1, 2)';

for n = 1 : 1 : N
	% Time update
	e_i(0 + 2, 0 + 2) = x(n);
	r_i(0 + 2, 0 + 3) = x(n);
	E_ri(0 + 2, 0 + 3) = (1 - alpha_JCLSL);
	E_ei(0 + 2, 0 + 2) = E_ri(0 + 2, 0 + 3);
	gamma_i(0 + 2, -1 + 2) = 0;
	
	% Order update
	for i = 0 : 1 : p
		% Lattice
		if i ~= 0
			deltaTerm = e_i(0 + 2, -1 + 2) * conj(r_i(-1 + 3, -1 + 2)) / (1 - gamma_i(-1 + 2, -2 + 3));
			Delta_i(0 + 2, i + 1) = (1 - alpha_JCLSL) * Delta_i(-1 + 2, 0 + 1);
			Delta_i(0 + 2, i + 1) = Delta_i(0 + 2, i + 1) - deltaTerm;
			K_ei(0 + 1, 0 + 1) = conj(Delta_i(0 + 2, 0 + 1)) / E_ei(0 + 2, -1 + 2);
			K_ri(0 + 1, 0 + 1) = Delta_i(0 + 2, 0 + 1) / E_ri(-1 + 2, -1 + 2);
		end
	end
end

