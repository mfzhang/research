% findline - returns the coordinates of a line in an image using the
% linear Hough transform and Canny edge detection to create
% the edge map.
%
% Usage: 
% lines = findline(image)
%
% Arguments:
%	image   - the input image
%
% Output:
%	lines   - parameters of the detected line in polar form
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

function lines = findline(image)

%Prevents trying to calculate lines of an empty image
if isempty(image)
 lines = [];
 return;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Perform CANNY edge detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[I2 or] = canny(image, 2, 1, 0.00, 1.00);
I3 = adjgamma(I2, 1.9);
I4 = nonmaxsup(I3, or, 1.5);
edgeimage = hysthresh(I4, 0.20, 0.15);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

theta = (0:179)';
[R, xp] = radon(edgeimage, theta);
%Radon é somente uma transformada de hough. A diferença principal no uso é
%que na hough só passamos a imagem como parametro e ela retorna [H theta
%rho] e em radon, passmos como parametros a imagem e o vetor theta, assim,
%podemos controlar melhor a direçao que desejamos procurar. Radon retorna
%[R xp], R, o espaço transformado e xp o equivalente a rho

%Procura pelo pico
%search for the highest value
maxv = max(max(R));

%Verifica se esse pico possui valor maior que um certo limiar
if maxv > 25
    i = find(R == max(max(R)));
else
    lines = [];
    return;
end

%se o pico possuir um valor maior que o limiar, devemos procurar sua
%posição:
%i é um vetor com as posiçoes onde encontram-se max(R)
[foo, ind] = sort(-R(i));
u = size(i,1);
k = i(ind(1:u));
[y,x]=ind2sub(size(R),k);
t = -theta(x)*pi/180;
r = xp(y);

%equacao parametrica da reta
lines = [cos(t) sin(t) -r];

cx = size(image,2)/2-1;
cy = size(image,1)/2-1;
lines(:,3) = lines(:,3) - lines(:,1)*cx - lines(:,2)*cy;
