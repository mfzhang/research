% remove_noise - removes small groups of connected components of a binary
% image
%
% Usage: 
% [image] = remove_noise(image_bw, min_contected_pixels)
%
% Arguments:
%	image_bw                - a binary image
%   min_contected_pixels    - the minimum value for connected components
%
% Output:
%	image                   - the binary withou small groups of connected
%                           pixels
%
% Modified by: 
% Carlos Bastos
% cacmb@cin.ufpe.br
% Informatics Center / Centro de Informatica
% Federal Univerty of Pernambuco / Universidade Federal de Pernambuco
% November 2008

function image = remove_noise(image_bw, min_contected_pixels)

if nargin == 1
  %default value for minimal theshold
  min_contected_pixels = 15;
end

%label all the white pixels in the image
[L n] = bwlabel(image_bw);

%calculate the size of each group
%calcula o tamanho de cada grupo
for k = 1:n
    connectedsize(k) = size( find(L == k), 1);
end

%Find the index of groups greater than the threshold
%encontra o numero dos grupos maiores que o limiar
[posA posB] = find( connectedsize >= min_contected_pixels );

for k = 1:size(posB,2)
    %encontra os pixels do objeto k
    posA = find( L == posB(k) );
    %troca o valor dos pixels
    L(posA) = n+1;
end

%Return the image without groups of pixels smaller than thesh
image = L > n;