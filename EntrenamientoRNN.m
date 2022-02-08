function RNNModel = EntrenamientoRNN(Entrada,Salida)
x = Entrada';
t = Salida';
trainFcn = 'trainlm';  
hiddenLayerSize = 10;
net = fitnet(hiddenLayerSize,trainFcn);
net.divideParam.trainRatio = 60/100;
net.divideParam.valRatio = 20/100;
net.divideParam.testRatio = 20/100;
[net,tr] = train(net,x,t);
RNNModel = net;
