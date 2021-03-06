function fig_mod = plot_model(varargin)


% function that plots the model in rho mu lambda parametrisation.
% NOTE: Currenly this is a rather ugly function and I could make it much
% nicer by putting the plotting commands within a for loop over rho mu
% lambda.
%
% - fig_mod = plot_model(Model);
% - fig_mod = plot_model(Model, outparam);
% - fig_mod = plot_model(Model, middle);
% - fig_mod = plot_model(Model, minmax, outparam);
% - fig_mod = plot_model(Model, middle, outparam);
%
% INPUT:
% Model:    struct containing .rho .mu .lambda
% outparam: string, 'rhomulambda', 'rhovsvp' (future: 'rhomukappa'?)
%           parametrisation of output plot (also parametrisation of middle)
% middle:   1x3 array w/ colour scale centre values for [param1, param2, param3]; 
%
% OUTPUT:   
% - figure with the model plotted. Colour scale are defined by middle (if 
%   given) -- otherwise, it is the actual max and min of the parameter 
%   values, not some standard deviation.

% format long

[Model, middle, minmax, outparam] = checkargs(varargin);
%  middle
%  minmax

input_parameters;
[X,Z,dx,dz]=define_computational_domain(Lx,Lz,nx,nz);
set_figure_properties_bothmachines;

load 'propagation/cm_model.mat';

fig_mod = figure;
set(fig_mod,'OuterPosition',pos_mod) 
% set(gca,'FontSize',14)

j=1;
for params = fieldnames(Model)';
    

    param = Model.(params{1});

%     g = subplot(2,3,j);
%     p = get(g,'position');
% %     p(4) = p(4)*1.50;  % Add 10 percent to height
%     set(g, 'position', p);

    subplot(1,3,j);
    
    hold on
    pcolor(X,Z,param');
    
    % difference_mumax_mumin = max(mu(:)) - min(mu(:));
    
    %- colour scale
    if ~(isnan (minmax.(params{1})) )
        cmin = minmax.(params{1})(1);
        cmax = minmax.(params{1})(2);
    elseif (isnan( middle.(params{1}) ))
        
        if all(abs(param-mode(param(:))) <= 1e-14*mode(param(1)))
            cmax = param(1) + 0.01*param(1);
            cmin = param(1) - 0.01*param(1);
            %     disp 'bips!!! all param are the same!'
        else
            % max and min are calculated in this way so that the most common value
            % (i.e. the background value) is white, and that the extreme coulours
            % are determined by whichever of max and min is farthest off from the
            % background colour.
            % this is done not with mode but with hist, because after
            % update, the values all vary just a bit.
            %     cmid = mode(param(:))
            [bincounts, centre] = hist(param(:),100);
            [~,ix]=max(bincounts);
            cmid = centre(ix);
            cmax = cmid + max(abs(param(:) - cmid));
            cmin = cmid - max(abs(param(:) - cmid));

        end
        
    else
        
        if all(abs(param-mode(param(:))) <= 1e-14*mode(param(1)))
            cmax = param(1) + 0.01*param(1);
            cmin = param(1) - 0.01*param(1);
            %     disp 'bips!!! all param are the same!'
        else
            
            % max and min are calculated in this way so that the the 
            % background value) is white, and that the extreme coulours are
            % determined by whichever of max and min is farthest off from 
            % the background colour.
            
            cmid = middle.(params{1});
            cmax = cmid + max(abs(param(:) - cmid));
            cmin = cmid - max(abs(param(:) - cmid));
            
        end
        
    end
    
    caxis([cmin cmax]);
    
    
    for k=1:length(src_x)
        plot(src_x(k),src_z(k),'kx')
    end
    
    for k=1:length(rec_x)
        plot(rec_x(k),rec_z(k),'ko')
    end
    colormap(cm_model);
    axis image
    shading flat
    switch params{1}
        case 'rho'
        title([params{1}, ' [kg/m^3]'])
        case {'vs', 'vp'}
            title([params{1}, ' [m/s]'])
        case {'mu', 'lambda'}
            title([params{1}, ' [N/m^2]'])
        otherwise
            title([params{1}, ' [unit??]'])
    end
    xlabel('x [m]');
    ylabel('z [m]');
    colorbar
    hold off;
    
%     subplot(4,3,6+j)
%     
%      hist(Model.(params{1})(:),100)
%      h = findobj(gca,'Type','patch');
%      set(h,'FaceColor',[.9 .9 .9],'EdgeColor',[.9 .9 .9])
    
    j = j+1;
    
%     disp(['cmin: ',num2str(cmin,'%5.5e'),'   cmax: ', num2str(cmax,'%5.5e')]);
%     cmax
end

end

function [Model, middle, minmax, outparam] = checkargs(arg)

% checks the input argument and defines the fields to be plotted, the
% middle of the plot colour (in all three) and 

narg = length(arg);



switch narg
    
    case 1
        % disp '1 argument'
        
        if isstruct(arg{1})
            Model = arg{1};
            if length(Model) > 1
                error('You supplied more than one models (i.e. a struct w/ multiple models?)');
            end
            
        elseif isnumeric(arg{1})
            modelnr = arg{1};
            Model = update_model(modelnr);
        else
            error('input has to be a model structure or modelnr');
        end
        %         middle = [NaN NaN NaN];
        middle.rho = NaN;
        middle.mu = NaN;
        middle.lambda = NaN;
        
    case 2
        % disp '2 arguments'
        Model = arg{1};
        
        if length(Model) > 1
            error('You supplied more than one models (i.e. a struct w/ multiple models?)');
        end

        if ischar(arg{2})
            
            outparam = arg{2};
            Model = change_parametrisation('rhomulambda',outparam,Model);
            
            % middle = [NaN NaN NaN];
            middle1.rho = NaN;
            middle1.mu = NaN;
            middle1.lambda = NaN;
            middle = change_parametrisation('rhomulambda',outparam,middle1);
            
            minmax1.rho = [NaN NaN];
            minmax1.mu = [NaN NaN];
            minmax1.lambda = [NaN NaN];
            minmax = change_parametrisation('rhomulambda',outparam,minmax1);
            
        elseif isstruct(arg{2})
            middle = arg{2};
        else
            disp 'allowed var types for input argument {2}: char, struct'
            error('the var type of input argument {2} was not recognised')
        end
        
    case 3
        % disp '3 arguments'
        Model = arg{1};
        midmima = arg{2};
        outparam = arg{3};
        
        if length(Model) > 1
            error('You supplied more than one models (i.e. a struct w/ multiple models?)');
        end
        Model = change_parametrisation('rhomulambda',outparam,Model);
        
        if length(midmima.rho) > 1
            minmax1 = midmima;
            middle1.rho = NaN;
            middle1.mu = NaN;
            middle1.lambda = NaN;
        elseif length(midmima.rho) == 1
            middle1 = midmima;
            minmax1.rho = [NaN NaN];
            minmax1.mu = [NaN NaN];
            minmax1.lambda = [NaN NaN];
        else
            disp('midmima doesn''t have the right size');
        end
        middle = change_parametrisation('rhomulambda',outparam,middle1);
        minmax = change_parametrisation('rhomulambda',outparam,minmax1);
        

    otherwise
        error('wrong number of variable arguments')
end



end