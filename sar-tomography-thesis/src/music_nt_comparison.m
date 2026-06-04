%% MUSIC TomoSAR Reconstruction - NT Comparison
% Single-polarization HH SAR data acquired over French Guiana.
%
% The data stack contains 6 co-registered P-band SAR images.
% CHM and DTM are canopy height and ground elevation models derived from LiDAR.
%
% This script:
% - loads the HH SAR data stack;
% - estimates the covariance matrix;
% - applies the MUSIC algorithm;
% - compares the reconstruction for NT = 1, NT = 2 and NT = 3;
% - overlays the DTM and DTM + CHM reference curves.

clc;
clear;
close all;

%% Load input data

load('datiHH.mat');          % HH-polarized SAR data stack
load('Bas_and_Lidar.mat');   % Contains kz, DTM and CHM

Im = datiHH;
[Naz, Nr, N] = size(Im);

%% Reconstruction parameters

iiaz = 150;          % Selected azimuth line
z_span = -60:60;    % Elevation span [m]
range = 1:Nr;       % Range axis [pixel]

%% Interpolation of LiDAR reference curves

x_lidar = linspace(1, Nr, size(DTM, 2));

DTM_interp = interp1( ...
    x_lidar, ...
    DTM(iiaz, :), ...
    range, ...
    'linear', ...
    'extrap');

CHM_interp = interp1( ...
    x_lidar, ...
    CHM(iiaz, :), ...
    range, ...
    'linear', ...
    'extrap');

%% Covariance matrix estimation

covariance = zeros(N, N, Naz, Nr);

for ii = 1:N
    for jj = ii:N

        numerator = imfilter( ...
            Im(:,:,ii) .* conj(Im(:,:,jj)), ...
            fspecial('gaussian', [15 15], 4), ...
            'replicate');

        denominator_ii = imfilter( ...
            abs(Im(:,:,ii)).^2, ...
            fspecial('gaussian', [15 15], 4), ...
            'replicate');

        denominator_jj = imfilter( ...
            abs(Im(:,:,jj)).^2, ...
            fspecial('gaussian', [15 15], 4), ...
            'replicate');

        covariance(ii, jj, :, :) = numerator ./ sqrt(denominator_ii .* denominator_jj);
        covariance(jj, ii, :, :) = conj(covariance(ii, jj, :, :));

    end
end

%% MUSIC reconstruction for different NT values

NT_values = [1, 2, 3];

Nz = length(z_span);
SP_all = zeros(Nz, Nr, length(NT_values));

for idx = 1:length(NT_values)

    NT = NT_values(idx);
    spMusic = zeros(Nz, Nr);

    for jj = 1:Nr

        A = exp(1i * squeeze(kz(iiaz, jj, :)) * z_span);

        R = squeeze(covariance(:,:,iiaz,jj));

        [U, ~] = eig(R);

        U_noise = U(:, 1:end-NT);

        spMusic(:, jj) = 1 ./ abs(diag(A' * (U_noise * U_noise') * A));

    end

    SP_all(:,:,idx) = spMusic / max(spMusic(:));

end

%% Visualization

figure('Units', 'pixels', 'Position', [100, 100, 1200, 600]);

subplot_handles = gobjects(length(NT_values), 1);

for idx = 1:length(NT_values)

    subplot_handles(idx) = subplot(1, length(NT_values), idx);

    imagesc(range, z_span + 40, SP_all(:,:,idx));
    colormap('jet');

    set(gca, 'YDir', 'normal');

    xlabel('Range [pixel]');
    ylabel('Height [m]');
    title(['NT = ', num2str(NT_values(idx))]);

    hold on;
    plot(range, DTM_interp, 'k', 'LineWidth', 1.5);
    plot(range, DTM_interp + CHM_interp, 'r', 'LineWidth', 1.5);

    ylim([-20 100]);

    legend( ...
        {'DTM', 'DTM + CHM'}, ...
        'TextColor', 'k', ...
        'Box', 'on', ...
        'Location', 'northwest');

end

% Link y axes for consistent comparison
linkaxes(subplot_handles, 'y');

% Shared colorbar
colorbar_handle = colorbar('Position', [0.91 0.2 0.015 0.6]);
colorbar_handle.Label.String = 'Spectral power [a.u.]';
colorbar_handle.Label.FontSize = 10;
colorbar_handle.Position = [0.35 0.08 0.3 0.02];

% Global title
sgtitle('MUSIC TomoSAR Reconstruction for Different NT Values');
