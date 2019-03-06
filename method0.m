function greater= method0(x,M)
l=length(x);
if (mod(l,M)>0)
    n=ceil(l/M);
    x=[x;zeros(n*M-l,1)];
end
E=[];
for i=0:floor((length(x)-M)/M)
    E=[E mean((x(M*i+1:M*i+M)).^2)];
end
E_med=mean(E);
E_med;
cutoff=0.0007/0.02;
E_cut=cutoff*mean(E);
greater=E>E_cut;