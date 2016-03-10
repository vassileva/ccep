
% first run the preprocessing in master02

%% %%%%%%%
%% %%%%%%% Now, we are going to fit some data
%% %%%%%%%

%% N1 and N2 detection
close all

% Define electrodes
el = 23; % stimulated electrode

% def_chan;

% Preallocate matrices to contain components' amplitude, width and peak latency.
% 1st dim - stimulated electrode
% 2nd dim - measured electrode
% 3rd dim - (a(1), a(2) - Latency, a(3), a(4) - Offset, 4 - Amplitude, 5 - Width)
n1_mat_all = NaN(size(data,1),size(data,1),6); % parameters matrix

% Preallocate matrices for rsss:
rmseN1_all = NaN(size(data,1),size(data,1),2);


%% And now run fitting procedure

ccep_parmsN1fit = ccep_setFitParms(times); % load fit parameters (times to fit, starting points, lower/upper bounds)

tic
for elec_ms = 1:size(data,1)
    if mod(elec_ms,10) == 0, disp(['el ' int2str(elec_ms) ' of ' int2str(size(data,1))]),end
    data2fit = squeeze(nanmean(data(elec_ms,:,ccep(el).epochs),3));
    if sum(isnan(data2fit))==0 % check whether this epoch was bad
        [n1_mat,rmseN1,fitted_line_n1] = ...
            ccep_fitN1(ccep_parmsN1fit,ccep,data,times,el,elec_ms);
        n1_mat_all(el,elec_ms,:) = n1_mat;
    end
end
toc

clear data2fit fitted_line_n1 

%%% I DO NOT KNOW WHETHER THIS IS THE GOOD WAY TO DO THIS
% CHECK N1 for wrong fits, when the latency is the lower edge of time, we're
% just getting the amplifier return to baseline
for elec_ms = 1:size(data,1)
    if abs(n1_mat_all(el,elec_ms,3) - ccep_parmsN1fit.LB1(2))<1;
        n1_mat_all(el,elec_ms,:) = 0;
    end
end


%% plot fitting result for one measured electrode

elm = 4;
t_min = 5;

t_n1 = times>ccep_parmsN1fit.t_low_N1 & times<ccep_parmsN1fit.t_up_N1;

% fitted line
n1_elm = n1_mat_all(el,elm,:);
fitted_line_n1 = n1_elm(1)*sqrt(2*pi)*normpdf(ccep_parmsN1fit.times2fitN1,n1_elm(2),n1_elm(3)) + n1_elm(4);

figure,hold on
t_plot = times(times>t_min);
plot(t_plot,zeros(size(t_plot)),'k:')

data_plot = squeeze(data(elm,times>t_min,ccep(el).epochs));
plot(t_plot,data_plot,'Color',[.9 .9 .9])

data_plot = squeeze(mean(data(elm,times>t_min,ccep(el).epochs),3));
plot(t_plot,data_plot,'k')

plot(times(t_n1),fitted_line_n1,'r')

%% render figure
figure
ctmr_gauss_plot(cortex,[0 0 0],0)

n1_amp = n1_mat_all(el,:,5);
n1_amp(isnan(n1_amp)) = 0;
n1_lat = n1_mat_all(el,:,2);
n1_lat(isnan(n1_lat)) = 0;

el_add_sizecolor(elecmatrix,n1_amp,n1_lat,[200],40)
el_add(elecmatrix(ccep(el).els,:),'k',50) % stimulated electrodes


%% Save data


