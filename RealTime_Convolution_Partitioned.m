% PRE-PROCESS
%--------------------------------------------------------
%impulse response length (filter pre-processing)


%%% Uniformly Partioned Convolution Reverb
%%% Partitioning of Impulse Response and Input Signal
%%% Transformed into DFTs, multiplied, accumulated,
%%% transformed back, and output




% input / output blocks: size L
% FFT and IFFT -> size 2 * L
L = 30000;

%P = 16; %num partitions

[h] = audioread('CCRMAStairwell.wav');
% number of filters, P, is length(h) / L
%h = vertcat(h, zeros(length(h) * 4,2));
%L = floor(length(h) / P);
P = floor(length(h)/L);
% subfilter size is 2 * L -> L samples and L zeros
H_slices = zeros(L * 2, P * 2);
twoL = 2 * L;

i = 0;
p = 1;

%
% PARTITION IMPULSE RESPONSE
%

while (i < P)
   
    % get time domain slice, zero pad it to L
    s_temp_L = vertcat(h((i*L)+1:((i+1)*L),1), zeros((L*2) - length(h((i*L)+1:((i+1)*L))),1));
    s_temp_R = vertcat(h((i*L)+1:((i+1)*L),2), zeros((L*2) - length(h((i*L)+1:((i+1)*L))),1));
    
    % save filter of that slice in the array
    
    H_slices(:,p) = fft(s_temp_L, L * 2);
    H_slices(:,p+1) = fft(s_temp_R, L * 2);
    
   i = i + 1; 
   p = p + 2;
end


% input pre-processing
fileReader = dsp.AudioFileReader('drum.wav', 'SamplesPerFrame', L);
[x, Fs] = audioread ('drum.wav');
deviceWriter = audioDeviceWriter();%('Device', 'SoundFlower (2ch)');

% buffer to save overlap in each iteration of the loop
% last M-1 samples are appended to the start of each block of x
% BEFORE the block's DFT is multiplied with H
OLAP = zeros(L, 1);
FDL = zeros(L * P * 2, 1);

% first in matlab --> 0 in normal programming languages...
curr_out = 1;

%--------------------------------------------------------

%output is size L of ym, OLAP becomes (ym(L:M-1), zeros(L)), and ym is
%added with OLAP

while (true)

    % input stage -- get L input samples, concatenate to previous L input
    % samples, get N size DFT
    x_r = fileReader();
    
    % OVERLAP SAVE -- MOVING INPUT SIGNAL WINDOW
    x_r_overlap = vertcat(OLAP, x_r);
    % iteration
    OLAP = x_r;
   

    %
    % MULTIPLICATION and FREQUENCY DELAY LINE
    %
 
    % multiplication stage, do for each channel:
    % create accumulation buffer, size L, all zeros
    
    % change --> there should be P accumulators
    
    Y_Accum_L = zeros(L * 2, 1);
    Y_Accum_R = zeros(L * 2, 1);
    
    % get DFT of X, size L 
    Xm = fft(x_r_overlap, L * 2);
    % delay FDL by L, place Xm in beginning
    FDL = delayseq(FDL, L);
    FDL = vertcat(Xm, zeros(length(FDL) - length(Xm), 1)) + FDL;
    
    iter = 0;
    p_iter = 1;
    
    curr_add = curr_out;
    
    fdl = Xm;
    Ym_iter_L = zeros(L, 1);
    Ym_iter_R = zeros(L, 1);
    % loop through H_slices, each size L
    % first L samples processed by FIR
    while (iter < ( 2 * P))
       % in each iteration, delay X by k samples

       % multiply appropriate slot of FDL with the current H_slice
       FDL_chunk = FDL((iter*L) + 1:((iter + 2)*(L)));
       Ym_iter_L = Xm .* H_slices(:,p_iter);
       Ym_iter_R = Xm .* H_slices(:,p_iter + 1);
       
       % accumulate with accumulation buffer
       
       Y_Accum_L = Y_Accum_L + Ym_iter_L;
       Y_Accum_R = Y_Accum_R + Ym_iter_R;
      
       iter = iter + 2; 
       p_iter = p_iter + 2; % stereo iterator
    end
    
    
    
    %
    % POST PROCESSING OUTPUT
    %
    % return to time domain
    ym_1 = real(ifft(Y_Accum_L));
    ym_2 = real(ifft(Y_Accum_R));
    
    % output stage -- keep last L samples of the output block
    % combine into a stereo signal, mix with dry signal
    ym_L = ((ym_1(L+1:length(ym_1)) / 10) + x_r * 2);
    ym_R = ((ym_2(L+1:length(ym_2)) / 10) + x_r * 2);
    ym = [ym_L, ym_R];
    
    %send to the output buffer
    deviceWriter(ym);
    
end

release(fileReader);
release(deviceWriter);