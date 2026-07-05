% JCLMS (Joint Complex Gradient Transversal Filter)

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
noise = 0.5 * (randn(size(t)) * 1j * randn(size(t)));
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


