% create_database_template - cria toda a cadeia de arquivos que resulta no
% padrão biométrico de cada indivíduo para a base de dados completa.
% Parametros:
% imagesDir     - Diretorio onde encontram-se as imagens de olhos da base. 
% O codigo esta pronto para a estrutura da base CASIA v1 e pode ser 
% alterada para qualquer outra estrutura, sem muito esforço.
% normalizedDir - Diretorio onde serão armazenadas as imagens normalizadas
% encodedDir    - Diretorio onde serão armazenadas as imagens codificadas
% 
% Original Author: 
% Carlos Bastos
% cacmb@cin.ufpe.br
% Informatics Center / Centro de Informatica
% Federal Univerty of Pernambuco / Universidade Federal de Pernambuco
% November 2008

function create_database_template()

% diretorios
imagesDir = 'D:/euclides/doutorado/iris/database/CASIAv1/';
normalizedDir = [imagesDir, 'normalized/'];
encodedDir = [imagesDir, 'encoded_gabor2d/'];

% carregando diretorio de imagens de entrada
total_time = 0.0;
total_images = 0;

images = dir([imagesDir, '*.bmp']);

%Pocessa cada imagem
for i = 1:size(images)
   total_images = total_images + 1;

   disp([int2str(total_images), ' : ', imagesDir, images(i).name]);

   tic
   createiristemplate(images(i).name, imagesDir, normalizedDir, encodedDir);
   t = toc;

   total_time = total_time + t;
end%for i

disp(['Total Time: ' num2str(total_time) ' seconds']);
disp(['Mean Time: ' num2str(total_time/total_images) ' seconds']);