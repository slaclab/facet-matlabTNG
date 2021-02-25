fig = uifigure;

cm = uicontextmenu(fig);
uimenu(cm,'Text','Menu1');
uimenu(cm,'Text','Menu2');

fig.ContextMenu = cm;