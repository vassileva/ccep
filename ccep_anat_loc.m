%% Check significant CCEPs for each subject per anatomical location
% In each array enter the corresponding electrode numbers.
% eg: IGF = [1,2,3]; - electrodes 1,2 and 3 lie on inferior frontal gyrus
%
% IFG - ingerior frontal gyrus
% STG - superior temporal gyrus
% MTG - middle temporal gyrus
% AG - angular gyrus
% SMG - supramarginal gyrus
% esmPlus - identified as critical sites by ESM
% fmriPlus - identified as language-related by fMRI

%% Define electrodes for each location per subject
switch s
    case '' 
        IFG = [];
        STG = [];
        MTG = [];
        AG = [];
        SMG = [];
        esmPlus = [];
        fmriPlus = [];
end