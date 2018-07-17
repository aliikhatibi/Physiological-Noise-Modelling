clc
clear
close all

[dcmfname,dcmfpath] = uigetfile('*.*','Plaese select one of the functional dicom images');
[pulsname,pulspath] = uigetfile('*.*','Please select the pulseoximeter output file');
[respname,resppath] = uigetfile('*.*','Please select the respiratory output file');


if dcmfname==0
    warndlg('You have not chosen any dicom file');
else
    dicomheader= dicominfo(fullfile(dcmfpath,dcmfname));
    TR= dicomheader.RepetitionTime;
    IS= dicomheader.SeriesTime;
    ISn= str2num(IS(1:2))*60*60*1000+str2num(IS(3:4))*60*1000+str2num(IS(5:6))*1000+str2num(IS(8:10));
    slt= str2num(cell2mat(inputdlg('How many volumes does your EPI sequence have?')));
    slt= slt*TR;
end
    


if pulsname ~= 0
    fid= fopen(fullfile(pulspath,pulsname));
    pulseraw = textscan(fid,'%s');
    fclose(fid);
    pulsesignal= [pulseraw{:}];
    TimeIndex= strcmp(pulsesignal, 'LogStartMDHTime:'), StartTime= str2num(cell2mat(pulsesignal(find(TimeIndex==1)+1)));
    sindex= strcmp(pulsesignal,'uiSwVersionPdau/ucSWMainRevLevel:');
    signalstart= find(sindex==1)+3;
    pulsesignal(1:signalstart-1)=[];
    eindex= strcmp(pulsesignal,'ECG');
    signalend= find(eindex==1);signalend(2)=[];
    pulsesignal(signalend-1:end)=[];
    k1= strcmp(pulsesignal,'5000');
    pulsesignal(find(k1==1))= [];
    k2= strcmp(pulsesignal,'6000');
    pulsesignal(find(k2==1))= [];
    r=0;
    StartTimet= StartTime;
    while StartTimet<ISn
        StartTimet=StartTimet+20;
        r=r+1;
    end
    pulsesignal(1:r)=[];
    endpoint= round(slt/20);
    pulsesignal(endpoint:end)=[];
    pulsesignalm= zeros(length(pulsesignal),1);
    for l=1:length(pulsesignal)
        pulsesignalm(l)= str2num(pulsesignal{l,1});
    end
    pulsecovariate = pulsesignalm(1:TR/20:end);
    figure, plot(pulsecovariate);
    figure, plot(pulsesignalm);
end

if respname ~= 0
    fid= fopen(fullfile(resppath,respname));
    respraw = textscan(fid,'%s');
    fclose(fid);
    respsignal= [respraw{:}];
    TimeIndex= strcmp(respsignal, 'LogStartMDHTime:'), StartTime= str2num(cell2mat(respsignal(find(TimeIndex==1)+1)));
    sindex= strcmp(respsignal,'uiSwVersionPdau/ucSWMainRevLevel:');
    signalstart= find(sindex==1)+3;
    respsignal(1:signalstart-1)=[];
    eindex= strcmp(respsignal,'ECG');
    signalend= find(eindex==1);signalend(2)=[];
    respsignal(signalend-1:end)=[];
    k3= strcmp(respsignal,'5000');
    respsignal(find(k3==1))= [];
    k4= strcmp(respsignal,'6000');
    respsignal(find(k4==1))= [];
    r=0;
    StartTimet= StartTime;
    while StartTimet<ISn
        StartTimet=StartTimet+20;
        r=r+1;
    end
    respsignal(1:r)=[];
    endpoint= round(slt/20);
    respsignal(endpoint:end)=[];
    for l=1:length(respsignal)
        respsignalm(l)= str2num(respsignal{l,1});
    end
    respcovariate = respsignalm(1:TR/20:end);
    figure,plot(respcovariate);
    figure, plot(respsignalm);
end
save('signals.mat','pulsesignalm','respsignalm','pulsecovariate','respcovariate');
