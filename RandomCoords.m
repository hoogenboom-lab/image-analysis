
MainFolder = '';
FilePattern = strcat(MainFolder, '*.csv');
Files = dir(FilePattern);

% Get 5 sets of random coordinates within real image bounds
for z = 1 : 5
    for k = 1 : length(Files)
        Dists_filename = strcat(Files(k).folder, '\', Files(k).name);
        Dists = readtable(Dists_filename);

        Parts = split(Files(k).name, '_CLAHE');
        SampleName = Parts{1};
        SizeFiles = dir(strcat(Files(k).folder, '\*_', SampleName, '_Area_only.tif'));

        %Get area outline 

        AreaOutlineFile = '';
        AreaOutlinergb = imread(AreaOutlineFile);
        if size(AreaOutlinergb,3)==3
            AreaOutlineBW = imbinarize(rgb2gray(AreaOutlinergb));
        else 
            AreaOutlineBW = imbinarize(AreaOutlinergb);
        end
        ImageSize = size(AreaOutlineBW);

        %Change ImageSize scale to nm
        nmPerPixel = 500/512;
        w = ImageSize(1)/nmPerPixel;
        h = ImageSize(2)/nmPerPixel;
        areanm = imresize(AreaOutlineBW, nmPerPixel);
        
        % Get Random coordinates
        RanCoords = [];
        % Find same number as real coordinates
        while length(RanCoords) < height(Dists)
            x = randi([1 ImageSize(1)], 1, 1);
            y = randi([1 ImageSize(2)], 1, 1);
            xnm = x/nmPerPixel;
            ynm = y/nmPerPixel;
            xy = [xnm,ynm];
            % Make sure coordinate falls within image boundary
            if AreaOutlineBW(x,y) == 1 
                RanCoords = [RanCoords;xy];
                RanCoordsSize = size(RanCoords);
                % And that the coordinates are no closer than physically
                % possible 
                for j = 1 : (RanCoordsSize(1)-2)
                    Dist = sqrt((xnm - RanCoords(j,1))^2 + (ynm - RanCoords(j,2))^2);
                    if Dist <= 8 
                       RanCoords(end,:) = [];
                       continue;
                    end    
                end
            end             
        end

        %Save all the ran coords
        savenumber1 = strcat('RanCoords', num2str(z));
        RanCoordsFile = strcat(Files(k).folder, '\', 'Out\', strrep(Files(k).name, 'CLAHE_prediction', savenumber1));
        writematrix(RanCoords, RanCoordsFile);

    end
end