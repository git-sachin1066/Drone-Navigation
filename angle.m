function [ theta1] = angle(xh,yh,xl,yl )


X=(yl-yh)./(xl-xh);

theta1=atand(X)  ;
if(theta1<0)
    theta1=180+theta1;
end
theta1;

end

