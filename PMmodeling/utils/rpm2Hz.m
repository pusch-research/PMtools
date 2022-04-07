function Hz=rpm2Hz(rpm)

if nargin<1
    rpm=1;
end

Hz=rpm/60;