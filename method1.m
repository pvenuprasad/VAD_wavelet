
function VAD=method1(x,M)
alpha=1.8;beta=1.8;%parameters for algorithm
n_init=4;%number of initial frames considered as noise 
filter='dB3';% filter for wavelet transform
l=length(x);
k=1;%k has the starting index of the next frame
dw3=0;%noise 3rd detailed coeff
dw4=0;%noise 4th detailed coeff
while(k<n_init*M)%calculate dw3,dw4
    [A1,D1] = dwt(x(k:k+M),filter);
    [A2,D2] = dwt(A1,filter);
    [A3,D3] = dwt(A2,filter);
    [A4,D4] = dwt(A3,filter);
    dw3=dw3+(1/n_init)*rms(A3)^2;
    dw4=dw4+(1/n_init)*rms(A4)^2;
    k=k+M;
end
VAD=zeros(n_init,1);%array containing decision for each frame
while(k<=l)
    k;
    [A1,D1] = dwt(x(k:min(l,k+M)),filter);
    [A2,D2] = dwt(A1,filter);
    [A3,D3] = dwt(A2,filter);
    [A4,D4] = dwt(A3,filter);
    dy3=rms(A3)^2;
    dy4=rms(A4)^2;
    k=k+M;
    flag=((dy3+dy4)>(alpha*dw3+beta*dw4));
    VAD=[VAD;flag];
    if(flag==0)%no speech detected
        dw3=dy3;
        dw4=dy4;
    end
end