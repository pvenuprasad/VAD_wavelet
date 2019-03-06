function y= run_length(x)
    n_state=8;
    l=length(x);
    y=zeros(l,1);
    state=1;
    for i=1:l
        if (ismember(state,1:n_state/2-1))
            if(x(i)==1)
                state=state+1;
                y(i)=0;
            else
                state=1;
                y(i)=0; 
            end
        elseif ((state==n_state/2))
            if(x(i)==1)
                state=state+1;
                y(i)=1;y(i-1)=1;y(i-2)=1;
            else
                state=1;
                y(i)=0;
            end
        elseif (ismember(state,(n_state/2+1:n_state-1)))
            if(x(i)==0)
                state=state+1;
                y(i)=1;
            else
                state=n_state/2+1;
                y(i)=1; 
            end
        else
            if(x(i)==0)
                state=1;
                y(i)=0;y(i-1)=0;y(i-2)=0;
            else
                state=n_state/2+1;
                y(i)=1;
            end
        end
    end
end
                
            
            

