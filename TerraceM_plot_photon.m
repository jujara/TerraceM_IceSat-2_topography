function TerraceM_plot_photon(filename)

%this function plots the outputs of marine terrace mapping stored in a .mat file 
%
%Example:
%
%filename='photon_2020-07-24_gt3l_t438_1682201062883.csv';
%TerraceM_plot_photon(filename)
%
%Copyright: Julius Jara Muñoz, Hochschule Biberach, 2023

load(filename);

ii=numel(TERRACEM_PHOTON.level);

figure
box on
hold on
plot(TERRACEM_PHOTON.topo(:,1),TERRACEM_PHOTON.topo(:,2),'-k');

for i=1:ii
 hold on   
   plot(TERRACEM_PHOTON.level(i).cliff(:,1),TERRACEM_PHOTON.level(i).cliff(:,2),'-r')
   plot(TERRACEM_PHOTON.level(i).cliff(:,1),TERRACEM_PHOTON.level(i).cliff(:,3),'--r') 
   plot(TERRACEM_PHOTON.level(i).cliff(:,1),TERRACEM_PHOTON.level(i).cliff(:,4),'--r')
    
   plot(TERRACEM_PHOTON.level(i).plat(:,1),TERRACEM_PHOTON.level(i).plat(:,2),'-r')
   plot(TERRACEM_PHOTON.level(i).plat(:,1),TERRACEM_PHOTON.level(i).plat(:,3),'--r') 
   plot(TERRACEM_PHOTON.level(i).plat(:,1),TERRACEM_PHOTON.level(i).plat(:,4),'--r')
   
   errorbar(TERRACEM_PHOTON.level(i).SH(3),TERRACEM_PHOTON.level(i).SH(4),TERRACEM_PHOTON.level(i).SH(5),'ok','MarkerFaceColor','k')
   text(TERRACEM_PHOTON.level(i).SH(3)+10,TERRACEM_PHOTON.level(i).SH(4),sprintf('%.2f $\\pm$ %.2f m',TERRACEM_PHOTON.level(i).SH(4),TERRACEM_PHOTON.level(i).SH(5)),'FontSize',12,'interpreter','latex');

end

xlabel('Distance along profile (m)'); ylabel('Elevation (m)')