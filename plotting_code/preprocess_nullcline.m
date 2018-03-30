function [nullclinex, nullcliney] =  preprocess_nullcline(nullclinex, nullcliney)

[nullclinex_unique, uniqueIndecies] = unique(nullclinex);
nullcliney_unique = zeros(size(uniqueIndecies));
for i=1:size(uniqueIndecies)
    nullcliney_unique(i) = nullcliney(uniqueIndecies(i));
end

nullclinex=nullclinex_unique;
nullcliney=nullcliney_unique;
return;

end