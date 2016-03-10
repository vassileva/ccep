

function_path = '/Fridge/users/dora/ccep/m-files/';
addpath(function_path);

%identify the list of subjects
clear all
subjects = {'99','31','78','50'};

% subject to analyse
s_nr = 1;

% Create structure to save data for 1 subject
rmse = struct('subj', [0], 'n1', [], 'n2', []); % root mean square error
ccepmat = struct('subj', [0], 'n1', [], 'n2', []); % ccep parameters; contains matrices with amplitude, width and peak latency

%% Load data

s = subjects{s_nr}; % specify subject
s_info = subj_info_ccep(s); % get subject info

eval(['ccep = subj_info_SPES_' s]); % make CCEP structure

load(s_info.data,'data','times'); % load the data
load(s_info.cortex)
load(s_info.els)

clear setname
disp('data loaded')

%% Detect outliers based on jumps and voltage threshold works well
outlier_matrix = ccep_detectOutliers(data,ccep,times,1);

%% Remove the outliers
% outliers are replaced with NaNs

data = ccep_clearOut(data,outlier_matrix);
disp('outliers removed')

%% Correction for an offset
% choose baseline or median correction

% Baseline correction:
% subtracts for every single trial, the average from a baseline period
data = ccep_baseline_corr(data,times);

% Median correction
% corrects for a constant difference with the median response
data = ccep_median_corr(data,times,ccep,[10 600]);

%% Plot electrode grid
figure
ctmr_gauss_plot(cortex,[0 0 0],0)
label_add(elecmatrix)

%% %%%%%%%
%% %%%%%%% Here, we are done with the preprocessing, and we can look at some CCEPs
%% %%%%%%%

%% Plot all CCEPs for chosen electrode

el = 23; % choose electrode 
data2plot = nanmean(data(:,:,ccep(el).epochs),3); % take the mean across epochs
t_plot = times(times>10 & times<500); % pick the times in ms that I want to plot
data_plot = data2plot(:,times>10 & times<500); % pick the same times for the data

% make a figure
figure('Position', [0 0 800 600]);

for k=1:size(data_plot,1) % loop across electrodes
    subplot(ceil(size(data2plot,1)/10),10,k),hold on % make a subplot, we need 8x8 for 64 electrodes, more if we have more electrodes
    plot(t_plot,zeros(size(t_plot)),'k:') % plot a zero-line
    plot(t_plot,data_plot(k,:)) % plot the data as a function of time
    ylim([-700 300])
    set(gca,'YTick',[],'XTick',[])
    ylabel([int2str(k)])
end


%% Plot CCEP for a specific pair
el = 1;
elm = 24;

figure('Position', [0 0 300 300]),hold on
set(gcf,'PaperPositionMode', 'auto')

cm = colormap(jet);
for k=1:length(ccep(el).epochs)
    plot(times,data(elm,:,ccep(el).epochs(k)),...
        'LineWidth',1,...
        'Color',cm(round(k*size(cm,1)/length(ccep(el).epochs)),:))
end
plot(times,squeeze(mean(data(elm,:,ccep(el).epochs),3)),'k',...
'LineWidth',2)

title({['CCEP measured el ' int2str(elm)],...
 [' stim el ' int2str(el)]})

ylim([-900 300])  % max voltage amps differ 
xlim([-100 500])

xlabel('ms')
ylabel('microV')



