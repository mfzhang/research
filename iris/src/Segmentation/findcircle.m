% findcircle - returns the coordinates of a circle in an image using the Hough transform
% and Canny edge detection to create the edge map.
%
% Usage: 
% [row, col, r] = findcircle(image,lradius,uradius,scaling, sigma, hithres, lowthres, vert, horz, type)
%
% Arguments:
%	image		    - the image in which to find circles
%	lradius		    - lower radius to search for
%	uradius		    - upper radius to search for
%	scaling		    - scaling factor for speeding up the
%			          Hough transform
%	sigma		    - amount of Gaussian smoothing to
%			          apply for creating edge map.
%	hithres		    - threshold for creating edge map
%	lowthres	    - threshold for connected edges
%	vert		    - vertical edge contribution (0-1)
%	horz		    - horizontal edge contribution (0-1)
%   type            - type of image being processed: 1 iris, 2 pupil
%	
% Output:
%	circleiris	    - centre coordinates and radius
%			          of the detected iris boundary
%	circlepupil	    - centre coordinates and radius
%			          of the detected pupil boundary
%	imagewithnoise	- original eye image, but with
%			          location of noise marked with
%			          NaN values
%
% Modified by: 
% Carlos Bastos
% cacmb@cin.ufpe.br
% Informatics Center / Centro de Informatica
% Federal Univerty of Pernambuco / Universidade Federal de Pernambuco
% November 2008
% 
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003

function [row, col, r] = findcircle(image,lradius,uradius,scaling, sigma, hithres, lowthres, vert, horz, type)

%scaled bounds to search in hough space parameters
%limites escalados para procurar no espaço transformado de hough
lradsc = round(lradius*scaling);
uradsc = round(uradius*scaling);

rd = round( scaling*(uradius - lradius));

%Verify if it's processing an iris or pupil image
if type == 1 %iris
   %perform histogram equalization, only for segmentation, to increase
   %image contrast
   image = histeq(image, 256);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Perform CANNY edge detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate the edge image
[I2 or] = canny(image, sigma, scaling, vert, horz);
%Esta implementacao de canny tende a deixar os pixels com valores muito
%baixos (perto do preto), %assim uma correção de gama (Gama Transformation)
%faz com que os detalhes outrora escondidos %tonem-se visíveis.
I3 = adjgamma(I2, 1.9);
I4 = nonmaxsup(I3, or, 1.5);
edgeimage = hysthresh(I4, hithres, lowthres);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Remove noise from the edge image to speed up 
%circular hough transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
edgeimage = remove_noise(edgeimage);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Perform Circular Hough Transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Aqui demora! Here you should wait a little bit.
% perform the circular Hough transform
h = houghcircle(edgeimage, lradsc, uradsc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Find the maximum value for Hough parameter space
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxtotal = 0;

% find the maximum in the Hough space, and hence
% the parameters of the circle
for i=1:rd
    
    layer = h(:,:,i);
    [maxlayer] = max(max(layer));
    
    
    if maxlayer > maxtotal
        
        maxtotal = maxlayer;
        
        
        r = int32((lradsc+i) / scaling);
        
        [row,col] = ( find(layer == maxlayer) );
        
        
        row = int32(row(1) / scaling); % returns only first max value
        col = int32(col(1) / scaling);    
        
    end   
    
end