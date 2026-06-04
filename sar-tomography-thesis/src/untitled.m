clc; clear; close all;

load datiHH   % stack SAR in HH (Naz x Nr x N)
Im = datiHH;

% Calcolo immagine media
Im_media = mean(abs(Im),3);

% Normalizzazione per visualizzare meglio
Im_norm = Im_media / prctile(Im_media(:), 99);  % normalizza rispetto al 99° percentile
Im_norm(Im_norm > 1) = 1;                       % taglia valori troppo alti

% Riga azimutale scelta
iiaz = 1200;

% Visualizzazione
figure;
imagesc(Im_norm); colormap('gray'); colorbar;
xlabel('Range [pixel]');
ylabel('Azimuth [pixel]');
title('Immagine radar media (HH) con riga selezionata');

% Disegno la riga scelta (rossa spessa + marker agli estremi)
hold on;
plot([1 size(Im_norm,2)], [iiaz iiaz], 'r-', 'LineWidth', 2);
plot(1, iiaz, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
plot(size(Im_norm,2), iiaz, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
