function success = F_plotcomparebusbranch_noline(N,X1,X2,X3,X4,xlabelname,ylabelname,titlename,yrange,marker1,marker2,marker3,marker4,legendname, savename)
    % X3,X4 是可选的。
    if isempty(savename)
        savename = titlename;
    end
    if isempty(X4)
        if isempty(X3)
            plot(1:N,reshape(X1,1,N),['-' marker1],1:N,reshape(X2,1,N),['-' marker2],'MarkerSize',2);
        else
            plot(1:N,reshape(X1,1,N),['-' marker1],1:N,reshape(X2,1,N),['-' marker2],1:N,reshape(X3,1,N),['-' marker3],'MarkerSize',2);
        end
    else
        plot(1:N,reshape(X1,1,N),['-' marker1],1:N,reshape(X2,1,N),['-' marker2],1:N,reshape(X3,1,N),['-' marker3],1:N,reshape(X4,1,N),['-' marker4],'MarkerSize',2);
    end 
    xlabel(xlabelname);
    ylabel(ylabelname);
    if ~isempty(titlename)
        title(titlename);
    end
    if ~isempty(yrange)
        axis([1 N yrange(1) yrange(2)]);
    else
        xlim([1 N]);

    end
    grid on
    hold on
%     plot([8 8],[0 60],'r--',[30 30],[0 60],'r--',[38 38],[0 60],'r--',[65 65],[0 60],'r--','Linewidth',2)
    
    legend(legendname,'Location','NorthEast');
%     if isempty(X4)
%         if isempty(X3)
%             legend(legendname{1},legendname{2},'Location','NorthEast');
%         else
%             legend(legendname{1},legendname{2},legendname{3},'Location','NorthEast');
%         end
%     else 
%             legend(legendname{1},legendname{2},legendname{3},legendname{4},'Location','NorthEast');
%     end 
    legend('boxoff');
    
    print('-dpng','-r1000',[savename,'.png']);
    saveas(gcf,savename,'bmp');
    success = 1;
end