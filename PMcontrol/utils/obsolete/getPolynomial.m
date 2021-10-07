function Tuv=getPolynomial(type,n,x)

switch lower(type(1:min(4,end)))
    
    case 'cheb' % chebyshev
        % from http://stackoverflow.com/questions/11993722/need-to-fit-polynomial-using-chebyshev-polynomial-basis
        if numel(x)==1 && mod(x,1)==0
            x = linspace(-1,1,x);
        else
            x = ((x-min(x))-(max(x)-x))/(max(x)-min(x)); 
        end
        x=x(:);

        Tuv(:,1) = ones(numel(x),1);
        if n > 1
           Tuv(:,2) = x;
        end
        if n > 2
          for k = 3:n
             Tuv(:,k) = 2*x.*Tuv(:,k-1) - Tuv(:,k-2);  %% recurrence relation
          end
        end
        
    case 'bern' % bernstein
        
        if numel(x)==1 && mod(x,1)==0
            x = linspace(0,1,x);
        else
            x = (1+((x-min(x))-(max(x)-x))/(max(x)-min(x)))/2; 
        end

        Tuv=bernsteinMatrix(n-1,x);
        
    otherwise
        
        error('not implemented.')
        
end