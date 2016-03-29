function [errorN1_testmodel, errorN1_testtrain, errorN1_rel_rms, spearmanMat, pearsonMat] = ccep_test_modelChan(data,ccep,el,elm,t,ccep_parmsN1fit)
% % A function to test CCEP model. Trains the model on half the
% data (odd epochs) and is tested on the other half (even epochs).
% Outputs:
% errorN1_testmodel - model prediction errors (how does the model explain the new data)
% errorN1_testtrain - test-retest errors (how does the training data explain the new data)
% errorN1_rel_rms - Is the model better or worse than the training data at
% predicting the new data? (better if rel rms < 1)
% spearmanMat - spearman's correlation between model and new data
% pearsonMat - pearson's correlation between model and new data. As data is
% nonlinear, pearson's rho is to be used for R^2 calculation.
%
% This function tests the model only for one chosen stimulated and one measured channel. Looped for all channels in the test_model script.
% To run as a stand-alone, uncomment next section and choose individual stimulated + measured channels
%
% Hermes and Vassileva, UMC Utrecht, 2016
%% 
%%%% Choose channels: %%%
% el = 1;  % stimulated
% elm = 9; % measured

%% Define epochs
oddEp = 1:2:length(ccep(el).epochs); % odd epochs - fitting data (data2train)
evenEp = 2:2:length(ccep(el).epochs); % even epochs - testing data (data2test)

%%%%% Fitting data %%%%%
% N1 training:
data2trainN1 =...
    squeeze(...
        nanmean(...
            data(...
                elm,...
                t > ccep_parmsN1fit.t_low_N1 & t < ccep_parmsN1fit.t_up_N1,...
                ccep(el).epochs(oddEp)...
            ),...
        3)...
    );
data2trainN1 = double(data2trainN1);

% N2 training data:
% data2trainN2 =...
%     squeeze(...
%         nanmean(...
%             data(...
%                 elm,...
%                 t > ccep_parmsN1fit.t_low_N2 & t < ccep_parmsN1fit.t_up_N2,...
%                 ccep(el).epochs(oddEp)...
%             ),...
%         3)...
%     );
% data2trainN2 = double(data2trainN2);

%%%%% Testing data %%%%%
% N1 testing data:
data2testN1 =...
    squeeze(...
        nanmean(...
            data(...
                elm,...
                t > ccep_parmsN1fit.t_low_N1 & t < ccep_parmsN1fit.t_up_N1,...
                ccep(el).epochs(evenEp)...
            ),...
        3)...
    );
data2testN1 = double(data2testN1);
% N2 testing data:
% data2testN2 =...
%     squeeze(...
%         nanmean(...
%             data(...
%                 elm,...
%                 t > ccep_parmsN1fit.t_low_N2 & t < ccep_parmsN1fit.t_up_N2,...
%                 ccep(el).epochs(evenEp)...
%             ),...
%         3)...
%     );
% data2testN2 = double(data2testN2);

if find(isnan(data2trainN1),1)>0
    disp(['WARNING: input fitting data N1 has NANs, fitting function is going to crash at electrode ' int2str(elm)])
end
if find(isnan(data2testN1),1)>0
    disp(['WARNING: input training data N1 has NANs, fitting function is going to crash at electrode ' int2str(elm)])
end
% if find(isnan(data2trainN2),1)>0
%     disp(['WARNING: input fitting data N2 has NANs, fitting function is going to crash at electrode ' int2str(elm)])
% end
% if find(isnan(data2testN2),1)>0
%     disp(['WARNING: input training data N2 has NANs, fitting function is going to crash at electrode ' int2str(elm)])
% end



%% Train the model by fitting a gauss + line in the training data.

a =...
  lsqnonlin(@(x) LinePlusGauss(x,data2trainN1,ccep_parmsN1fit.t2fitN1),...
          ccep_parmsN1fit.X01,...
          ccep_parmsN1fit.LB1,...
          ccep_parmsN1fit.UB1,...
          ccep_parmsN1fit.my_options);

    % fit line
fitted_line_n1 = a(1)*sqrt(2*pi)*normpdf(ccep_parmsN1fit.t2fitN1,a(2),a(3));

%% Calculate errors
% Model prediction errors - how well does the model explain the testing (new)
% dataset:
errorN1_testmodel = sqrt(sum(bsxfun(@minus,data2testN1,fitted_line_n1).^2)); % prediction errors

% Test-retest prediction errors = how well does the training data predict
% the testing data:
errorN1_testtrain = sqrt(sum(bsxfun(@minus,data2testN1,data2trainN1).^2)); 
 
% Relative root mean square error - Is the model better than the training
% data at predicting the testing data?
% Model is better if Relative RMS < 1
% Model is worse if Relative RMS > 1
errorN1_rel_rms = errorN1_testmodel./errorN1_testtrain;

% how well does the model correlate with a new dataset
[rS,pS] = corr(data2testN1',fitted_line_n1','Type','Spearman'); % Spearman's + p-values
spearmanMat = [rS, pS];

[rP,pP] = corr(data2testN1',fitted_line_n1','Type','Pearson'); % Pearson's + p-values
pearsonMat = [rP, pP];

%% N2 fit
% % calculate least squares
% a =...
%   lsqnonlin(@(x) LinePlusGauss(x,data2trainN2,ccep_parmsN1fit.t2fitN2),...
%           ccep_parmsN1fit.X02,...
%           ccep_parmsN1fit.LB2,...
%           ccep_parmsN1fit.UB2,...
%           ccep_parmsN1fit.my_options);
% 
% % fit line
% fitted_line_n2 = a(1)*sqrt(2*pi)*normpdf(ccep_parmsN1fit.t2fitN2,a(2),a(3));

%% calculate correlation coefficient
% errorN2 = bsxfun(@minus,data2testN2,fitted_line_n2); % prediction errors
% [r2,p2] = corr(data2testN2',fitted_line_n2','Type','Spearman');

%% Plot N1 fit
% figure,
% hold on
% plot(t2fitN1,data2testN1,'k')
% plot(t2fitN1,data2trainN1,'b')
% plot(t2fitN1,fitted_line_n1,'r')
% title(['N1 ' int2str(el) ' to ' int2str(elm)])
% hold off

% figure,
% h = histogram(errorVec(el,elm,:),50)



