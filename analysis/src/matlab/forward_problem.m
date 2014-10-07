function [chars,sol] = forward_problem(xi,ti,tf,q,beta,dtlnbeta,params,options)
% function [chars,sol] = forward_problem(xi,ti,tf,q,beta,dtlnbeta,params,options)
%
% Solve the forward problem for the characteristics and find q

    for k=1:size(xi,1)
        disp(k)
        c = num2str(k);

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

    end

    if params.save_raw
        save([params.savedir,'/raw/',params.rawname])
    end

end