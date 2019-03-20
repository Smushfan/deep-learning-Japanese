# -*- coding: utf-8 -*-
#from skimage import io, transform
import numpy as np
import os
import socket
import random

def sigmoid(matrix,deriv):
    if deriv:
        return matrix*(1-matrix)
    return 1/(1+np.exp(-matrix))

imgSX=32
imgSY=32
layernumber=4
neurons=30
M=[]
datacount=-1
syn=[]
bias=[]
numberOfEachKanjisTrainingData=[]
input = []
output = []
miniBatchSize=10


def training(layers,neurons,inP,outP):
    layer=[]
    global bias
    global syn
    syn=[]
    bias=[]
    error=[]
    delta=[]
    random.seed(2314)
    np.random.seed(2314)
    
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
    syn.append(2*np.random.random((imgSX*imgSY,neurons))-1)     
    for i in range(layers-3):
        #initialises np.array with values between -1 and 1
        syn.append(2*np.random.random((neurons,neurons))-1)
    for i in range(layers-2):
        #initialises np.array with values between -1 and 1
        bias.append(2*np.random.random(neurons)-1)
         
    syn.append(2*np.random.random((neurons,len(numberOfEachKanjisTrainingData)))-1)
    bias.append(2*np.random.random(len(numberOfEachKanjisTrainingData))-1)
    for i in range(layers-1):
        layer.append(0)
        error.append(0)
        delta.append(0)
    layer.append(0)
    for i in range(1000):
        layer[0]=miniBatchesIn[i%(int(datacount/miniBatchSize))]
        
        for a in range(layers-1):
            layer[a+1]=sigmoid(np.dot(layer[a],syn[a])+bias[a],False)
        error[layers-2]=miniBatchesOut[i%(int(datacount/miniBatchSize))]-layer[layers-1]
        #console log
        for a in range(miniBatchSize):
            print(a,".",layer[layers-1][a],"  ",miniBatchesOut[i%(int(datacount/miniBatchSize))][a])
        
        delta[layers-2]=error[layers-2]*sigmoid(layer[layers-1],True)
        for i in range(layers-2):
            error[layers-(i+3)]=delta[layers-(i+2)].dot(syn[layers-(i+2)].T)
            delta[layers-(i+3)]=error[layers-(i+3)]*sigmoid(layer[layers-(i+2)],True)
        #update weights and biases
        for i in range(layers-1):
            syn[i]+=np.dot(layer[i].T,delta[i])
            for a in range(miniBatchSize):
                bias[i]+=delta[i][a]
    print(bias)
    save=open('weights.txt','w')
    for a in range(1024):
        for b in range(30):
            save.write(str(syn[0][a][b])+"\n")
    for a in range(30):
        for b in range(30):
            save.write(str(syn[1][a][b])+"\n")
    for a in range(30):
        for b in range(2):
            save.write(str(syn[2][a][b])+"\n")
    save.close()
    




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
    os.chdir('C:\Python34')
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
    #output=np.array([[1,0],[1,0],[1,0],[1,0],[1,0],[1,0],[0,1],[0,1],[0,1],[0,1],[0,1],[0,1],[0,1],[0,1],[0,1],[0,1],[0,1],[0,1],[0,1],[0,1],[0,1],[0,1],[0,1],[0,1]])
    print(out)
    output=np.array(out)


def previous():
    syn0=2*np.random.random((imgSX*imgSY,10))-1
    syn1=2*np.random.random((10,10))-1
    syn2=2*np.random.random((10,2))-1
    
    for i in range(10000):
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

def propagate(d):
    layer=[]
    for a in range(layernumber):
        layer.append([])
    layer[0]=d
    for i in range(layernumber-1):
        layer[i+1]=sigmoid(np.dot(layer[i],syn[i])+bias[i],False)
    return layer[layernumber-1]
    
    #averagePropagation=[]
    #for a in range(len(l3[0])):
     #   averagePropagation.append(0)
      #  for b in range(len(l3)):
       #     averagePropagation[a]+=l3[b][a]
        #averagePropagation[a]=averagePropagation[a]/len(l3)
    #return averagePropagation
    
#loading data, calculating values
loadData()
#training the neural network
training(layernumber,neurons,input,output)


#communication with client

#1.protocolFunctions
def sendPredictions(msg):
    d=[]
    data=msg[2:]
    for i in range(len(data)):
        d.append(int(data[i]))
    print(d)
    prediction=propagate(d)
    print(prediction)
    predictionString=""
    for value in prediction:
        predictionString+=str(value)+";"
    conn.send(bytes(predictionString.strip(";")+"\r\n",'UTF-8'))

def newTrainingData(msg):
    #splits the data where data[0] will be the kanjis Name and data[1] the training data
    data = msg[2:].split("#")
    writer = open(data[0]+".txt","a")
    trainingData=data[1].split(";")
    for i in range(len(trainingData)):
        writer.write(trainingData[i]+"\n")
    writer.close()
    conn.send(bytes("nx"+"\r\n",'UTF-8'))
    
        
    
def newKanji(msg):
    #update the list of Kanji + add first training example
    
    #splitting into kanjiList and training example
    data = msg[2:].split("#")
    
    #write new kanjiList
    writer = open("kanjiList.txt","a")
    writer.write(data[0]+"\n")
    writer.close()
    
    #fill in first training example for new Kanji
    writer = open(data[0]+".txt","w",)
    writer.write(data[1]+"\n")
    
    #update the network
    updateNeuralNetwork("")
    
def updateNeuralNetwork(msg):
    loadData()
    training(4,30,input,output)

def noValidProtocoll(msg):
    print("not a valid protocoll\n")
    print("message: "+msg)
    
#protocoll to function dictionary        
switcher= {
        "pr":sendPredictions,
        "nk":newKanji,
        "up":updateNeuralNetwork,
        "td":newTrainingData
    }
    

#2. establish connection and start protokoll loop
soc = socket.socket()         # Create a socket object
host = "localhost" # Get local machine name
port = 2052                # Reserve a port for your service.
soc.bind((host, port))       # Bind to the port
soc.listen(5)# Now wait for client connection.
while True:
    conn, addr = soc.accept()     # Establish connection with client.
    print ("Got connection from",addr)
    msg = conn.recv(2052)
    msg = msg.decode("utf-8")
    print(msg)
    msg = msg[2:]
    #print (msg)
    
    #execute function according to protocol
    func = switcher.get(msg[:2], noValidProtocoll)
    func(msg)