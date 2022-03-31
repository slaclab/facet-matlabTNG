classdef F2_MDLFFApp < handle
  %F2_MDLFF FACET Main Drive line feed-forward
  properties(Transient)
    predpv PV
    pvlist PV
    pvs
    data
  end
  properties(SetAccess=private)
    regmodel
    MDL_temps
    Pressure
  end
  properties(Constant)
    secs=11:19
  end
  methods
    function obj = F2_MDLFFApp()
      %F2_MDLFF FACET Main Drive line feed-forward
      
      % - monitor PVs
      cntx=PV.Initialize(PVtype.EPICS);
%       obj.pvlist(end+1) = PV(cntx,'Name',"Pressure",'pvname',"ROOM:BSY0:1:OUTSIDEPRESFMDL0_S",'monitor',true) ;
      n=0;
      for isec=obj.secs
        n=n+1;
        obj.predpv(end+1) = PV(cntx,'Name',"PHA Prediction SBST"+isec,'pvname',"SIOC:SYS1:ML01:AO"+(450+n),'mode',"rw") ;
        obj.pvlist(end+1) = PV(cntx,'Name',"GOLD_"+isec,'pvname',"LI"+isec+":SBST:1:GOLD",'monitor',true) ;
        obj.pvlist(end+1) = PV(cntx,'Name',"PMDL_"+isec,'pvname',"LI"+isec+":SBST:1:PMDL",'monitor',true) ;
        obj.pvlist(end+1) = PV(cntx,'Name',"MDL_temp_"+isec,'pvname',"LI"+isec+":ASTS:M_D_LINE",'monitor',true) ;
      end
      obj.pvs=struct(obj.pvlist);
    end
    function GetArchiveData(obj,ndays)
      ad = [datevec(datetime(clock)-days(ndays));datevec(now)];
      obj.pvlist.pset('ArchiveDate',ad);
      obj.pvlist.pset('UseArchive',2);
      caget(obj.pvlist);
      ttA=obj.pvlist.ArchiveSync('minutely');
      iptemps=startsWith(ttA.Properties.VariableNames,"MDL_temp"); iptemps(1)=true;
      tt=cell(1,length(obj.secs));
      n=0;
      for isec=obj.secs
        n=n+1;
        [~,ii]=unique(ttA.("GOLD_"+isec),'stable');
        tt{n}=[ttA(ii,iptemps) timetable(ttA.Time(ii),ttA.("GOLD_"+isec)(ii)-ttA.("PMDL_"+isec)(ii))];
        tt{n}.Properties.VariableNames(end) = "GOLDPHA_"+isec ;
      end
      obj.data.raw=ttA;
      obj.data.proc=tt;
      figure
      stackedplot(ttA);
    end
    function Train(obj)
      %TRAIN Train regression model based on Archive Data taken with GetArchiveData method
      
      obj.regmodel={};
      n=0;
      figure;
      for isec=obj.secs
        n=n+1;
        % - Unpack data
        tab=timetable2table(obj.data.proc{n});
        dat=tab{:,2:end};
        data_in=dat(:,2:end-1);
        data_target=dat(:,end);
        % robust linear regression model
        obj.regmodel{n} = obj.trainRegressionModel(data_in, data_target) ;
        subplot(length(obj.secs),1,n);
        plot(tab.Time,data_target,'*',tab.Time,obj.regmodel{n}.predictFcn(data_in)), title("LI "+isec+" SBST GOLD");
        drawnow
      end
      
    end
    function pha = Predict(obj)
      pha=zeros(length(obj.secs),1);
      for n=1:length(obj.secs)
        pha(n) = obj.regmodel{n}.predictFcn(obj.MDL_temps(:)');
        caput(obj.predpv(n),pha(n));
      end
    end
    function ReadData(obj)
      obj.pvlist.pset('UseArchive',0);
      caget(obj.pvlist);
      n=0;
      for isec=obj.secs
        n=n+1;
        obj.MDL_temps(n) = obj.pvs.("MDL_temp_"+isec).val{1} ;
      end
    end
    
  end
  methods(Static)
    function [trainedModel, validationRMSE] = trainRegressionModel(trainingData, responseData)
      % [trainedModel, validationRMSE] = trainRegressionModel(trainingData,
      % responseData)
      % Returns a trained regression model and its RMSE. This code recreates the
      % model trained in Regression Learner app. Use the generated code to
      % automate training the same model with new data, or to learn how to
      % programmatically train models.
      %
      %  Input:
      %      trainingData: A matrix with the same number of columns and data type
      %       as the matrix imported into the app.
      %
      %      responseData: A vector with the same data type as the vector
      %       imported into the app. The length of responseData and the number of
      %       rows of trainingData must be equal.
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
      % data as the input arguments trainingData and responseData.
      %
      % For example, to retrain a regression model trained with the original data
      % set T and response Y, enter:
      %   [trainedModel, validationRMSE] = trainRegressionModel(T, Y)
      %
      % To make predictions with the returned 'trainedModel' on new data T2, use
      %   yfit = trainedModel.predictFcn(T2)
      %
      % T2 must be a matrix containing only the predictor columns used for
      % training. For details, enter:
      %   trainedModel.HowToPredict
      
      % Auto-generated by MATLAB on 31-Mar-2022 14:37:35
      
      
      % Extract predictors and response
      % This code processes the data into the right shape for training the
      % model.
      % Convert input to table
      inputTable = array2table(trainingData, 'VariableNames', {'column_1', 'column_2', 'column_3', 'column_4', 'column_5', 'column_6', 'column_7', 'column_8', 'column_9'});
      
      predictorNames = {'column_1', 'column_2', 'column_3', 'column_4', 'column_5', 'column_6', 'column_7', 'column_8', 'column_9'};
      predictors = inputTable(:, predictorNames);
      response = responseData(:);
      isCategoricalPredictor = [false, false, false, false, false, false, false, false, false];
      
      % Train a regression model
      % This code specifies all the model options and trains the model.
      concatenatedPredictorsAndResponse = predictors;
      concatenatedPredictorsAndResponse.data_target = response;
      linearModel = fitlm(...
        concatenatedPredictorsAndResponse, ...
        'linear', ...
        'RobustOpts', 'on');
      
      % Create the result struct with predict function
      predictorExtractionFcn = @(x) array2table(x, 'VariableNames', predictorNames);
      linearModelPredictFcn = @(x) predict(linearModel, x);
      trainedModel.predictFcn = @(x) linearModelPredictFcn(predictorExtractionFcn(x));
      
      % Add additional fields to the result struct
      trainedModel.LinearModel = linearModel;
      trainedModel.About = 'This struct is a trained model exported from Regression Learner R2020a.';
      trainedModel.HowToPredict = sprintf('To make predictions on a new predictor column matrix, X, use: \n  yfit = c.predictFcn(X) \nreplacing ''c'' with the name of the variable that is this struct, e.g. ''trainedModel''. \n \nX must contain exactly 9 columns because this model was trained using 9 predictors. \nX must contain only predictor columns in exactly the same order and format as your training \ndata. Do not include the response column or any columns you did not import into the app. \n \nFor more information, see <a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appregression_exportmodeltoworkspace'')">How to predict using an exported model</a>.');
      
      % Extract predictors and response
      % This code processes the data into the right shape for training the
      % model.
      % Convert input to table
      inputTable = array2table(trainingData, 'VariableNames', {'column_1', 'column_2', 'column_3', 'column_4', 'column_5', 'column_6', 'column_7', 'column_8', 'column_9'});
      
      predictorNames = {'column_1', 'column_2', 'column_3', 'column_4', 'column_5', 'column_6', 'column_7', 'column_8', 'column_9'};
      predictors = inputTable(:, predictorNames);
      response = responseData(:);
      isCategoricalPredictor = [false, false, false, false, false, false, false, false, false];
      
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
        concatenatedPredictorsAndResponse.data_target = trainingResponse;
        linearModel = fitlm(...
          concatenatedPredictorsAndResponse, ...
          'linear', ...
          'RobustOpts', 'on');
        
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
      validationRMSE = sqrt(nansum(( validationPredictions - response ).^2) / numel(response(isNotMissing) ));
    end
  end
end