disp("Hello, World!")

function a = wavedn(f, N)
%
	M = length(f);
	n = round(log(M) / log(2));
	c = dcoeffs(N);
	clr = fliplr(c);
	for j = 1 : 2 : N - 1
		clr(j) = -clr(j);
	end
	a = f;
	for k = n : -1 : 1
		m = 2 ^ (k - 1);
		x = [0];
		y = [0];
		for i = 1 : 1 : m
			for j = 1 : 1 : N
				k(j) = 2 * i - 2 + j;
				while k(j) > 2 * m
					k(j) = k(j) - 2 * m;
				end
			end
			z = a(k);
			[mr, nc] = size(z);
			if nc > 1
				z = z.'
			end
			x(i) = x * z;
			y(i) = clr * z;
		end
		x = x / 2;
		y = y / 2;
		a(1 : m) = x;
		a(m + 1 : 2 * m) = y;
	end
end

function f = iwavedn(a, N)
%
	M = length(a);
	n = round(log(M) / log(2));
	c = dcoeffs(N);
	f(1) = a(1);
	for j = 1 : 1 : N / 2
		c1(1, j) = -c(2 * j);
		c1(2, j) = c(2 * j - 1);
		c2(1, j) = c(N - 2 * j + 1);
		c2(2, j) = c(N - 2 * j + 2);
	end
	for k = 1 : 1 : n
		m = 2 ^  (k - 1);
		for i = 1 : 1 : m
			for j = 1 : N / 2
				k(j) = m + i - N / 2 + j;
				while k(j) < m + 1
					k(j) = k(j) + m
				end
			end
			z = a(k);
			[mr, nc] = size(z);
			if nc > 1
				z = z.';
			end
			x(2 * i - 1 : 2 * i) = c1 * z;
			zz = f(k - m);
			[mr, nc] = size(zz);
			if nc > 1
				zz = zz.';
			end
			xx(2 * i - 1 : 2 * i) = c2 * zz;
		end
		f(1 : 2 * m) = x + xx;
	end
end

function A = displayn(f, N)
%
	M = length(f);
	n = round(log(M) / log(2));
	subplot(2 1 1)
	plot(f)
	grid
	title('signal f')
	a = wavedn(f, N);
	plot(a)
	grid
	title(['wavelet transform wavedn(f,', int2str(N), ')'])
	xlabel('PRESS TO CONTINUE . . . AND WAIT PLEASE')
	pause
	%
	b = zeros(1, M);
	b(1) = a(1);
	A(1, :) = iwavedn(b, N);
	for i = 2 : 1 : n + 1
		b = zeros(1 : M);
		b(2 ^ (i - 2) + 1 : 2 ^ (i - 1)) = a(2 ^ (i - 2) + 1 : 2 ^ (i - 1));
		A(i, :) = iwavedn(b, N);
	end
	%
	j = 0;
	for i = 1 : 1 : n + 1
		plot (A(i, :))
		gridtitle(['wavelet level ', int2str(i - 2)])
		j = j + 1;
		if j == 2
			xlabel('PRESS TO CONTINUE')
			pause
			j = j - 2;
		end
	end
	plot(sum(A))
	grid
	title('Reconstructed signal: all levels added')
	xlabel('PRESS TO CONTINUE')
	pause
	clg
	subplot(1 1 1)
end

function a = mapdn(f, N)
%
	M = length(f);
	n = round(log(M) / log(2));
	a = wavedn(f, N);
	b(1) = a(1);
	b(2) = a(2);
	for j = 1 : n - 1
		for k = 1 : 2 ^ j
			index = 2 ^ j + k  + N / 2 - 1;
			while index > 2 ^ (j + 1)
				index = index - 2 ^ j;
			end
			b(index) = a(2 ^ j + k);
		end
	end
	a = b;
	for j = 1 : 2 ^ (n - 1)
		A(1, j) = a(1);
	end
	for j = 2 : n + 1
		for k = 1 : 2 ^ (j - 2)
			for m = 1 : 2 ^ (n - j + 1)
				A(j, (k - 1) * 2 ^ (n - j + 1) + m) = a(2 ^ (j - 2) + k);
			end
		end
	end
	A = A .* conj(A);
end

function A = wave2dn(F, N)
%
	[M1, M2] = size(F);
	for k = 1 : M1
		B(k, :) = wavedn(F(k, :), N);
	end
	for j = 1 : M2
		A(:, j) = (wavedn(B(:, j).', N)).';
	end
end

function F = iwave2dn(A, N)
%
	[M1, M2] = size(A);
	for k = 1 : M1
		B(k, :) = iwavedn(A(k, :), N);
	end
	for j = 1 : M2
		F(:, j) = (iwavedn(B(:, j).', N)).';
	end
end

function c = dcoeffs(N)
%
	if N == 2
		c(1) = 1;
		c(2) = 1;
	end
	if N == 4
		c(1) = (1 + sqrt(3)) / 4;
		c(2) = (3 + sqrt(3)) / 4;
		c(3) = (3 - sqrt(3)) / 4;
		c(4) = (1 - sqrt(3)) / 4;
	end
	%
	if N == 6
		s = sqrt(5 + 2 * sqrt(10));
		c(1) = (1 + sqrt(10) + s) / 16;
		c(2) = (5 + sqrt(10) + 3 * s) / 16;
		c(3) = (5 - sqrt(10) + s) / 8;
		c(4) = (5 - sqrt(10) - s) / 8;
		c(5) = (5 + sqrt(10) - 3 * s) / 16;
		c(6) = (1 + sqrt(10) - s) / 16;
	end
	%
	if N == 8
		c(1) = 0.325803428051;
		c(2) = 1.010945715092;
		c(3) = 0.892200138246;
		c(4) = -0.039575026236;
		c(5) = -0.264507167369;
		c(6) = 0.043616300475;
		c(7) = 0.046503601071;
		c(8) = -0.014986989330;
	end
	%
	if N == 10
		c(1) = 0.226418982583;
		c(2) = 0.853943542705;
		c(3) = 1.024326944260;
		c(4) = 0.195766961347;
		c(5) = -0.342656715382;
		c(6) = -0.045601131884;
		c(7) = 0.109702658642;
		c(8) = -0.008826800109;
		c(9) = -0.017791870102;
		c(10) = 0.004717427938;
	end
	%
	if N == 12
		c(1) = 0.157742432003;
		c(2) = 0.699503814075;
		c(3) = 1.062263759882;
		c(4) = 0.445831322930;
		c(5) = -0.319986598891;
		c(6) = -0.183518064060;
		c(7) = 0.137888092974;
		c(8) = 0.038923209708;
		c(9) = -0.044663748331;
		c(10) = 0.000783251152;
		c(11) = 0.006756062363;		
		c(12) = -0.001523533805;
	end
	%
	if N == 14
		c(1) = 0.110099430746;
		c(2) = 0.560791283626;
		c(3) = 1.031148491636;
		c(4) = 0.664372482211;
		c(5) = -0.203513822463;
		c(6) = -0.316835011281;
		c(7) = 0.100846465010;
		c(8) = 0.114003445160;
		c(9) = -0.053782452590;
		c(10) = -0.023439941565;
		c(11) = 0.017749792379;
		c(12) = 0.000607514996;
		c(13) = -0.002547904718;
		c(14) = 0.000500226853;		
	end
	%
	if N == 16
		c(1) = 0.076955622108;
		c(2) = 0.442467247152;
		c(3) = 0.955486150427;
		c(4) = 0.827816532422;
		c(5) = -0.022385735333;
		c(6) = -0.401658632782;
		c(7) = 0.000668194093;
		c(8) = 0.182076356847;
		c(9) = -0.024563901046;
		c(10) = -0.062350206651;
		c(11) = 0.019772159296;
		c(12) = 0.012368844819;
		c(13) = -0.006887719256;
		c(14) = -0.000554004548;
		c(15) = 0.000955229711;
		c(16) = -0.000166137261;
	end
	%
	if N == 18
		c(1) = 0.053850349589;
		c(2) = 0.344834303815;
		c(3) = 0.855349064359;
		c(4) = 0.929545714366;
		c(5) = 0.188369549506;
		c(6) = -0.414751761802;
		c(7) = -0.136953549025;
		c(8) = 0.210068342279;
		c(9) = 0.043452675461;
		c(10) = -0.095647264120;
		c(11) = 0.000354892813;
		c(12) = 0.031624165853;
		c(13) = -0.006679620227;
		c(14) = -0.006054960574;
		c(15) = 0.002612967280;
		c(16) = 0.000325814672;
		c(17) = -0.000356329759;
		c(18) = 0.000055645514;
	end
	%
	if N == 20
		c(1) = 0.037717157593;
		c(2) = 0.266122182794;
		c(3) = 0.745575071487;
		c(4) = 0.973628110734;
		c(5) = 0.397637741770;
		c(6) = -0.353336201794;
		c(7) = -0.277109878720;
		c(8) = 0.180127448534;
		c(9) = 0.131602987102;
		c(10) = -0.100966571196;
		c(11) = -0.041659248088;
		c(12) = 0.046969814097;
		c(13) = 0.005100436968;
		c(14) = -0.015179002335;
		c(15) = 0.001973325365;
		c(16) = 0.002817686590;		
		c(17) = -0.000969947840;
		c(18) = -0.000164709006;
		c(19) = 0.000132354366;
		c(20) = -0.000018758416;
	end
end
