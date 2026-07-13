disp("Hello, World!")

%% Complex tone recovery - JCLMS

clear

fs = 1000;
t = (0 : 999)' / fs;
s = exp(1j * 2 * pi * 50 * t);
noise = 0.5 * (randn(size(t)) + 1j * randn(size(t)));

x = s + noise;
d = s;

M = 16;
mu = 0.01;

[y, e, w_hist] = jclms(x, d, M, mu);

mse = mean(abs(e).^2);

fprintf('MSE = %f\n', mse);

%% Adaptive noise cancellation - JCLMS

% Desired channel d(n) = s(n) + v(n)
% Reference channel x(n) = v_r(n) where v_r(n) is  correlated with the interference v(n)

clear

N = 5000;
s = exp(1j * 2 * pi * 0.05 * (0 : N - 1)).';
v = 0.5 * (randn(N, 1) + 1j * randn(N, 1));

d = s + v;
x = v + 0.1 * (randn(N, 1) + 1j * randn(N, 1));

[y, e, w_hist] = jclms(x, d, 16, 0.005);

% e contains interference-reduced signal

%% Object Oriented JCLMS

clear

filter = JCLMS(16, 0.01);

for n = 1 : length(x)
    [y(n), e(n)] = filter.update(x(n), d(n));
end

%% Adaptive predicction of a complex sinusoid - JCGL

clear

fs = 1000;
t = (0 : 999)' / fs;

x = exp(1j * 2 * pi * 50 * t);
x = x + 0.1 * (randn(size(x)) + 1j * randn(size(x)));

M = 8;
mu = 0.01;

[f, b, k_hist] = jcgl(x, M, mu);

prediction_error = f(end, :);

figure
plot(abs(prediction_error).^2)
xlabel('Sample')
ylabel('Prediction Error Power')
title('JCGL Prediction Error')
grid on

%% Spectral tracking - JCGL

clear

fs = 10240;
N = 8192;
n = (0 : N - 1).';

x = exp(1j * 2 * pi * 0.15 * n);
x(4097 : end) = exp(1j * 2 * pi * 0.10 * n(4097 : end));
x = x + 0.1 * (randn(N, 1) + 1j * randn(N, 1));

[f, b, k_hist] = jcgl(x, 10, 0.005);

e = f(end, :);

figure
spectrogram(e, 256, 200, 256, fs, 'centered')
title('JCGL Tracking Frequency Step')

%% System identification - JCLSL

rng(0)
N = 5000;

x = randn(N, 1) + 1j * randn(N, 1);
h = [1; 0.6 + 0.3j; -0.2 + 0.4j];
d = filter(h, 1, x);
M = 6;
lambda = 0.995;

[y, e, v_hist, k_hist] = jclsl(x, d, M, lambda);

figure
plot(10 * log10(abs(e).^2))
xlabel('Sample')
ylabel('Error Power (dB)')
title('JCLSL System Identification')
grid on

%% Adaptive line enhancement - JCLSL

clear

fs = 10240;
N = 8192;
n = (0 : N - 1).';
tone = exp(1j * 2 * pi * 0.12 * n);
noise = 0.5 * (randn(N, 1) + 1j * randn(N, 1));

x = tone + noise;
delay = 1;

d = [zeros(delay, 1); x(1 : end - delay)];

[y, e, v_hist, k_hist] = jclsl(x, d, 12, 0.995);

figure
spectrogram(y, 256, 220, 256, fs, 'centered')
title('JCLSL Output')

%% Frequency-step tracking - JCLSL

clear

fs = 10240;
N = 8192;
n = (0 : N - 1).';
x = exp(1j * 2 * pi * 0.15 * n);
x(N / 2 : end) = exp(1j * 2 * pi * 0.10 * n(N / 2 : end));
x = x + 0.1 * (randn(N, 1) + 1j * randn(N, 1));
d = x;

[y, e, v_hist, k_hist] = jclsl(x, d, 10, 0.995);

figure
spectrogram(e, 256, 220, 256, fs, 'centered')
title('JCLSL Tracking Error')

%% Functions

function [y,e,w_hist] = jclms(x,d,M,mu)
% JCLMS Joint Complex LMS Transversal Filter
%
% Inputs
%   x   - complex input signal
%   d   - complex desired signal
%   M   - filter length
%   mu  - LMS step size
%
% Outputs
%   y       - filter output
%   e       - error signal
%   w_hist  - coefficient history
%
% Example:
%   [y,e,w] = jclms(x,d,16,0.01);
	N = length(x);

	y = zeros(N,1);
	e = zeros(N,1);

	% coefficient vector
	w = zeros(M,1);

	% coefficient history
	w_hist = zeros(M,N);

	for n = M:N

		% input vector
		xvec = x(n:-1:n-M+1);

		% filter output
		y(n) = w' * conj(xvec);

		% error
		e(n) = d(n) - y(n);

		% coefficient update
		w = w + mu * xvec * conj(e(n));

		w_hist(:,n) = w;

	end
end

function [f,b,k_hist] = jcgl(x,M,mu)
% JCGL Joint Complex Gradient Lattice
%
% Inputs
%   x  - complex input sequence
%   M  - lattice order
%   mu - adaptation step size
%
% Outputs
%   f      - forward prediction errors
%   b      - backward prediction errors
%   k_hist - reflection coefficient history
%
	N = length(x);

	f = zeros(M+1,N);
	b = zeros(M+1,N);

	k = zeros(M,1);

	k_hist = zeros(M,N);

	for n = 1:N

		f(1,n) = x(n);
		b(1,n) = x(n);

		for m = 1:M

			if n == 1
				b_prev = 0;
			else
				b_prev = b(m,n-1);
			end

			f(m+1,n) = f(m,n) - k(m)*b_prev;

			b(m+1,n) = b_prev - conj(k(m))*f(m,n);

			k(m) = k(m) + mu*f(m+1,n)*conj(b(m+1,n));

		end

		k_hist(:,n) = k;

	end
end

function [y,e,v_hist,k_hist] = jclsl(x,d,M,lambda)
% JCLSL Joint Complex Least Squares Lattice
%
% Inputs:
%   x      Complex input
%   d      Desired signal
%   M      Lattice order
%   lambda Forgetting factor (0.95-1)
%
% Outputs:
%   y      Filter output
%   e      Estimation error
%   v_hist Ladder coefficient history
%   k_hist Reflection coefficient history
	N = length(x);

	% Reflection coefficients
	k = zeros(M,1);

	% Ladder coefficients
	v = zeros(M+1,1);

	% Inverse covariance matrices
	P = repmat({1e3},M+1,1);

	% Storage
	y = zeros(N,1);
	e = zeros(N,1);

	v_hist = zeros(M+1,N);
	k_hist = zeros(M,N);

	% Forward/backward errors
	f = zeros(M+1,1);
	b = zeros(M+1,1);

	for n = 1:N

		f(1) = x(n);
		b(1) = x(n);

		%-------------------------
		% Lattice section
		%-------------------------
		for m = 1:M

			f_old = f(m);

			f(m+1) = f(m) - k(m)*b(m);

			b(m+1) = b(m) - conj(k(m))*f_old;

			denom = lambda + abs(b(m))^2;

			k(m) = k(m) + ...
				(1/denom)*f(m+1)*conj(b(m));

		end

		%-------------------------
		% Ladder section
		%-------------------------
		phi = b;

		y(n) = v' * phi;

		e(n) = d(n) - y(n);

		for m = 1:(M+1)

			gain = P{m}*conj(phi(m)) / ...
				   (lambda + phi(m)'*P{m}*phi(m));

			v(m) = v(m) + gain*e(n);

			P{m} = (P{m} - gain*phi(m)'*P{m})/lambda;
		end

		v_hist(:,n) = v;
		k_hist(:,n) = k;

	end
end
