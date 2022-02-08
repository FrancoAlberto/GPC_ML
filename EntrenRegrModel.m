function [Modelo, RMSE] = EntrenRegrModel(DataEntrenar)
% [trainedModel, validationRMSE] = trainRegressionModel(trainingData)
% Returns a trained regression model and its RMSE. This code recreates the
% model trained in Regression Learner app. Use the generated code to
% automate training the same model with new data, or to learn how to
% programmatically train models.
%
%  Input:
%      trainingData: A table containing the same predictor and response
%       columns as those imported into the app.
%
%  Output:
%      trainedModel: A struct containing the trained regression model. The
%       struct contains various fields with information about the trained
%       model.
%
%      trainedModel.predictFcn: A function to make predictions on new data.
%
%      validationRMSE: A double containing the RMSE. In the app, the
%       History list displays the RMSE for each model.
%
% Use the code to train the model with new data. To retrain your model,
% call the function from the command line with your original data or new
% data as the input argument trainingData.
%
% For example, to retrain a regression model trained with the original data
% set T, enter:
%   [trainedModel, validationRMSE] = trainRegressionModel(T)
%
% To make predictions with the returned 'trainedModel' on new data T2, use
%   yfit = trainedModel.predictFcn(T2)
%
% T2 must be a table containing at least the same predictor columns as used
% during training. For details, enter:
%   trainedModel.HowToPredict

% Auto-generated by MATLAB on 05-Aug-2021 11:29:23


% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = DataEntrenar;
predictorNames = {'Ingreso mensual de la familia (S/.)', 'Diferencia de gastos en servicios (S/.)', 'Número de personas en la vivienda', 'Agua en la vivienda', 'Electricidad en la vivienda', 'Celular en la vivienda', 'TV en la vivienda', 'Servicios'};
predictors = inputTable(:, predictorNames);
response = inputTable.('Generación percápita (Kg/hab/día)');
isCategoricalPredictor = [false, false, false, true, true, true, true, true];

% Train a regression model
% This code specifies all the model options and trains the model.
concatenatedPredictorsAndResponse = predictors;
concatenatedPredictorsAndResponse.('Generación percápita (Kg/hab/día)') = response;
linearModel = stepwiselm(...
    concatenatedPredictorsAndResponse, ...
    'linear', ...
    'Upper', 'interactions', ...
    'NSteps', 1000, ...
    'Verbose', 0);

% Create the result struct with predict function
predictorExtractionFcn = @(t) t(:, predictorNames);
linearModelPredictFcn = @(x) predict(linearModel, x);
Modelo.predictFcn = @(x) linearModelPredictFcn(predictorExtractionFcn(x));

% Add additional fields to the result struct
Modelo.RequiredVariables = {'Agua en la vivienda', 'Celular en la vivienda', 'Diferencia de gastos en servicios (S/.)', 'Electricidad en la vivienda', 'Ingreso mensual de la familia (S/.)', 'Número de personas en la vivienda', 'Servicios', 'TV en la vivienda'};
Modelo.LinearModel = linearModel;
Modelo.About = 'This struct is a trained model exported from Regression Learner R2020a.';
Modelo.HowToPredict = sprintf('To make predictions on a new table, T, use: \n  yfit = c.predictFcn(T) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nThe table, T, must contain the variables returned by: \n  c.RequiredVariables \nVariable formats (e.g. matrix/vector, datatype) must match the original training data. \nAdditional variables are ignored. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appregression_exportmodeltoworkspace'')">How to predict using an exported model</a>.');

% Extract predictors and response
% This code processes the data into the right shape for training the
% model.
inputTable = DataEntrenar;
predictorNames = {'Ingreso mensual de la familia (S/.)', 'Diferencia de gastos en servicios (S/.)', 'Número de personas en la vivienda', 'Agua en la vivienda', 'Electricidad en la vivienda', 'Celular en la vivienda', 'TV en la vivienda', 'Servicios'};
predictors = inputTable(:, predictorNames);
response = inputTable.('Generación percápita (Kg/hab/día)');
isCategoricalPredictor = [false, false, false, true, true, true, true, true];

% Perform cross-validation
KFolds = 5;
cvp = cvpartition(size(response, 1), 'KFold', KFolds);
% Initialize the predictions to the proper sizes
validationPredictions = response;
for fold = 1:KFolds
    trainingPredictors = predictors(cvp.training(fold), :);
    trainingResponse = response(cvp.training(fold), :);
    foldIsCategoricalPredictor = isCategoricalPredictor;
    
    % Train a regression model
    % This code specifies all the model options and trains the model.
    concatenatedPredictorsAndResponse = trainingPredictors;
    concatenatedPredictorsAndResponse.('Generación percápita (Kg/hab/día)') = trainingResponse;
    linearModel = stepwiselm(...
        concatenatedPredictorsAndResponse, ...
        'linear', ...
        'Upper', 'interactions', ...
        'NSteps', 1000, ...
        'Verbose', 0);
    
    % Create the result struct with predict function
    linearModelPredictFcn = @(x) predict(linearModel, x);
    validationPredictFcn = @(x) linearModelPredictFcn(x);
    
    % Add additional fields to the result struct
    
    % Compute validation predictions
    validationPredictors = predictors(cvp.test(fold), :);
    foldPredictions = validationPredictFcn(validationPredictors);
    
    % Store predictions in the original order
    validationPredictions(cvp.test(fold), :) = foldPredictions;
end

% Compute validation RMSE
isNotMissing = ~isnan(validationPredictions) & ~isnan(response);
RMSE = sqrt(nansum(( validationPredictions - response ).^2) / numel(response(isNotMissing) ));
