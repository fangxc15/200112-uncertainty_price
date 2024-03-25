function success = F_fprintfarray(a)
    for aa = 1:length(a)
        atemp = a(aa);
        fprintf('%6.2f ',a(aa));
    end 
    fprintf('\n');
    success = 1;
end 