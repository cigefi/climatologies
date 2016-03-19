function [] = PlotData3D(data2D)
    %hacer el promedio climatologico
%     for n=1:1:length(data3D(1,:,1))
%         for k=1:1:length(data3D(1,1,:))
%             data2D(n,k)=mean(data3D(:,n,k)); 
%         end
%     end

    %extender el mapa para rellenar el campo de long 360 con lon 0
    A=data2D(:,1);
    data2Dh=[data2D,A];
    
    %nuevo mapa
    longitud = linspace(0,360,length(data2D(1,:))+1);
    latitud = linspace(-90,90,length(data2D(:,1)));
    
    [longrat,latgrat]=meshgrat(longitud,latitud);
    testi=data2Dh;
    
    p=10;%p=round(latitud(2)-latitud(1));%[25:15:30];
    f = figure('visible', 'on');
    hold on;
    worldmap([-90 90],[-180 180])
    mlabel('off')
    plabel('off')
    framem('on')
    set(gcf,'Color',[1,1,1]);
    %hold on;
    colormap(jet(50));%colormap(jet(50));
    [c,h]=contourfm(latgrat,longrat,testi',p,'LineStyle','none');
%     hi = worldhi([-90 90],[-180 180]);
%     for i=1:length(hi)
%         disp(num2str(i));
%         plotm(hi(i).lat,hi(i).long,'k')
%     end
    label = 'Precip';
    cb = colorbar('southoutside');
    xlabel(cb,label);
    print('SurfacePlot','-depsc','-tiff');
    disp('Map saved');
    %savefig('PeaksFile.fig')
    close(f);
end