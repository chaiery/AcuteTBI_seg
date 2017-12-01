function [phi,pin,pout] = Tryphon_NB(I, phi, iter, dt, alpha, flag_approx)
%Coded by:  Romeil Sandhu
%Function:  This function implements the active contour flow for the energy
%           presented in "A New Distribution Metric for Medical Imaging."
%           The framework can also be used to implement other energies.
%
%Note:      Re-distance: Done with sussman every 10 iterations.  
%           Narrowband:  Around the -2<0<2 region.  
%           Display:     Done every 10 iterations.
%
%Thanks:    Special thanks to Shawn Lankton, Samuel Dambreville, and James 
%           Malcolm for their input and help in constucting this framework

%get image size dimensions
[dimR, dimC] = size(I);

%set intensity range (need for delta function
h = 1:1:256;  

%start the iteration process
for s = 1:iter
    
    %find appropriate narrowband
    index = find(phi < 2 & phi > -2);  

    %index for rows/cols
    [nrow, ncol] = ind2sub(size(phi), index);
    
    %initalize memory
    K   = zeros(size(index));
    d_T = zeros(size(index));

    %set inside/outside curve points
    in_pt    = find(phi < 0) ;
    out_pt   = find(phi > 0) ;

    %compute probability densit function
    pin =  create_pdf(I(in_pt))';
    pout = create_pdf(I(out_pt))';
     
    %area computation
    Ain  = numel(in_pt); 
    Aout = numel(out_pt);
    
    %compute "global" energy terms
    T    = log((pin+eps)./(pout+eps));
    D    = sqrt(mean(T.^2) - mean(T).^2);
    
    %cycle through narrowband points
    for i = 1:numel(index)
        
        %index properly
        nr = nrow(i);  nc = ncol(i); ind = index(i);
        
        %boundary conditions
        if((nr+1) >= nrow) nr = dimR-1; end
        if((nr-1) <= 0)    nr = 2;    end
        if((nc+1) >= ncol) nc = dimC-1; end
        if((nc-1) <= 0)    nc = 2;    end
        
        %derivatives for kappa
        phi_x =  phi(nr, nc+1) - phi(nr, nc-1);
        phi_y =  phi(nr+1, nc) - phi(nr-1, nc);
        phi_xx = phi(nr, nc+1) - 2*phi(nr, nc) + phi(nr,nc-1);
        phi_yy = phi(nr+1, nc) - 2*phi(nr, nc) + phi(nr-1,nc);
        phi_xy = -0.25*phi(nr-1,nc-1)-0.25*phi(nr+1,nc+1)+0.25*phi(nr-1,nc+1)+0.25*phi(nr+1,nc-1);
                
        %curvature gradient flow
        norm = sqrt(phi_x.^2 + phi_y.^2);
        K(i) = ((phi_x.^2.*phi_yy + phi_y.^2.*phi_xx - 2*phi_x.*phi_y.*phi_xy)./...
                (phi_x.^2 + phi_y.^2 +eps).^(3/2)).*norm;       

        %energy to Minimize      
        delta  = Dirac2(h - (I(ind)+1), 1);
        delta  = delta/(sum(delta));
        
        %compute curve energy
        G = (1/Ain - 1/Aout) - delta.*(1./(Ain*pin+eps) + 1./(Aout*pout+eps));
        d_T(i) = (1./D) * (mean(T.*G)-mean(T)*mean(G))*norm;
        if(flag_approx); d_T(i) = .25*sign(d_T(i)); end;
    end
    
    %combine energy terms
    if(flag_approx); alpha = .125; end;
    e = (d_T)+alpha*K;
    
    %find max energy
    max_e = max(abs(e));
    
    %compute update of level set function
    phi(index) = phi(index) + (dt/(max_e+eps))*(e);
    
    %redistance every 10 iterations, might want to change!
    if(mod(s,10) == 0); phi = sussman(phi, .5); end
    
    %display every 10 iterations
    %if(mod(s,10) == 0);imshow(uint8(I),'InitialMagnification',200); fat_contour(phi); disp(['iteration: ' num2str(s)]); drawnow; end;
       
    end
end


