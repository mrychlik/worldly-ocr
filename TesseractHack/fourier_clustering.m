function [cluster_idx, cluster_num, cluster_reps] = fourier_clustering(objects)
fprintf('Determining maximum object size...')
max_h = 0;
max_w = 0;
for j=1:length(objects)
    [h,w] = size(objects(j).bwimage);
    max_h = max(max_h, h);
    max_w = max(max_w, w);
end
fprintf('Max. height: %g, max. width: %g', max_h, max_w);


wb = waitbar(0, 'Cropping/centering objects and converting to grayscale...');
num_objects = length(objects);
for j=1:num_objects;
    waitbar(j/num_objects, wb);
    J = zeros([max_h,max_w],'uint8');
    BW = objects(j).bwimage;
    [h,w] = size(BW);
    x = round((max_w - w)/2);
    y = round((max_h - h)/2);
    J( (y+1):(y+h), (x+1):(x+w) ) = BW .* 255;
    objects(j).grayscaleimage = J;
    objects(j).char = ' ';
end
close(wb);

% Find equivalent objects
n = length(objects);
Q = zeros(n,n);
threshold = .75;
classified = zeros(1,n);
cluster_reps = zeros(1,n);
for j = 1:(n-1)
    if classified(j)
        continue;
    end;
    classified(j)=1;
    cluster_reps(j)=1;
    fprintf('New object: %d, Number of classes: %d\n', j, length(find(cluster_reps)));
    for k = (j+1):n
        D = dissimilarity(objects(j), objects(k));
        if classified(k)
            continue;
        end
        if D > threshold
            Q(j,k)=1;
            classified(k) = 1;
        end
    end
end

% Visualize classes
imagesc(Q),drawnow;
cluster_idx = zeros(1,n);
cluster_num = 0;
for j = 1:n
    if cluster_reps(j)
        idx = [j,find(Q(j,:))];
        cluster_num = cluster_num + 1;
        class_idx(idx) = cluster_num;
        s = length(idx);
        t = ceil(sqrt(s));
        for k=1:s
            subplot(t,t,k), imagesc(objects(idx(k)).grayscaleimage);
        end
        drawnow, pause(1);
        clf;
    end
end
