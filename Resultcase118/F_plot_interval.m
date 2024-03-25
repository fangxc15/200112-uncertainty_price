function success = F_plot_interval(N,X1,X1_max,X1_min,X2,X2_max,X2_min,xlabelname,ylabelname,titlename,yrange,marker1,marker2,legendname, savename)
    % X3,X4 是可选的。
    if isempty(savename)
        savename = titlename;
    end
    
    plot(1:N,reshape(X1,1,N),['-' marker1],1:N,reshape(X2,1,N),['-' marker2],'MarkerSize',1,'Linewidth',1.5);

%     if isempty(X4)
%         if isempty(X3)
%             plot(1:N,reshape(X1,1,N),['-' marker1],1:N,reshape(X2,1,N),['-' marker2],'MarkerSize',2);
%         else
%             plot(1:N,reshape(X1,1,N),['-' marker1],1:N,reshape(X2,1,N),['-' marker2],1:N,reshape(X3,1,N),['-' marker3],'MarkerSize',2);
%         end
%     else
%         plot(1:N,reshape(X1,1,N),['-' marker1],1:N,reshape(X2,1,N),['-' marker2],1:N,reshape(X3,1,N),['-' marker3],1:N,reshape(X4,1,N),['-' marker4],'MarkerSize',2);
%     end 
    if ~isempty(X1_max) && ~isempty(X1_min)
        hold on
    %     plot([8 8],[0 60],'r--',[30 30],[0 60],'r--',[38 38],[0 60],'r--',[65 65],[0 60],'r--','Linewidth',2)
        hfill1 = fill([1:N flip(1:N)], [X1_max flip(X1_min)], [0.12 0.37 0.82]);
        hfill1.FaceColor = [0.12 0.37 0.82];
        hfill1.FaceAlpha = 0.3;
        hfill1.EdgeAlpha = 0;
    end
    
    if ~isempty(X2_max) && ~isempty(X2_min)
        hold on
    %     plot([8 8],[0 60],'r--',[30 30],[0 60],'r--',[38 38],[0 60],'r--',[65 65],[0 60],'r--','Linewidth',2)
        hfill2 = fill([1:N flip(1:N)], [X2_max flip(X2_min)],'r');
    %     hfill.FaceColor = [0.12 0.37 0.82];
        hfill2.FaceAlpha = 0.3;
        hfill2.EdgeAlpha = 0;
    end
    grid on
    legend(legendname, 'Location','NorthEast');
    legend('boxoff');
    
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

    
    print('-dpng','-r1000',[savename,'.png']);
    saveas(gcf,savename,'bmp');
    success = 1;
end