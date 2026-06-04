%% Capon and MUSIC TomoSAR Reconstruction
% Single-polarization HH SAR data acquired over French Guiana.
%
% The data stack contains 6 co-registered P-band SAR images.
% CHM and DTM are canopy height and ground elevation models derived from LiDAR.
%
% This script:
% - loads the HH SAR data stack;
% - estimates the covariance matrix;
% - applies Capon beamforming;
% - applies MUSIC reconstruction;
% - compares the reconstructed profiles with DTM and DTM + CHM references.

clc;
clear;
close all;

%% Load input data

load Bas_and_Lidar;   % Contains kz, CHM and DTM
load datiHH;          % HH-polarized SAR data stack

Im = datiHH;

[Naz, Nr, N] = size(Im);

% Mean SAR intensity image
Im_media = mean(abs(Im), 3);

figure;
imagesc(Im_media, [0 1.5]);
colormap('gray');
colorbar;
xlabel('Range [pixel]');
ylabel('Azimuth [pixel]');
title('Mean SAR intensity image - HH polarization');

%% Covariance matrix estimation

covariance = zeros(N, N, Naz, Nr);

for ii = 1:N
    for jj = ii:N

        numerator = imfilter( ...
            Im(:,:,ii) .* conj(Im(:,:,jj)), ...
            fspecial('gaussian', 19, 7), ...
            'replicate');

        denominator_ii = imfilter( ...
            Im(:,:,ii) .* conj(Im(:,:,ii)), ...
            fspecial('gaussian', 19, 7), ...
            'replicate');

        denominator_jj = imfilter( ...
            Im(:,:,jj) .* conj(Im(:,:,jj)), ...
            fspecial('gaussian', 19, 7), ...
            'replicate');

        covariance(ii,jj,:,:) = numerator ./ sqrt(denominator_ii .* denominator_jj);

        covariance(jj,ii,:,:) = conj(squeeze(covariance(ii,jj,:,:)));
    end
end

%% Tomographic reconstruction parameters

iiaz = 1200;          % Selected azimuth line
z_span = -60:60;     % Elevation span [m]
range = 0:Nr;

spCapon = zeros(length(z_span), Nr);
spMusic = zeros(length(z_span), Nr);

NT = 3;              % Number of signal sources for MUSIC

%% Capon and MUSIC reconstruction

for jj = 1:Nr

    A = exp(1i * squeeze(kz(iiaz, jj, :)) * z_span);

    % Capon beamforming
    R = squeeze(covariance(:,:,iiaz,jj));
    spCapon(:,jj) = 1 ./ abs(diag(A' * pinv(R, 1e-3) * A));

    % MUSIC reconstruction
    [U, ~] = eig(R);
    U_noise = U(:, 1:N-NT);
    spMusic(:,jj) = 1 ./ abs(diag(A' * (U_noise * U_noise') * A));

end

%% Capon visualization

figure;
imagesc(range, z_span + 40, spCapon, [0 max(spCapon(:))]);
axis xy;
colormap('jet');
colorbar;

set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

xlabel('Range [pixel]');
ylabel('Height [m]');
title('Capon TomoSAR Reconstruction');

hold on;
plot(DTM(iiaz,:), 'k', 'LineWidth', 1);
plot(DTM(iiaz,:) + CHM(iiaz,:), 'r', 'LineWidth', 1);

legend({'DTM', 'DTM + CHM'}, 'Location', 'northwest');

%% MUSIC visualization

figure;

normalization_factor = 0.15;

imagesc( ...
    range, ...
    z_span + 40, ...
    spMusic / (normalization_factor * max(spMusic(:))), ...
    [0 1]);

axis xy;
colormap('jet');
colorbar;

set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');

xlabel('Range [pixel]');
ylabel('Height [m]');
title(['MUSIC TomoSAR Reconstruction - NT = ', num2str(NT)]);

hold on;
plot(DTM(iiaz,:), 'k', 'LineWidth', 1);
plot(DTM(iiaz,:) + CHM(iiaz,:), 'r', 'LineWidth', 1);

legend({'DTM', 'DTM + CHM'}, 'Location', 'northwest');

%% Mean SAR image with selected azimuth line

figure;
imagesc(Im_media, [0 1.5]);
colormap('gray');
colorbar;

xlabel('Range [pixel]');
ylabel('Azimuth [pixel]');
title('Mean SAR intensity image - selected azimuth line');

hold on;
plot([1 size(Im_media, 2)], [iiaz iiaz], 'r-', 'LineWidth', 3);
