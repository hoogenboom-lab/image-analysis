
% Get all coordinate files
MainFolder = 'C:\Users\gdbenn\Documents\Data\Georginadata\WholeCellData\deltaOmpR+OmpR_Supressed\out\';
FilePattern = strcat(MainFolder, '*.csv');
Files = dir(FilePattern);

% Set bin parameters
BinSize = 15;
Edges = 0:BinSize:2500;
Middles = (BinSize/2):BinSize:(2500-(BinSize/2));

% For each sample
for k = 1 : length(Files)
    % Get real cooridinates file
    CoordsFile = strcat(Files(k).folder, '\', Files(k).name);
    RealCoordsTable = readtable(CoordsFile);
    Coords = table2array(RealCoordsTable(:,:));
    % Convert coordinates from pixels to nm
    Coords = Coords*512/500;
    % Get all distances for the real data
    AllRealDists = [];
    % Take each coordinate at a time
    for i = 1 : length(Coords)
        DistsForGR = [];        
        % Get the distance between coordinate i and all other coordinates
        for j = 1 : length(Coords)
            Dist = sqrt((Coords(i,1)- Coords(j,1))^2 + (Coords(i,2)- Coords(j,2))^2);
            % Add all the distances in one column 
            DistsForGR = [DistsForGR;Dist];
        end
        % For g(r) append all distances between all coordinates together in
        % one enormous array
        AllRealDists = [AllRealDists,DistsForGR];
    end
    
    % Remove repeats from distances as each pair is compared twice
    SizeDists = size(AllRealDists);
    for i = 1 : SizeDists(1)
        AllRealDists(i:end,i) = NaN;
    end 
    
    % Save real distances
    DistsFilename = strcat(Files(k).folder, '\Out\', strrep(Files(k).name, '.csv', 'all_dists_real.txt'));
    writematrix(AllRealDists, DistsFilename);
    
    % Put all distances in one column
    RealDists1D = AllRealDists(:);
    % Remove NaNs and sort lowest to highest
    RealDists1D = sort(RealDists1D(~isnan(RealDists1D)));
    
    % Take each RandomCoords file for this sample and get distances for gr
    FileParts = split(Files(k).name, 'CLAHE');
    AllRanNNs = [];
    AllRanDists1D = [];
    % For all 5 random coordinate files...
    for n = 1 : 5
        if n == 1
            RanCoordsFile = strcat(Files(k).folder, '\Out\', FileParts{1}, 'RanCoords1', '.csv');
        else
            RanCoordsFile = strcat(Files(k).folder, '\Out\', FileParts{1}, 'RanCoords', num2str(n), '.csv');
        end
        % ... open coordinates 
        RanCoordsTable = readtable(RanCoordsFile);
        RanCoords = table2array(RanCoordsTable);   
        % Take each coord at a time
        AllRanDists = [];
        for i = 1 : length(RanCoords)
            DistsForGR = [];        
            % Get the distance between coordinate i and all other coordinates
            for j = 1 : length(RanCoords)
                Dist = sqrt((RanCoords(i,1)- RanCoords(j,1))^2 + (RanCoords(i,2)- RanCoords(j,2))^2);
                % Add all the distances in one column 
                DistsForGR = [DistsForGR;Dist];
            end
            % For g(r) append all distances together in one enormous array
            AllRanDists = [AllRanDists,DistsForGR];
        end
        
        % Save random distances
        ranDistsFilename = strcat(Files(k).folder, '\Out\', strrep(Files(k).name, '.csv', 'all_dists'), '_Ran', num2str(n), '.txt');
        writematrix(AllRanDists, ranDistsFilename);
        
        % Remove repeats 
        SizeDists = size(AllRanDists);
        for i = 1 : SizeDists(1)
            AllRanDists(i:end,i) = NaN;
        end   

        
        
        % Put all dists in one column
        RanDists1D = AllRanDists(:);
        % Remove NaNs and sort lowest to highest
        RanDists1D = sort(RanDists1D(~isnan(RanDists1D)));
        % Put all Ran distances in one array
        AllRanDists1D = [AllRanDists1D,RanDists1D];
    end
           
    AllDists = [RealDists1D,AllRanDists1D];
        
    % Get g(r)
    % Get area used by opening area files, converting to binary and summing
    % pixels
    AreaFile = strcat(strrep(Files(k).folder, '\out', '\'), strrep(Files(k).name, 'CLAHE_prediction.csv', 'area.tiff'));
    AreaNumber = imread(AreaFile); 
    Area = 500*(sum(AreaNumber,'all'))/(255*512);
        
    % Bin all distances to save
    AllBinned = Middles.';
    for n = 1 : 6
        N = (histcounts(AllDists(:,n),Edges)).';
        AllBinned = [AllBinned,N];
    end
    
    % Save binned distances
    BinnedDistFilename = strcat(Files(k).folder, '\Out\', strrep(Files(k).name, '.csv', 'binned_dists.txt'));
    writematrix(AllBinned, BinnedDistFilename);
    
    NumDists = sum(AllBinned(:,2));
    BinnedNoMiddles = AllBinned(:,2:end);
    gr = [];
    % For real and all random cases
    for i = 1 : size(BinnedNoMiddles,1)
        grcol = [];
        % Take each bin
        for j = 1 : size(BinnedNoMiddles,2)
            % Calculate g(r)
            grij = (BinnedNoMiddles(i,j)*Area)/(2*pi*Middles(i)*BinSize*NumDists);
            % Append for each bin
            grcol = [grcol,grij];
        end
        % Append for each sample 
        gr = [gr;grcol];
    end
    
    grwithMiddles = [Middles.',gr];
    
    % Save grs 
    grFilename = strcat(Files(k).folder, '\Out\', strrep(Files(k).name, '.csv', 'grs.txt'));
    writematrix(grwithMiddles, grFilename);
    

    
end
    
    
        
        
        
        
        
        
        
        
   
    
    
    
