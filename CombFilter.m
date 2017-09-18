[x, Fs] = audioread ('input.wav');

y = x;

b1 = 0.49;
b0 = b1-1.0;

%compensate for first sample
for n = 2:length(x)
y(n) = b0*x(n) + b1*x(n-1);
end
y= y/max(max(abs(y))); % normalize max. amplitude to 1

subplot(211), plot(x); 
subplot(212), plot(y);

%audiowrite('hpf.wav', y, Fs);

sound (y, Fs);