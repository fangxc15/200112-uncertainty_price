[~,matB] = F_generateDCB(nnode);
matB = imag(matB);
deltaB = diag(1./mpc.branch(:,4));
MB = full(sparse(mpc.branch(:,1),1:nl,ones(1,nl),nnode,nl) + sparse(mpc.branch(:,2),1:nl,-ones(1,nl),nnode,nl));
PQPVset = union(find(mpc.bus(:,2) == 1),find(mpc.bus(:,2) == 2));
GSDFtest0 = deltaB * MB(PQPVset,:)' * inv(matB(PQPVset,PQPVset)) * eye(nnode-1);
GSDFtest = zeros(nl,nb);
GSDFtest(:,PQPVset)  = GSDFtest0;


