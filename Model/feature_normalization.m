function nom = feature_normalization(fmatrix, fmean, fstd)
    if (nargin==1)
        % Using mean and std of the dataset
        % For training data
        n = length(fmatrix(:,1));
        nom = fmatrix - repmat(mean(fmatrix),n,1);
        fstd = std(fmatrix,0,1);
        fstd(fstd==0)=1; % Avoid Inf
        nom = nom./repmat(fstd,n,1);
    elseif (nargin == 3)
        % Using predefined mean and std
        % For testing data
        n = length(fmatrix(:,1));
        nom = fmatrix - repmat(fmean,n,1);
        nom = nom./repmat(fstd,n,1);
    end
end