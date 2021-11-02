function motorValues = getMotorValues(UserData)
%GETMOTORVALUES Summary of this function goes here
%   Detailed explanation goes here
for ij = 1:length(UserData.motorpvs)-3% Do B4,B5,B6 by hand
    for n=1:4
        motor_str = strcat(UserData.motorpvs{ij},':CH',num2str(n),':MOTOR');
        motorValues(n+4*(ij-1)) = lcaGetSmart(motor_str);
    end
end
motorValues(21) = lcaGetSmart([UserData.motorpvs{6},':CH',num2str(3),':MOTOR']);%B4
motorValues(22) = lcaGetSmart([UserData.motorpvs{6},':CH',num2str(4),':MOTOR']);%B4
motorValues(23) = lcaGetSmart([UserData.motorpvs{7},':CH',num2str(1),':MOTOR']);%B5
motorValues(24) = lcaGetSmart([UserData.motorpvs{7},':CH',num2str(2),':MOTOR']);%B5
motorValues(25) = lcaGetSmart([UserData.motorpvs{8},':CH',num2str(1),':MOTOR']);%B6
motorValues(26) = lcaGetSmart([UserData.motorpvs{8},':CH',num2str(2),':MOTOR']);%B6

end

