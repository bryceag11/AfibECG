%% LOAD
dsavage = load('Example\04015m_2.mat');
ecg = dsavage.val(1,:);
Fs=250;
t=1:length(ecg)/Fs;
N=length(ecg);
ax1 =subplot(2,2,1); 

plot(ecg);
title('Unfiltered NSR_2');
xlabel('time in ms'); ylabel('voltage in mV');
hold all;

%% STEP 1 FILTER
%{
[filtered_baseline,baseline]=ECG_Baseline_Removal(ecg,Fs, 1,0.5);
ax2= subplot (2,2,2);
plot(filtered_baseline);
title('Baseline Removal');
xlabel('time in ms'); ylabel('voltage in mV');
linkaxes([ax1, ax2], 'xy')
%}

[ecg_filtered_frq] = ECG_High_Low_Filter(ecg,Fs,6,12);
ecg_filtered_frq=Notch_Filter(ecg_filtered_frq,Fs,60,2);

Y = fft(ecg)/N;
f = Fs/2*linspace(0,1,N);
ax3= subplot(2,2,3);
plot(f,2*abs(Y(1:N))) 
title('FFT')

Y2 = fft(ecg)/N;
f2 = Fs/2*linspace(0,1,N);
%ax4= subplot(2,2,4);
%plot(f,2*abs(Y(1:N))) 
%title('FFT')

ax2 = subplot(2,2,2);
plot(ecg_filtered_frq(1:500)); hold on; plot(ecg_filtered_frq(126:155), 'Color', 'r');
title('Highpass, Lowpass, Bandstop NSR_2');
xlabel('time in ms'); ylabel('voltage in mV');


%{
[ecg_filtered_isoline,offset,~,~]=Isoline_Correction(ecg_filtered_frq);
ax4 = subplot (2,2,4);
plot(ecg_filtered_isoline);
linkaxes([ax1, ax2, ax3, ax4],'xy')

[FPT_MultiChannel,FPT_Cell]=Annotate_ECG_Multi(ecg_filtered_isoline,Fs);

% extract FPTs for Channel 1 (Lead I):
FPT_LeadI = FPT_Cell{3,1};

Pwave_samples = reshape(FPT_LeadI(:,1:3), [1,size(FPT_LeadI(:,1:3),1)*size(FPT_LeadI(:,1:3),2)]);
QRS_samples = reshape([FPT_LeadI(:,4),FPT_LeadI(:,6), FPT_LeadI(:,8)] , [1,size(FPT_LeadI(:,1:3),1)*size(FPT_LeadI(:,1:3),2)]);
Twave_samples = reshape(FPT_LeadI(:,10:12), [1,size(FPT_LeadI(:,10:12),1)*size(FPT_LeadI(:,10:12),2)]);

% visualize fiducial points
figure; 
plot(ecg_filtered_isoline(:,3));
hold on; 
scatter(Pwave_samples, ecg_filtered_isoline(Pwave_samples,3), 'g', 'filled');

title('Filtered ECG');
xlabel('samples'); ylabel('voltage');
legend({'ECG signal', 'P wave', 'QRS complex', 'T wave'});


%}

%{
Y = fft(ecg_filtered_frq)/N;
f = Fs/2*linspace(0,1,N);
ax3= subplot(2,2,3);
plot(f,2*abs(Y(1:N))) 
title('FFT Filtered')

Y = fft(ecg)/N;
f = Fs/2*linspace(0,1,N);
ax4= subplot(2,2,4);
plot(f,2*abs(Y(1:N))) 
title('FFT')
%}
%% STEP 2 EXTRACTION
%%lineFittingEventDetection
[~,locs_Rwave] = findpeaks(ecg_filtered_frq, 'MinPeakHeight', -0.5, 'MinPeakDistance', 200);
%%datam = merge(dat(1:250),dat(281:600),dat(651:1000));
%% STEP 3 MOVING AVERAGE
%{
[filtered_baseline,no]=ECG_Baseline_Removal(ecg,Fs,1,0.5);
ax3= subplot (2,2,3);
plot(filtered_baseline);
title('Baseline Removal');
xlabel('time in ms'); ylabel('voltage in mV');
linkaxes([ax1, ax2], 'xy')
%}

firstSample = 1;
lastSample = N;
d =pan_tompkin(ecg,Fs,1);


% physionet WFDB toolbox for Matlab - functions rdsamp(), rdann() 
% read samples, firstSample and lastSample are optional parameters
[signal, fs, tm] = rdsamp(ecg, firstSample, lastSample);
% read annotations 
[ann, anntype, subtype, chan, num, comments] = rdann('Example\04015m_2.atr', firstSample, lastSample);
% plots all channels
plot(signal)
hold on
% plots markers on annotation positions 'ann' as # of sample
% markers are adjusted to channel 1
plot(ann,signal(ann,1),'o');
% plots marker labels
text(ann,signal(ann,1), anntype);
hold off
%% Step 4 