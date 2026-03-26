function equalizer_gui()
    % 5-Band Graphic Equalizer GUI
    % Load audio, control gains, visualize, and play processed audio
    
    % Initializing Variables
    audio_data = [];
    fs_audio = [];
    processed_audio = [];
    is_playing = false;
    player = [];
    
    % Loading filter coefficients
    if ~exist('eq_filters.mat', 'file')
        errordlg('Filter file eq_filters.mat not found! Run the filter design script first.', 'Error');
        return;
    end
    
    filter_data = load('eq_filters.mat');
    B_all = filter_data.B_all;
    A_all = filter_data.A_all;
    fc = filter_data.fc;
    
    % Initializing gains 
    gains_dB = [0, 0, 0, 0, 0];
    
    % Creating Main Figure with Resize Support
    fig = figure('Name', '5-Band Graphic Equalizer', ...
                 'NumberTitle', 'off', ...
                 'Position', [100, 100, 1200, 700], ...
                 'MenuBar', 'none', ...
                 'Toolbar', 'none', ...
                 'Resize', 'on', ...
                 'SizeChangedFcn', @resize_callback, ...
                 'CloseRequestFcn', @close_callback);
    
    % UI Components (we are using normalized units for auto-resize)
    
    % Title
    txt_title = uicontrol('Style', 'text', ...
                         'String', '5-BAND GRAPHIC EQUALIZER', ...
                         'Units', 'normalized', ...
                         'Position', [0.02, 0.92, 0.96, 0.06], ...
                         'FontSize', 18, ...
                         'FontWeight', 'bold', ...
                         'BackgroundColor', [0.94 0.94 0.94], ...
                         'HorizontalAlignment', 'center');
    
    % Load Audio Button
    btn_load = uicontrol('Style', 'pushbutton', ...
                         'String', 'Load Audio File', ...
                         'Units', 'normalized', ...
                         'Position', [0.04, 0.85, 0.12, 0.05], ...
                         'FontSize', 11, ...
                         'Callback', @load_audio);
    
    % Process Audio Button
    btn_process = uicontrol('Style', 'pushbutton', ...
                           'String', 'Process Audio', ...
                           'Units', 'normalized', ...
                           'Position', [0.17, 0.85, 0.12, 0.05], ...
                           'FontSize', 11, ...
                           'Enable', 'off', ...
                           'Callback', @process_audio);
    
    % Play Original Button
    btn_play_orig = uicontrol('Style', 'pushbutton', ...
                             'String', 'Play Original', ...
                             'Units', 'normalized', ...
                             'Position', [0.30, 0.85, 0.12, 0.05], ...
                             'FontSize', 11, ...
                             'Enable', 'off', ...
                             'Callback', @play_original);
    
    % Play Processed Button
    btn_play_proc = uicontrol('Style', 'pushbutton', ...
                             'String', 'Play Processed', ...
                             'Units', 'normalized', ...
                             'Position', [0.43, 0.85, 0.12, 0.05], ...
                             'FontSize', 11, ...
                             'Enable', 'off', ...
                             'Callback', @play_processed);
    
    % Stop Button
    btn_stop = uicontrol('Style', 'pushbutton', ...
                        'String', 'Stop', ...
                        'Units', 'normalized', ...
                        'Position', [0.56, 0.85, 0.12, 0.05], ...
                        'FontSize', 11, ...
                        'Enable', 'off', ...
                        'Callback', @stop_playback);
    
    % Reset Gains Button
    btn_reset = uicontrol('Style', 'pushbutton', ...
                         'String', 'Reset All Gains', ...
                         'Units', 'normalized', ...
                         'Position', [0.69, 0.85, 0.12, 0.05], ...
                         'FontSize', 11, ...
                         'Callback', @reset_gains);
    
    % Status Text
    txt_status = uicontrol('Style', 'text', ...
                          'String', 'Status: No audio loaded', ...
                          'Units', 'normalized', ...
                          'Position', [0.04, 0.79, 0.92, 0.04], ...
                          'FontSize', 10, ...
                          'BackgroundColor', [0.94 0.94 0.94], ...
                          'HorizontalAlignment', 'left');
    
    %% Gain Control Sliders Panel
    slider_panel = uipanel('Title', 'Gain Control (dB)', ...
                          'Units', 'normalized', ...
                          'Position', [0.04, 0.54, 0.92, 0.22], ...
                          'FontSize', 12, ...
                          'FontWeight', 'bold');
    
    sliders = cell(5, 1);
    slider_labels = cell(5, 1);
    slider_values = cell(5, 1);
    
    % Normalized x positions for 5 sliders
    slider_x = [0.08, 0.24, 0.40, 0.56, 0.72];
    
    for i = 1:5
        % Slider label (frequency)
        slider_labels{i} = uicontrol('Parent', slider_panel, ...
                                     'Style', 'text', ...
                                     'String', sprintf('%d Hz', fc(i)), ...
                                     'Units', 'normalized', ...
                                     'Position', [slider_x(i)-0.04, 0.75, 0.12, 0.15], ...
                                     'FontSize', 10, ...
                                     'FontWeight', 'bold');
        
        % Slider
        sliders{i} = uicontrol('Parent', slider_panel, ...
                              'Style', 'slider', ...
                              'Min', -12, 'Max', 12, ...
                              'Value', 0, ...
                              'Units', 'normalized', ...
                              'Position', [slider_x(i), 0.20, 0.04, 0.50], ...
                              'Callback', {@slider_callback, i});
        
        % Value display
        slider_values{i} = uicontrol('Parent', slider_panel, ...
                                    'Style', 'text', ...
                                    'String', '0.0 dB', ...
                                    'Units', 'normalized', ...
                                    'Position', [slider_x(i)-0.04, 0.05, 0.12, 0.12], ...
                                    'FontSize', 9);
    end
    
    %% Plotting Axes (using normalized units)
    
    % Input Time Domain
    ax_input_time = axes('Units', 'normalized', ...
                        'Position', [0.08, 0.34, 0.38, 0.16]);
    title('Input Signal - Time Domain');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;
    
    % Output Time Domain
    ax_output_time = axes('Units', 'normalized', ...
                         'Position', [0.54, 0.34, 0.38, 0.16]);
    title('Output Signal - Time Domain');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;
    
    % Input Frequency Spectrum
    ax_input_freq = axes('Units', 'normalized', ...
                        'Position', [0.08, 0.08, 0.38, 0.16]);
    title('Input Spectrum');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    grid on;
    
    % Output Frequency Spectrum
    ax_output_freq = axes('Units', 'normalized', ...
                         'Position', [0.54, 0.08, 0.38, 0.16]);
    title('Output Spectrum');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    grid on;
    
    %% Callback Functions
    
    function resize_callback(~, ~)
        % This function is called when window is resized
        % All components use normalized units so they auto-resize
        % We just need to ensure minimum size
        pos = get(fig, 'Position');
        if pos(3) < 800
            pos(3) = 800;
        end
        if pos(4) < 600
            pos(4) = 600;
        end
        set(fig, 'Position', pos);
    end
    
    function load_audio(~, ~)
        % Load audio file
        [filename, pathname] = uigetfile({'*.wav;*.mp3;*.m4a;*.flac', 'Audio Files (*.wav, *.mp3, *.m4a, *.flac)'}, ...
                                         'Select Audio File');
        if filename == 0
            return;
        end
        
        try
            filepath = fullfile(pathname, filename);
            [audio_data, fs_audio] = audioread(filepath);
            
            % Convert to mono if stereo
            if size(audio_data, 2) == 2
                audio_data = mean(audio_data, 2);
                set(txt_status, 'String', sprintf('Status: Loaded %s (converted to mono) - Fs = %d Hz', filename, fs_audio));
            else
                set(txt_status, 'String', sprintf('Status: Loaded %s - Fs = %d Hz', filename, fs_audio));
            end
            
            % Normalize
            audio_data = audio_data / max(abs(audio_data));
            
            % Enable process button
            set(btn_process, 'Enable', 'on');
            set(btn_play_orig, 'Enable', 'on');
            
            % Plot input signal
            plot_input_signal();
            
        catch err
            errordlg(['Error loading audio: ' err.message], 'Error');
        end
    end
    
    function process_audio(~, ~)
        if isempty(audio_data)
            errordlg('Please load audio first!', 'Error');
            return;
        end
        
        try
            set(txt_status, 'String', 'Status: Processing audio...');
            drawnow;
            
            % Apply equalizer
            processed_audio = zeros(size(audio_data));
            gains_linear = 10.^(gains_dB / 20);
            
            for i = 1:5
                % Filter audio through each band
                filtered = filter(B_all{i}, A_all{i}, audio_data);
                
                % Apply gain
                processed_audio = processed_audio + gains_linear(i) * filtered;
            end
            
            % Normalize to prevent clipping
            max_val = max(abs(processed_audio));
            if max_val > 0.99
                processed_audio = processed_audio * (0.99 / max_val);
            end
            
            % Plot output signal
            plot_output_signal();
            
            % Enable play processed button
            set(btn_play_proc, 'Enable', 'on');
            set(txt_status, 'String', 'Status: Audio processed successfully');
            
        catch err
            errordlg(['Error processing audio: ' err.message], 'Error');
            set(txt_status, 'String', 'Status: Error processing audio');
        end
    end
    
    function play_original(~, ~)
        if isempty(audio_data)
            return;
        end
        
        stop_playback();
        
        try
            player = audioplayer(audio_data, fs_audio);
            set(player, 'StopFcn', @player_stopped);
            play(player);
            is_playing = true;
            set(btn_stop, 'Enable', 'on');
            set(txt_status, 'String', 'Status: Playing original audio...');
        catch err
            errordlg(['Error playing audio: ' err.message], 'Error');
        end
    end
    
    function play_processed(~, ~)
        if isempty(processed_audio)
            return;
        end
        
        stop_playback();
        
        try
            player = audioplayer(processed_audio, fs_audio);
            set(player, 'StopFcn', @player_stopped);
            play(player);
            is_playing = true;
            set(btn_stop, 'Enable', 'on');
            set(txt_status, 'String', 'Status: Playing processed audio...');
        catch err
            errordlg(['Error playing audio: ' err.message], 'Error');
        end
    end
    
    function stop_playback(~, ~)
        if ~isempty(player) && isplaying(player)
            stop(player);
        end
        is_playing = false;
        set(btn_stop, 'Enable', 'off');
        if ~isempty(audio_data)
            set(txt_status, 'String', 'Status: Playback stopped');
        end
    end
    
    function player_stopped(~, ~)
        is_playing = false;
        set(btn_stop, 'Enable', 'off');
        set(txt_status, 'String', 'Status: Playback finished');
    end
    
    function slider_callback(src, ~, idx)
        gains_dB(idx) = get(src, 'Value');
        set(slider_values{idx}, 'String', sprintf('%.1f dB', gains_dB(idx)));
        
        % Auto-process if audio is loaded
        if ~isempty(audio_data)
            process_audio();
        end
    end
    
    function reset_gains(~, ~)
        for i = 1:5
            set(sliders{i}, 'Value', 0);
            gains_dB(i) = 0;
            set(slider_values{i}, 'String', '0.0 dB');
        end
        
        if ~isempty(audio_data)
            process_audio();
        end
    end
    
    function plot_input_signal()
        % Time domain
        t = (0:length(audio_data)-1) / fs_audio;
        
        axes(ax_input_time);
        cla;
        plot(t, audio_data, 'b', 'LineWidth', 0.5);
        title('Input Signal - Time Domain');
        xlabel('Time (s)');
        ylabel('Amplitude');
        grid on;
        xlim([0, min(t(end), 5)]);
        
        % Frequency domain
        N = length(audio_data);
        freq_data = fft(audio_data);
        freq_data = freq_data(1:floor(N/2));
        freq_axis = (0:length(freq_data)-1) * fs_audio / N;
        
        axes(ax_input_freq);
        cla;
        mag_dB = 20*log10(abs(freq_data) + eps);
        semilogx(freq_axis, mag_dB, 'b', 'LineWidth', 0.5);
        title('Input Spectrum');
        xlabel('Frequency (Hz)');
        ylabel('Magnitude (dB)');
        grid on;
        xlim([20, min(20000, fs_audio/2)]);
    end
    
    function plot_output_signal()
        % Time domain
        t = (0:length(processed_audio)-1) / fs_audio;
        
        axes(ax_output_time);
        cla;
        plot(t, processed_audio, 'r', 'LineWidth', 0.5);
        title('Output Signal - Time Domain');
        xlabel('Time (s)');
        ylabel('Amplitude');
        grid on;
        xlim([0, min(t(end), 5)]);
        
        % Frequency domain
        N = length(processed_audio);
        freq_data = fft(processed_audio);
        freq_data = freq_data(1:floor(N/2));
        freq_axis = (0:length(freq_data)-1) * fs_audio / N;
        
        axes(ax_output_freq);
        cla;
        mag_dB = 20*log10(abs(freq_data) + eps);
        semilogx(freq_axis, mag_dB, 'r', 'LineWidth', 0.5);
        title('Output Spectrum');
        xlabel('Frequency (Hz)');
        ylabel('Magnitude (dB)');
        grid on;
        xlim([20, min(20000, fs_audio/2)]);
    end
    
    function close_callback(~, ~)
        stop_playback();
        delete(fig);
    end
end