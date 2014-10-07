function plot_q_chars(chars,sol,params)
h0 =figure;
figure(h0)
cc = hsv(params.np);
fontsize = params.fontsize;
np = params.np;
hold on
for i = 1:np
    c = num2str(i);
    plot(chars.(['t',c]),chars.(['x',c]),'-','color',cc(i,:))
end
xlabel('t (a.u.)','FontSize',fontsize)
ylabel('x (a.u.)','FontSize',fontsize)
set(gca,'FontSize',fontsize)
set(h0,'DefaultTextFontSize',fontsize)
axis tight

h1 = figure;
figure(h1)
hold on
for i = 1:np
    c = num2str(i);
    plot(sol.(['t',c]),sol.(['q',c]),'-','color',cc(i,:))
end
xlabel('t (a.u.)','FontSize',fontsize)
ylabel('q (a.u.)','FontSize',fontsize)
set(gca,'FontSize',fontsize)
set(h1,'DefaultTextFontSize',fontsize)
axis tight
print(h0,'-depsc2',[params.savedir,'/figures/',params.figname,'_','xt.eps'])
print(h1,'-depsc2',[params.savedir,'/figures/',params.figname,'_','qt.eps'])

if params.lorentz
    h2 = figure;
    figure(h2)
    hold on
    for i = 1:np
        c = num2str(i);
        plot(chars.(['tp',c]),chars.(['xp',c]),'-','color',cc(i,:))
    end
    xlabel('t'' (a.u.)','FontSize',fontsize)
    ylabel('x'' (a.u.)','FontSize',fontsize)
    set(gca,'FontSize',fontsize)
    set(h2,'DefaultTextFontSize',fontsize)
    axis tight
    print(h2,'-depsc2',[params.savedir,'/figures/',params.figname,'_','xt_lorentz.eps'])
end
end