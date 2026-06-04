
%% This code for Giamp!
% there is 6 P-band co-registrated fully polarimetric image in Guiana
% datiHH is a matrix (2450,1428, 6), representing the data stack in HH pol

% CHM and DTM are the conopy height and ground elevation modelsusing LIDAR.
% 

clc
clear all;
close all;

load Bas_and_Lidar    % legge le matrici kZ CHM e DTM

load datiHH % legge i dati in polarizzazione HH calibrati in fase
Im=datiHH;

[Naz, Nr,N] = size(Im); % Naz=n. righe, Nr=n. colonne dell'immagine, N=n. immagini = 6
figure, imagesc(mean(abs(Im),3),[0 1.5]), colormap('gray') % ampiezza media delle 6 immagini

%% (1) Reconstruction using Single polarization data, e.g. HH pol

% Estimation of data covariance matrix (boxcar!)
covariance = zeros(N,N, Naz, Nr);
for ii=1:N
    for jj=ii:N
        covariance(ii,jj,:,:) = imfilter(Im(:,:,ii).*conj(Im(:,:,jj)),fspecial('gaussian',19,7),'replicate')./...
                                 sqrt(imfilter(Im(:,:,ii).*conj(Im(:,:,ii)),fspecial('gaussian',19,7),'replicate').*imfilter(Im(:,:,jj).*conj(Im(:,:,jj)),fspecial('gaussian',19,7),'replicate'));
           % covariance(ii,jj,:,:) = imfilter(Im(:,:,ii).*conj(Im(:,:,jj)),fspecial('gaussian',19,5),'replicate');
        covariance(jj,ii,:,:) =  conj(squeeze(covariance(ii,jj,:,:)));
    end
end

% Reconstruction using Capon 
% select the azimuth line 
iiaz=1200;  % indice della riga scelta
z_span=-60:60; 

spCapon=zeros(length(z_span),Nr);
spMusic=zeros(length(z_span),Nr);
NT=3;
for jj=1:Nr    
    A = exp(1i*squeeze(kz(iiaz,jj,:))*z_span);
    spCapon(:,jj)= 1./abs(diag(A'*pinv( squeeze(covariance(:,:,iiaz,jj)),1e-3)*A));  % Capon 
    [U,D,V]=eig(squeeze(covariance(:,:,iiaz,jj)));
    Uw(1:N,1:N-NT)=U(1:N,1:N-NT);
    spMusic(:,jj)= 1./abs(diag(A'*(Uw*Uw')*A));
end

range=(0:Nr);
figure, 
imagesc(range,z_span+40,spCapon, [0 max(spCapon(:))]), axis('xy'), colormap('jet')
set(gca,'XMinorTick','on','YMinorTick','on')
xlabel('Range [pixel]');
    ylabel('Altezza [m]');
     title('CAPON');

hold on
plot(DTM(iiaz,:),'k','LineWidth',1)
plot(DTM(iiaz,:)+CHM(iiaz,:),'r','LineWidth',1)
colorbar;

figure,
fact=0.15;
imagesc(range,z_span+40,spMusic/(fact*max(spMusic(:))), [0 1]), axis('xy'), colormap('jet')
set(gca,'XMinorTick','on','YMinorTick','on')
xlabel('Range [pixel]');
    ylabel('Altezza [m]');
    title('MUSIC – NT = 3');
hold on
plot(DTM(iiaz,:),'k','LineWidth',1)
plot(DTM(iiaz,:)+CHM(iiaz,:),'r','LineWidth',1)
colorbar;

% clc; clear; close all;

figure;
imagesc(Im_media, [0 1.5]); colormap('gray'); colorbar;
xlabel('Range [pixel]');
ylabel('Azimuth [pixel]');
title('Immagine radar media (HH) con riga selezionata');

% Disegno la riga scelta
hold on;
plot([1 size(Im_media,2)], [iiaz iiaz], 'r-', 'LineWidth', 3);
