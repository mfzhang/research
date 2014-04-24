% create_database_template_parametros - cria toda a cadeia de arquivos que resulta no
% padrão biométrico de cada indivíduo para a base de dados completa,
% baseado em diferentes valores de parametros para o filtro Log-Gabor 2D.
% Parametros:
% imagesDir     - Diretorio onde encontram-se as imagens de olhos da base. 
% O codigo esta pronto para a estrutura da base CASIA v1 e pode ser 
% alterada para qualquer outra estrutura, sem muito esforço.
% normalizedDir - Diretorio onde serão armazenadas as imagens normalizadas
% encodedDir    - Diretorio onde serão armazenadas as imagens codificadas
% OBS: o encodedDir é formado pela juncao dos parametros que compoem o
% filtro Log-Gabor 2D. Muito cuidado utiliza-lo.
%
% Parametros do Filtro:
% waves      -  comprimento da onda. A frequencia é calculada por 1/waves
% sigmaOnf   - largura de banda da componente radial
% angl       - orientaçao da componente angular
% thetaSigma - largura de banda da componente angular
% 
% Original Author: 
% Carlos Bastos
% cacmb@cin.ufpe.br
% Informatics Center / Centro de Informatica
% Federal Univerty of Pernambuco / Universidade Federal de Pernambuco
% November 2008

%function create_database_template_parametros()
%antes de executar esta funçao, certifique-se de que todos os
%sub-diretorios para a codificacao estejam criados. Do contrário mensagens
%de erro aparecerão.

cd C:\MATLAB7\work\projeto_iris
%Parametros do Filtro
waves = [14 26 28];%24;
sigmaOnf = [0.50 0.55];%[0.50 0.55]
angl = [0] ;
thetaSigma = [pi/4];

%
imagesDir = 'iris_database\casia_v1\';
normalizedDir = 'normalized';
% encodedDir = 'encode_gabor2d';
%-------------

% % carregando diretorio de imagens de entrada
% folders = dir([imagesDir]);
% 
% total_time = 0.0;
% total_images = 0;
% 
% for i = 3:size(folders,1)
%     %lendo diretorios
%     if folders(i).isdir
%         folder1 = folders(i).name; %sujeito
%         sections = dir([imagesDir folder1]);
%         
%         for j = 3:size(sections,1)
%             if sections(j).isdir
%                section1 = sections(j).name;
%                %lendo imagens
%                images = dir([imagesDir folder1 '\' section1 '\' '*.bmp']);
%                
%                for k = 1:size(images)
%                    %Pocessa cada imagem
%                    imagepath = [imagesDir folder1 '\' section1 '\' images(k).name];
%                    
%                    total_images = total_images + 1;
%                    
%                    disp([int2str(total_images) ' : ' imagepath]);
%                    
%                    %Alterado aqui
%                    tic
%                    for j = 1:size(waves,2)
%                       for l = 1:size(sigmaOnf,2)
%                          for m = 1:size(angl,2)
%                              encodedDir = ['en\encoded_gabor2d_' num2str(waves(j)) '_' num2str(100*sigmaOnf(l)) ...
%                                 '_' num2str(m) '_pi4'];
%                              createiristemplate(imagepath, normalizedDir, encodedDir, waves(j),sigmaOnf(l), angl(m), thetaSigma);                          
%                          end %m
%                       end %l
%                    end %j
%                    %tic
%                    %createiristemplate(imagepath, normalizedDir, encodedDir);
%                    t = toc;
%                    %-------------
%                    
%                    total_time = total_time + t;
%                end%for k
%             end%if
%         end%for j
%         
%         
%     end%if
% end%for i
% 
% disp(['Total Time: ' num2str(total_time) ' seconds']);
% disp(['Mean Time: ' num2str(total_time/total_images) ' seconds']);

% % % %%%%%%%%%%%%%%%%%%%%%%%%%
% % % % Limpa tudo
% % % % clear
% % % % clc
% % % % combinacoes = nchoosek([1:size(iriscodes,2)],2);
% % % % o tamanho de iriscodes deve ser conhecido já na etapa de segmentação

%Ou carrega o arquivo que ja contem todas as combinações ou
%cria as combinacoes na hora
load('compara.mat');



iriscodes = struct;
HD = struct;
    
%Guarda tudo na struct IrisCodes
for j = 1:size(waves,2)
   for l = 1:size(sigmaOnf,2)
      for m = 1:size(angl,2)
          straux = ['gabor2d_' num2str(waves(j)) '_' num2str(100*sigmaOnf(l)) ...
             '_' num2str(m) '_pi4'];

%      HD = struct;
     stat = exist(['HD_' straux '.mat'],'file');
     if stat ~= 0
      continue;
%      else
%         HD = struct;
     end

    diretorioImagens = ['en\encoded_' straux '\']; 

    total_images = 0;

%     iriscodes = struct;

    %lendo arquivos
    imagens = dir([diretorioImagens '*-encoded.mat']);

    for k = 1:size(imagens)
        %Pocessa cada imagem
        diretorio = [diretorioImagens];
        imagem = imagens(k).name;

        total_images = total_images + 1;

        disp([int2str(total_images) ' : ' imagem]);                   

        %
        %processa_imagem(diretorio, imagem);
        %carrega o arquivo
        load([diretorio imagem]);

        %salva na matriz de iriscodes
        iriscodes(total_images).template = template;
        iriscodes(total_images).mask = mask;
        iriscodes(total_images).name = imagem;
        iriscodes(total_images).person = uint8( str2num( imagens(k).name(1:3) ) );
    end%for k

    clear k total_images diretorio imagem diretorioImagens template mask image imagens 
     
     
     total_t = 0.0;
     
     %for k = 1:floor(size(combinacoes,1)/10)
     tic
     for k = 1:size(combinacoes,1)
          
         HD(k).person_A = iriscodes( combinacoes(k,1) ).person;
         HD(k).person_B = iriscodes( combinacoes(k,2) ).person;
         
         %tic
         HD(k).hd = gethammingdistance(iriscodes( combinacoes(k,1) ).template, ...
             iriscodes( combinacoes(k,1) ).mask, iriscodes( combinacoes(k,2) ).template, ...
             iriscodes( combinacoes(k,2) ).mask, 1);
         %t = toc;
         %total_t = total_t + t;
     end %for k
     total_t = toc;
     
     disp(['Tempo Total: ' num2str(total_t) ' segundos']);
     disp(['Tempo Médio: ' num2str(total_t/size(combinacoes,1)) ' segundos']);
     
     %Separa em 2 grupos Intra e Inter
     
     Intra = [];
     Inter = [];
     
     for k = 1:size(HD,2)
        if (HD(k).person_A == HD(k).person_B)
          Intra = [Intra HD(k).hd];
        else
          Inter = [Inter HD(k).hd];
        end;
     end %for k
        
     %Calcula Media e Desvio Padrao
     Intra_mean = mean(Intra);
     Inter_mean = mean(Inter);
     
     Intra_std = std(Intra);
     Inter_std = std(Inter);
     
     %Decidabilidade
     D = abs(Intra_mean - Inter_mean) /  sqrt( abs(Intra_std^2 + Inter_std^2) / 2);    
     
     %salva
     save(['HD_' straux],'HD', 'Inter', 'Intra', 'Intra_mean', ...
        'Inter_mean', 'Intra_std', 'Inter_std', 'D', 'straux');     
     
     %Calcula as taxas
     %verifica_limiar;
       
      end %m
   end %l        
end %j