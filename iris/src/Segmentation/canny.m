% CANNY - Canny edge detection
%
% Function to perform Canny edge detection. Code uses modifications as
% suggested by Fleck (IEEE PAMI No. 3, Vol. 14. March 1992. pp 337-345)
%
% Usage: [gradient or] = canny(im, sigma)
%
% Arguments:   im       - image to be procesed
%              sigma    - standard deviation of Gaussian smoothing filter
%                      (typically 1)
%		       scaling  - factor to reduce input image by
%		       vert     - weighting for vertical gradients
%		       horz     - weighting for horizontal gradients
%
% Returns:     gradient - edge strength image (gradient amplitude)
%              or       - orientation image (in degrees 0-180, positive
%                         anti-clockwise)
%
% See also:  NONMAXSUP, HYSTHRESH

% Author: 
% Peter Kovesi   
% Department of Computer Science & Software Engineering
% The University of Western Australia
% pk@cs.uwa.edu.au  www.cs.uwa.edu.au/~pk
%
% April 1999    Original version
% January 2003  Error in calculation of d2 corrected
% March 2003	Modified to accept scaling factor and vertical/horizontal
%		        gradient bias (Libor Masek)
% November 2008 Added Comments only in Portuguese, (Carlos Bastos)

function [gradient, or] = canny(im, sigma, scaling, vert, horz)

%Alterado aqui por Libor
xscaling = vert;
yscaling = horz;
%-----------------------

hsize = [6*sigma+1, 6*sigma+1];   % The filter size.

gaussian = fspecial('gaussian',hsize,sigma);
im = filter2(gaussian,im);        % Smoothed image.

%Alterado aqui por Libor
im = imresize(im, scaling);
%-----------------------

[rows, cols] = size(im);

%desloca a imagem 1 coluna a esquerda e preenche a ultima coluna com zeros
%e subtrai de uma imagem deslocada para a direita, com a primeira coluna
%zero, [1 0 -1] como em Fleck pg 339 (3) (Horizontal)
h =  [  im(:,2:cols)  zeros(rows,1) ] - [  zeros(rows,1)  im(:,1:cols-1)  ];
%desloca a imagem 1 linha para cima e preenche a ultima linha com zeros
%e subtrai de uma imagem deslocada para baixo, com a primeira linha
%zero, [1 0 -1] como em Fleck pg 339 (3) (Vertical)
v =  [  im(2:rows,:); zeros(1,cols) ] - [  zeros(1,cols); im(1:rows-1,:)  ];
d1 = [  im(2:rows,2:cols) zeros(rows-1,1); zeros(1,cols) ] - ...
                               [ zeros(1,cols); zeros(rows-1,1) im(1:rows-1,1:cols-1)  ];
d2 = [  zeros(1,cols); im(1:rows-1,2:cols) zeros(rows-1,1);  ] - ...
                               [ zeros(rows-1,1) im(2:rows,1:cols-1); zeros(1,cols)   ];

%Alterado aqui por Libor
X = ( h + (d1 + d2)/2.0 ) * xscaling;
Y = ( v + (d1 - d2)/2.0 ) * yscaling;
%-----------------------

%Como acima zerou (ou n�o) devido a escala, tentar investigar se
%� possivel alterar isso em outro lugar e n�o suprimir diretamente
%os termos de Y ou X, se desejarmos os gradientes horizontais e verticais
gradient = sqrt(X.*X + Y.*Y); % Gradient amplitude.

or = atan2(-Y, X);            % Angles -pi to + pi.
neg = or<0;                   % Map angles to 0-pi.
or = or.*~neg + (or+pi).*neg; 
or = or*180/pi;               % Convert to degrees.
