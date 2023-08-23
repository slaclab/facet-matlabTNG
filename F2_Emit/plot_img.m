function fh = plot_img(x, y, img, GUI)

    yyaxis(GUI.UIAxes, 'left')
    imagesc(GUI.UIAxes, x, y, img)
    axis(GUI.UIAxes, 'tight')
    
    
    
    yyaxis(GUI.UIAxes, 'right')
    imagesc(GUI.UIAxes, x, y, img)
    axis(GUI.UIAxes, 'tight')  
    
    %linkaxes(GUI.UIAxes, 'y');
    

end