function util_printLog_wComments(fig,author,title,text,dim,invert,accel)
%PRINTLOG
%  PRINTLOG(FIG) prints figure FIG to lcls logbook.

% Features:

% Input arguments:
%    FIG: Handle of figure to print
% AUTHOR: Text to be entered in Author field of logbook
%  TITLE: Text to be entered in Title field of logbook
%   TEXT: Text to be entered in Text field of logbook
%    DIM: dimensions of figure for elog ([480 400] for usual size)
% INVERT: Flag to invert hardcopy, default 1

% Output arguments:

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC
%         J. Rzepiela (added support for comments to be added to log
%         8/4/10)

% --------------------------------------------------------------------

% Parse input arguments.
if nargin< 7, [~,accel]=getSystem; end
if nargin< 6, invert=1; end
if nargin< 5, dim=[480 400]; end
if nargin< 4, text='Matlab'; end
if nargin< 3, title='Matlab'; end
if nargin< 2, author='Matlab'; end

% Check if FIG is handle.
fig(~ishandle(fig))=[];

%Render tag strings to comply with XML.
text=make_XML(text);
title=make_XML(title);
author=make_XML(author);

% Determine accelerator.
pathName=['/u1/' lower(reshape(char(accel)',1,[])) '/physics/logbook/data'];
if strcmp(pathName,'/u1/lcls2/physics/logbook/data')
    pathName = '/u1/lcls/physics/logbook/lcls2/data';
end
if ~exist(pathName,'dir'), return, end

fileIndex=0;
ext='.jpg';
for f=fig(:)'
    set(f,'PaperPositionMode','auto')
    tstamp=datestr(now,31);
    [dstr, tstr] = strtok(tstamp);
    fileName=[strrep(tstamp, ' ', 'T') sprintf('-0%d',fileIndex)];
    if invert, set(f,'InvertHardcopy','off');end
    if invert && 0
        print(f,'-djpeg100',(fullfile(pathName,[fileName ext])));
        A = imread(fullfile(pathName,[fileName ext]));
        newimg=util_figResize(A,dim(1),dim(2));
        imwrite(newimg,fullfile(pathName,[fileName ext]),'Quality',100);
    else
        ext='.png';
%        print(f,'-djpeg100','-r75',(fullfile(pathName,[fileName ext])));
        print(f,'-dpng','-r75',(fullfile(pathName,[fileName ext])));
    end
%     print(f,'-dpsc2' ,'-loose',(fullfile(pathName,[fileName '.ps'])));
    print(f,'-dpng', (fullfile(pathName,[fileName '.png'])));
%     print(f,'-dpdf' ,(fullfile(pathName,[fileName '.pdf'])));
    fid=fopen(fullfile(pathName,[fileName '.xml']),'w');
    if fid~=-1
        fprintf(fid,'<severity>NONE</severity>\n');
        fprintf(fid,'<location>not set</location>\n');
        fprintf(fid,'<keywords>none</keywords>\n');
        fprintf(fid,'<time>%s</time>\n',tstr(2:end));
        fprintf(fid,'<isodate>%s</isodate>\n',dstr);
        fprintf(fid,'<author>%s</author>\n',author);
        fprintf(fid,'<category>USERLOG</category>\n');
        fprintf(fid,'<title>%s</title>\n',title);
        fprintf(fid,'<metainfo>%s</metainfo>\n',[fileName '.xml']);
        fprintf(fid,'<file>%s</file>\n',[fileName ext]);
        fprintf(fid,'<link>%s</link>\n',[fileName '.png']);
        fprintf(fid,'<text>%s</text>\n',text);
        fclose (fid);
    end
    fileIndex=fileIndex+1;
    %opts.fontName='Times';opts.fontSize=12;opts.lineWidth=1.5;
    %util_appFonts(f,opts);
%     print(f,'-dpsc2','-Pphysics-lclslog');
    %hAxes=findobj(f,'type','axes');
    %opts.title=get(get(hAxes(1),'Title'),'String');
    %opts.title='Matlab Figure';
    %util_eLogEntry(f,now,'lcls',opts);
end


function str = make_XML(str)

str=strrep(str,'&','&amp;');
str=strrep(str,'"','&quot;');
str=strrep(str,'''','&apos;');
str=strrep(str,'<','&lt;');
str=strrep(str,'>','&gt;');
