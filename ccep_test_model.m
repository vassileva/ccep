%% Run model testing procedure for a subject
% Output is:
% errorN1_testmodel_all - el (stimulated electrode) x elm (measured
% electrode) matrix of model prediction errors
% 
% errorN1_testtrain_all -  el (stimulated electrode) x elm (measured
% electrode) matrix of test-retest errors
%
% errorN1_rel_rms_all - el (stimulated electrode) x elm (measured
% electrode) matrix of relative root mean square errors.
% Is the model better or worse than the training data at
% predicting the new data? (better if rel rms < 1)
%
% rmatN1 - correlation coefficients between fitted model and testing data for N1 component
%     dimension 1 - stimulated electrode
%     dimension 2 - measured electrode
%     dimension 3(1) - Spearman's rho
%     dimension 3(2) - p-value for Spearman's
%     dimension 3(3) - r squared
%% Run
ccep_parmsN1fit = ccep_setFitParms(t); % fitting parameters

% preallocate empty matrices to store outputs:
errorN1_testmodel_all = zeros(size(data,1),size(data,1));
errorN1_testtrain_all = zeros(size(data,1),size(data,1));
errorN1_rel_rms_all = zeros(size(data,1),size(data,1));
rmatN1 = zeros(size(data,1),size(data,1),3);

for el = 1:size(data,1)
    for elm = 1:size(data,1)
        data2fit = squeeze(mean(data(elm,:,ccep(el).epochs),3));
        if sum(isnan(data2fit))>0 % check whether this epoch is bad and fill with NaNs if it is
                rmatN1(el,elm,1) = NaN;
                rmatN1(el,elm,2) = NaN;
                rmatN1(el,elm,3) = NaN;
                errorN1_testmodel_all(el,elm) = NaN;
                errorN1_testtrain_all(el,elm) = NaN;
                errorN1_rel_rms_all(el,elm) = NaN;
                
        elseif sum(isnan(data2fit))==0 % If it isn't run model testing function and write down results
            test_modelChan;
                rmatN1(el,elm,1) = spearmanMat(1); % spearman's
                rmatN1(el,elm,2) = spearmanMat(2); % p-value for spearman's
                rmatN1(el,elm,3) = pearsonMat(1)^2; % r squared
                errorN1_testmodel_all(el,elm) = errorN1_testmodel;
                errorN1_testtrain_all(el,elm) = errorN1_testtrain;
                errorN1_rel_rms_all(el,elm) = errorN1_rel_rms;
        end
    end
    disp (['subject ' s ' el ' int2str(el) ' done'])
end

%% Save data:

save('model_test_outputs', 'rmatN1', 'errorN1_testmodel_all', 'errorN1_testtrain_all', 'errorN1_rel_rms_all');
% % disp('data saved in model_test_outputs')


 
