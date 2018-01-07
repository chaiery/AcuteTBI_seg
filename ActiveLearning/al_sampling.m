%% Active learning sampling
function [samples_in, samples_out] = al_sampling(pool_1, score_model, num_cluster)
%% Then perform cluster for two matrix: pool_1_features, pool_0_features
    idx = kmeans(pool_1,num_cluster,'MaxIter',10000);
    
    [~, score] = predict(score_model,pool_1);

    % for each superpixel
    pool_entropy = repelem(0,length(pool_1));
    for i = 1:length(pool_1)
        entropy = -score(i,1)*log(score(i,1))-score(i,2)*log(score(i,2));
        pool_entropy(i) = entropy;
    end
    
    samples_in = [];
    samples_out = [];
    
    for i = 1:num_cluster
        index = find(idx==i);
        cluster = pool_1(index,:);
        cluster_entropy = pool_entropy(index);
        [~,A] = sort(cluster_entropy, 'descend');
        cluster = cluster(A,:);
        sample_in = cluster(1:10,:);
        samples_in = [samples_in; sample_in];
        
        if length(cluster)>1
            sample_out = cluster(2:end,:);
            samples_out = [samples_out; sample_out];
        end
    end

end

