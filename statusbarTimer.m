function varargout = statusbarTimer(varargin)
% STATUSBARTIMER Count-up timer for MATLAB status bar
%
%   t = STATUSBARTIMER([h],[prefix],[noprint]) sets the MATLAB status bar
%   to the prefix ("Busy..." if omitted or left blank) followed by a
%   running clock of the elapsed time. STATUSBARTIMER uses a timer object
%   named statusbarTimer to keep track of the elapsed time and update the
%   status bar text. The function returns a handle to that timer object,
%   which will delete itself and reset the status bar when stop(t) is
%   called. Unless noprint is set to true, the final time will be displayed
%   in the command window in the style of toc.
% 
%   STATUSBARTIMER(t,prefix) updates the message string of an existing
%   timer.
% 
% Examples:
% 
%   t = statusbarTimer();
%   pause(5)
%   stop(t)
% 
%   statusbarTimer(figure(),'Hello, World!')
% 
%   t = statusbarTimer('Entering loop');
%   for ii = 1:10
%       pause(1)
%       statusbarTimer(t,sprintf('Finished iteration %d!',ii))
%   end
%   stop(t)
%
% Hosted on MATLAB File Exchange:
%   <a href="matlab:system('open https://www.mathworks.com/matlabcentral/fileexchange/52833-statusbartimer');">https://www.mathworks.com/matlabcentral/fileexchange/52833-statusbartimer</a>
% 
% Requires:
%   <a href="matlab:system('open https://www.mathworks.com/matlabcentral/fileexchange/52831-parsetime');">parseTime</a>
%   <a href="matlab:system('open https://www.mathworks.com/matlabcentral/fileexchange/52832-num2sepstr');">num2sepstr</a>
% 
% Created by:
%   Robert Perrotta

narginchk(0,3)
nargoutchk(0,1)

h = 0;
prefix = 'Busy...';
noprint = false;

n = nargin();

if n==2 && isa(varargin{1},'timer') % Update UserData to be used by TimerFcn
    t = varargin{1};
    prefix = varargin{2};
    data = get(t,'UserData');
    data{1} = prefix;
    set(t,'UserData',data)
    return
end

if n >= 1
    if isscalar(varargin{1}) && (varargin{1}==0 || ishghandle(varargin{1}))
        h = varargin{1};
        varargin = varargin(2:end);
        n = n - 1;
    end
end

if n == 2
    prefix = varargin{2};
    noprint = logical(varargin{3});
elseif n == 1
    if ischar(varargin{1})
        prefix = varargin{1};
    else
        noprint = logical(varargin);
    end
end

existingTimer = timerfind('Name','statusbarTimer');
for ii = 1:length(existingTimer)
    h2 = get(existingTimer(ii),'TimerFcn');
    h2 = h2{end};
    if h2 == h % existing timer applies to same target
        stop(existingTimer(ii))
    end
end

t = timer('Name','statusbarTimer','ExecutionMode','fixedRate','Period',0.07,...
    'TimerFcn',{@timerFcn,h},'UserData',{prefix,clock},'StopFcn',{@cleanup,h,noprint});
start(t)

if nargout == 1
    varargout = {t};
end

end

function timerFcn(t,~,h)

if h~=0 && ~ishghandle(h) % Figure was closed
    stop(t)
    return
end
    
data = get(t,'UserData');
str = parseTime(etime(clock,data{2}));
statusbar(h,sprintf('%s (%s elapsed.)',data{1},str))

end

function cleanup(t,~,h,noprint)

data = get(t,'UserData');
str = parseTime(etime(clock,data{2}));
if ~noprint
    fprintf('Elapsed time is %s.\n',str)
end
stop(t)
delete(t)
if h==0 || ishghandle(h)
    statusbar(h) % Clear status
end

end
