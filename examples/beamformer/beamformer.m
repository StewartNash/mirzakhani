ELEVATION = -60 : 0.1 : 60;
AZIMUTH = -60 : 0.1 : 60;
[THETA, PHI] = meshgrid(ELEVATION, AZIMUTH);
N = 16;
M = 16;
k = 2 * pi;
dx = 0.25;
dy = 0.25;
%AF = 10 * log10(abs(arrayfactor(k, M, N, dx, dy, deg2rad(THETA), deg2rad(PHI))));
AF = abs(arrayfactor(k, M, N, dx, dy, deg2rad(THETA), deg2rad(PHI)));
AF = AF / max(AF(:));
AF = 10 * log10(AF);
mySurface = surf(PHI, THETA, AF);
mySurface.EdgeColor = 'none';
xlabel('Azimuth (degrees)');
ylabel('Elevation (degrees)');
title('16-by-16 Array, lambda/4 Spacing');

function output = arrayfactor(k,...
	M,...
	N,...
	dx,...
	dy,...
	elevation,...
	azimuth,...
	excitations,...
	beta_x,...
	beta_y)
	if nargin < 8
		excitations = [];
		beta_x = 0;
		beta_y = 0;
	elseif nargin < 10
		beta_x = 0;
		beta_y = 0;
	end
	if isempty(excitations)
		I = ones(M, N);
	else
		I = excitations;
	end
	theta = elevation;
	phi = azimuth;
	by = beta_y;
	bx = beta_x;
	output = zeros(size(theta));
	for n = 1 : 1 : N
		nfactor = exp(1j * (n - 1) * (k * dy * sin(theta) .* sin(phi) + by));
		for m = 1 : 1 : M
			mfactor = I(m, n) * exp(1j * (m - 1) * (k * dx * sin(theta) .* cos(phi) + bx));
			output = output + nfactor .* mfactor;
		end
	end
end

