function []=animatePoleVector(v,geom,varargin)

% IMPORTANT: all elements of v need to be of same derivative degree (ALL positions OR velocities OR accelerations)

% userdefined parameters
p=inputParser();
p.addOptional('offset',[]);
p.addOptional('dircos',[]);
p.addOptional('planform',{});
p.addOptional('quivFormat',[{'LineWidth'},{1.5},{'LineStyle'},{'-'},{'Color'},{[1 0 0]},{'Marker'},{'none'}]);
p.addOptional('f_Hz',0.2); % animation frequency [Hz];
p.addOptional('sumArrows',true); % sum arrows at same grid point (i.e. offset)
p.addOptional('arrow_scale',4);
p.addOptional('rotationIRS_scale',1);
p.addOptional('translationIRS_scale',1);
p.addOptional('IRS_iArr',nan(6,1),@(x) numel(x)==6); % eigenvector components for IRS (x-y-z-phi-theta-psi) 
p.addOptional('viewAngle',[-50 70],@(x) numel(x)==2);
p.addOptional('gif_file','');
p.addOptional('gif_crop',[0 0;0 0]); % [fromTop fromBottom; fromLeft fromRigh] in pixels
p.addOptional('loop',true); % loop animation {integer: number of loops, boolean: loop infinit times or not}
p.parse(varargin{:});
opt=p.Results;

% inits
if ~isempty(geom)
    planform=geom.planform;
    offset=geom.offset;
    dircos=geom.dircos;
else
    error('not implemented.')
end
planformDim_max=max(cellfun(@(x) max(max(abs(minmax(x)))),planform));
if isempty(planformDim_max)
    planformDim_max=1;
end
isRealValued=all(imag(v)==0);
n_v=numel(v);


% IRS data
IRS_iArr=opt.IRS_iArr(~isnan(opt.IRS_iArr));
vIRS=zeros(6,1);
vIRS(~isnan(opt.IRS_iArr))=v(IRS_iArr);
offsetIRS=unique(offset(:,IRS_iArr)','rows')';
if size(offsetIRS,2)>1
    error('IRS offset inconsistent.');
end

% arrow data
arrow_iArr=setdiff(1:n_v,IRS_iArr);
vArrow=v(arrow_iArr);
offsetArrow=offset(:,arrow_iArr);
dircosArrow=dircos(:,arrow_iArr);

% scaling
normFactor=1/norm(v);
vArrow=vArrow(:)*planformDim_max*opt.arrow_scale*normFactor; % normalize vTrans (and make column vector)
vIRS=[vIRS(1:3)*opt.translationIRS_scale*planformDim_max;
      vIRS(4:6)*opt.rotationIRS_scale]*normFactor;

% sum up elements of equal offset points
if opt.sumArrows
    [sumOffset,~,sumIdx]=unique(offsetArrow','rows');
    offsetArrow=sumOffset';
else
    sumIdx=[];
end

% check if real-valued pole vector


% % check if only real or only imaginary
% imag_max=max(abs(imag(v)));
% real_max=max(abs(real(v)));
% if imag_max/real_max<tol
%     v=dircos*real(v);
%     dircos=[];
% elseif real_max/imag_max<tol
%     v=dircos*imag(v);
%     dircos=[];
% end
    

% initialize axes (and plot planform)
set(gcf,'Color',[1 1 1]);
hAx=gca;
set(hAx,'clipping','off')
axis off
hold on
hgParent=hgtransform(hAx);
view(hAx,opt.viewAngle);
for ii=1:numel(planform)
    patch(hAx,planform{ii}(1,:),planform{ii}(2,:),planform{ii}(3,:),'k','FaceAlpha',0.1,'Parent',hgParent)
end
if any(cellfun(@(x) range(x(1,:)),planform)>0)
    xlim(hAx,[min(cellfun(@(x) min(x(1,:)),planform)) max(cellfun(@(x) max(x(1,:)),planform))]);
else
    xlim(hAx,[-1 1]*planformDim_max);
end
if any(cellfun(@(x) range(x(2,:)),planform)>0)
    ylim(hAx,[min(cellfun(@(x) min(x(2,:)),planform)) max(cellfun(@(x) max(x(2,:)),planform))]);
else
    ylim(hAx,[-1 1]*planformDim_max);
end
if any(cellfun(@(x) range(x(3,:)),planform)>0)
    zlim(hAx,[min(cellfun(@(x) min(x(3,:)),planform)) max(cellfun(@(x) max(x(3,:)),planform))]);
else
    zlim(hAx,[-1 1]*planformDim_max);
end

% initialize arrows
phi=0;  
plot3(hAx,offsetArrow(1,:),offsetArrow(2,:),offsetArrow(3,:),'k.','MarkerSize',15,'Parent',hgParent);
plot3(hAx,offsetIRS(1,:),offsetIRS(2,:),offsetIRS(3,:),'b.','MarkerSize',15,'Parent',hgParent); % IRS
arrow0=calcDeflection_LOCAL(vArrow,phi,dircosArrow,sumIdx);
hQuiver= quiver3(hAx,offsetArrow(1,:),offsetArrow(2,:),offsetArrow(3,:),...
                 arrow0(1,:),arrow0(2,:),arrow0(3,:),...
                 0.0,opt.quivFormat{:},'Parent',hgParent);
             



% % video writer
% %-------------
% if notempty(options,'avi_file') % get frame and write to animated avi
%     vWriter=VideoWriter(options.avi_file,'Uncompressed AVI');
%     open(vWriter);
% end


% do time simulation
dphi=2*pi/100; % 50 samples per rotation
dt=dphi/(opt.f_Hz*2*pi); % wait time
while true
        
    % update arrows
    arrow_arr=calcDeflection_LOCAL(vArrow,phi,dircosArrow,sumIdx);
    IRS_arr=calcDeflection_LOCAL(vIRS,phi);

    if ishandle(hQuiver)
        set(hQuiver,'UData',arrow_arr(1,:),'VData',arrow_arr(2,:),'WData',arrow_arr(3,:));
        
        % rotate/translate planform
        if ~isempty(IRS_iArr)
            
            Rx = makehgtform('xrotate',-IRS_arr(4));
            Ry = makehgtform('yrotate',IRS_arr(5));
            Rz = makehgtform('zrotate',-IRS_arr(6));
            Tx1 = makehgtform('translate',-offsetIRS);
            Tx2 = makehgtform('translate', offsetIRS+[IRS_arr(1) IRS_arr(2) -IRS_arr(3)]');
            set(hgParent,'Matrix',(Tx2*(Rx*Ry*Rz)*Tx1));

        end
        
    else
        break;
    end   
    drawnow
    pause(dt);
        
    if ~isempty(opt.gif_file) % get frame and write to animated gif

        % get frame
        temp = getframe(hAx); % 16-10-07 pusch.research@gmail.com
        % take cdata and perform rgb2ind
        [X,map] = rgb2ind_new(temp.cdata);
        x_first=opt.gif_crop(1,1)+1;
        x_last=size(X,1)-opt.gif_crop(1,2);
        y_first=opt.gif_crop(2,1)+1;
        y_last=size(X,2)-opt.gif_crop(2,2);
        if x_first>=x_last || y_first>=y_last
            error('wrong gif_crop.');
        end
        X=X(x_first:x_last,y_first:y_last);
        % write frame to animated gif file
        if phi == 0
            TransparentColor =  get(gcf,'Color'); % 16-10-07 pusch.research@gmail.com                           %[0.8 0.8 0.8]; 
            [~,TransparentColor] = min(sum(abs(bsxfun(@minus,map,TransparentColor)),2));% 16-10-07 pusch.research@gmail.com              % find(~sum(map-repmat(TransparentColor,size(map,1),1),2));
            TransparentColor=TransparentColor-isa(X,'uint8');
            imwrite(X,map, opt.gif_file, 'gif', 'DelayTime', dt*0.8, 'LoopCount', inf,'TransparentColor',TransparentColor);
            %imwrite(X,map, gif_file, 'gif', 'Delay', t_step*slowmo, 'LoopCount', 1);
        else
            imwrite(X,map, opt.gif_file, 'gif', 'DelayTime', dt*0.8, 'WriteMode', 'append');
        end
    end

    
    % increase rotation angle
    phi=phi+dphi;
    if isRealValued && phi>pi/2
        
        phi=0;        
        if opt.gif_file
            disp(['> ' opt.gif_file ' saved..']);
            opt.gif_file='';
        end
        
        if isnumeric(opt.loop)
            opt.loop=opt.loop-1;
        end
        if opt.loop<=0
            break;
        end
        
    elseif phi>2*pi
        
        phi=phi-2*pi;
        if opt.gif_file
            disp(['> ' opt.gif_file ' saved..']);
            opt.gif_file='';
        end
        
        if isnumeric(opt.loop)
            opt.loop=opt.loop-1;
        end
        if opt.loop<=0
            break;
        end
    end
    
        % -------------------------------------------------------------------------
        % write animimated avi to file
        % -------------------------------------------------------------------------
%         if notempty(options,'avi_file') % get frame and write to animated avi
%             writeVideo(vWriter,getframe(h_axplot));
%         end
        
%         if notempty(options,'avi_file') % get frame and write to animated avi
%     close(vWriter);
%         end
end


        
function arrow_arr=calcDeflection_LOCAL(v,phi,dircos,sumIdx)

% compute arrows
v_act=imag(v)*cos(phi)+real(v)*sin(phi);
%v_act=v*phi; %exp(phi/2);

% rotate if necessary
if nargin>2 && ~isempty(dircos)
    arrow_arr=bsxfun(@times,dircos,v_act');
else
    arrow_arr=v_act;
end

% sum arrows
if nargin>3 && ~isempty(sumIdx)
   tmp=nan(3,max(sumIdx));
   for ii=1:size(tmp,2)
       tmp(:,ii)=sum(arrow_arr(:,sumIdx==ii),2);
   end
   arrow_arr=tmp;
end
