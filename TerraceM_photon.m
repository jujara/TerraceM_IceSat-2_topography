function TerraceM_photon(filename,level)
% This is a matlab function to map marine terrace shoreline angles using
% IceSat-2 photon data. The data can be dowbloaded from Openaltimetry.org
%the data format is a .csv table downloaded from each selected area in
%openaltimetry.
%inputs: 
%filename of the .csv file downloaded from openaltimetry.org
%marine terrace level to map
%the outputs of marine terrace mapping are stored in a .mat file 
%
%Example:
%
%filename='photon_2020-07-24_gt3l_t438_1682201062883.csv';
%level = 1;
%TerraceM_photon(filename,level)
%
%
%Copyright: Julius Jara Muñoz, Hochschule Biberach, 2023

M = csvread(filename,1,0);

%Select best
% NN=M(M(:,4)==4,:);
NN=M;

%to UTM
[x,y,~]=deg2utm(NN(:,1),NN(:,2));

MM=NN;
MM(:,1)=x;
MM(:,2)=y;


%get track geometry
[P1,Id1]=  min(MM(:,2));
[P2,Id2]=  max(MM(:,2));

l(1,:)=[MM(Id1,1) MM(Id1,2)];
l(2,:)=[MM(Id2,1) MM(Id2,2)];

%project all
type=1;%unflipped
dist1=projection(l,MM,type);

if dist1(1,4)>dist1(end,4)
    type=2; %flipped profile
 dist=projection(l,MM,type); 
else
    dist=dist1;
end


% levels of quality photon data
D1=dist(dist(:,5)==4,:);%best
D2=dist(dist(:,5)==2,:);
D3=dist(dist(:,5)==1,:);
D4=dist(dist(:,5)==3,:);

if exist(sprintf('PH_MAP_%s.mat',filename)) == 2   
    load(sprintf('PH_MAP_%s.mat',filename))
    sly=TERRACEM_PHOTON.geoid;      
else

f1=figure(1);
clf
hold on
plot(D1(:,3),D1(:,4),'.k')
disp('adjust zoom, press enter and mark the sea level position with one click')
pause
[slx,sly]=ginput(1);

plot([min(D1(:,3)) max(D1(:,3))],[sly sly],'--b')
pause (2)
close(f1)
end

%tranform geoid elevation to orthometric
D1(:,4)=D1(:,4)-sly;

% filter and smooth routine
Dm=movmean([D1(:,3),D1(:,4)],20);
Dm(:,2)=smooth(Dm(:,2),10);


f1=figure(1);
clf
hold on
plot(D1(:,3),D1(:,4),'.','Markeredgecolor',[.6 .6 .6])
plot(Dm(:,1),Dm(:,2),'-k')

%plot([min(D1(:,3)) max(D1(:,3))],[sly sly],'--b')
disp('Shoreline angle mapping: Adjust the zoom and press enter, mark the upper and lower part of the paleocliff')
pause

[clif(1,1),clif(1,2)]=ginput(1); 
[clif(2,1),clif(2,2)]=ginput(1);

disp('mark the top and bottom of paleo abrasion platform');

[plat(1,1),plat(1,2)]=ginput(1); 
[plat(2,1),plat(2,2)]=ginput(1);  


da(:,1)=Dm(:,1); 
da(:,2)=Dm(:,2); 
disp('wait, processing data');
%area for interpolation
daclif1=da(da(:,1)>=clif(2,1),:);
daclif=daclif1(daclif1(:,1)<=clif(1,1),:);
daplat1=da(da(:,1)>=plat(2,1),:); 
daplat=daplat1(daplat1(:,1)<=plat(1,1),:);

% fit cliff
xc=daclif(:,1); yc=daclif(:,2);
[pclif,sclif]=polyfit(xc,yc,1);
% fit plat
xp=daplat(:,1); yp=daplat(:,2);
[pplat,splat]=polyfit(xp,yp,1);

% save points and project profile
clifx=[clif(1,1),clif(1,2),clif(2,1),clif(2,2)];
platx=[plat(1,1),plat(1,2),plat(2,1),plat(2,2)];

d=xc(2)-xc(1);
d=abs(d);
xx=min(xp):d:max(xc); xx=xx';

%regressions
[p_clif,d_clif]=polyval(pclif,xx,sclif);
[p_plat,d_plat]=polyval(pplat,xx,splat);

% plot intersection
cla
hold on
plot(D1(:,3),D1(:,4),'.','Markeredgecolor',[.6 .6 .6])
plot(Dm(:,1),Dm(:,2),'-k')

plot(xx,p_clif,'r-',...
   xx,p_clif+2*d_clif,'r--',xx,p_clif-2*d_clif,'r--') %, axis equal tight
hold on
%plot(xp,yp,'ok','MarkerSize',5,'MarkerFaceColor','w')
plot(xx,p_plat,'r-',xx,p_plat+2*d_plat,'r--',xx,p_plat-2*d_plat,'r--') 
axis([min(xx)-15 max(xx)+15 min(yp)-15 max(yc)+15]); 
yl1=ylabel('Elevation (m)'); 
xl1=xlabel('Distance along swath(m)');

%%%%% shoreline angle
% find intersections
mc=pclif(1,1); mp=pplat(1,1); ic=pclif(1,2); ip=pplat(1,2);
% output shoreline angle is sh
sh=[(-ic+ip)/(mc-mp),(ip*mc-ic*mp)/(mc-mp)];
shx=sh(1,1); %distance along ptofile
shz=sh(1,2); %elevation
%intersect to determine error in Z
V1=[xx,p_plat+2*d_plat];
V2=[xx,p_clif-2*d_clif];
[X0,Y0]=intersections(V1(:,1),V1(:,2),V2(:,1),V2(:,2));
shze=(Y0-shz)*1;


%text on plot
xL = get(gca,'XLim'); yL = get(gca,'YLim');
dxL=xL(2)-xL(1); dyL=yL(2)-yL(1);
text(shx-dxL/10,shz+dyL/10,sprintf('%.2f $\\pm$ %.2f m',shz,shze),'FontSize',12,'BackgroundColor',[1 1 1],'interpreter','latex'); %Shoreline angle value and location

%get coordinates in map view, point2utm do this
pt2utm=point2utm(D1(:,3),l,type,sh);

Rx=pt2utm(:,1); %UTM E
Ry=pt2utm(:,2); %UTM N

%plot shoreline angle with error in z
h=errorbar(shx,shz,shze,'ok','MarkerFaceColor','k'); 
%errorbar_tick(h, 30);
box on
ylabel('Elevation (m)'); xlabel('Distance along swath (m)');
%

%arrange outputs
shoreline=[Rx Ry shx shz shze]; %number of shoreline,E, N, distance along profile,z ze

%regressions
regr_cliff=[xx,p_clif,p_clif+2*d_clif,p_clif-2*d_clif];
regr_plat=[xx,p_plat,p_plat+2*d_plat,p_plat-2*d_plat];



if exist(sprintf('PH_MAP_%s.mat',filename),'file') == 2   
    load(sprintf('PH_MAP_%s.mat',filename))
end
%     TERRACEM_PHOTON.level(level).SH=shoreline;
%     TERRACEM_PHOTON.level(level).cliff=regr_cliff;
%     TERRACEM_PHOTON.level(level).plat=regr_plat;
%     TERRACEM_PHOTON.geoid=sly;
    
    TERRACEM_PHOTON.level(level).SH=shoreline;
    TERRACEM_PHOTON.level(level).cliff=regr_cliff;
    TERRACEM_PHOTON.level(level).plat=regr_plat;
    TERRACEM_PHOTON.geoid=sly;
    TERRACEM_PHOTON.topo=da;
    
    save(sprintf('PH_MAP_%s.mat',filename),'TERRACEM_PHOTON');

