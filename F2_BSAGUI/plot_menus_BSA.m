
% PLOT_MENUS
%
%			Function to establish GUI interface to the user, present
%			options for plotting, and return appropriate data.
%
%
%
%-------------------------------------------------------
function plot_menus(bsa_app)
%
%-------------------------------------------------------
%
% Return if GUI
%
%-------------------------------------------------------
if strcmp(get(gcf,'MenuBar'),'none'), return, end
%
%-------------------------------------------------------
%
% Create menus
%
%-------------------------------------------------------
% First create the top level menu Plot Options
%-------------------------------------------------------
%
plot_opt = uimenu(gcf,...
	'Label','Plot Options');
%
%-------------------------------------------------------
% Create menu item Line Type
%-------------------------------------------------------
%
	plot_lt = uimenu(plot_opt,...
		'Label','Line Type');
%
%-------------------------------------------------------
% Create submenu items Solid line, Dotted line, Dashed line,
% and Noline, and handle check mark.
%-------------------------------------------------------
%
		uData.noline = uimenu(plot_lt,...
			'Label','none',...
            'CallBack',{@MenuAction,'noline'});
		uData.solid = uimenu(plot_lt,...
			'Label','Solid line',...
            'CallBack',{@MenuAction,'solid'});
		uData.dotted = uimenu(plot_lt,...
			'Label','Dotted line',...
            'CallBack',{@MenuAction,'dotted'});
		uData.dashed = uimenu(plot_lt,...
			'Label','Dashed line',...
            'CallBack',{@MenuAction,'dashed'});
		lineco = uimenu(plot_lt,...
			'Label','Color');
%			'CallBack',['lict = '--';'...
%				'set(lineco,'Checked','off'),']);
			uData.ycolor = uimenu(lineco,...
				'Label','Yellow',...
                'CallBack',{@MenuAction,'ycolor'});
			uData.mcolor = uimenu(lineco,...
				'Label','Magenta',...
                'CallBack',{@MenuAction,'mcolor'});
			uData.ccolor = uimenu(lineco,...
				'Label','Cyan',...
                'CallBack',{@MenuAction,'ccolor'});
			uData.rcolor = uimenu(lineco,...
				'Label','Red',...
                'CallBack',{@MenuAction,'rcolor'});
			uData.gcolor = uimenu(lineco,...
				'Label','Green',...
                'CallBack',{@MenuAction,'gcolor'});
			uData.bcolor = uimenu(lineco,...
				'Label','Blue',...
                'CallBack',{@MenuAction,'bcolor'});
			uData.wcolor = uimenu(lineco,...
				'Label','White',...
                'CallBack',{@MenuAction,'wcolor'});
			uData.kcolor = uimenu(lineco,...
				'Label','Black',...
                'CallBack',{@MenuAction,'kcolor'});
%
%-------------------------------------------------------
% Create menu item Plot Symbol
%-------------------------------------------------------
%
	plot_sym = uimenu(plot_opt,...
		'Label','Plot Symbol');
%
%-------------------------------------------------------
% Create submenu items point, circle, xmark, plus, asterisk
% and handle check mark.
%-------------------------------------------------------
%
%			'CallBack',['symtype = 'none';'...
		uData.no_marker = uimenu(plot_sym,...
			'Label','none',...
            'CallBack',{@MenuAction,'no_marker'});
		uData.point = uimenu(plot_sym,...
			'Label','point',...
            'CallBack',{@MenuAction,'point'});
		uData.circle = uimenu(plot_sym,...
			'Label','circle',...
            'CallBack',{@MenuAction,'circle'});
		uData.xmark = uimenu(plot_sym,...
			'Label','xmark',...
            'CallBack',{@MenuAction,'xmark'});
		uData.plus = uimenu(plot_sym,...
			'Label','plus',...
            'CallBack',{@MenuAction,'plus'});
		uData.asterisk = uimenu(plot_sym,...
			'Label','asterisk',...
            'CallBack',{@MenuAction,'asterisk'});
		uData.square = uimenu(plot_sym,...
			'Label','square',...
            'CallBack',{@MenuAction,'square'});
		uData.diamond = uimenu(plot_sym,...
			'Label','diamond',...
            'CallBack',{@MenuAction,'diamond'});
		uData.up_triangle = uimenu(plot_sym,...
			'Label','up_triangle',...
            'CallBack',{@MenuAction,'up_triangle'});
		uData.down_triangle = uimenu(plot_sym,...
			'Label','down_triangle',...
            'CallBack',{@MenuAction,'down_triangle'});
		uData.right_triangle = uimenu(plot_sym,...
			'Label','right_triangle',...
            'CallBack',{@MenuAction,'right_triangle'});
		uData.left_triangle = uimenu(plot_sym,...
			'Label','left_triangle',...
            'CallBack',{@MenuAction,'left_triangle'});
		uData.pentagram = uimenu(plot_sym,...
			'Label','pentagram',...
            'CallBack',{@MenuAction,'pentagram'});
		uData.hexagram = uimenu(plot_sym,...
			'Label','hexagram',...
            'CallBack',{@MenuAction,'hexagram'});
		pointco = uimenu(plot_sym,...
			'Label','Color');
%			'CallBack',['poct = '--';'...
%				'set(pointco,'Checked','off'),']);
			uData.ycol = uimenu(pointco,...
				'Label','Yellow',...
                'CallBack',{@MenuAction,'ycol'});
			uData.mcol = uimenu(pointco,...
				'Label','Magenta',...
                'CallBack',{@MenuAction,'mcol'});
			uData.ccol = uimenu(pointco,...
				'Label','Cyan',...
                'CallBack',{@MenuAction,'ccol'});
			uData.rcol = uimenu(pointco,...
				'Label','Red',...
                'CallBack',{@MenuAction,'rcol'});
			uData.gcol = uimenu(pointco,...
				'Label','Green',...
                'CallBack',{@MenuAction,'gcol'});
			uData.bcol = uimenu(pointco,...
				'Label','Blue',...
                'CallBack',{@MenuAction,'bcol'});
			uData.wcol = uimenu(pointco,...
				'Label','White',...
                'CallBack',{@MenuAction,'wcol'});
			uData.kcol = uimenu(pointco,...
				'Label','Black',...
                'CallBack',{@MenuAction,'kcol'});
%
%-------------------------------------------------------
% Create menu item Fitting
%-------------------------------------------------------
%
%	plot_fit = uimenu(plot_opt,...
%		'Label','Fit Type');
%
%-------------------------------------------------------
% Create submenu items none, line, poly, parb, gaus, asym,
% and handle check mark.
%-------------------------------------------------------
% XData YData
%		uData.fit_none = uimenu(plot_fit,...
%			'Label','none',...
%                'CallBack',{@MenuAction,'fit_none'});
%		uData.fit_line = uimenu(plot_fit,...
%			'Label','line',...
%                'CallBack',{@MenuAction,'fit_line'});
%		uData.fit_poly = uimenu(plot_fit,...
%			'Label','polynomial',...
%                'CallBack',{@MenuAction,'fit_poly'});
%		uData.fit_parb = uimenu(plot_fit,...
%			'Label','parabola',...
%                'CallBack',{@MenuAction,'fit_parb'});
%		uData.fit_gaus = uimenu(plot_fit,...
%			'Label','gaussian',...
%                'CallBack',{@MenuAction,'fit_gaus'});
%		uData.fit_asym = uimenu(plot_fit,...
%			'Label','asym gaussian',...
%                'CallBack',{@MenuAction,'fit_asym'});
%
%-------------------------------------------------------
% Create menu item Hold
%-------------------------------------------------------
%
	hold_state = uimenu(plot_opt,...
		'Label','Hold');
%
		uData.hold_on = uimenu(hold_state,...
			'Label','hold on',...
                'CallBack',{@MenuAction,'hold_on'});
		uData.hold_off = uimenu(hold_state,...
			'Label','hold off',...
                'CallBack',{@MenuAction,'hold_off'});
%
%
%-------------------------------------------------------
% Create menu item Grid
%-------------------------------------------------------
%
	grid_state = uimenu(plot_opt,...
		'Label','Grid');
%
		uData.grid_on = uimenu(grid_state,...
			'Label','grid on',...
                'CallBack',{@MenuAction,'grid_on'});
		uData.grid_off = uimenu(grid_state,...
			'Label','grid off',...
                'CallBack',{@MenuAction,'grid_off'});
%
%
%
%
%-------------------------------------------------------
% Create menu item Print
%-------------------------------------------------------
%
	uData.print_it = uimenu(plot_opt,...
		'Label','Print ala Henrik to LCLS Elog',...
		'Callback',{@dataExportLCLS,bsa_app});
    
    uData.print_it = uimenu(plot_opt,...
		'Label','Print ala Henrik to LCLS2 Elog',...
		'Callback',{@dataExportLCLS2,bsa_app});
%
%
set(gcf, 'UserData', uData);
%
%

function dataExportLCLS(src,eventdata,varargin)
bsa_app = varargin{:};
util_printLog(gcf,'title','BSA', 'accel', 'LCLS');
externalSave(bsa_app,eventdata);

function dataExportLCLS2(src,eventdata,varargin)
bsa_app = varargin{:};
util_printLog(gcf,'title','BSA', 'accel', 'LCLS2');
externalSave(bsa_app,eventdata);


function MenuAction(src, evt, action)
uData = get(gcf, 'UserData');

switch action
    case 'noline'
        set(uData.noline,'Checked','on');
        set(uData.solid,'Checked','off');
        set(uData.dotted,'Checked','off');
        set(uData.dashed,'Checked','off');
        set(findobj(gcf,'Type','Line'),'LineStyle', '.');
    case 'solid'
        set(uData.noline,'Checked','off');
        set(uData.solid,'Checked','on');
        set(uData.dotted,'Checked','off');
        set(uData.dashed,'Checked','off');
        set(findobj(gcf,'Type','Line'),'LineStyle', '-');
    case 'dotted'
        set(uData.noline,'Checked','off');
        set(uData.solid,'Checked','off');
        set(uData.dotted,'Checked','on');
        set(uData.dashed,'Checked','off');
        set(findobj(gcf,'Type','Line'),'LineStyle', ':');
    case 'dashed'
        set(uData.noline,'Checked','off');
        set(uData.solid,'Checked','off');
        set(uData.dotted,'Checked','off');
        set(uData.dashed,'Checked','on');
        set(findobj(gcf,'Type','Line'),'LineStyle', '--');
    case 'ycolor'
        set(uData.ycolor,'Checked','on');
		set(uData.mcolor,'Checked','off');
		set(uData.ccolor,'Checked','off');
		set(uData.rcolor,'Checked','off');
		set(uData.gcolor,'Checked','off');
		set(uData.bcolor,'Checked','off');
		set(uData.wcolor,'Checked','off');
		set(uData.kcolor,'Checked','off');
        set(findobj(gcf,'Type','Line'),'Color', 'y')
    case 'mcolor'
        set(uData.ycolor,'Checked','off')
		set(uData.mcolor,'Checked','on')
		set(uData.ccolor,'Checked','off')
		set(uData.rcolor,'Checked','off')
		set(uData.gcolor,'Checked','off')
		set(uData.bcolor,'Checked','off')
		set(uData.wcolor,'Checked','off')
		set(uData.kcolor,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Color', 'm');
    case 'ccolor'
        set(uData.ycolor,'Checked','off')
		set(uData.mcolor,'Checked','off')
		set(uData.ccolor,'Checked','on')
		set(uData.rcolor,'Checked','off')
		set(uData.gcolor,'Checked','off')
		set(uData.bcolor,'Checked','off')
		set(uData.wcolor,'Checked','off')
		set(uData.kcolor,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Color', 'c');
    case 'rcolor'
        set(uData.ycolor,'Checked','off')
		set(uData.mcolor,'Checked','off')
		set(uData.ccolor,'Checked','off')
		set(uData.rcolor,'Checked','on')
		set(uData.gcolor,'Checked','off')
		set(uData.bcolor,'Checked','off')
		set(uData.wcolor,'Checked','off')
		set(uData.kcolor,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Color', 'r');
    case 'gcolor'
        set(uData.ycolor,'Checked','off')
		set(uData.mcolor,'Checked','off')
		set(uData.ccolor,'Checked','off')
		set(uData.rcolor,'Checked','off')
		set(uData.gcolor,'Checked','on')
		set(uData.bcolor,'Checked','off')
		set(uData.wcolor,'Checked','off')
		set(uData.kcolor,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Color', 'g');
    case 'bcolor'
        set(uData.ycolor,'Checked','off')
		set(uData.mcolor,'Checked','off')
		set(uData.ccolor,'Checked','off')
		set(uData.rcolor,'Checked','off')
		set(uData.gcolor,'Checked','off')
		set(uData.bcolor,'Checked','on')
		set(uData.wcolor,'Checked','off')
		set(uData.kcolor,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Color', 'b');
    case 'wcolor'
        set(uData.ycolor,'Checked','off')
		set(uData.mcolor,'Checked','off')
		set(uData.ccolor,'Checked','off')
		set(uData.rcolor,'Checked','off')
		set(uData.gcolor,'Checked','off')
		set(uData.bcolor,'Checked','off')
		set(uData.wcolor,'Checked','on')
		set(uData.kcolor,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Color', 'w');        
    case 'kcolor'
        set(uData.ycolor,'Checked','off')
		set(uData.mcolor,'Checked','off')
		set(uData.ccolor,'Checked','off')
		set(uData.rcolor,'Checked','off')
		set(uData.gcolor,'Checked','off')
		set(uData.bcolor,'Checked','off')
		set(uData.wcolor,'Checked','off')
		set(uData.kcolor,'Checked','on')
        set(findobj(gcf,'Type','Line'),'Color', 'k');
    case 'no_marker'       
        set(uData.no_marker,'Checked','on')
		set(uData.point,'Checked','off')
		set(uData.circle,'Checked','off')
		set(uData.xmark,'Checked','off')
		set(uData.plus,'Checked','off')
		set(uData.asterisk,'Checked','off')
		set(uData.square,'Checked','off')
		set(uData.diamond,'Checked','off')
		set(uData.up_triangle,'Checked','off')
		set(uData.down_triangle,'Checked','off')
		set(uData.right_triangle,'Checked','off')
		set(uData.left_triangle,'Checked','off')
		set(uData.pentagram,'Checked','off')
		set(uData.hexagram,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Marker', 'none');
    case 'point'
        set(uData.no_marker,'Checked','off')
		set(uData.point,'Checked','on')
		set(uData.circle,'Checked','off')
		set(uData.xmark,'Checked','off')
		set(uData.plus,'Checked','off')
		set(uData.asterisk,'Checked','off')
		set(uData.square,'Checked','off')
		set(uData.diamond,'Checked','off')
		set(uData.up_triangle,'Checked','off')
		set(uData.down_triangle,'Checked','off')
		set(uData.right_triangle,'Checked','off')
		set(uData.left_triangle,'Checked','off')
		set(uData.pentagram,'Checked','off')
		set(uData.hexagram,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Marker', '.');
    case 'circle'
        set(uData.no_marker,'Checked','off')
		set(uData.point,'Checked','off')
		set(uData.circle,'Checked','on')
		set(uData.xmark,'Checked','off')
		set(uData.plus,'Checked','off')
		set(uData.asterisk,'Checked','off')
		set(uData.square,'Checked','off')
		set(uData.diamond,'Checked','off')
		set(uData.up_triangle,'Checked','off')
		set(uData.down_triangle,'Checked','off')
		set(uData.right_triangle,'Checked','off')
		set(uData.left_triangle,'Checked','off')
		set(uData.pentagram,'Checked','off')
		set(uData.hexagram,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Marker', 'o');
    case 'xmark'
        set(uData.no_marker,'Checked','off')
		set(uData.point,'Checked','off')
		set(uData.circle,'Checked','off')
		set(uData.xmark,'Checked','on')
		set(uData.plus,'Checked','off')
		set(uData.asterisk,'Checked','off')
		set(uData.square,'Checked','off')
		set(uData.diamond,'Checked','off')
		set(uData.up_triangle,'Checked','off')
		set(uData.down_triangle,'Checked','off')
		set(uData.right_triangle,'Checked','off')
		set(uData.left_triangle,'Checked','off')
		set(uData.pentagram,'Checked','off')
		set(uData.hexagram,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Marker', 'x');
    case 'plus'
        set(uData.no_marker,'Checked','off')
		set(uData.point,'Checked','off')
		set(uData.circle,'Checked','off')
		set(uData.xmark,'Checked','off')
		set(uData.plus,'Checked','on')
		set(uData.asterisk,'Checked','off')
		set(uData.square,'Checked','off')
		set(uData.diamond,'Checked','off')
		set(uData.up_triangle,'Checked','off')
		set(uData.down_triangle,'Checked','off')
		set(uData.right_triangle,'Checked','off')
		set(uData.left_triangle,'Checked','off')
		set(uData.pentagram,'Checked','off')
		set(uData.hexagram,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Marker', '+');
    case 'asterisk'
        set(uData.no_marker,'Checked','off')
		set(uData.point,'Checked','off')
		set(uData.circle,'Checked','off')
		set(uData.xmark,'Checked','off')
		set(uData.plus,'Checked','off')
		set(uData.asterisk,'Checked','on')
		set(uData.square,'Checked','off')
		set(uData.diamond,'Checked','off')
		set(uData.up_triangle,'Checked','off')
		set(uData.down_triangle,'Checked','off')
		set(uData.right_triangle,'Checked','off')
		set(uData.left_triangle,'Checked','off')
		set(uData.pentagram,'Checked','off')
		set(uData.hexagram,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Marker', '*');
    case 'square'
        set(uData.no_marker,'Checked','off')
		set(uData.point,'Checked','off')
		set(uData.circle,'Checked','off')
		set(uData.xmark,'Checked','off')
		set(uData.plus,'Checked','off')
		set(uData.asterisk,'Checked','off')
		set(uData.square,'Checked','on')
		set(uData.diamond,'Checked','off')
		set(uData.up_triangle,'Checked','off')
		set(uData.down_triangle,'Checked','off')
		set(uData.right_triangle,'Checked','off')
		set(uData.left_triangle,'Checked','off')
		set(uData.pentagram,'Checked','off')
		set(uData.hexagram,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Marker', 's');
    case 'diamond'
        set(uData.no_marker,'Checked','off')
		set(uData.point,'Checked','off')
		set(uData.circle,'Checked','off')
		set(uData.xmark,'Checked','off')
		set(uData.plus,'Checked','off')
		set(uData.asterisk,'Checked','off')
		set(uData.square,'Checked','off')
		set(uData.diamond,'Checked','on')
		set(uData.up_triangle,'Checked','off')
		set(uData.down_triangle,'Checked','off')
		set(uData.right_triangle,'Checked','off')
		set(uData.left_triangle,'Checked','off')
		set(uData.pentagram,'Checked','off')
		set(uData.hexagram,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Marker', 'd');
    case 'up_triangle'
        set(uData.no_marker,'Checked','off')
		set(uData.point,'Checked','off')
		set(uData.circle,'Checked','off')
		set(uData.xmark,'Checked','off')
		set(uData.plus,'Checked','off')
		set(uData.asterisk,'Checked','off')
		set(uData.square,'Checked','off')
		set(uData.diamond,'Checked','off')
		set(uData.up_triangle,'Checked','on')
		set(uData.down_triangle,'Checked','off')
		set(uData.right_triangle,'Checked','off')
		set(uData.left_triangle,'Checked','off')
		set(uData.pentagram,'Checked','off')
		set(uData.hexagram,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Marker', '^');
    case 'down_triangle'
        set(uData.no_marker,'Checked','off')
		set(uData.point,'Checked','off')
		set(uData.circle,'Checked','off')
		set(uData.xmark,'Checked','off')
		set(uData.plus,'Checked','off')
		set(uData.asterisk,'Checked','off')
		set(uData.square,'Checked','off')
		set(uData.diamond,'Checked','off')
		set(uData.up_triangle,'Checked','off')
		set(uData.down_triangle,'Checked','on')
		set(uData.right_triangle,'Checked','off')
		set(uData.left_triangle,'Checked','off')
		set(uData.pentagram,'Checked','off')
		set(uData.hexagram,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Marker', 'v');
    case 'right_triangle'
        set(uData.no_marker,'Checked','off')
		set(uData.point,'Checked','off')
		set(uData.circle,'Checked','off')
		set(uData.xmark,'Checked','off')
		set(uData.plus,'Checked','off')
		set(uData.asterisk,'Checked','off')
		set(uData.square,'Checked','off')
		set(uData.diamond,'Checked','off')
		set(uData.up_triangle,'Checked','off')
		set(uData.down_triangle,'Checked','off')
		set(uData.right_triangle,'Checked','on')
		set(uData.left_triangle,'Checked','off')
		set(uData.pentagram,'Checked','off')
		set(uData.hexagram,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Marker', '>');
    case 'left_triangle'
        set(uData.no_marker,'Checked','off')
		set(uData.point,'Checked','off')
		set(uData.circle,'Checked','off')
		set(uData.xmark,'Checked','off')
		set(uData.plus,'Checked','off')
		set(uData.asterisk,'Checked','off')
		set(uData.square,'Checked','off')
		set(uData.diamond,'Checked','off')
		set(uData.up_triangle,'Checked','off')
		set(uData.down_triangle,'Checked','off')
		set(uData.right_triangle,'Checked','off')
		set(uData.left_triangle,'Checked','on')
		set(uData.pentagram,'Checked','off')
		set(uData.hexagram,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Marker', '<');
    case 'pentagram'
        set(uData.no_marker,'Checked','off')
		set(uData.point,'Checked','off')
		set(uData.circle,'Checked','off')
		set(uData.xmark,'Checked','off')
		set(uData.plus,'Checked','off')
		set(uData.asterisk,'Checked','off')
		set(uData.square,'Checked','off')
		set(uData.diamond,'Checked','off')
		set(uData.up_triangle,'Checked','off')
		set(uData.down_triangle,'Checked','off')
		set(uData.right_triangle,'Checked','off')
		set(uData.left_triangle,'Checked','off')
		set(uData.pentagram,'Checked','on')
		set(uData.hexagram,'Checked','off')
        set(findobj(gcf,'Type','Line'),'Marker', 'p');
    case 'hexagram'
        set(uData.no_marker,'Checked','off')
		set(uData.point,'Checked','off')
		set(uData.circle,'Checked','off')
		set(uData.xmark,'Checked','off')
		set(uData.plus,'Checked','off')
		set(uData.asterisk,'Checked','off')
		set(uData.square,'Checked','off')
		set(uData.diamond,'Checked','off')
		set(uData.up_triangle,'Checked','off')
		set(uData.down_triangle,'Checked','off')
		set(uData.right_triangle,'Checked','off')
		set(uData.left_triangle,'Checked','off')
		set(uData.pentagram,'Checked','off')
		set(uData.hexagram,'Checked','on')
        set(findobj(gcf,'Type','Line'),'Marker', 'h');
    case 'ycol'
        set(uData.ycol,'Checked','on')
		set(uData.mcol,'Checked','off')
		set(uData.ccol,'Checked','off')
		set(uData.rcol,'Checked','off')
		set(uData.gcol,'Checked','off')
		set(uData.bcol,'Checked','off')
		set(uData.wcol,'Checked','off')
		set(uData.kcol,'Checked','off')
        set(findobj(gcf,'Type','Line'),'MarkerEdgeColor', 'y');
    case 'mcol'
        set(uData.ycol,'Checked','off')
		set(uData.mcol,'Checked','off')
		set(uData.ccol,'Checked','off')
		set(uData.rcol,'Checked','off')
		set(uData.gcol,'Checked','off')
		set(uData.bcol,'Checked','off')
		set(uData.wcol,'Checked','off')
		set(uData.kcol,'Checked','off')
        set(findobj(gcf,'Type','Line'),'MarkerEdgeColor', 'm');
    case 'ccol'
        set(uData.ycol,'Checked','off')
		set(uData.mcol,'Checked','off')
		set(uData.ccol,'Checked','off')
		set(uData.rcol,'Checked','off')
		set(uData.gcol,'Checked','off')
		set(uData.bcol,'Checked','off')
		set(uData.wcol,'Checked','off')
		set(uData.kcol,'Checked','off')
        set(findobj(gcf,'Type','Line'),'MarkerEdgeColor', 'c');
    case 'rcol'
        set(uData.ycol,'Checked','off')
		set(uData.mcol,'Checked','off')
		set(uData.ccol,'Checked','off')
		set(uData.rcol,'Checked','off')
		set(uData.gcol,'Checked','off')
		set(uData.bcol,'Checked','off')
		set(uData.wcol,'Checked','off')
		set(uData.kcol,'Checked','off')
        set(findobj(gcf,'Type','Line'),'MarkerEdgeColor', 'r');
    case 'gcol'
        set(uData.ycol,'Checked','off')
		set(uData.mcol,'Checked','off')
		set(uData.ccol,'Checked','off')
		set(uData.rcol,'Checked','off')
		set(uData.gcol,'Checked','off')
		set(uData.bcol,'Checked','off')
		set(uData.wcol,'Checked','off')
		set(uData.kcol,'Checked','off')
        set(findobj(gcf,'Type','Line'),'MarkerEdgeColor', 'g');
    case 'bcol'
        set(uData.ycol,'Checked','off')
		set(uData.mcol,'Checked','off')
		set(uData.ccol,'Checked','off')
		set(uData.rcol,'Checked','off')
		set(uData.gcol,'Checked','off')
		set(uData.bcol,'Checked','off')
		set(uData.wcol,'Checked','off')
		set(uData.kcol,'Checked','off')
        set(findobj(gcf,'Type','Line'),'MarkerEdgeColor', 'b');
    case 'wcol'
        set(uData.ycol,'Checked','off')
		set(uData.mcol,'Checked','off')
		set(uData.ccol,'Checked','off')
		set(uData.rcol,'Checked','off')
		set(uData.gcol,'Checked','off')
		set(uData.bcol,'Checked','off')
		set(uData.wcol,'Checked','off')
		set(uData.kcol,'Checked','off')
        set(findobj(gcf,'Type','Line'),'MarkerEdgeColor', 'w');
    case 'kcol'
        set(uData.ycol,'Checked','off')
		set(uData.mcol,'Checked','off')
		set(uData.ccol,'Checked','off')
		set(uData.rcol,'Checked','off')
		set(uData.gcol,'Checked','off')
		set(uData.bcol,'Checked','off')
		set(uData.wcol,'Checked','off')
		set(uData.kcol,'Checked','off')
        set(findobj(gcf,'Type','Line'),'MarkerEdgeColor', 'k');
    case 'fit_none'
		set(uData.fit_none,'Checked','on')
		set(uData.fit_line,'Checked','off')
		set(uData.fit_poly,'Checked','off')
		set(uData.fit_parb,'Checked','off')
		set(uData.fit_gaus,'Checked','off')
		set(uData.fit_asym,'Checked','off')
     case 'fit_line'
		set(uData.fit_none,'Checked','off')
		set(uData.fit_line,'Checked','on')
		set(uData.fit_poly,'Checked','off')
		set(uData.fit_parb,'Checked','off')
		set(uData.fit_gaus,'Checked','off')
		set(uData.fit_asym,'Checked','off')
     case 'fit_poly'
		set(uData.fit_none,'Checked','off')
		set(uData.fit_line,'Checked','off')
		set(uData.fit_poly,'Checked','on')
		set(uData.fit_parb,'Checked','off')
		set(uData.fit_gaus,'Checked','off')
		set(uData.fit_asym,'Checked','off')
     case 'fit_parb'
		set(uData.fit_none,'Checked','off')
		set(uData.fit_line,'Checked','off')
		set(uData.fit_poly,'Checked','off')
		set(uData.fit_parb,'Checked','on')
		set(uData.fit_gaus,'Checked','off')
		set(uData.fit_asym,'Checked','off')
     case 'fit_gaus'
		set(uData.fit_none,'Checked','off')
		set(uData.fit_line,'Checked','off')
		set(uData.fit_poly,'Checked','off')
		set(uData.fit_parb,'Checked','off')
		set(uData.fit_gaus,'Checked','on')
		set(uData.fit_asym,'Checked','off')
     case 'fit_asym'
		set(uData.fit_none,'Checked','off')
		set(uData.fit_line,'Checked','off')
		set(uData.fit_poly,'Checked','off')
		set(uData.fit_parb,'Checked','off')
		set(uData.fit_gaus,'Checked','off')
		set(uData.fit_asym,'Checked','on')
    case 'hold_on'
		set(uData.hold_on,'Checked','on')
		set(uData.hold_off,'Checked','off')
        hold on
    case 'hold_off'
		set(uData.hold_on,'Checked','off')
		set(uData.hold_off,'Checked','on')
        hold on
    case 'grid_on'
		set(uData.grid_on,'Checked','on')
		set(uData.grid_off,'Checked','off')
        grid on
    case 'grid_off'
		set(uData.grid_on,'Checked','off')
		set(uData.grid_off,'Checked','on')
        



        
end