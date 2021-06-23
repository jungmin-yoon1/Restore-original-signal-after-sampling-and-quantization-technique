clc; clear all; close all;
%% Quantization
% 원신호와 sinc 함수의 discrete time 설정

T0=0.001;
f0=1/T0;
t=[0:T0:1];
A=2;
x=A*sin(8*pi*t);

%샘플링 신호
fs=9;
Ts=1/fs;
t_s=[0:Ts:1];
N_s=length(t_s);
x_s=2*sin(8*pi*t_s);

%양자화
Q_level=64;
Q_step=(A+A)/Q_level;

%Quantization level에 해당하는 amplitude 값을 갖는 Q 생성
for i1=1:Q_level
    Q(i1)=Q_step*(i1-1)-A;
end

%샘플링 신호를 양자화 x_q로 변환
for i1=1:N_s
    for i2=1:Q_level
        if((x_s(i1)>=Q(i2))&(x_s(i1)<=Q(i2)+Q_step))
            x_q(i1)=i2-1;
        end
    end
end

%부호화
temp=dec2bin(x_q);
x_en=reshape(temp', 1, numel(temp)); 

%복호화
N_bit=log2(Q_level);
temp=(reshape(x_en,N_bit,N_s))';
for i1=1:N_s
    x_de(i1)=Q_step*bin2dec(temp(i1,:))+Q_step/2-A;
end

%% 평균 양자화 잡음 전력

for i1=1:N_s
    q(i1)=((x_s(i1)-x_de(i1))^2);
end

Nq=mean(q);
Nq_th=(Q_step^2)/12;

%복원
y_t=zeros(length(t_s),length(t));
for i1=1:length(t_s)
    y_t(i1,:)=x_de(i1)*sinc((t-(i1-1)*Ts)/Ts);
end

y=sum(y_t);

figure;
subplot(3,1,1); plot(t,x); hold on; stem(t_s,x_s); grid on;
xlabel('Time [s]'); ylabel('Amplitude')
legend('Original','Sampling')

subplot(3,1,2); stem(t_s,x_s); hold on; stem(t_s,x_q*Q_step-A,'x'); grid on;
xlabel('Time [s]'); ylabel('Amplitude')
legend('Sampling', 'Quantization')

subplot(3,1,3); plot(t,x); hold on; plot(t,y); grid on;
xlabel('Time [s]'); ylabel('Amplitude')
legend('Original','Reconstruction')






















