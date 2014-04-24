% normaliseiris - performs normalisation of the iris region by
% unwraping the circular region into a rectangular block of
% constant dimensions.
%
% Usage: 
% [polar_array, polar_noise] = normaliseiris(image, x_iris, y_iris, r_iris,...
% x_pupil, y_pupil, r_pupil,eyeimage_filename, radpixels, angulardiv)
%
% Arguments:
% image                 - the input eye image to extract iris data from
% x_iris                - the x coordinate of the circle defining the iris
%                         boundary
% y_iris                - the y coordinate of the circle defining the iris
%                         boundary
% r_iris                - the radius of the circle defining the iris
%                         boundary
% x_pupil               - the x coordinate of the circle defining the pupil
%                         boundary
% y_pupil               - the y coordinate of the circle defining the pupil
%                         boundary
% r_pupil               - the radius of the circle defining the pupil
%                         boundary
% eyeimage_filename     - original filename of the input eye image
% radpixels             - radial resolution, defines vertical dimension of
%                         normalised representation
% angulardiv            - angular resolution, defines horizontal dimension
%                         of normalised representation
%
% Output:
% polar_array
% polar_noise
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

function [polar_array, polar_noise] = normaliseiris(image, x_iris, y_iris, r_iris,...
x_pupil, y_pupil, r_pupil,eyeimage_filename, radpixels, angulardiv)

%Adjust variables
radiuspixels = radpixels + 2; %+2 = 1 para pupila e 1 para iris
angledivisions = angulardiv-1; %
%esse angledivisions = angulardiv-1; eu acho q eh pq vai de 0 a n-1, o que
%da a mesma quantidade de elementos (n) que 1 a n;

%divisoes radiais / radial divisions
r = 0:(radiuspixels-1); %0 indica pupila e (radiuspixels-1) indica a borda da iris

%divisões angulares / angular divisions
theta = 0:(2*pi/angledivisions):2*pi;

%update parameters to avoid type incompatibility
%transforma os parametros em double para evitar incompatibilidade
x_iris = double(x_iris);
y_iris = double(y_iris);
r_iris = double(r_iris);

x_pupil = double(x_pupil);
y_pupil = double(y_pupil);
r_pupil = double(r_pupil);

% calculate displacement of pupil center from the iris center
ox = x_pupil - x_iris;
oy = y_pupil - y_iris;

if ox <= 0
    sgn = -1;
elseif ox > 0
    sgn = 1;
end

if ((ox==0) && (oy > 0))
    sgn = 1;  
end

%update parameters to avoid type incompatibility
%transforma as variaveis em double para evitar incompatibilidade
r = double(r);
theta = double(theta);

alpha = ones(1,angledivisions+1)*(ox^2 + oy^2);

% need to do something for ox = 0
if ox == 0
    phi = pi/2;
else
    phi = atan(oy/ox);
end

beta = sgn.*cos(pi - phi - theta);

% calculate radius around the iris as a function of the angle
r = (sqrt(alpha).*beta) + ( sqrt( alpha.*(beta.^2) - (alpha - (r_iris^2))));

%retira r_pupil, para que a distancia seja zero em r_pupil e maxima em
%r_iris
r = r - r_pupil;

%transforma esta distancia radial (em funcao do angulo) em uma matriz, com
%as dimensões apropriadas
rmat = ones(1,radiuspixels)'*r;
%normaliza para que os raios fiquem entre 0 e 1
rmat = rmat.* (ones(angledivisions+1,1)*[0:1/(radiuspixels-1):1])';
%adiciona o valor r_pupil, para assim, ficar com os valores reais do raio
%na imagem
rmat = rmat + r_pupil;

%limpa variaveis / clear variables
clear alpha beta phi sgn oy ox

% exclude values at the boundary of the pupil iris border, and the iris scelra border
% as these may not correspond to areas in the iris region and will introduce noise.
%
% ie don't take the outside rings as iris data.
rmat  = rmat(2:(radiuspixels-1), :);

% calculate cartesian location of each data point around the circular iris
% region
xcosmat = ones(radiuspixels-2,1)*cos(theta);
xsinmat = ones(radiuspixels-2,1)*sin(theta);

xo = rmat.*xcosmat;    
yo = rmat.*xsinmat;

%soma um valor para dar as coordenadas reais na imagem
xo = x_pupil+xo;
yo = y_pupil-yo;%-,pq a origem é invertida

%limpa variaveis / clear variables
clear xcosmat xsinmat rmat

%Maybe here we could change for utilize the pixel value at (x,y) or round x
%and y values to use the pixel value
% extract intensity values into the normalised polar representation through
% interpolation
[x,y] = meshgrid(1:size(image,2),1:size(image,1));  
polar_array = interp2(x,y,image,xo,yo);

% create noise array with location of NaNs in polar_array
polar_noise = zeros(size(polar_array));
coords = find(isnan(polar_array));
polar_noise(coords) = 1;

polar_array = double(polar_array)./255; %normaliza o resultado da interpolacao, dividindo por 255

%Maybe here we could change the way it changes NaN values.
%replace NaNs before performing feature encoding
% coords = find(isnan(polar_array));
% polar_array(coords) = 0.0;

coords = find(isnan(polar_array));
polar_array2 = polar_array;
polar_array2(coords) = 0.5;
avg = sum(sum(polar_array2)) / (size(polar_array,1)*size(polar_array,2));
polar_array(coords) = avg;