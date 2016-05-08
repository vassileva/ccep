function [IFG, SMG, STG, els2check, esmPlus, fmriPlus] = ccep_anat_locs(s)
%% Defines electrodes in anatomical locatoins:
% [IFG, SMG, AG, STG, MTG, els2check, esmPlus, fmriPlus] = ccep_anat_locs(s)
%
%         s - subject code - 1x2 char
%       IFG - ingerior frontal gyrus
%       SMG - supramarginal gyruss
%        AG - angular gyrus
%       STG - superior temporal gyrus
%       MTG - middle temporal gyrus
% els2check - an array of the electrodes on all locations in the order: IFG, STG, MTG, AG, SMG
%   esmPlus - identified as critical language cortex by direct electrical stimulation mapping
%  fmriPlus - identified as language cortex by fMRI
%
% A.G. Vassileva & D. Hermes, UMC Utrecht 2016


%% Define electrodes for each location per subject
switch s
    case '99' 
        IFG = [1,2,9];
        STG = [17:21,25:28,30];
        MTG = [29 37:40];
        AG = [16,23,24,31];
        SMG = [6,7,14,15,22];
        esmPlus = [17,18,22,23,24,15,31];
        fmriPlus = [41,49,51];
        
    case '31' 
        IFG = [51,58,59,69,77,78,79];
        STG = [56,64,83:87,94];
        MTG = [95,96];
        AG = [];
        SMG = [40,47,48,55,88];
        esmPlus = [19,20,27,28,36];
        fmriPlus = [41,49,51,85,96];
        
    case '78'
        IFG = [43:45,51:53,59];
        STG = [56,61:64];
        MTG = [];
        AG = [];
        SMG = [];
        esmPlus = [43,44,45,51,52];
        fmriPlus = [];
        
    case '81'
        IFG = [25:28,33:36,42:44];
        STG = [47,48];
        MTG = [];
        AG = [];
        SMG = [24,32,40];
        esmPlus = [36,44,45];
        fmriPlus = [];
        
    case '88'
        IFG = [29,39:40,47,48,56];
        STG = [36,37,44,50,51,57,58];
        MTG = [34,35,41,49];
        AG = [];
        SMG = [65:67];
        esmPlus = [];
        fmriPlus = [];
end

els2check = [IFG, SMG, STG];
%% 