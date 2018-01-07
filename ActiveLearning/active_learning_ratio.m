function [samples_in, samples_class, pool_adaptive, pool_class_adaptive] = active_learning_ratio(pool_adaptive, pool_class_adaptive, score_model, number) 
    
    [~, score] = predict(score_model,pool_adaptive);

    % for each superpixel
    pool_entropy = repelem(0,length(pool_adaptive));
    for i = 1:length(pool_adaptive)
        entropy = -abs(score(i,1)-0.5);
        %entropy = -score(i,1)*log(score(i,1))-score(i,2)*log(score(i,2));
        pool_entropy(i) = entropy;
    end
    
    [~,A] = sort(pool_entropy, 'descend');
    samples_in = pool_adaptive(A(1:number),:);
    samples_class = pool_class_adaptive(A(1:number));
    pool_adaptive = pool_adaptive(A(number+1:end),:);
    pool_class_adaptive = pool_class_adaptive(A(number+1:end));

end