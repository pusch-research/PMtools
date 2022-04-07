function [mi,ma] = minmax( A )
  Amin = min(A,[],2);
  Amax = max(A,[],2);

  if nargout==1
    mi=[Amin Amax];
  elseif nargout==2
    mi=Amin;
    ma=Amax;
  end
end