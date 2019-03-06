clear;close all
load babble%speech noise
load white%white noise
load leopard%cockpit noise
load factory1%factory noise
noise_list=[ white babble factory1  leopard ];
noise_list=resample(noise_list,16000,19980);%making sampling rates for signal and noise same.

snr_array=[inf 50 40 30 20 10];%SNR values to consider
SAN=zeros(length(snr_array),4);%accuracy : true positive rate
FPR=zeros(length(snr_array),4);%false positive rate
SAN2=SAN;FPR2=FPR;
clip=zeros(length(snr_array),4);%false positive rate
t_array=[4610:4620 1675:1680];
len1=zeros(length(snr_array),4);len_all=0;len_true=0;
len12=len1;
clip2=clip;
for t=t_array%loop over all signals
    t
    [x_orig f]=audioread(strcat('data/raw/train/timit_train',num2str(t,'%05d'),'.wav'));
    vad_truth=load(strcat('data/raw/train/timit_train',num2str(t,'%05d'),'.mat'));%groundtruth for VAD
    M=.03*f;%30ms frames
%     if(size(x_orig,2)==2)%convert stereo to mono
%     x_orig=(x_orig(:,1)+x_orig(:,2))/2;
%     end
    l=length(x_orig);
     for i=1:4%loop over 4 types of noise signals
        noise_unscaled=noise_list(1:l,i);%reduce to length of x_orig
        noise_energy=norm(noise_unscaled);%rms of noise
        x_energy=norm(x_orig(find(vad_truth.y_label==1)));%rms of speech

        for j=1:length(snr_array)
            snr=snr_array(j);
            noise=noise_unscaled*(x_energy/noise_energy)*10^(-snr/20);%SNR=20log(x_en/noise_en)
            x=noise+x_orig;
            
            VAD=method1(x,M);%Actual detection
            VAD2=method2(x,M);
            VAD=run_length(VAD);%run length algorithm
            VAD2=run_length(VAD2);
            vad_series=repelem(VAD,M);%convert decisions on frames to decisions on time series
            vad_series=vad_series(1:l);%limit to length of signal
            vad_series2=repelem(VAD2,M);%convert decisions on frames to decisions on time series
            vad_series2=vad_series2(1:l);      
%             figure;
%            b= plot((0:(length(vad_truth.y_label)-1))/f,vad_truth.y_label,'g');hold on;
%             a=plot((0:(length(vad_series)-1))/f,vad_series);
%             plot((0:(length(x)-1))/f,x/max(x));
%             set(a,'LineWidth',1.75)
%             set(b,'LineWidth',1.75)
%             legend('groundtruth','algorithm')
%             title(strcat('Method 1, SNR=',num2str(snr)));xlabel('time(sec)');ylabel('x[n]');

            ind1=find(vad_truth.y_label==1);
            ind0=find(vad_truth.y_label==0);
            SAN(j,i)=[SAN(j,i)+ mean(vad_series(ind1)==0)];%True positive rate
            FPR(j,i)=[FPR(j,i)+ mean(vad_series(ind0)==1)];%False Positive rate
            SAN2(j,i)=[SAN2(j,i)+ mean(vad_series2(ind1)==0)];%True positive rate
            FPR2(j,i)=[FPR2(j,i)+ mean(vad_series2(ind0)==1)];%False Positive rate
            
            len1(j,i)=len1(j,i)+length(find(vad_series==1));
            len12(j,i)=len12(j,i)+length(find(vad_series2==1));
            if (snr==inf)
%                 ind1_rel=find(vad_truth.y_label==1);
                ind1_rel=find(vad_series==1);
                ind1_rel2=find(vad_series2==1);
            end
            clip(j,i)=clip(j,i)+mean(vad_series(ind1_rel)==0);
            clip2(j,i)=clip2(j,i)+mean(vad_series2(ind1_rel2)==0);
        end
     end
     len_all=len_all+l;len_true=len_true+length(ind1);
end
SAN=SAN/length(t_array);SAN2=SAN2/length(t_array);
FPR=FPR/length(t_array);FPR2=FPR2/length(t_array);
clip=clip/length(t_array);clip2=clip2/length(t_array);
%  
subplot(1,2,1);
a=plot(snr_array(2:end),100*clip(2:end,:));set(a,'LineWidth',1.75);hold on
legend('  BG speech noise','  white noise','  cockpit noise','  factory noise');xlabel('SNR');ylabel('Clipping%');title('Clipping : Method1');
subplot(1,2,2);
a=plot(snr_array(2:end),100*clip2(2:end,:));set(a,'LineWidth',1.75);hold on
legend('  BG speech noise','  white noise','  cockpit noise','  factory noise');xlabel('SNR');ylabel('Clipping%');title('Clipping : Method2');
figure;

subplot(1,2,1);
a=plot(snr_array(2:end),100*len1(2:end,:)/len_all);set(a,'LineWidth',1.75);hold on;a=plot(snr_array(2:end),ones(1,5)*100*len_true/len_all);set(a,'LineWidth',1.75);
legend('  BG speech noise','  white noise','  cockpit noise','  factory noise', 'Groundtruth');xlabel('SNR');ylabel('%Activity');title('%Activity: Method1');
subplot(1,2,2);
a=plot(snr_array(2:end),100*len12(2:end,:)/len_all);set(a,'LineWidth',1.75);hold on;a=plot(snr_array(2:end),ones(1,5)*100*len_true/len_all);set(a,'LineWidth',1.75);
legend('  BG speech noise','  white noise','  cockpit noise','  factory noise', 'Groundtruth');xlabel('SNR');ylabel('%Activity');title('%Activity : Method2');
figure;

subplot(1,2,1);
a=plot(snr_array(2:end),100*SAN(2:end,:));set(a,'LineWidth',1.75);hold on
legend('  BG speech noise','  white noise','  cockpit noise','  factory noise');xlabel('SNR');ylabel('SAN%');title('Speech as Noise : Method1');
subplot(1,2,2);
a=plot(snr_array(2:end),100*SAN2(2:end,:));set(a,'LineWidth',1.75);hold on
legend('  BG speech noise','  white noise','  cockpit noise','  factory noise');xlabel('SNR');ylabel('SAN%');title('Speech as Noise : Method2');
figure;

subplot(1,2,1);
a=plot(snr_array(2:end),100*FPR(2:end,:));set(a,'LineWidth',1.75);
legend('  BG speech noise','  white noise','  cockpit noise','  factory noise');xlabel('SNR');ylabel('NAS %');title('Noise as Speech : Method1');
subplot(1,2,2);
a=plot(snr_array(2:end),100*FPR2(2:end,:));set(a,'LineWidth',1.75);
legend('  BG speech noise','  white noise','  cockpit noise','  factory noise');xlabel('SNR');ylabel('NAS %');title('Noise as Speech : Method2');
