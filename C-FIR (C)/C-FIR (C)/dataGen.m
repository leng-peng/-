% =========================================================================
% FIR 滤波器实验 — MATLAB 数据生成与结果分析
% DSP 实验  X = 组号 % 3
%   X = 0 → 低通 (lowpass)
%   X = 1 → 带通 (bandpass)   ← 本组 (group % 3 = 1)
%   X = 2 → 高通 (highpass)
%
% 实验内容:
%   1. 产生含 3 个频点的测试信号
%   2. 设计对应类型的 FIR 滤波器
%   3. 在 MATLAB 中滤波并画出时域/频谱图
%   4. 读取 DSP (fir.c) 运算结果并与 MATLAB 结果对比
%   5. 加入不同信噪比 (SNR) 的噪声，验证滤波效果
% =========================================================================

close all; clc; clear;

% -------------------------------------------------------------------------
% 0. 参数设定
% -------------------------------------------------------------------------
X  = 1;           % 组号 mod 3：0=低通, 1=带通, 2=高通
fs = 10000;       % 采样率 (Hz)
N  = 32;          % 采样点数
M  = 16;          % FIR 滤波器阶数 (taps)
n  = 0 : N-1;     % 离散时间序列
t  = n / fs;      % 对应时间 (s)
f_axis = (0:N-1) * fs / N;   % 频率轴 (Hz), 单边

% -------------------------------------------------------------------------
% 1. 产生 3 个频点的测试信号
%    f_low  =  500 Hz — 低频分量
%    f_mid  = 2000 Hz — 中频分量 (带通中心)
%    f_high = 4000 Hz — 高频分量
% -------------------------------------------------------------------------
f_low  =  500;   % Hz
f_mid  = 2000;   % Hz
f_high = 4000;   % Hz

x_low  = sin(2*pi*f_low  * t);
x_mid  = sin(2*pi*f_mid  * t);
x_high = sin(2*pi*f_high * t);
x_clean = x_low + x_mid + x_high;   % 纯净混合信号

fprintf('信号组成: %d Hz + %d Hz + %d Hz,  fs = %d Hz,  N = %d 点\n', ...
        f_low, f_mid, f_high, fs, N);

% -------------------------------------------------------------------------
% 2. 根据 X 设计 FIR 滤波器系数 (Hamming 窗)
%    本实验使用与 fir.c 完全相同的系数，确保 MATLAB 与 DSP 结果可比较
% -------------------------------------------------------------------------
switch X
    case 0   % 低通: 截止 1500 Hz
        Wn   = 1500 / (fs/2);
        b    = fir1(M-1, Wn, 'low', hamming(M));
        ftype_str = '低通 (Lowpass)  截止频率 1500 Hz';
        pass_freqs = f_low;    reject_freqs = [f_mid, f_high];

    case 1   % 带通: 通带 1000–3000 Hz  (与 fir.c 完全一致)
        % 使用 fir.c 中的相同系数，以便 MATLAB 结果能与 DSP 结果直接比较
        b = [6.9657248924e-03,  3.0082158460e-03, -6.8925032823e-03,  1.4434004436e-02, ...
            -2.7431417681e-02, -2.0113530627e-01, -9.9277668082e-02,  3.2323615798e-01, ...
             3.2323615798e-01, -9.9277668082e-02, -2.0113530627e-01, -2.7431417681e-02, ...
             1.4434004436e-02, -6.8925032823e-03,  3.0082158460e-03,  6.9657248924e-03];
        ftype_str = '带通 (Bandpass)  通带 1000–3000 Hz';
        pass_freqs = f_mid;    reject_freqs = [f_low, f_high];

    case 2   % 高通: 截止 3500 Hz
        Wn   = 3500 / (fs/2);
        b    = fir1(M-1, Wn, 'high', hamming(M));
        ftype_str = '高通 (Highpass)  截止频率 3500 Hz';
        pass_freqs = f_high;   reject_freqs = [f_low, f_mid];
end

fprintf('滤波器类型: %s\n', ftype_str);

% -------------------------------------------------------------------------
% 3. 保存输入数据文件 (供 DSP / fir.c 读取)
% -------------------------------------------------------------------------
fid = fopen('sinInput.dat', 'w');
fprintf(fid, '%15.10e\n', x_clean);
fclose(fid);
fprintf('输入信号已保存至 sinInput.dat\n');

% -------------------------------------------------------------------------
% 4. MATLAB FIR 滤波 (直接型实现，与 fir.c 算法一致)
% -------------------------------------------------------------------------
y_matlab = filter(b, 1, x_clean);

% -------------------------------------------------------------------------
% 5. 读取 DSP 输出结果 (fir.c 运行后生成 firOutput.dat)
% -------------------------------------------------------------------------
dsp_available = false;
if exist('firOutput.dat', 'file')
    y_dsp = load('firOutput.dat');
    y_dsp = y_dsp(:)';
    if length(y_dsp) >= N
        y_dsp = y_dsp(1:N);
        dsp_available = true;
        fprintf('已读取 DSP 输出文件 firOutput.dat\n');
    end
end

% -------------------------------------------------------------------------
% 6. 幅频响应
% -------------------------------------------------------------------------
[H, f_resp] = freqz(b, 1, 1024, fs);

% -------------------------------------------------------------------------
% 图 1: 滤波器幅频响应
% -------------------------------------------------------------------------
figure('Name', '滤波器幅频响应', 'NumberTitle', 'off');
plot(f_resp, 20*log10(abs(H) + 1e-10), 'b-', 'LineWidth', 1.5);
hold on;
xline(1000, 'r--', '1000 Hz', 'LabelOrientation','horizontal');
xline(3000, 'r--', '3000 Hz', 'LabelOrientation','horizontal');
xline(f_low,  'g:', sprintf('%d Hz (阻带)', f_low),  'LabelOrientation','horizontal');
xline(f_mid,  'm-', sprintf('%d Hz (通带)', f_mid),  'LabelOrientation','horizontal');
xline(f_high, 'c:', sprintf('%d Hz (阻带)', f_high), 'LabelOrientation','horizontal');
ylim([-80 5]);  grid on;
xlabel('频率 (Hz)');  ylabel('幅度 (dB)');
title(['FIR 滤波器幅频响应  —  ' ftype_str]);
legend('|H(f)|', '通带边界', '', '500 Hz', '2000 Hz', '4000 Hz');

% -------------------------------------------------------------------------
% 图 2: 时域信号 — 输入与 MATLAB 滤波输出
% -------------------------------------------------------------------------
figure('Name', '时域信号对比', 'NumberTitle', 'off');
subplot(3,1,1);
stem(n, x_clean, 'filled', 'b'); grid on;
xlabel('样本 n');  ylabel('幅度');
title(sprintf('输入信号 (%d Hz + %d Hz + %d Hz)', f_low, f_mid, f_high));

subplot(3,1,2);
stem(n, y_matlab, 'filled', 'r'); grid on;
xlabel('样本 n');  ylabel('幅度');
title(['MATLAB 滤波输出  (' ftype_str ')']);

if dsp_available
    subplot(3,1,3);
    stem(n, y_dsp, 'filled', 'm'); grid on;
    xlabel('样本 n');  ylabel('幅度');
    title('DSP (fir.c) 滤波输出');
else
    subplot(3,1,3);
    text(0.5, 0.5, {'DSP 输出未找到', '请先运行 fir.c 生成 firOutput.dat'}, ...
         'HorizontalAlignment','center', 'Units','normalized', 'FontSize',12);
    axis off;
    title('DSP 输出 (不可用)');
end

% -------------------------------------------------------------------------
% 图 3: 频谱对比 (单边幅度谱)
% -------------------------------------------------------------------------
X_in  = abs(fft(x_clean)) / N;
Y_mat = abs(fft(y_matlab)) / N;
f_ax  = (0:N-1) * fs / N;

figure('Name', '频谱对比', 'NumberTitle', 'off');
if dsp_available
    subplot(3,1,1);
else
    subplot(2,1,1);
end
stem(f_ax, X_in, 'filled', 'b'); grid on;
xlabel('频率 (Hz)');  ylabel('幅度');
title('输入信号频谱');
xlim([0 fs/2]);

if dsp_available
    subplot(3,1,2);
else
    subplot(2,1,2);
end
stem(f_ax, Y_mat, 'filled', 'r'); grid on;
xlabel('频率 (Hz)');  ylabel('幅度');
title('MATLAB 滤波后频谱');
xlim([0 fs/2]);

if dsp_available
    Y_dsp = abs(fft(y_dsp)) / N;
    subplot(3,1,3);
    stem(f_ax, Y_dsp, 'filled', 'm'); grid on;
    xlabel('频率 (Hz)');  ylabel('幅度');
    title('DSP 滤波后频谱');
    xlim([0 fs/2]);
end

% -------------------------------------------------------------------------
% 图 4: MATLAB 与 DSP 结果误差对比 (若 DSP 数据可用)
% -------------------------------------------------------------------------
if dsp_available
    err = y_matlab - y_dsp;
    figure('Name', 'MATLAB vs DSP 误差', 'NumberTitle', 'off');
    subplot(2,1,1);
    plot(n, y_matlab, 'r-o', n, y_dsp, 'b--s', 'MarkerSize', 4);
    legend('MATLAB', 'DSP'); grid on;
    xlabel('样本 n');  ylabel('幅度');
    title('MATLAB 与 DSP 滤波输出对比');

    subplot(2,1,2);
    stem(n, err, 'filled', 'k'); grid on;
    xlabel('样本 n');  ylabel('误差');
    title(sprintf('误差 (MATLAB − DSP),  最大绝对误差 = %.2e', max(abs(err))));
end

% -------------------------------------------------------------------------
% 图 5: 不同信噪比 (SNR) 下的滤波效果
% -------------------------------------------------------------------------
snr_list = [5, 10, 20, 30];   % dB
figure('Name', '不同 SNR 下的滤波效果', 'NumberTitle', 'off');

sig_power = mean(x_clean .^ 2);
for idx = 1 : length(snr_list)
    snr_db = snr_list(idx);
    noise_power = sig_power / (10 ^ (snr_db / 10));
    noise = sqrt(noise_power) * randn(1, N);
    x_noisy = x_clean + noise;
    y_noisy = filter(b, 1, x_noisy);

    subplot(length(snr_list), 2, 2*idx-1);
    stem(n, x_noisy, 'filled', 'b', 'MarkerSize', 3); grid on;
    title(sprintf('含噪输入  SNR = %d dB', snr_db));
    xlabel('n');  ylabel('幅度');

    subplot(length(snr_list), 2, 2*idx);
    stem(n, y_noisy, 'filled', 'r', 'MarkerSize', 3); grid on;
    title(sprintf('滤波输出  SNR = %d dB', snr_db));
    xlabel('n');  ylabel('幅度');
end
sgtitle(['不同 SNR 下 FIR ' ftype_str ' 滤波效果']);

% -------------------------------------------------------------------------
% 7. 数值结果打印
% -------------------------------------------------------------------------
fprintf('\n===== 关键频点滤波增益验证 =====\n');
for fq = [f_low, f_mid, f_high]
    w = 2*pi*fq/fs;
    H_val = abs(sum(b .* exp(-1j*w*(0:M-1))));
    fprintf('  |H(%4d Hz)| = %.4f  (%.1f dB)\n', fq, H_val, 20*log10(H_val+1e-10));
end

fprintf('\n===== MATLAB 滤波输出 (前 10 点) =====\n');
for k = 1:10
    fprintf('  y_matlab[%2d] = %+.8f\n', k-1, y_matlab(k));
end

if dsp_available
    fprintf('\n===== DSP 滤波输出 (前 10 点) =====\n');
    for k = 1:10
        fprintf('  y_dsp   [%2d] = %+.8f\n', k-1, y_dsp(k));
    end
    fprintf('\n最大绝对误差 (MATLAB vs DSP): %.4e\n', max(abs(y_matlab - y_dsp)));
end

fprintf('\n实验完成。\n');

