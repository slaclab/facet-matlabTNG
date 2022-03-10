function [yfit,sigma]=fit_gaussian(yvals)

  % if ~exist('xvals')
  % xvals = [1:length(yvals)];
% end
% dx = abs(xvals(2)-xvals(1));

% maxi = max(yvals);
% yvals = yvals/maxi;

[amp_guess,mu_guess] = max(yvals);
sigma_guess = std(yvals);

[xbest,fval]= fminsearch(@(params) obj(yvals,params),[mu_guess,sigma_guess,amp_guess]);

yfit = xbest(3).*exp(-([1:length(yvals)]-xbest(1)).^2/2/xbest(2)^2);

%yfit = yfit* maxi;
% figure
% plot(yvals)
% hold on
% plot(yfit,'r--')
% enhance_plot
%legend('Data',strcat('Fit: sigma =',num2str(sigma*dx,'%2.1f')));

function f = obj(y,params)
  mu = params(1);
sigma = abs(params(2));
amp = params(3);
yguess = amp*exp(-([1:length(y)]-mu).^2/2/sigma^2);
f = sum((y-yguess).^2);
end

end
