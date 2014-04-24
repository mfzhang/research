%'HD_gabor2d_30_55_1_pi4.mat'

% function verifica_limiar(base)
% load(base);

thresh = [0.20:0.005:0.50];

%matriz thresh colunas e HD linhas para os acertos, falsa aceitacao e falsa
%rejeicao
%cada coluna representa um thresh
acertos_erros = zeros(size(HD,2), size(thresh,2));

for k = 1:size(HD,2)
 for j = 1:size(thresh,2)
%     hd(k) = HD(k).hd;
  %se menor que o threshold
    if ( HD(k).hd <= thresh(j) ) 
     %se for a mesma pessoa
      if  ( HD(k).person_A == HD(k).person_B ) 
        acertos_erros(k,j) = 1; %TP - true positive
      else
        acertos_erros(k,j) = 2; %FP - false positive
      end
    else
     %se maior que o threshold
      if  ( HD(k).person_A == HD(k).person_B ) 
        acertos_erros(k,j) = 3; %FN - false negative
      else
        acertos_erros(k,j) = 4; %TN - true negative
      end
    end
    
    %if HD(k).hd >
 end %for j
end %for k

%positivos
P = size(Intra,2);
N = size(Inter,2);
FP = [];
FN = [];
TP = [];
TN = [];

for k = 1:size(thresh,2)
    FP(k) = size( find( acertos_erros(:,k) == 2 ) , 1);
    FN(k) = size( find( acertos_erros(:,k) == 3 ) , 1);
    
    TP(k) = size( find( acertos_erros(:,k) == 1 ) , 1);
    TN(k) = size( find( acertos_erros(:,k) == 4 ) , 1);
    
    %disp([num2str( far(k) + frr(k) + aac(k) + aer(k))]);
end

tpr = 100 * TP / P;
fpr = 100 * FP / N;

frr = 100 * FN / P;

figure, plot(fpr, tpr,'-*');
axis([0 5 95 100]);

a = [thresh' tpr' fpr' frr'];

save(['HD_' straux],'HD', 'Inter', 'Intra', 'Intra_mean', ...
   'Inter_mean', 'Intra_std', 'Inter_std', 'D', 'straux', ...
   'a');     