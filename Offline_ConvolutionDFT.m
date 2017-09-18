[x, Fs] = audioread ('input.wav');
[h] = audioread('ir.wav');

% get length of FFT by finding length of convolution (N + M - 1)
% and rounding to next power of two for efficiency
nx = length(x);
nh = length(h);
nfft = 2^nextpow2(nx+nh-1);

x = vertcat(x, zeros(nfft - nx, 1));
h = vertcat(h, zeros(nfft - nh, 2));

X = fft(x);
H = fft(h);

Y = H .* X;
y = real(ifft(Y));

%wet/dry
for n = 1:size(x)
    y(n,1) = (y(n, 1)/4) + (10 * x(n, 1));
    y(n, 2) = (y(n, 2)/4) + (10 * x(n, 1));
end
%picking up extra output samples
%output will always be size(x) + size(h) - 1
for n = size(x):size(y)
    y(n,1) = (y(n, 1)/4);
    y(n, 2) = (y(n, 2)/4);
end

y= y/max(max(abs(y))); % normalize max. amplitude to 1

subplot(211), plot(x); 
subplot(212), plot(y);

sound (y, Fs);