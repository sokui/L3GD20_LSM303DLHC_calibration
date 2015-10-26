classdef Calibrator
    %CALIBRATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        %%
        % Each line is one sample including 3-axis raw data from three sensors. The order is:
        % gyro-x, gyro-y, gyro-z, acc-x, acc-y, acc-z, mag-x, mag-y, mag-z, timestamp, seqNo

        function s=loadData(filePath)
            s=[];
            if exist(filePath, 'file') ~= 2
                disp(['The input file ', filePath, ' does not exist.']);
                return;
            end
            s = load(filePath, '-ascii');
        end
        
        function [gyroBias, accBias]=getBiases(s)
            gyroBias=[];
            accBias=[];
            if (isempty(s) || size(s, 2)<6)
                disp('The input matrix is in a bad format.');
                return;
            end
            gyroBias=mean(s(:,1:3),1);
            accBias=mean(s(:,4:6),1);
        end
        
        function [bias, scaleFactor]=getBiasAndScaleFactor(s)
            bias=[];
            scaleFactor=[];
            if (size(s,2)~=2)
                disp('Invalid format of the input matrix.');
                return;
            end
            stillEnd=3.5;
            firstRotationStart=4;
            firstRotationEnd=11;
            rotationBackStart=13.5;
            rotationBackEnd=21;
            
            %normalize the time
            s(:,2)=(s(:,2)-s(1,2))/1000000;
            
            %subsctract bias
            stillEndIndex=find(s(:,2)>stillEnd,1);
            bias=mean(s(1:stillEndIndex,1));
            s(:,1)=s(:,1)-bias;
            
            integration1=0;
            integration2=0;
            for i=(stillEndIndex+1):size(s,1)
                if (s(i,2)>firstRotationStart && s(i,2)<firstRotationEnd)
                    integration1=integration1+s(i,1)*(s(i,2)-s(i-1,2));
                elseif (s(i,2)>rotationBackStart && s(i,2)<rotationBackEnd)
                    integration2=integration2+s(i,1)*(s(i,2)-s(i-1,2));
                elseif (s(i,2)>=rotationBackEnd)
                    break;
                end
            end
            
            scale1=-90/integration1;
            scale2=90/integration2;
            scaleFactor=(scale1+scale2)/2;
        end
    end
    
end

