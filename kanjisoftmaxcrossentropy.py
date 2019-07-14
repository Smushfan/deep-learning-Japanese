# -*- coding: utf-8 -*-
import numpy as np
import os
import socket
import random

def sigmoid(matrix,deriv):
    if deriv:
        return matrix*(1-matrix)
    return 1/(1+np.exp(-matrix))

def derrivSoftmax(activation_vector):
    matrix = []
    indexA = 0
    for i in activation_vector:
        matrixForOneTrainingExample = []
        for a in i:
            vectorForOneActivation = []
            indexB = 0
            for b in i:
                if not indexA==indexB:
                    vectorForOneActivation.append(a*(-b))
                else:
                    vectorForOneActivation.append(a*(1-b))
                indexB+=1
            matrixForOneTrainingExample.append(vectorForOneActivation)
            indexA+=1
        matrix.append(matrixForOneTrainingExample)
        return np.array(matrix)
    
def softmax(X, theta = 1.0, axis = 1):
    """
    Compute the softmax of each element along an axis of X.

    Parameters
    ----------
    X: ND-Array. Probably should be floats.
    theta (optional): float parameter, used as a multiplier
        prior to exponentiation. Default = 1.0
    axis (optional): axis to compute values along. Default is the
        first non-singleton axis.

    Returns an array the same size as X. The result will sum to 1
    along the specified axis.
    """

    # make X at least 2d
    y = np.atleast_2d(X)

    # find axis
    if axis is None:
        axis = next(j[0] for j in enumerate(y.shape) if j[1] > 1)

    # multiply y against the theta parameter,
    y = y * float(theta)

    # subtract the max for numerical stability
    y = y - np.expand_dims(np.max(y, axis = axis), axis)

    # exponentiate y
    y = np.exp(y)

    # take the sum along the specified axis
    ax_sum = np.expand_dims(np.sum(y, axis = axis), axis)

    # finally: divide elementwise
    p = y / ax_sum

    # flatten if X was 1D
    if len(X.shape) == 1: p = p.flatten()

    return p

imgSX=32
imgSY=32
layernumber=3
neurons=30
M=[]
datacount=-1
syn=[]
bias=[]
numberOfEachKanjisTrainingData=[]
input = []
output = []
miniBatchSize=1
iterations=4000
learningRate=0.2

testDataInfo = 1
testData=[]

#trainiert das neuronale Netz nach dem Algorithmus, der in der Arbeit beschrieben ist
def training(layers,neurons,inP,outP):
    print("training:")
    print("")
    layer=[]
    global bias
    global syn
    syn=[]
    bias=[]
    error=[]
    delta=[]
    
    random.seed(2314)
    np.random.seed(2314)

    #teilt die Trainingsdaten in zufällige Gruppen auf
    iterator=zip(inP,output)
    training_data=list(iterator)
    random.shuffle(training_data)
    miniBatchesIn=[]
    miniBatchesOut=[]
    
    for a in range(int(datacount/miniBatchSize)):
        inP=[]
        outP=[]
        for i in range(a*miniBatchSize,miniBatchSize+a*miniBatchSize):
            inP.append(training_data[i][0])
            outP.append(training_data[i][1])
        inP = np.array(inP)
        miniBatchesIn.append(inP)
        miniBatchesOut.append(outP)
    
    #initialising synapses and biases
    syn.append(np.random.randn(imgSX*imgSY,neurons)*0.01)     
    for i in range(layers-3):
        #initialises np.array with values between -1 and 1
        syn.append(np.random.randn(neurons,neurons)*0.01)
    for i in range(layers-2):
        #initialises np.array with values between -1 and 1
        bias.append(np.zeros(neurons))
         
    syn.append(np.random.randn(neurons,len(numberOfEachKanjisTrainingData))*0.01)
    bias.append(np.zeros(len(numberOfEachKanjisTrainingData)))
    for i in range(layers-1):
        layer.append(0)
        error.append(0)
        delta.append(0)
    layer.append(0)

    #tatsächlicher Trainingsalgorithmus
    loss= 0
    
    print("Prediction accurracy")
    for it in range(iterations):
        layer[0]=miniBatchesIn[it%(int(datacount/miniBatchSize))]
        
        #Berechnung des Outputs
        for a in range(layers-2):
            layer[a+1]=sigmoid(np.dot(layer[a],syn[a])+bias[a],False)
        layer[layers-1]=softmax(np.dot(layer[layers-2],syn[layers-2])+bias[layers-2])
        

        #Berechnung der Ableitung der Fehlerfunktion nach den Gewichten    
        lossVectors = miniBatchesOut[it%(int(datacount/miniBatchSize))]*(layer[layers-1])
        for lossVector in lossVectors:
            for value in lossVector:
                if not value == 0:
                    loss+=-np.log(value)
                    
        error[layers-2]=miniBatchesOut[it%(int(datacount/miniBatchSize))]*(learningRate/layer[layers-1])
        delta[layers-2]=(error[layers-2].dot(derrivSoftmax(layer[layers-1]))).reshape((miniBatchSize,len(numberOfEachKanjisTrainingData)))
        for i in range(layers-2):
            error[layers-(i+3)]=delta[layers-(i+2)].dot(syn[layers-(i+2)].T)
            delta[layers-(i+3)]=error[layers-(i+3)]*sigmoid(layer[layers-(i+2)],True)

            
        #ändern der Gewichte
        for i in range(layers-1):
            syn[i]+=np.dot(layer[i].T,delta[i])
            for a in range(miniBatchSize):
                bias[i]+=delta[i][a]

        #Konsolenausgaben        
        if((it+1)%(iterations/10)==0):
            print("after "+str(it+1)+" iterations: ")
            print("test:")
            test(testData)

        if(it+1)%(datacount/miniBatchSize*2)==0:
            print("after "+str(it+1)+" iterations ("+str(int((it+1)/datacount*miniBatchSize))+" Epochs): ")
            print("avg loss:")
            print(loss/(datacount*2))
            print()
            loss=0
            
                
    #speichern der berechneten Gewichte (bisher nutze ich die gespeicherten Gewichte noch nicht)         
    #save=open('weights.txt','w')
    #for a in range(1024):
    #    for b in range(30):
    #        save.write(str(syn[0][a][b])+"\n")
    #for a in range(30):
    #    for b in range(30):
    #        save.write(str(syn[1][a][b])+"\n")
    #for a in range(30):
    #    for b in range(2):
    #        save.write(str(syn[2][a][b])+"\n")
    #save.close()
    print("Training completed")
    

#Laden der Trainingsdaten aus den Textdateinen
def loadData():
    global datacount
    datacount=-1
    global numberOfEachKanjisTrainingData
    numberOfEachKanjisTrainingData=[]
    global input
    global output
    global M
    M=[]
    kanjiCount=-1
    abspath=os.path.abspath(__file__)
    fileDir = os.path.dirname(abspath)
    os.chdir(fileDir)
    kanjiList = open("kanjiList.txt","r")
    for kanji in kanjiList:
        kanjiCount+=1
        numberOfEachKanjisTrainingData.append(0)
        kanjiData = open(kanji.strip('\n')+".txt","r")
        for line in kanjiData:
            numberOfEachKanjisTrainingData[kanjiCount]+=1
            M.append([])
            datacount+=1
            for a in range(0,imgSX*imgSY):
                M[datacount].append(int(line[a]))
                
    input=np.array(M)
    out=[]
    count=0
    numberOfDifferentKanji=len(numberOfEachKanjisTrainingData)
    for i in range(datacount+1):
        out.append([])
        for a in range(numberOfDifferentKanji):
            out[i].append(0)
    for i in range(numberOfDifferentKanji):
        for a in range(numberOfEachKanjisTrainingData[i]):
            out[count][i]=1
            count+=1
    output=np.array(out)
    print("successfully loaded data")

def loadDataNew():
    global testData
    global datacount
    datacount=-1
    global numberOfEachKanjisTrainingData
    numberOfEachKanjisTrainingData=[]
    global input
    global output
    global M
    M=[]
    testData=[]
    kanjiCount=-1
    abspath=os.path.abspath(__file__)
    fileDir = os.path.dirname(abspath)
    os.chdir(fileDir)
    kanjiList = open("kanjiList.txt","r")
    for kanji in kanjiList:
        kanjiCount+=1
        numberOfEachKanjisTrainingData.append(0)
        kanjiData = open(kanji.strip('\n')+".txt","r")
        for line in kanjiData:
            numberOfEachKanjisTrainingData[kanjiCount]+=1
            M.append([])
            datacount+=1
            for a in range(0,imgSX*imgSY):
                M[datacount].append(int(line[a]))
    
        #loading test Data
        kanjiData=open(kanji.strip('\n')+"Test.txt","r")
        testdataCount=-1
        testData.append([])
        for line in kanjiData:
            testdataCount+=1
            testData[kanjiCount].append([])
            for a in range(0,imgSX*imgSY):
                testData[kanjiCount][testdataCount].append(int(line[a]))
                
    input=np.array(M)
    out=[]
    count=0
    numberOfDifferentKanji=len(numberOfEachKanjisTrainingData)
    for i in range(datacount+1):
        out.append([])
        for a in range(numberOfDifferentKanji):
            out[i].append(0)
    for i in range(numberOfDifferentKanji):
        for a in range(numberOfEachKanjisTrainingData[i]):
            out[count][i]=1
            count+=1
    output=np.array(out)
    print("successfully loaded data")

    
#alte, ungenutzte Funktion für das Training
def previous():
    #initialise Synapses
    syn0=2*np.random.random((imgSX*imgSY,10))-1
    syn1=2*np.random.random((10,10))-1
    syn2=2*np.random.random((10,2))-1
    
    for i in range(10000):
        
        #calculate the Output
        l0=input
        l1=sigmoid(np.dot(l0,syn0),False)
        l2=sigmoid(np.dot(l1,syn1),False)
        l3=sigmoid(np.dot(l2,syn2),False)
        
        l3_error = output-l3
        l3_delta = l3_error*sigmoid(l3,True)
        l2_error = l3_delta.dot(syn2.T)
        l2_delta = l2_error*sigmoid(l2,True)
        l1_error = l2_delta.dot(syn1.T)
        l1_delta = l1_error*sigmoid(l1,True)
        
        syn2+=np.dot(l2.T,l3_delta)
        syn1+=np.dot(l1.T,l2_delta)
        syn0+=np.dot(l0.T,l1_delta)
        
    print(l3)
    
# Funktion zur Berechnung des Outputs
def propagate(d):
    layer=[]
    for a in range(layernumber):
        layer.append([])
    layer[0]=d
    for i in range(layernumber-2):
        layer[i+1]=sigmoid(np.dot(layer[i],syn[i])+bias[i],False)
    return softmax(np.dot(layer[layernumber-2],syn[layernumber-2])+bias[layernumber-2], theta = 1.0)

def test(d):
    if not testDataInfo == 0:
        currentKanji = -1
        totalPredictions = 0
        totalCorrectPredictions = 0
        for a in d:
            correctPredictions = 0
            predictionNumber = 0
            currentKanji+=1
            for b in a:
                predictions=propagate(b)
                predictionNumber+=1
                br=False
                for p in predictions:
                    if(predictions[currentKanji]<p):
                        br=True
                        break;
                if not br:    
                    correctPredictions+=1
            if testDataInfo==2:        
                print(str(currentKanji)+": "+str(correctPredictions/predictionNumber))
            totalPredictions+=predictionNumber
            totalCorrectPredictions+=correctPredictions
          
        print(totalCorrectPredictions/totalPredictions)
        print("")
    
    
    

#communication with client

#1.protocolFunctions
def sendPredictions(msg):
    d=[]
    data=msg[2:]
    for i in range(len(data)):
        d.append(int(data[i]))    
    prediction=propagate(d)
    print(prediction)
    predictionString=""
    for value in prediction:
        predictionString+=str(value)+";"
    conn.send(bytes(predictionString.strip(";")+"\r\n",'UTF-8'))
    print("sent prediction to the client")

def newTrainingData(msg):
    #splits the data where data[0] will be the kanjis Name and data[1] the training data
    data = msg[2:].split("#")
    writer = open(data[0]+".txt","a")
    trainingData=data[1].split(";")
    for i in range(len(trainingData)):
        writer.write(trainingData[i]+"\n")
    writer.close()
    print("new training data received and added")
    conn.send(bytes("nx"+"\r\n",'UTF-8'))
    
        
    
def newKanji(msg):
    #update the list of Kanji + add first training example
    
    #splitting into kanjiList and training example
    data = msg[2:].split("#")

    kanjiList = open("kanjiList.txt","r")
    for kanji in kanjiList:
        if data[0]==kanji.strip('/n'):
            print("This Kanji already exists")
            return
        
    #add to kanjiList
    writer = open("kanjiList.txt","a")
    writer.write(data[0]+"\n")
    writer.close()
    
    #fill in first training example for new Kanji
    writer = open(data[0]+".txt","w",)
    writer.write(data[1]+"\n")

    writer = open(data[0]+"Test.txt","w")
    writer = open(data[0]+"T.txt","w")

    print("successfully added new Kanji")
    
    #update the network
    updateNeuralNetwork("")
    
def updateNeuralNetwork(msg):
    loadDataNew()
    training(layernumber,neurons,input,output)

def noValidProtocol(msg):
    print("not a valid protocoll\n")
    print("message: "+msg)
    
#protocoll to function dictionary        
switcher= {
        "pr":sendPredictions,
        "nk":newKanji,
        "up":updateNeuralNetwork,
        "td":newTrainingData
    }

#Start des Programms
    
#Daten laden
loadDataNew()

#neuronales Netz Trainieren
training(layernumber,neurons,input,output)


# Verbindung einrichten und Protokollschleife starten
soc = socket.socket()           # Socket Objekt erstellen
host = "localhost"              # Name der lokalen Maschine
port = 2052                     # Port reservieren
soc.bind((host, port))          
soc.listen(5)                   # Warten, bis eine Anfrage vom Client kommt
while True:
    conn, addr = soc.accept()   # Verbindung zum Client herrstellen
    print ("Got connection from",addr)
    msg = conn.recv(2052)
    msg = msg.decode("utf-8")
    msg = msg[2:]
    
    #Funktion je nach Protokoll ausführen
    func = switcher.get(msg[:2], noValidProtocol)
    func(msg)
