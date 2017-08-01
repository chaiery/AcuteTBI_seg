function getMousePositionOnImage(src, event)

handles = guidata(src);

cursorPoint = get(handles.axes1, 'CurrentPoint');
handles.curX = cursorPoint(1,1);
handles.curY = cursorPoint(1,2);

xLimits = get(handles.axes1, 'xlim');
yLimits = get(handles.axes1, 'ylim');

if (handles.curX > min(xLimits) && handles.curX < max(xLimits) && handles.curY > min(yLimits) && handles.curY < max(yLimits))
plot(handles.curX,handles.curY,  '*')
else
disp('Cursor is outside bounds of image.');
end
guidata(handles.output,handles);


