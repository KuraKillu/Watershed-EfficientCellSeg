% =========================================================================
% EKSPERIMEN POST-PROCESSING (METODE WATERSHED)
% =========================================================================

%% 1. Daftar Gambar
image_folder = 'image';
file_list = {
    'Fluo-C3DH-A549-SIM.png', ...
    'Fluo-C3DL-MDA231.png', ...
    'Fluo-N3DL-TRIC.png'
    };

%% 2. Loop untuk Setiap Gambar
for i = 1:length(file_list)
    
    current_filename_with_ext = file_list{i};
    image_path = fullfile(image_folder, current_filename_with_ext);
    
    fprintf('Memproses gambar: %s\n', current_filename_with_ext);
    
    % --- Validasi File ---
    if ~exist(image_path, 'file')
        warning('File gambar tidak ditemukan: %s. Melanjutkan ke gambar berikutnya.', image_path);
        continue;
    end
    
    % --- Memuat dan Pra-pemrosesan ---
    original_image = imread(image_path);
    if size(original_image, 3) == 3
        gray_image = rgb2gray(original_image);
    else
        gray_image = original_image;
    end
    
    raw_segmentation = imbinarize(gray_image);
    
    % --- Post-Processing Menggunakan Fungsi Watershed ---
    processed_segmentation = postprocess_cells_regular(raw_segmentation);
    
    % --- Visualisasi untuk Setiap Gambar ---
    figure;
    
    subplot(1, 2, 1);
    imshow(original_image);
    title('Original');
    
    subplot(1, 2, 2);
    imshow(processed_segmentation);
    title('Setelah Post-Processing (Watershed Biasa)');
    
    % Menghapus ekstensi .png dari nama file untuk judul
    [~, basename, ~] = fileparts(current_filename_with_ext);
    title_text = sprintf('Hasil Proses untuk: %s', basename);
    sgtitle(title_text, 'FontSize', 14);
    
end

fprintf('Semua gambar telah selesai diproses.\n');


%% FUNGSI UNTUK POST-PROCESSING (WATERSHED)
function final_mask_rgb = postprocess_cells_regular(binary_mask)

    % Mengisi lubang-lubang kecil di dalam objek sel
    filled_mask = imfill(binary_mask, 'holes');

    % Menghitung Distance Transform
    D = -bwdist(~filled_mask);
    
    % Menjalankan Watershed
    L = watershed(D);
    
    % Membuat citra hasil
    final_mask = filled_mask;
    final_mask(L == 0) = 0; % Membuat garis pemisah
    
    % Menghilangkan noise
    pixel_threshold = 15;
    final_mask = bwareaopen(final_mask, pixel_threshold);
    final_mask_rgb = label2rgb(bwlabel(final_mask), 'jet', 'k', 'shuffle');
end