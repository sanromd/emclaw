function [chars,sol,Q,X] = forward_problem(xi,ti,tf,q,beta,dtlnbeta,params,options)
% function [chars,sol] = forward_problem(xi,ti,tf,q,beta,dtlnbeta,params,options)
%
% Solve the forward problem for the characteristics and find q
    if params.inverse_problem
        xf = xi;
        if isfield(params,'xg')
            xg = params.xg
        else
            xg = xf - params.v.*tf
        end
        xi = zeros(np,1);
    end

    if params.summary_q
        % create array with Qi and Qf
        Q = zeros(np,2);
        X = Q;
    end

    for k=1:size(xi,1)
        disp(k)
        c = num2str(k);

        if params.inverse_problem
            fun = @(x) dcharacteristics(beta,x,xf(k,1),ti,tf,params,options);
            %   find the initial point
            xi(k,1) = fzero(fun,xg(k,1));
        end
        %   get the characteristic beginning at xi
        [chars.(['t',c]),chars.(['x',c])] = ode45(@(t,x) beta(x,t,params),[ti tf],xi(k,1),options);
        if params.lorentz
            sbeta  = params.v/params.co;
            gamma = 1.0/sqrt(1 - sbeta^2);
            chars.(['tp',c]) = gamma.*(chars.(['t',c]) - params.v.*chars.(['x',c])/(params.co^2));
            chars.(['xp',c]) = gamma.*(chars.(['x',c]) - params.v.*chars.(['t',c]));        
        end
        % get q  initial,  q(xi,ti)
        qo = q(xi(k,1),params);

        % solve the equation along the characteristic
        [sol.(['t',c]),sol.(['q',c])] = ode45(@(t,q) Dq(dtlnbeta,q,t,chars.(['x',c]),chars.(['t',c]),params),[ti tf],qo,options);

        if params.summary_q
            Q(i,1) = sol.(['q',c])(1);
            Q(i,2) = sol.(['q',c])(end);
            X(i,1) = chars.(['x',c])(1);
            X(i,2) = chars.(['x',c])(end);
        end
    end

    if params.save_raw
        save([params.savedir,'/raw/',params.rawname])
    end

end