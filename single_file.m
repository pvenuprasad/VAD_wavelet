clear;close all

t=4610;%choose audio signal;
[x f]=audioread(strcat('data/raw/train/timit_train',num2str(t,'%05d'),'.wav'));
vad_truth=load(strcat('data/raw/train/timit_train',num2str(t,'%05d'),'.mat'));%groundtruth for VAD
M=.03*f;%30ms frames
%     if(size(x_orig,2)==2)%convert stereo to mono
%     x_orig=(x_orig(:,1)+x_orig(:,2))/2;
%     end
x=x+rand(length(x),1)*.001;
l=length(x);
VAD=method1(x,M);%Actual detection
VAD=run_length(VAD);%run length algorithm
vad_series=repelem(VAD,M);%convert decisions on frames to decisions on time series
vad_series=vad_series(1:l);%limit to length of signal

figure;
% b=plot(vad_truth.y_label,'g');hold on;
plot((1:length(x))/f,x/max(x),'r');hold on;
% a=plot((1:length(vad_series))/f,vad_series);
xlabel('time in seconds');ylabel('x[n]');
% set(a,'LineWidth',1.75)
% set(b,'LineWidth',1.75)
% legend('groundtruth','algorithm')

           