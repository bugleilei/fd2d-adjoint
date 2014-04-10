
%
% vel:      velocity recordings (dimensions (n_receivers, nt) )
% t:        time axis
% veldis:   the mode of the seismograms that we plot: 'displacement' or
% 'velocity'

function plot_seismograms(vel,t,veldis)

%==========================================================================
%- plot recordings, ordered according to distance from the first source ---
%==========================================================================

%- initialisations and parameters -----------------------------------------

spacing=1.5;
sort=0;

%- read input -------------------------------------------------------------

% path(path,'../input/');
% input_parameters;


%- convert to displacement if wanted ------------------------------------------

if strcmp(veldis,'displacement')
    nt=length(t);
    u=zeros(length(rec_x),nt);
    
    u = cumsum(vel,2)*dt;
    
    % now put the displacement values back in the vel variable so that it
    % can be plotted.
    vel=u;
    
elseif (not(strcmp(veldis,'velocity')))
    error('ERRORR your veldis input variable is wrong. Eejit.');
end

%- plot seismograms ----------

recordings = figure;
% set(gca)
hold on

% for k=1:length(rec_x)
for k = 1:size(vel,1)
    
    m=max(abs(vel(k,:)));
    % traces om en om blauw en zwart kleuren
    if mod(k,2)
        plot(t,spacing*(size(vel,1)-k) + vel(k,:)/m,'k','LineWidth',1)
    else
        plot(t,spacing*(size(vel,1)-k) + vel(k,:)/m,'b','LineWidth',1)
    end
    
    tekstje = ['trace nr ', num2str(k), ' (max: ', num2str(m,'%3.1e'), ')' ];
    text(min(t)-(t(end)-t(1))/6,spacing*(size(vel,1)-k)+0.3,tekstje)
    
%     % afstanden geven in m of km
%     if (max(rec_x)<=1000)
%         text(min(t)-(t(end)-t(1))/6,spacing*(k-1)+0.3,['x=' num2str(rec_x(k)) ' m, z=' num2str(rec_z(k)) ' m'],'FontSize',14)
%     else
%         text(min(t)-(t(end)-t(1))/6,spacing*(k-1)+0.3,['x=' num2str(rec_x(k)/1000) ' km, z=' num2str(rec_z(k)/1000) ' km'],'FontSize',14)
%     end
    
end

% text on figure: velocity or displacement seismogram
figure(recordings);
title([veldis, ' seismograms']);

xlabel('time [s]');
ylabel('normalised traces');
axis([min(t)-(t(end)-t(1))/5 max(t)+(t(end)-t(1))/10 -1.5 spacing*size(vel,1)])