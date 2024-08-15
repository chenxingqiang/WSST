function [X_balanced, y_balanced] = balanceDataset(X, y)
    % BALANCEDATASET Balance the dataset by undersampling the majority class
    classes = categories(y);
    numClasses = length(classes);
    counts = countcats(y);
    [~, minorityIdx] = min(counts);
    minorityClass = classes{minorityIdx};
    
    X_balanced = [];
    y_balanced = categorical();
    
    for i = 1:numClasses
        currentClass = classes{i};
        idx = y == currentClass;
        X_class = X(idx, :);
        y_class = y(idx);
        
        if strcmp(currentClass, minorityClass)
            X_balanced = [X_balanced; X_class];
            y_balanced = [y_balanced; y_class];
        else
            numSamples = sum(y == minorityClass);
            randIdx = randperm(size(X_class, 1), numSamples);
            X_balanced = [X_balanced; X_class(randIdx, :)];
            y_balanced = [y_balanced; y_class(randIdx)];
        end
    end
    
    randIdx = randperm(size(X_balanced, 1));
    X_balanced = X_balanced(randIdx, :);
    y_balanced = y_balanced(randIdx);
end

