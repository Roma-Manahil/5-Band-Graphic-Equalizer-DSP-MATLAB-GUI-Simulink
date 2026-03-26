% 5-Band Graphic Equalizer

clc; clear; close all;

% PARAMETERS
fs = 62000;                 
Q = 0.6;                    
fc = [63, 250, 1000, 4000, 16000];  
N = 3;                      
gains_dB = [0 0 0 0 0];      
gains = 10.^(gains_dB/20);

B_all = cell(1,5);
A_all = cell(1,5);

colors = lines(5);

fprintf("\n=== 5-BAND GRAPHIC EQ INFORMATION ===\n");
fprintf("Sampling Frequency: %d Hz\n", fs);
fprintf("Butterworth Order: %d\n", N);
fprintf("Constant Q Value: %.2f\n\n", Q);

%  FIGURE 1 — ALL BANDS TOGETHER
figure;
hold on; grid on;

H_store = zeros(2048,5);
W_global = [];

for k = 1:length(fc)

    f1 = fc(k) / 2^(1/(2*Q));
    f2 = fc(k) * 2^(1/(2*Q));
    BW = f2 - f1;
    Q_actual = fc(k) / BW;

    Wn = [f1 f2] / (fs/2);
    [B, A] = butter(N, Wn, 'bandpass');

    B_all{k} = B;
    A_all{k} = A;

    [H, W] = freqz(B, A, 2048, fs);

    if isempty(W_global)
        W_global = W;
    end

    H_store(:,k) = abs(H);

    plot(W, 20*log10(abs(H)), 'Color', colors(k,:), 'LineWidth', 1.7);
    xline(fc(k), '--', 'Color', colors(k,:), 'LineWidth', 1);

    fprintf("Band %d (%d Hz):\n", k, fc(k));
    fprintf("   Lower cutoff f1  = %.2f Hz\n", f1);
    fprintf("   Upper cutoff f2  = %.2f Hz\n", f2);
    fprintf("   Bandwidth (f2-f1)= %.2f Hz\n", BW);
    fprintf("   Actual Q         = %.4f\n\n", Q_actual);

end

title("All 5 Bands — Frequency Responses with Center Markers");
xlabel("Frequency (Hz)");
ylabel("Magnitude (dB)");
legend("63 Hz","250 Hz","1 kHz","4 kHz","16 kHz");
xlim([0 fs/2]);
hold off;

%  FIGURE 2 — COMBINED NORMALIZED FREQUENCY RESPONSE

H_total = zeros(1024,1);
for i = 1:length(fc)
    [H, W] = freqz(B_all{i}, A_all{i}, 1024, fs);
    H_total = H_total + gains(i) * abs(H);
end

figure;
plot(W, 20*log10(H_total), 'Color',[0.85 0.3 0.2], 'LineWidth', 2);
xlabel('Freq (Hz)');
ylabel('Mag (dB)');
title('5-Band EQ – Combined Response');
grid on;
set(gca,'FontName','Arial','FontSize',12);


% Deviation

dB_response = 20*log10(H_total);

peak_dB = max(dB_response);

flat_idx = dB_response > (peak_dB - 1);

W_valid = W(flat_idx);
dB_valid = dB_response(flat_idx);

mean_level = mean(dB_valid);
dev = dB_valid - mean_level;

max_dev = max(abs(dev));
rms_dev = sqrt(mean(dev.^2));

fprintf("\n=== DEVIATION ===\n");
fprintf("Max deviation : %.4f dB\n", max_dev);
fprintf("RMS deviation: %.4f dB\n\n", rms_dev);


%  FIGURE 3 — SUBPLOTS (Individual Normalized Bands)
figure;
for k = 1:5
    subplot(5,1,k);
    H_norm = H_store(:,k) / max(H_store(:,k));
    plot(W_global, 20*log10(H_norm), 'Color', colors(k,:), 'LineWidth', 1.5);
    grid on;
    ylabel(sprintf('%d Hz', fc(k)));
    xlim([0 fs/2]);
    if k == 1
        title("Normalized Individual Band Responses ");
    end
end
xlabel("Frequency (Hz)");

% SAVING FILTER COEFFICIENTS
save('eq_filters.mat','B_all','A_all','fc','Q','N');
fprintf("Filters saved to eq_filters.mat\n");
