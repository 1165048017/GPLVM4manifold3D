function handle = xyzhumanevaVisualise(pos,fid)

% XYZHUMANEVAVISUALISE
%
%	Description:
%	


%	Copyright (c) 2008 Carl Henrik Ek and Neil Lawrence
% 	xyzhumanevaVisualise.m SVN version 119
% 	last update 2008-10-21T09:52:55.000000Z


if(nargin<2)
  fid = 2;
end

figure(fid);

% determine parametrization
if(max(max(abs(pos)))<100)
  type = 'jon';
else
  type = 'raquel';
end

switch type
 case 'raquel'
  if(size(pos(1,:),2)==54);
    type = 'raquelS3';
  end
end


joint = xyzhumaneva2joint(pos);
handle = xyzhumanevaDraw(joint,[],type);axis equal;view([1 0 0]);
% switch type
%  case 'raquel'
%   set(gca,'XLim',[-300 300],'YLim',[-300 300],'ZLim',[-800 800]);
%  case 'jon'
%   % Jon Parametrization
%   set(gca,'XLim',[-0.35 0.35],'YLim',[-0.35 0.35],'ZLim',[-1 0.3]);
% end

  
return