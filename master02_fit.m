
% first run the preprocessing in master01

%% %%%%%%%
%% %%%%%%% Now, we are going to fit some data
%% %%%%%%%

%% N1 and N2 detection
close all

% % Define electrodes
% % el = 23; % stimulated electrode
% 
% % Preallocate matrices to contain components' amplitude, width and peak latency.
% % 1st dim - stimulated electrode
% % 2nd dim - measured electrode
% % 3rd dim - (a(1), a(2) - Latency, a(3), a(4) - Offset, 4 - Amplitude, 5 - Width)
% n1_mat_all = NaN(size(data,1),size(data,1),6); % parameters matrix
% 
% % Preallocate matrices for rsss:
% rmseN1_all = NaN(size(data,1),size(data,1),2);
% 
% %% And now run fitting procedure
% 
% ccep_parmsN1fit = ccep_setFitParms(t); % load fit parameters (t to fit, starting points, lower/upper bounds)
% 
% tic
% for el = 1:size(data,1)
%     for elec_ms = 1:size(data,1)
%     %     if mod(elec_ms,10) == 0, disp(['el ' int2str(elec_ms) ' of ' int2str(size(data,1))]),end
%         data2fit = squeeze(nanmean(data(elec_ms,:,ccep(el).epochs),3));
%         if sum(isnan(data2fit))==0 % check whether this epoch was bad
%             [n1_vec,rmseN1,fitted_line_n1] = ...
%                 ccep_fitN1(ccep_parmsN1fit,ccep,data,t,el,elec_ms);
%             n1_mat_all(el,elec_ms,:) = n1_vec;
%         end
%     end
%     disp(['el ' int2str(el)])
% end
% toc
% 
% clear data2fit fitted_line_n1 

%% Run fitting procedure for each trial separately

% load fit parameters (t to fit, starting points, lower/upper bounds):
ccep_parmsN1fit = ccep_setFitParms(t); 

% Preallocate matrices:
n1_mat_epochs = zeros(size(data,1),10,6);
n1_ttest = NaN(size(data,1),10,2);

% This big structure contains the number of each electrode, its anatomical
% location, the fit data and the t-test data:
n1_mat_all_epochs = struct('el', [], 'loc',[], 'fit', [], 'ttest', []);



% This script creates vectors named after the anatomical locations. Each
% vector contains the electrode numbers that correspond to that location.
% To change electrode numbers, edit script.
ccep_anat_locs;

% concatenate all locations for the purposes of the next loop:
elsToCheck = [IFG, STG, MTG, AG, SMG];
% set alpha for t-test
alphaVal = 0.05/length(elsToCheck);

tic
for el = elsToCheck % loop through stimulated electrodes
    if numel(ccep(el).epochs) == 0 % skip this electrode, if it wasn't stimulated.  
        disp(['el ' int2str(el) ' not stimulated'])
    else
        for elm = elsToCheck % loop through measured electrodes
            % Calculate a threshold to check against in the t-test.
            % 3 standard deviations of the pre-stimulation baseline between
            % -500 and -100 ms
            data2check = squeeze(nanmean(data(elm,:,ccep(el).epochs),3));
            signThr = -3*std(data2check(1,t > -500 & t < -100),[],2);
            for ep = 1:10 % loop through epochs
                
                % check if epoch has NaNs and if not - run fit and test
                % procedures
                epochCheck = squeeze(nanmean(data(elm,:,ccep(el).epochs(ep)),3));
                
                if sum(isnan(epochCheck))==0

                    % fit each epoch individually:
                    [n1_vec,rmseN1,~] = ...
                        ccep_fitN1_ind_epochs(ccep_parmsN1fit,ccep,data,t,el,elm,ep);
                    n1_mat_epochs(elm,ep,:) = n1_vec;

                    % do a t-test for the amplitude against the calculated significance threshold 
                    % and store the p-value and t-statistic:
                    [~,p,~,stats] = ttest(n1_mat_epochs(elm,ep,5), signThr, 'Dim', 2, 'Tail', 'both', 'Alpha', alphaVal);
                    n1_ttest(elm,ep,:) = [stats.tstat p];
                    
                else
                    n1_mat_epochs(elm,ep,:) = NaN;
                    n1_ttest(elm,ep,:) = NaN;
                    clear p stats.tstat
                end
            end
        end
        disp(['el ' int2str(el)])
        % Write data in structure. If you don't want to fit and test all electrodes,
        % it skips them, but keeps structure with the same size as data size
        % (i.e. number of electrodes). Structure fields for untested electrodes
        % remain empty
        n1_mat_all_epochs(el).el = el;
        n1_mat_all_epochs(el).fit = n1_mat_epochs;
        n1_mat_all_epochs(el).ttest = n1_ttest;
    end    
end

switch s
    case '31'
        n1_31 = n1_mat_all_epochs;
        save('n1_31', 'n1_31')
    case '78'
        n1_78 = n1_mat_all_epochs;
        save('n1_78', 'n1_78')
end

% Write down the location corresponding to each electrode in the big
% structure:
for loc = IFG
    n1_mat_all_epochs(loc).loc = 'IFG';
end
for loc = STG
    n1_mat_all_epochs(loc).loc = 'STG';
end
for loc = MTG
    n1_mat_all_epochs(loc).loc = 'MTG';
end
for loc = AG
    n1_mat_all_epochs(loc).loc = 'AG';
end
for loc = SMG
    n1_mat_all_epochs(loc).loc = 'SMG';
end

clear data2fit
toc

 %% I DO NOT KNOW WHETHER THIS IS THE GOOD WAY TO DO THIS
% % CHECK N1 for wrong fits, when the latency is the lower edge of time, we're
% % just getting the amplifier return to baseline
% for elec_ms = 1:size(data,1)
%     if abs(n1_mat_all(el,elec_ms,3) - ccep_parmsN1fit.LB1(2))<1;
%         n1_mat_all(el,elec_ms,:) = 0;
%     end
% end


%% plot fitting result for one measured electrode
% el = 1;
% elm = 9;
% t_min = 5;
% 
% t_n1 = t>ccep_parmsN1fit.t_low_N1 & t<ccep_parmsN1fit.t_up_N1;
% 
% % fitted line
% n1_elm = mean(n1_mat_all_epochs(el).fit(elm,:,:),2);
% fitted_line_n1 = n1_elm(1)*sqrt(2*pi)*normpdf(ccep_parmsN1fit.t2fitN1,n1_elm(2),n1_elm(3));
% 
% figure,hold on
% t_plot = t(t>t_min);
% plot(t_plot,zeros(size(t_plot)),'k:')
% 
% data_plot = squeeze(data(elm,t>t_min,ccep(el).epochs));
% plot(t_plot,data_plot,'Color',[.9 .9 .9])
% 
% data_plot = squeeze(mean(data(elm,t>t_min,ccep(el).epochs),3));
% plot(t_plot,data_plot,'k')
% 
% plot(t(t_n1),fitted_line_n1,'r')
% 
% %% render figure
% figure
% ctmr_gauss_plot(cortex,[0 0 0],0)
% 
% n1_amp = mean(n1_mat_all_epochs(el).fit(elm,:,5),2);
% n1_amp(isnan(n1_amp)) = 0;
% n1_lat = mean(n1_mat_all_epochs(el).fit(elm,:,2),2);
% n1_lat(isnan(n1_lat)) = 0;
% 
% el_add_sizecolor(elecmatrix,n1_amp,n1_lat,[200],40)
% el_add(elecmatrix(ccep(el).els,:),'k',50) % stimulated electrodes
% 
% %% Save data
% 
% %% DO a t-test and render the results
% 
% alphaVal = 0.05/length(elsToCheck); 
% % Bonferroni correction for multiple comparisons across electrodes % FDR is less conservative
% % do a t-test after the fit
% 
% for k=1:length(elsToCheck)
%     el = elsToCheck(k);
%     n1_mat_all_epochs(el).ttestcheck = NaN(length(elsToCheck),2);
%     for elm = 1:length(elsToCheck)
%         % test amplitude against -50
%         [h,p,ci,stats]=ttest(n1_mat_all_epochs(el).fit(elsToCheck(elm),:,5), -50, 'Dim', 2, 'Tail', 'both', 'Alpha', alphaVal); % 5 is the amplitude
%         n1_mat_all_epochs(el).ttest(elm,:)=[stats.tstat p];
%     end
% end
% 
% %% render the results
% 
% figure
% 
% ctmr_gauss_plot(cortex,[0 0 0],0)
% el_add(elecmatrix(elsToCheck,:),'k',10)

%% get the things we want to plot

screenSize = get( groot, 'Screensize' );
figure('Position', screenSize);
set(gcf,'PaperPositionMode', 'auto')
    
for el = elsToCheck
    if numel(ccep(el).epochs) == 0 % skip this electrode, if it wasn't stimulated.  
        disp(['el ' int2str(el) ' not stimulated'])
    else
        n1_p = n1_mat_all_epochs(el).ttest(:,2);

        n1_amp = mean(n1_mat_all_epochs(el).fit(elsToCheck,:,5),2);
        n1_lat = mean(n1_mat_all_epochs(el).fit(elsToCheck,:,2),2);

        n1_amp(n1_p>=0.05) = 0; % if its not significant, we're setting it to zero

        ctmr_gauss_plot(cortex,[0 0 0],0)
        el_add(elecmatrix(ccep(el).els,:),[.9 .9 .9],20)
        el_add_sizecolor(elecmatrix(elsToCheck,:),n1_amp,n1_lat,[200],40)

        print(gcf,'-r300', '-dpng', strcat(['figures/cortexCCEPs/cortex_cceps_el' int2str(el) '_s' s]))
        clf(gcf,'reset');
    end
end

close all