function mm = minmax( A )
  Amin = min(A,[],2);
  Amax = max(A,[],2);
  mm=[Amin Amax];
end