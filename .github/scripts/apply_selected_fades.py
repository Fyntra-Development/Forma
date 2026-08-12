from pathlib import Path

path = Path('Library.lua')
source = path.read_text()

old_main_tabs = """        function Tab:ShowTab()
            for _, Tab in next, Window.Tabs do
                Tab:HideTab();
            end;

            Blocker.BackgroundTransparency = 0;
            TabButton.BackgroundColor3 = Library.MainColor;
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';
            TabFrame.Visible = true;
        end;

        function Tab:HideTab()
            Blocker.BackgroundTransparency = 1;
            TabButton.BackgroundColor3 = Library.BackgroundColor;
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';
            TabFrame.Visible = false;
        end;"""
new_main_tabs = """        function Tab:ShowTab()
            for _, Tab in next, Window.Tabs do
                Tab:HideTab();
            end;

            Library:TweenProperty(Blocker, 'BackgroundTransparency', 0, 0.16);
            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.MainColor, 0.16);
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';
            TabFrame.Visible = true;
        end;

        function Tab:HideTab()
            Library:TweenProperty(Blocker, 'BackgroundTransparency', 1, 0.16);
            Library:TweenProperty(TabButton, 'BackgroundColor3', Library.BackgroundColor, 0.16);
            Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';
            TabFrame.Visible = false;
        end;"""

if old_main_tabs in source:
    source = source.replace(old_main_tabs, new_main_tabs, 1)
elif "Library:TweenProperty(Blocker, 'BackgroundTransparency'" not in source:
    raise RuntimeError('main tab selected-state block mismatch')

old_tabbox = """                function Tab:Show()
                    for _, Tab in next, Tabbox.Tabs do
                        Tab:Hide();
                    end;

                    Container.Visible = true;
                    Block.Visible = true;

                    Button.BackgroundColor3 = Library.BackgroundColor;
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';

                    Tab:Resize();
                end;

                function Tab:Hide()
                    Container.Visible = false;
                    Block.Visible = false;

                    Button.BackgroundColor3 = Library.MainColor;
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';
                end;"""
new_tabbox = """                function Tab:Show()
                    for _, Tab in next, Tabbox.Tabs do
                        Tab:Hide();
                    end;

                    Container.Visible = true;
                    Block.Visible = true;

                    Library:TweenProperty(Button, 'BackgroundColor3', Library.BackgroundColor, 0.16);
                    Library:TweenProperty(Block, 'BackgroundTransparency', 0, 0.16);
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';

                    Tab:Resize();
                end;

                function Tab:Hide()
                    Library:TweenProperty(Button, 'BackgroundColor3', Library.MainColor, 0.16);
                    Library:TweenProperty(Block, 'BackgroundTransparency', 1, 0.14);
                    Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';

                    task.delay(0.14, function()
                        if Button.BackgroundColor3 == Library.MainColor then
                            Container.Visible = false;
                            Block.Visible = false;
                        end;
                    end);
                end;"""

if old_tabbox in source:
    source = source.replace(old_tabbox, new_tabbox, 1)
elif "Library:TweenProperty(Block, 'BackgroundTransparency'" not in source:
    raise RuntimeError('tabbox selected-state block mismatch')

if "Library:TweenProperty(Blocker, 'BackgroundTransparency'" not in source:
    raise RuntimeError('main tab fade marker missing')
if "Library:TweenProperty(Block, 'BackgroundTransparency'" not in source:
    raise RuntimeError('tabbox fade marker missing')

path.write_text(source)
