function [q,eta,beta,dtlnbeta,params] = load_parameters(shape)
    
    % graphics and output
    params.fontsize = 18;
    params.basename = shape;
    params.rawname  = shape;
    params.figname  = shape;
    params.savedir  = '/simdesk/sandbox/emclaw/analysis/results/1D';
    params.save_raw = 1;
    % Setup q0, A: Ammplitude, sq: pulse width, qxoff: xoffset
    params.A     =  1.0;
    params.sq    =  2.0;
    params.qxoff = -5.0;

    q = @(x,params) params.A.*exp(-((x-params.qxoff).^2)./((params.sq).^2));

    % Material background and RIP eta = no + dn*f(x,t)
    params.no   = 1.50;
    params.dn   = 0.15;
    params.co   = 1.00;

    switch shape
        case 'cosine'
            params.lorentz = 0;
            params.s = 6.0;
            params.xoff = 47.0;
            params.num_cycles = 50.0;
            params.fomega = @(num_cycles) num_cycles*(params.s/(1.0/params.no))*pi;
            params.omega = params.fomega(params.num_cycles);
            params.rawname = [params.rawname,'_50'];
            params.figname = [params.figname,'_50'];
            eta = @(x,t,params) params.no + params.dn.*cos(params.omega*t)*...
                ((x>=params.xoff)*(x<=(params.xoff + params.s)));
            % beta = 1/eta
            beta = @(x,t,params) 1./(params.no + params.dn.*cos(params.omega*t)*...
                ((x>=params.xoff).*(x<=(params.xoff + params.s))));
            % dt[ln(beta)]
            dtlnbeta = @(x,t,params) params.dn.*params.omega.*sin(params.omega*t)*...
                ((x>=params.xoff).*(x<=(params.xoff + params.s)))./(params.no +...
                params.dn.*cos(params.omega*t).*((x>=params.xoff).*...
                (x<=(params.xoff + params.s)))) + 0.0;
        case 'gaussian'
            params.lorentz = 1;
            params.v = 0.55;
            params.s    = 5.0;
            params.xoff = 10.0;
            eta  = @(x,t,params) params.no + ...
                params.dn.*exp(-((x - params.v.*t - params.xoff).^2)./params.s.^2);
            % beta = 1/eta
            beta = @(x,t,params) 1./(params.no + ...
                params.dn.*exp(-((x - params.v.*t - params.xoff).^2)./params.s.^2));
            % dt[ln(beta)]
            dtlnbeta = @(x,t,params) (2.0.*params.dn.*params.v.*(params.v.*t - x + params.xoff))./...
                ((params.dn + exp(((params.v.*t - x + params.xoff).^2)./params.s.^2).*...
                params.no).*params.s.^2);
        case 'jump'
            params.lorentz = 1;
            params.v = 0.55;
            params.s = 5.0;
            params.xoff = 10.0;
            
            eta = @(x,t,params) params.no.*(x<(params.v.*t + params.xoff)) +...
                (params.no + (params.dn/params.s).*(x - params.v.*t - params.xoff)).*...
                ((x>=(params.v.*t + params.xoff)).*(x<(params.v.*t + params.s + params.xoff))) + ...
                (params.no + params.dn).*(x>=(params.v.*t + params.s + params.xoff));
            
            beta = @(x,t,params) 1.0/(params.no.*(x<(params.v.*t + params.xoff)) +...
                (params.no + (params.dn/params.s).*(x - params.v.*t - params.xoff)).*...
                ((x>=(params.v.*t + params.xoff)).*(x<(params.v.*t + params.s + params.xoff))) + ...
                (params.no + params.dn).*(x>=(params.v.*t + params.s + params.xoff)));
            
            dtlnbeta = @(x,t,params) 0.0.*(x<(params.v.*t+params.xoff)) +...
                (params.v./(x - params.v.*t - params.xoff)).*...
                ((x>=(params.v.*t + params.xoff)).*(x<(params.v.*t + params.s + params.xoff))) + ...
                0.0.*(x>=(params.v.*t + params.s + params.xoff));
    end
end