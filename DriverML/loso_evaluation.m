function loso_evaluation(X, Y, SubjectID)
    % =========================
    % SUBJECT ID (LOSO)
    % =========================
    subjects = unique(SubjectID);

    % =========================
    % STORAGE METRICHE KNN
    % =========================
    acc = zeros(numel(subjects), 1);
    precision_all = zeros(numel(subjects), 1);
    recall_all = zeros(numel(subjects), 1);
    f1_all = zeros(numel(subjects), 1);
    fpr_all = zeros(numel(subjects), 1);

    Ytrue_all = [];
    Ypred_all = [];

    % =========================
    % STORAGE METRICHE SVM
    % =========================
    acc_svm_all      = zeros(numel(subjects), 1);
    precision_s_all  = zeros(numel(subjects), 1);
    recall_s_all     = zeros(numel(subjects), 1);
    f1_s_all         = zeros(numel(subjects), 1);
    fpr_s_all        = zeros(numel(subjects), 1);

    Ytrue_s_all = [];
    Ypred_s_all = [];

    % =========================
    % LOSO
    % =========================
    for s = 1:numel(subjects)

        testSub = subjects(s);
        fprintf('\n===== TEST: %s =====\n', testSub);

        testIdx  = SubjectID == testSub;
        trainIdx = ~testIdx;

        Xtrain = X(trainIdx, :);
        Ytrain = Y(trainIdx);

        Xtest  = X(testIdx, :);
        Ytest  = Y(testIdx);

        % Normalizzazione
        mu    = mean(Xtrain);
        sigma = std(Xtrain);
        sigma(sigma == 0) = 1;

        Xtrain = (Xtrain - mu) ./ sigma;
        Xtest  = (Xtest  - mu) ./ sigma;

        % =========================
        % KNN
        % =========================
        mdl = fitcknn(Xtrain, Ytrain, ...
            'NumNeighbors', 24, ...
            'Distance', 'euclidean');

        Ypred = predict(mdl, Xtest);

        % =========================
        % ACCURACY KNN
        % =========================
        acc(s) = mean(Ypred == Ytest);

        % ================================
        % CONFUSION MATRIX KNN (2 classi)
        % ================================
        order = categories(Y);

        cm = confusionmat(Ytest, Ypred, 'Order', categorical(order));

        % Classe positiva = "stress"
        idx_pos = find(string(order) == "stress");
        idx_neg = find(string(order) == "no stress");

        TP = cm(idx_pos, idx_pos);
        TN = cm(idx_neg, idx_neg);
        FP = cm(idx_neg, idx_pos);
        FN = cm(idx_pos, idx_neg);

        % =========================
        % METRICHE KNN
        % =========================
        precision = TP / (TP + FP + eps);
        recall    = TP / (TP + FN + eps);
        f1        = 2 * (precision * recall) / (precision + recall + eps);
        fpr       = FP / (FP + TN + eps);

        precision_all(s) = precision;
        recall_all(s)    = recall;
        f1_all(s)        = f1;
        fpr_all(s)       = fpr;

        fprintf('KNN - Accuracy   : %.2f%%\n', acc(s)*100);
        fprintf('KNN - Precision  : %.2f\n',   precision);
        fprintf('KNN - Recall     : %.2f\n',   recall);
        fprintf('KNN - F1-score   : %.2f\n',   f1);
        fprintf('KNN - FPR        : %.2f\n',   fpr);

        % accumulo globali KNN
        Ytrue_all = [Ytrue_all; Ytest];
        Ypred_all = [Ypred_all; Ypred];

        % ==================================
        % SVM (RBF) – conversione etichette
        % ==================================
        yTrainNum = double(Ytrain == categorical("stress"));
        yTestNum  = double(Ytest  == categorical("stress"));

        svmMdl = fitcsvm(Xtrain, yTrainNum, ...
            'KernelFunction', 'rbf', ...
            'KernelScale',    'auto', ...
            'BoxConstraint',  1, ...
            'Standardize',    false);

        yPredSVM = predict(svmMdl, Xtest);

        % =========================
        % ACCURACY SVM
        % =========================
        acc_svm = mean(yPredSVM == yTestNum);

        % ====================================
        % CONFUSION MATRIX SVM (ordine [0 1])
        % ====================================
        cm_svm = confusionmat(yTestNum, yPredSVM, 'Order', [0 1]);

        TP_s = cm_svm(2,2);
        TN_s = cm_svm(1,1);
        FP_s = cm_svm(1,2);
        FN_s = cm_svm(2,1);

        % =========================
        % METRICHE SVM
        % =========================
        precision_s = TP_s / (TP_s + FP_s + eps);
        recall_s    = TP_s / (TP_s + FN_s + eps);
        f1_s        = 2 * (precision_s * recall_s) / (precision_s + recall_s + eps);
        fpr_s       = FP_s / (FP_s + TN_s + eps);

        acc_svm_all(s)     = acc_svm;
        precision_s_all(s) = precision_s;
        recall_s_all(s)    = recall_s;
        f1_s_all(s)        = f1_s;
        fpr_s_all(s)       = fpr_s;

        fprintf('SVM - Accuracy   : %.2f%%\n', acc_svm*100);
        fprintf('SVM - Precision  : %.2f\n',   precision_s);
        fprintf('SVM - Recall     : %.2f\n',   recall_s);
        fprintf('SVM - F1-score   : %.2f\n',   f1_s);
        fprintf('SVM - FPR        : %.2f\n',   fpr_s);

        % accumulo globali SVM
        Ytrue_s_all = [Ytrue_s_all; yTestNum];
        Ypred_s_all = [Ypred_s_all; yPredSVM];
    end

    % =========================
    % RISULTATI FINALI KNN
    % =========================
    fprintf('\n====================\n');
    fprintf('KNN - Accuracy media     : %.2f%%\n', mean(acc)*100);
    fprintf('KNN - Precisione media   : %.2f%%\n', mean(precision_all)*100);
    fprintf('KNN - Recall media       : %.2f%%\n', mean(recall_all)*100);
    fprintf('KNN - F1-score medio     : %.2f%%\n', mean(f1_all)*100);
    fprintf('KNN - FPR medio          : %.2f%%\n', mean(fpr_all)*100);

    % =========================
    % CONFUSIONE GLOBALE KNN
    % =========================
    figure
    confusionchart(Ytrue_all, Ypred_all)
    title('LOSO KNN')

    % =========================
    % RISULTATI FINALI SVM
    % =========================
    fprintf('\n====================\n');
    fprintf('SVM - Accuracy media     : %.2f%%\n', mean(acc_svm_all)*100);
    fprintf('SVM - Precisione media   : %.2f%%\n', mean(precision_s_all)*100);
    fprintf('SVM - Recall media       : %.2f%%\n', mean(recall_s_all)*100);
    fprintf('SVM - F1-score medio     : %.2f%%\n', mean(f1_s_all)*100);
    fprintf('SVM - FPR medio          : %.2f%%\n', mean(fpr_s_all)*100);

    % =========================
    % CONFUSIONE GLOBALE SVM
    % =========================
    figure
    confusionchart(categorical(Ytrue_s_all), categorical(Ypred_s_all))
    title('LOSO SVM')
end