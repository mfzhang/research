% createiristemplate - generates a biometric template from an iris in
% an eye image.
%
% Usage: 
% [template, mask] = createiristemplate(eyeimage_filename, normalized_dir, encoded_dir)
%
% Arguments:
%	eyeimage_filename   - the file name of the eye image
%   eyeimage_dir        - the directory where image files are placed
%   normalized_dir      - the directory where normalized files should be
%                         saved or loaded
%   encoded_dir         - the directory where encoded files should be
%                         saved or loaded
%
% Output:
%	template		    - the binary iris biometric template
%	mask			    - the binary iris noise mask
%
% Modified by:
% Euclides Arcoverde
% enan@cin.ufpe.br
% Informatics Center / Centro de Informatica
% Federal Univerty of Pernambuco / Universidade Federal de Pernambuco
% April 2014
%
% Carlos Bastos
% cacmb@cin.ufpe.br
% Informatics Center / Centro de Informatica
% Federal Univerty of Pernambuco / Universidade Federal de Pernambuco
% November 2008
% 
% Original Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003

function [template, mask] = createiristemplate(eyeimage_filename, eyeimage_dir, normalized_dir, encoded_dir, ...
                                wavelength, sigmaOnf, angl, thetaSigma)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Global Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% path for writing diagnostic images
global DIAGPATH
DIAGPATH = [eyeimage_dir, 'diagnostics/'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
radial_res = 20;
angular_res = 240;
% with these settings a 9600 bit iris template is created

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%feature encoding parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin <= 5
    %Radial
    wavelength=14;
    sigmaOnf=0.50; %aprox. 2 octaves
    %Angular
    angl = 0;
    thetaSigma = pi/4;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IRIS SEGMENTATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load an EYE image
eyeimage = imread([eyeimage_dir, eyeimage_filename]); 

%Produce the name of the file to be saved or that was save previously
img_segmented_filename = [[eyeimage_dir, eyeimage_filename], '-houghpara.mat'];

%Check the status of the file
stat = exist(img_segmented_filename, 'file');

if stat ~= 0
    % if this file has been processed before
    % then load the circle parameters and
    % noise information for that file.
    load(img_segmented_filename);    
    disp('Parâmetros da segmentação carregados');
else    
    % if this file has not been processed before
    % then perform automatic segmentation and
    % save the results to a file    
    [circleiris circlepupil imagewithnoise] = segmentiris(eyeimage);
    save(img_segmented_filename, 'circleiris', 'circlepupil', 'imagewithnoise');    
    disp('Parâmetros da segmentação estimados');
    write_diagnostics(DIAGPATH, eyeimage_filename, eyeimage, imagewithnoise, circleiris, circlepupil)
end
% Discussion about the returned variables:
% circleiris contains the three parameters about the segmented iris circle:
% circleiris(1) - y position
% circleiris(2) - x position
% circleiris(3) - r radius
% circlepupil(1) - y position
% circlepupil(2) - x position
% circlepupil(3) - r radius
% imagewithnoise - the eye image, with occludded pixels values changed by Matlab NaN;
%                  this is necessary for not including this information to the final
%                  coding and to help building the mask
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IRIS NORMALIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Change the filename for normalization
img_normalized_filename = [normalized_dir, eyeimage_filename, '-normalized.mat'];

%Check the status of the file
stat = exist(img_normalized_filename, 'file');

if stat ~= 0  
    % if this file has been processed before
    % then load the normalized images for iris and
    % noise information
    load(img_normalized_filename);
    disp('Nomalização carregada');
else
    % if this file has not been processed before
    % then perform normalization and
    % save the results to a file        
    [polar_array noise_array] = normaliseiris(imagewithnoise, circleiris(2), ...
        circleiris(1), circleiris(3), circlepupil(2), circlepupil(1), circlepupil(3), eyeimage_filename, radial_res, angular_res);    
    
    %Save the results to 'normalized' directory
    save(img_normalized_filename, 'polar_array', 'noise_array');
    disp('Nomalização criada');

    % WRITE NORMALISED PATTERN, AND NOISE PATTERN
    w = cd;
    cd(DIAGPATH);
    imwrite(polar_array, [eyeimage_filename,'-polar.bmp'],      'bmp');
    imwrite(noise_array, [eyeimage_filename,'-polarnoise.bmp'], 'bmp');
    cd(w);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IRIS FEATURE CODING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%Change the filename for codification
img_encoded_filename = [encoded_dir, eyeimage_filename, '-encoded.mat'];

%Check the status of the file
stat = exist(img_encoded_filename, 'file');

if stat ~= 0  
    % if this file has been processed before
    % then load the normalized images for iris and
    % noise information
    load (img_encoded_filename);
    disp('Codificação carregada');
else
    % if this file has not been processed before
    % then perform feature encodind and
    % save the results to a file        
    % perform feature encoding
    [template mask] = encode_iris(polar_array, noise_array, wavelength, sigmaOnf, angl, thetaSigma);
    
    %Save the results to 'encoded' directory
    save(img_encoded_filename, 'template', 'mask');
    disp('Codificação criada');
end
