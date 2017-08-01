function [samples_in, samples_out,value] = active_learning_strategy(pool_1, model,number)
    %[~, score] = predict(score_model,pool_1);

    % for each superpixel
    % pool_entropy = repelem(0,length(pool_1));
   % for i = 1:length(pool_1)
        %entropy = -abs(score(i,1)-0.5);
        %entropy = -score(i,1)*log(score(i,1))-score(i,2)*log(score(i,2));
%         if label==1
%             entropy = score(i,1);
%         else
%             entropy = score(i,2);
%         end

        
    %end
    distance = pool_1*model.Beta+model.Bias;
    pool_entropy = -1*abs(distance);
        
    [B,A] = sort(pool_entropy, 'descend');
    value = B(number);
    samples_in = pool_1(A(1:number),:);
    samples_out = pool_1(A(number+1:end),:);
   
end