function fig_stf = plot_source_time_function(t,stf)

% plots the source time function in the format described here.

set_figure_properties_bothmachines;

dt = t(2) - t(1);

fig_stf = figure;
set(fig_stf,'OuterPosition',pos_stf);
% set(gca,'FontSize',20)
hold on

subplot(2,1,1);
plot(t,stf,'k');
    xlabel('time [s]');
    title('source-time function');
    
% frequency spectrum

subplot(2,1,2);
NFFT = 2^nextpow2(length(stf));
Y = fft(stf,NFFT)/length(stf);
Fs = 1/dt;
f = Fs/2*linspace(0,1,NFFT/2+1);
spectrum=2*abs(Y(1:NFFT/2+1));
% figure;
% plot(f,spectrum);
semilogx(f,spectrum);
    xlabel('frequency [Hz]');
    title('... and its frequency (amp) spectrum');
    
end