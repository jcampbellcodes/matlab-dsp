[x, Fs] = audioread ('input.wav');
[h] = audioread('ir.wav');

% pad signal with zeros so output has exactly enough room for reverb tail
x = vertcat(x, zeros(size(h) -1));

%FIR filter whose coefficients are channel 1 of impulse response
y1 = filter(h(:,1), 1, x);
%FIR filter whose coefficients are channel 2 of impulse response
y2 = filter(h(:,2), 1, x);

y= [y1,y2];

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

%audiowrite('conv.wav', y, Fs);

sound (y, Fs);