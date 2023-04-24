function point2utm=point2utm(x,l,type,sh)

%x=swat.x;
%type=swat.type_profile;
% l(:,1)=swat.prof_X;
% l(:,2)=swat.prof_Y;

if type==2   
    
    SHX=max(x)-sh(1,1);
    %SHX=sh(1,1);
else
    %SHX=max(x)-sh(1,1);
    SHX=sh(1,1);
end

%similar triangles %dx8/Dxf= Xc/X_surface;
dx8=l(2,1)-l(1,1);
dy8=l(1,2)-l(2,2);
Dxf=hypot(dx8,dy8);
m8=(dy8/dx8); 
an8=atand(m8);%angle

xc1=dx8/Dxf*SHX;
yc1=dy8/Dxf*SHX;

% profile angle conditional
%if an8>=0
point2utm(1,1)=l(1,1)+xc1;
point2utm(1,2)=l(1,2)-yc1;
%else
%point2utm(1,1)=l(1,1)+xc1;
%point2utm(1,2)=l(1,2)-yc1;   
%end