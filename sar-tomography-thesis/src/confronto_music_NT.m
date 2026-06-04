clc;
clear;
close all;

% === Caricamento dati ===
load('datiHH.mat');        % Cubo polarimetrico HH (2450 x 1428 x 6)
load('Bas_and_Lidar.mat'); % Contiene kz, DTM, CHM

Im = datiHH;
[Naz, Nr, N] = size(Im);

% === Parametri ===
iiaz = 150;                 % Riga azimutale selezionata
z_span = -60:60;            % Intervallo in quota
range = 1:Nr;               % Range orizzontale

% === Interpolazione delle curve LIDAR ===
x_lidar = linspace(1, Nr, size(DTM,2));
DTM_interp = interp1(x_lidar, DTM(iiaz,:), range, 'linear', 'extrap');
CHM_interp = interp1(x_lidar, CHM(iiaz,:), range, 'linear', 'extrap');

% === Stima matrice di covarianza ===
covariance = zeros(N, N, Naz, Nr);
for ii = 1:N
    for jj = ii:N
        num = imfilter(Im(:,:,ii) .* conj(Im(:,:,jj)), fspecial('gaussian', [15 15], 4), 'replicate');
        den1 = imfilter(abs(Im(:,:,ii)).^2, fspecial('gaussian', [15 15], 4), 'replicate');
        den2 = imfilter(abs(Im(:,:,jj)).^2, fspecial('gaussian', [15 15], 4), 'replicate');
        covariance(ii, jj, :, :) = num ./ sqrt(den1 .* den2);
        covariance(jj, ii, :, :) = conj(covariance(ii, jj, :, :));
    end
end

% === Valori di NT da confrontare ===
NT_values = [1, 2, 3];
Nz = length(z_span);
SP_all = zeros(Nz, Nr, length(NT_values));

% === Loop sui diversi NT ===
for idx = 1:length(NT_values)
    NT = NT_values(idx);
    sp = zeros(Nz, Nr);

    for jj = 1:Nr
        A = exp(1i * squeeze(kz(iiaz, jj, :)) * z_span);
        [V, D, U] = eig(squeeze(covariance(:,:,iiaz,jj)));
        U_noise = U(:, 1:end-NT);
        sp(:, jj) = 1 ./ abs(diag(A' * (U_noise * U_noise') * A));
    end

    SP_all(:,:,idx) = sp / max(sp(:));
end

% === Crea figura visibile in alta risoluzione ===
figure('Units', 'pixels', 'Position', [100, 100, 1200, 600]);
h = gobjects(length(NT_values), 1); % handle per subplot

for idx = 1:length(NT_values)
    h(idx) = subplot(1, length(NT_values), idx);
    imagesc(range, z_span + 40, SP_all(:,:,idx));
    colormap('jet');
    set(gca, 'YDir', 'normal');
    xlabel('Range [pixel]');
    ylabel('Altezza [m]');
    title(['NT = ', num2str(NT_values(idx))]);
    hold on;
    plot(range, DTM_interp, 'k', 'LineWidth', 1.5);
    plot(range, DTM_interp + CHM_interp, 'r', 'LineWidth', 1.5);
    ylim([-20 100]);  % ✅ altezza visibile, senza schiacciare
end

% Linka assi Y per coerenza
linkaxes(h, 'y');

% Colorbar unica
hcb = colorbar('Position', [0.91 0.2 0.015 0.6]);
  % Posiziona sotto i subplot
hcb.Label.String = 'Potenza spettrale [a.u.]';
hcb.Label.FontSize = 10;
hcb.Position = [0.35 0.08 0.3 0.02];  % [x y width height]


% Legenda nel primo subplot
subplot(1, length(NT_values), 1);
legend({'DTM', 'DTM + CHM'}, 'TextColor', 'k', 'Box', 'on', 'Location', 'northwest');
subplot(1, length(NT_values), 2);
legend({'DTM', 'DTM + CHM'}, 'TextColor', 'k', 'Box', 'on', 'Location', 'northwest');
subplot(1, length(NT_values), 3);
legend({'DTM', 'DTM + CHM'}, 'TextColor', 'k', 'Box', 'on', 'Location', 'northwest');

% Titolo globale
sgtitle('Confronto ricostruzione MUSIC per diversi NT');