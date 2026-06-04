%% Mean SAR Intensity Image with Selected Azimuth Line
% Single-polarization HH SAR data acquired over French Guiana.
%
% This script:
% - loads the HH SAR data stack;
% - computes the mean SAR intensity image;
% - normalizes the image for visualization;
% - displays the selected azimuth line used for TomoSAR reconstruction.

clc;
clear;
close all;

%% Load input data

load datiHH;   % HH-polarized SAR data stack

Im = datiHH;

%% Mean SAR intensity image

Im_media = mean(abs(Im), 3);

% Normalize the image using the 99th percentile for better visualization
Im_norm = Im_media / prctile(Im_media(:), 99);
Im_norm(Im_norm > 1) = 1;

%% Selected azimuth line

iiaz = 1200;   % Selected azimuth line

%% Visualization

figure;
imagesc(Im_norm);
colormap('gray');
colorbar;

xlabel('Range [pixel]');
ylabel('Azimuth [pixel]');
title('Mean SAR Intensity Image - HH Polarization with Selected Azimuth Line');

hold on;

plot([1 size(Im_norm, 2)], [iiaz iiaz], 'r-', 'LineWidth', 2);
plot(1, iiaz, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
plot(size(Im_norm, 2), iiaz, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
