% encode - generates a biometric template from the normalised iris region,
% also generates corresponding noise mask
%
% Usage: 
% [template mask] = encode_iris(polar_array, polar_noise, wavelenght, sigmaOnf, angl, thetaSigma)
%
% Arguments:
% polar_array       - normalised iris region
% noise_array       - corresponding normalised noise region map
% wavelength        - base wavelength
% sigmaOnf          - bandwidth parameter for radial direction
% angl              - orientation angle of the filter
% thetaSigma        - bandwidth parameter for angular direction
%
% OBS: all values that represents angles are in radians
%
% Output:
% template          - the binary iris biometric template
% mask              - the binary iris noise mask
%
% Original Author: 
% Carlos Bastos
% cacmb@cin.ufpe.br
% Informatics Center / Centro de Informatica
% Federal Univerty of Pernambuco / Universidade Federal de Pernambuco
% November 2008
% Using Comments from "encode.m" by Libor Masek

function [template mask] = encode_iris(polar_array, polar_noise, wavelenght, sigmaOnf, angl, thetaSigma)

% PQ = paddedsize(size(polar_array));
% rows = PQ(1); cols = PQ(2);
[rows cols] = size(polar_array);

%Perform Fourier Transform of the normalized image
%FFT da iris normalizada
IMG = fft2(polar_array, rows, cols);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Building the 2D log-Gabor Filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
logGabor2d = create_loggabor2d(rows, cols, wavelenght, sigmaOnf, angl, thetaSigma);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Filtering the image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
result = ifft2( IMG .* logGabor2d );

%como a imagem foi "aumentada" pelo paddedsize, agora eh hora de voltar ao
%tamanho normal
% result = result(1:size(polar_array,1),1:size(polar_array,2));

%quantizacao de fase
H1 = real(result) >= 0;
H2 = imag(result) >= 0;

%
% H3 = abs(result) < 0.0001;

%create the template
%cria o template
template = zeros(size(polar_array,1), 2*size(polar_array,2));

%fill the template and the mask with the real and imaginary bits
for j = 1:2:size(template,2)
 %
 template(:,j)   = H1(:,floor(j/2)+1);
 template(:,j+1) = H2(:,floor(j/2)+1);
 
%  %
 mask(:,j)   = polar_noise(:,floor(j/2)+1);
 mask(:,j+1) = polar_noise(:,floor(j/2)+1); 

%  mask(:,j)   = polar_noise(:,floor(j/2)+1) | H3(:,floor(j/2)+1);
%  mask(:,j+1) = polar_noise(:,floor(j/2)+1) | H3(:,floor(j/2)+1); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Building the 2D log-Gabor Filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% logGabor2d - creates the 2D log-Gabor function in the frequency domain
function logGabor2d = create_loggabor2d(rows, cols, wavelength, sigmaOnf, angl, thetaSigma)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RADIAL Component
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%construcao do filtro, componente RADIAL
[x y] = meshgrid([-cols/2:(cols/2-1)]/cols, [-rows/2:(rows/2-1)]/rows);

radius = sqrt(x.^2 + y.^2);

radius(rows/2+1, cols/2+1) = 1;

f0 = 2.0/wavelength;

radialGabor = exp( (-(log(radius/f0)).^2) / (2 * log(sigmaOnf)^2));
radialGabor(rows/2+1, cols/2+1) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ANGULAR Component
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%construcao do filtro, componente ANGULAR
theta = atan2(-y,x);

sintheta = sin(theta);
costheta = cos(theta);

ds = (sintheta * cos(angl)) - (costheta * sin(angl)); %diferença no seno
dc = (costheta * cos(angl)) + (sintheta * sin(angl)); %diferença no cosseno
dtheta = abs(atan2(ds,dc));
angularGabor = exp( -(dtheta.^2) / (2 * thetaSigma^2) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Joining the two Components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%multiplicando as componentes para gerar o filtro completo
logGabor = radialGabor .* angularGabor;

%descentraliza o filtro
logGabor2d = ifftshift(logGabor);
%agora ele esta pronto para ser usado