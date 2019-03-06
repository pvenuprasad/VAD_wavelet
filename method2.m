function VAD=method2(x, M)
P = 2; % Subframe divider
alpha = 0.5;
filter = 'dB4'; % Filter for the wavelet transform
l = length(x);
k = 1;
L = 4; % Number of times to filter
T1 = 1e-10; % Threshold for silence flag
T2 = 1e-4;  % Threshold for stationary flag
T3 = 1e-5;  % Threshold for subframe background level flag
T4 = 1e-5;  % Threshold for background level flag
E = zeros(L+1,1); % Frame energy
E_pre=E;
B = E;   % Background level
B_pre = B;
Delta_pre = 0;  % Previous difference measure
e2 = zeros(P,1);  % Subframe energies of D2

% For hangover addition
burstconst = 3; % 3
burstcount = 0; % 0
hangconst = 5;  % 10
hangcount = -1; % -1
VAD=zeros(1,1);%array containing decision for each frame
while(k<=l-M)
    % Wavelet transform
    [A1,D1] = dwt(x(k:k+M),filter);
    [A2,D2] = dwt(A1,filter);
    [A3,D3] = dwt(A2,filter);
    [A4,D4] = dwt(A3,filter);
    % Energy Computation and Silence Detection
    E(1) = sum(D1.^2);
    E(2) = sum(D2.^2);
    E(3) = sum(D3.^2);
    E(4) = sum(D4.^2);
    E(5) = sum(A4.^2);
    Etot = sum(E);
    f_sil = Etot < T1; % Flag for silence
    % Stationarity detection
    Delta = sqrt(sum(E(1:L)-E_pre(1:L))^2/L); % difference measure
    f_stat = (Delta<T2) & (Delta_pre<T2);   % flag for stationarity
    % Background-Noise Detection
    for i=[2,L]
        if(B_pre(i) > E(i))
            B(i) = E(i);
        else
            B(i) = alpha*B_pre(i)+(1-alpha)*E(i);
        end
    end
    
    % Subframe energy computation for D2
    % Assumes P=2 for now.
    [a1_1,~] = dwt(x(k:k+M/P),filter);
    [~,d2_1] = dwt(a1_1,filter);
    [a1_2,~] = dwt(x(k+M/P:k+M),filter);
    [~,d2_2] = dwt(a1_2,filter);
    e2(1) = sum(d2_1.^2);
    e2(2) = sum(d2_2.^2);
    f_B2 = ((e2(1)-B(2)) < T3) & ((e2(2)-B(2)) < T3); % Flag for fine background level
    f_BL = (E(L)-B(L)) < T4;    % Flag for course background level
    
    flag = ~(f_sil | (f_B2 & f_BL & f_stat));
    
    % VAD Hangover addition
    if (flag)
        burstcount = burstcount + 1;
    else
        burstcount = 0;
    end
    if(burstcount > burstconst)
        hangcount = hangconst;
        burstcount = burstconst;
    end
    vadflag = (flag | (hangcount >=0));
    VAD = [VAD;vadflag];
    if(hangcount >= 0)
        hangcount = hangcount - 1;
    end
    
    E_pre = E;
    Delta_pre = Delta;
    B_pre = B;
    k = k + M;
end

