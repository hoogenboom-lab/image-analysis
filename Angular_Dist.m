% Set main main folder as one with all cell types in folders, for summary
% table at end
MainMainFolder = '';

% This is a structure of all cell type folders
% cells = ;

% Loop through each cell type
for a = 1 : length(cells)
    % Get all coordinate files for pores in cell type a
    cell = cells(a).name;
    MainFolder = strcat(MainMainFolder, cell, '\out\');
    FilePattern = strcat(MainFolder, '*.csv');
    Files = dir(FilePattern);

    % Open blank arrays for later
    AllAlldiffs = [];
    AllAllAngs = [];

    % Go through each coordinate file (corresponding to one cell each) 
    for k = 1 : length(Files)
        Alldiffs = [];
        Sample = strcat(MainFolder, Files(k).name);
        coords = readmatrix(Sample);
        % Convert coords to nm
        Coordsnm = (500*coords(:,:))/512;
        % Find nearest 10 neighbours. This will be plenty to include those
        % within 15 nm 
        [idx,d] = knnsearch(Coordsnm, Coordsnm, 'k', 10);
        % For each pore...
        for j = 1 : length(Coordsnm)
            row = [];
            % ...compare to each neighbour
            for i = 2 : width(idx)
                % if neighbour is less than 15 nm away
                if d(j,i) <= 15 
                    %get angle between neighbours and x axis
                    angle_xaxis = atan((Coordsnm(idx(j,i),2)-Coordsnm(j,2))/(Coordsnm(idx(j,i),1)-Coordsnm(j,1)))*(180/pi);

                    % As arctan has a limited range of angles, need to do some rescaling
                    % depending on angle
                    % For angles between 90 and 275
                    if ((Coordsnm(idx(j,i),1)-Coordsnm(j,1)) < 0) 
                        %rescale so going form 0 to 360
                        angle_axis_actual = angle_xaxis + 180; 
                    % For angles between 275 and 360
                    elseif ((Coordsnm(idx(j,i),1)-Coordsnm(j,1)) > 0) && ((Coordsnm(idx(j,i),2)-Coordsnm(j,2)) < 0) 
                        %rescale so going form 0 to 360
                        angle_axis_actual = 360 + angle_xaxis; 
                    % Angles between 0 and 90 remain same
                    else
                        angle_axis_actual = angle_xaxis; 
                    end
                        %append all angles for this pore
                        row = [row,angle_axis_actual];
                end
                % Sort angles so they go clockwise
                AllAllAngs = [AllAllAngs;row.'];
                rowsorted = sort(row);
                % Find difference between neighbours
                diffs = [];
                for h = 1 : width(rowsorted)
                    % Don't use pores with only 1 neighbour.
                    % For the last neighbour angle...
                    if width(rowsorted) >= 3
                        % ...get the difference between that last angle and
                        % the first angle
                        if h == width(rowsorted)
                            difference = rowsorted(1) - rowsorted(h) + 360;
                        % For the others, just subtract from the following
                        % angle
                        else
                            difference = rowsorted(h+1) - rowsorted(h);
                        end
                        diffs = [diffs,difference];
                    end
                end
                % Append all differences for this sample
                Alldiffs = [Alldiffs;diffs.'];
            end
        end
        % Append all differences for this cell type
        AllAlldiffs = [AllAlldiffs;Alldiffs];
    end

    % Bin data in 1 degree bins
    histogram(AllAlldiffs)
    [N,edges] = histcounts(AllAlldiffs,[-0.5:1:360.5]);
    NormN = N/sum(N);
    SamplesHist = [[0:1:360].',NormN.'];
    writematrix(SamplesHist, strcat(MainMainFolder,cell,'_AngDist.csv'));

end
