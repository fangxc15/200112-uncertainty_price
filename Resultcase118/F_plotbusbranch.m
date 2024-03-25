function success = F_plotbusbranch(N,X,xlabelname,ylabelname,titlename,yrange,marker)
    plot(1:N,X,['-' marker]);
    xlabel(xlabelname);
    ylabel(ylabelname);
    title(titlename);
    if ~isempty(yrange)
        axis([1 N yrange(1) yrange(2)]);
    else
        xlim([1 N]);

    end
    grid on
    saveas(gcf,titlename,'bmp');
    success = 1;
end