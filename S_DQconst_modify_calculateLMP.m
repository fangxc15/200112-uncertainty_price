 if DQconstmodify == 1
       LMP.Pjointmax = 0;

       LMP.Pjointmin = 0;

    for l = 1:nl
        LMP.Pjointmax = LMP.Pjointmax +  result.w.Lmin(l).value(np+nd+np+nd+2) * result.dualLmin(l);
        LMP.Pjointmax = LMP.Pjointmax +  result.w.Lmax(l).value(np+nd+np+nd+2) * result.dualLmax(l);
    end
    for g = 1:ng
        LMP.Pjointmax = LMP.Pjointmax +  result.w.Gmin(g).value(np+nd+np+nd+2) * result.dualGmin(g);
        LMP.Pjointmax = LMP.Pjointmax +  result.w.Gmax(g).value(np+nd+np+nd+2) * result.dualGmax(g);
    end
    
    for l = 1:nl
        LMP.Pjointmin = LMP.Pjointmin +  result.w.Lmin(l).value(np+nd+np+nd+1) * result.dualLmin(l);
        LMP.Pjointmin = LMP.Pjointmin +  result.w.Lmax(l).value(np+nd+np+nd+1) * result.dualLmax(l);

    end
    for g = 1:ng
        LMP.Pjointmin = LMP.Pjointmin +  result.w.Gmin(g).value(np+nd+np+nd+1) * result.dualGmin(g);
        LMP.Pjointmin = LMP.Pjointmin +  result.w.Gmax(g).value(np+nd+np+nd+1) * result.dualGmax(g);
    end
end