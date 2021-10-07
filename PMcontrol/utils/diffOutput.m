% differentiate output of dynamical system
function sys=diffOutput(sys)


if isa(sys,'ss')
    
    if any(sys.d(:))
        error('nonzero feedthrough, differentiation is not possible.');
    end
    
    sys.d=sys.c*sys.b;
    sys.c=sys.c*sys.a;
    
else
    
    sys=tf('s')*sys; 
    
end