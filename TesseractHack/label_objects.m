function [objects,changed]=label_objects(objects)
%LABEL_OBJECTS labels images of characters with letters
% [OBJECTS,CHANGED]=LABEL_OBJECTS(OBJECTS) accepts OBJECTS, which should be an
% array of structures containing 
%   - a field 'grayscaleimage', holding an image of a character;
%   - a field 'char', holding the name of the character (a letter).
% The function starts a GUI editor which displays the images
% along with text edit controls which allow to attach a character to each
% image. The character is stored in the CHAR field of the structure. Upont
% closing of the GUI by the user, the function returns the labeled objects
% in return value OBJECTS. The return value CHANGED, if set to true,
% signals that at least one of the objects received a different label.
%
% The display is a 7-by-5 grid which displays images and text edit boxes.
% For a large number of characters (35 or more), the objects are divided
% into groups of 35, and navigation controls (push buttons) 'NEXT GROUP' and
% 'PREV. GROUP' are provided to navigate between the groups.
%    
    narginchk(1,inf);
    fig=figure('Visible','off',...
               'Position',[0,0,800,640],...
               'CloseRequestFcn',@closereq_Callback,...
               'CreateFcn',{@create_Callback,objects} ...
               );

    function closereq_Callback(hObject, ~, ~)
    %CLOSEREQ_CALLBACK is responsible for actions upon closing of the GUI
    % CLOSEREQ_CALLBACK(hObject, ~, ~) currently assigns the output value
    % OBJECTS to the result of editing the input variable OBJECTS.
    % Note that CLOSEREQ_CALLBACK must be defined in the scope of the
    % main GUI function, so that the output variable NEW_OBJECTS is 
    % accessible.
        myhandles=guidata(hObject);
        changed=myhandles.objects_changed;
        if changed
            disp('Objects changed, assigning new objects');
            objects=myhandles.objects;
        end
        delete(hObject);
    end

    populate_gui_with_objects(fig);
    set(fig,'Visible','on');
    % Block until GUI is closed
    waitfor(fig);
end


function create_Callback(hObject,~,objects)
%CREATE_CALLBACK is responsible for creating the GUI
% CREATE_CALLBACK(HOBJECT,~,OBJECTS) creates all GUI elements
% used by the GUI. It is also responsible for attaching OBJECTS
% to the GUI.
    myhandles=guidata(hObject);
    [myhandles.height,myhandles.width]=size(objects(1).grayscaleimage);
    myhandles.num_cols=5;
    myhandles.num_rows=7;
    % Number of objects GUI can display at a time
    myhandles.num_objects=myhandles.num_rows*myhandles.num_cols;
    myhandles.objects=objects;
    myhandles.objects_changed=false;
    % Offset to the first displayed character
    myhandles.offset=0;

    % Create GUI panels
    main_panel=uipanel('Parent',hObject,...
                       'Title','Main Panel',...
                       'FontSize',10,...
                       'BackgroundColor','white',...
                       'Visible','on',...
                       'Position',[0.0,0.0,1,1]);
    object_panel=uipanel('Parent',main_panel,...
                         'Title','Object Panel',...
                         'FontSize',10,...
                         'BackgroundColor','white',...
                         'Visible','on',...
                         'Position',[0.01,0.01,.98,.88]);
    nav_panel=uipanel('Parent',main_panel,...
                      'Title','Navigation Panel',...
                      'FontSize',10,...
                      'BackgroundColor','white',...
                      'Visible','on',...
                      'Position',[0.01,0.90,.98,.10]);

    iptsetpref('ImshowAxesVisible','off');

    % Create navigation controls
    uicontrol('Parent',nav_panel,'Style','Pushbutton',...
              'String','Prev. group',...
              'FontSize',14,...
              'Position',[25,10,150,40],...
              'Callback',{@range_Callback,-myhandles.num_objects} ...
              );
    uicontrol('Parent',nav_panel,'Style','Pushbutton',...
              'String','Next group',...
              'FontSize',14,...
              'Position',[200,10,150,40],...
              'Callback',{@range_Callback,+myhandles.num_objects} ...
              );
    myhandles.range_txt=...
        uicontrol('Parent',nav_panel,'Style','edit',...
                  'Enable','inactive',...
                  'String','',...
                  'FontSize',14,...
                  'Position',[400,10,350,40]...
                  );
    myhandles.padding=10;                         
    width_p=myhandles.width+3*myhandles.padding;
    height_p=myhandles.height+3*myhandles.padding;

    % Create items containing images of characters
    object_cnt=0;
    for row=myhandles.num_rows:-1:1
        for col=1:myhandles.num_cols
            object_cnt=object_cnt+1;
            myhandles.btn(object_cnt)=...
                uicontrol('Parent',object_panel,...
                          'Style','pushbutton',...
                          'Position',[(2*col-1)*width_p,row*height_p,...
                                myhandles.width+2*myhandles.padding,...
                                myhandles.height+2*myhandles.padding],...
                          'BackgroundColor',[0,0,0]);
        end
    end
    % Create text edit controls next to images
    % NOTE: this loop should not be merged with the
    % previous one, as the tab order would be adversely affected.
    % We need that upon pressing the TAB key we advance to the next
    % edit control. Thus, they must be created consecutively.
    object_cnt=0;
    for row=myhandles.num_rows:-1:1
        for col=1:myhandles.num_cols
            object_cnt=object_cnt+1;
            myhandles.txt(object_cnt)=...
                uicontrol('Parent',object_panel,...
                          'Style','edit',...
                          'FontSize',20,...
                          'FontName','Times New Roman',...
                          'Position',[2*col*width_p,row*height_p,...
                                40,40],...
                          'Callback',@edit_Callback ...
                          );
        end
    end

    guidata(hObject,myhandles);
end

function populate_gui_with_objects(fig)
%POPULATE_GUI_WITH_OBJECTS - Fills out GUI with object images and labels
% POPULATE_GUI_WITH_OBJECTS(FIG) puts objects GRAYSCALEIMAGE in the
% image box, and CHAR in the editable text box. For large 
% dataset, a range of objects is used to fill out the GUI elements.
    myhandles=guidata(fig);
    num_chars=length(myhandles.objects);
    first_char=myhandles.offset+1;
    last_char=min(myhandles.offset+myhandles.num_objects,num_chars);
    % Create images of characters
    for idx=first_char:last_char
        I=double(myhandles.objects(idx).grayscaleimage)/255;
        J=zeros(myhandles.height+2*myhandles.padding,...
                myhandles.width+2*myhandles.padding,...
                3,'double');
        for j=1:3
            idx1=(myhandles.padding+1):(myhandles.padding+myhandles.height);
            idx2=(myhandles.padding+1):(myhandles.padding+myhandles.width);
            J(idx1,idx2,j)=I;
        end;
        object_idx=idx-myhandles.offset;
        set(myhandles.btn(object_idx),'CData',J,'Enable','on','UserData',idx);
        if isfield(myhandles.objects(idx),'char')
            ch=myhandles.objects(idx).char;
        else
            ch='';
        end
        set(myhandles.txt(object_idx),'String',ch,'Enable','on','UserData',idx);
    end
    for object_idx=last_char-myhandles.offset+1:myhandles.num_objects
        set(myhandles.btn(object_idx),'Enable','off');
        set(myhandles.txt(object_idx),'String','','Enable','off');        
    end
    set(myhandles.range_txt,...
        'String',sprintf('Chars %d - %d (out of %d)',...
                         first_char,last_char,...
                         num_chars));
end

function edit_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
% str2double(get(hObject,'String')) returns contents as a double
    idx=get(hObject,'UserData');
    input = get(hObject,'string');
    if length(input)==1
        myhandles=guidata(gcbo);
        if myhandles.objects(idx).char ~= input
            myhandles.objects(idx).char=input;
            myhandles.objects_changed=true;
        end
        guidata(gcbo,myhandles);
    else
        uiwait(msgbox('Input should be a single character.',...
                      'Invalid input',...
                      'modal'));        
    end
end

function range_Callback(hObject, eventdata, delta)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% delta      amount to change offset by.

% Hints: get(hObject,'String') returns contents of edit1 as text
% str2double(get(hObject,'String')) returns contents as a double
    myhandles=guidata(gcbo);
    num_chars=length(myhandles.objects);

    if delta > 0 && myhandles.offset+delta < num_chars
        myhandles.offset=myhandles.offset+delta;
    elseif delta < 0 
        myhandles.offset=max(0,myhandles.offset+delta);
    end
    % Save handles
    guidata(gcbo,myhandles);
    fig=gcf;
    % Redraw the GUI
    populate_gui_with_objects(fig);
end

