%% JCLMS (Joint Complex Gradient Transversal Filter)

clear

% Constants (function input parameters)

SAMPLE_FREQUENCY = 1024;
SAMPLE_LENGTH = 1024;
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

alpha_JCLMS = ALPHA;
%mu = (2 * alpha_JCLMS) / ((p + 1) * E_e0(0));

E_e0 = 0; % Minimum forward prediction error

e_dp = []; % Error

h_k = []; % Filter coefficients
%a_ik = [] % Forward prediction (filter) coefficients
%b_ik = [] % Backward prediction (filter) coefficients

h_k = zeros(p + 1, 2)';
T = conv(x(1 : p), conj(flipud(x(1 : p)))); % Autocorrelation of signal
epsilon_JCLMS = T(0 + 1);
E_e0 = epsilon_JCLMS * ones(p + 1, 2)';
e_dp = zeros(p + 1, 2)';

for n = 1 : 1 : N
	if N - n >= p
		xx = x(n : n + p);
		dd = d(n : n + p);
	else
		xx = [x(n ; N); zeros(p - N + n, 1)];
		dd = [d(n ; N); zeros(p - N + n, 1)];
	end
	e_dp(0 + 1, :) = y + dd';
	E_e0(0 + 1, :) = E_e0(1 + 1, :);
	E_e0(1 + 1, :) = (1 - alpha_JCLMS) * E_e0(0 + 1, :) + alpha_JCLMS * abs(xx') .^2;
	h_k(0 + 1, :) = h_k(1 + 1, :);
end

% Output

mse = mean(abs(e_dp(1 + 1, :)).^2);
fprintf('MSE = %f\n', mse);

%% JCGL (Joint Complex Gradient Lattice)

clear

% Constants (function input parameters)

SAMPLE_FREQUENCY = 1024;
SAMPLE_LENGTH = 1024;
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
E_0 = T;
epsilon_JCGL = E_0(0 + 1);

%K_i = zeros(p, N + 2)';
K_i = zeros(p + 1, 2)'; % n - 1, n
%E_ri = epsilon_JCGL * ones(p, N + 2)';
E_ri = epsilon_JCGL * ones(p + 1, 3)'; % n - 2, n - 1, n
%E_ei = epsilon_JCGL * ones(p, N + 2)';
E_ei = epsilon_JCGL * ones(p + 1, 3)'; % n - 2, n - 1, n
e_i = zeros(p + 1, 1)';
r_i = zeros(p + 1, 2)';
K_di = zeros(p + 1, 1)';
e_di = zeros(p + 1, 1)';
a_ik = zeros(p + 1);
b_ik = zeros(p + 1);

for n = 1 + 2 : 1 : N + 1 + 2
	K_i(2, :) = K_i(2 - 1, :) - 2 * alpha_JCGL ./ (E_ri(3 - 2, :) + E_ei(2 - 1, :));
	%K_i(n, :) = K_i(n - 1, :) - 2 * alpha_JCGL ./ (E_ri(n - 2, :) + E_ei(n - 1, :));
	for i = 1 + 1 : 1 : p + 1
		e_i(i) = e_i(i - 1) + K_i(2, i) * r_i(2 - 1, i - 1);
		r_i(2, i) = r_i(2 - 1, i - 1) + conj(K_i(2, i - 1)) * e_i(i - 1);
		E_ri(3 - 1, i - 1) = (1 - alpha_JCGL) * E_ri(3 - 2, i - 1) + alpha_JCGL * abs(r_i(2 - 1, i - 1))^2;
		K_di(2, i) = K_di(2 - 1, i) - 2 * alpha_JCGL / (E_ri(2 - 1, i)) * e_di(2 - 1, i) * conj(r_i(2 - 1, i));
		e_di(i) = e_di(i - 1) + K_di(i) * r_i(2, i);
		for k = 1 : 1 : p
			a_ik(i, i) = K_i(2, i);
			if k < 1
				a_ik(i, k) = a_ik(i - 1, k) + K_i(2, i) * a_ik(i - k, i - 1);
			end
		end
		for k = 0 : 1 : p
			b_ik(k + 1) = conj(a_ik(i, p - k + 1));
		end
	end
end

% Output

mse = mean(abs(e_di).^2);

fprintf('MSE = %f\n', mse);

%% JCLSL (Joint Complex Least Squares Lattice)

clear

% Filter variables

gamma_i = []; % Gain factor
epsilon_JCLSL = 0.001;

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

	




